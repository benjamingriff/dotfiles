return {
  {
    "tpope/vim-dadbod",
    cmd = { "DB" },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      local uv = vim.uv or vim.loop
      local dadbod_state_dir = vim.fn.stdpath("state") .. "/dadbod"
      local dbout_preview_group = vim.api.nvim_create_augroup("dadbod_ui_dbout_preview", { clear = true })
      local cached_profiles = {
        {
          name = "redshift-dev",
          url = "postgresql://db_user@127.0.0.1:4000/dev?sslmode=require",
          host = "localhost",
          port = "4000",
          database = "dev",
          user = "ben_griffiths",
          cache_ttl = 4 * 60 * 60,
          password_prompt = "Redshift dev password: ",
          command_prefix = "RedshiftDev",
          command_label = "redshift-dev",
        },
        {
          name = "pep-brains",
          url = "postgresql://db_user@db.example.internal:5432/app_db?sslmode=require",
          host = "db.example.internal",
          port = "5432",
          database = "app_db",
          user = "postgres",
          cache_ttl = 7 * 24 * 60 * 60,
          password_prompt = "pep-brains password: ",
          command_prefix = "PepBrains",
          command_label = "pep-brains",
        },
        {
          name = "dashboard-prod",
          url = "postgresql://db_user@db.example.internal:5432/app_db?sslmode=require",
          host = "db.example.internal",
          port = "5432",
          database = "app_db",
          user = "postgres",
          cache_ttl = 7 * 24 * 60 * 60,
          password_prompt = "dashboard-prod password: ",
          command_prefix = "DashboardProd",
          command_label = "dashboard-prod",
        },
      }
      local cached_profiles_by_name = {}

      local function notify(message, level)
        vim.notify(message, level or vim.log.levels.INFO, { title = "Dadbod" })
      end

      local function create_or_replace_user_command(name, callback, opts)
        pcall(vim.api.nvim_del_user_command, name)
        vim.api.nvim_create_user_command(name, callback, opts)
      end

      local function dbui_reset_state()
        if vim.fn.exists("*db_ui#reset_state") == 1 then
          pcall(vim.fn["db_ui#reset_state"])
        end
      end

      local function ensure_private_state_dir()
        vim.fn.mkdir(dadbod_state_dir, "p", "0700")
      end

      local function set_private_permissions(path)
        if vim.fn.filereadable(path) == 1 then
          vim.fn.setfperm(path, "rw-------")
        elseif vim.fn.isdirectory(path) == 1 then
          vim.fn.setfperm(path, "rwx------")
        end
      end

      local function json_encode(value)
        if vim.json and vim.json.encode then
          return vim.json.encode(value)
        end

        return vim.fn.json_encode(value)
      end

      local function json_decode(value)
        if vim.json and vim.json.decode then
          return vim.json.decode(value)
        end

        return vim.fn.json_decode(value)
      end

      local is_list = vim.islist or vim.tbl_islist

      local function pgpass_escape(value)
        return value:gsub("\\", "\\\\"):gsub(":", "\\:")
      end

      local function stop_profile_expiry_timer(profile)
        if profile.expiry_timer == nil then
          return
        end

        profile.expiry_timer:stop()
        profile.expiry_timer:close()
        profile.expiry_timer = nil
      end

      local function clear_profile_runtime_auth(profile)
        stop_profile_expiry_timer(profile)
        if vim.env.PGPASSFILE == profile.passfile_path then
          vim.env.PGPASSFILE = nil
        end

        if vim.fn.filereadable(profile.passfile_path) == 1 then
          vim.fn.delete(profile.passfile_path)
        end
      end

      local function clear_profile_cache(profile, opts)
        opts = opts or {}

        clear_profile_runtime_auth(profile)
        if vim.fn.filereadable(profile.cache_path) == 1 then
          vim.fn.delete(profile.cache_path)
        end

        dbui_reset_state()

        if not opts.silent then
          notify("Cleared cached password for " .. profile.name .. ".", vim.log.levels.INFO)
        end
      end

      local function schedule_profile_expiry(profile, expires_at)
        if uv == nil or uv.new_timer == nil then
          return
        end

        stop_profile_expiry_timer(profile)

        local delay = math.max(0, (expires_at - os.time()) * 1000)
        profile.expiry_timer = uv.new_timer()
        profile.expiry_timer:start(delay, 0, vim.schedule_wrap(function()
          clear_profile_cache(profile, { silent = true })
          notify("Password cache expired for " .. profile.name .. ".", vim.log.levels.INFO)
        end))
      end

      local function read_profile_cache(profile)
        if vim.fn.filereadable(profile.cache_path) == 0 then
          return nil
        end

        local ok, decoded = pcall(function()
          local lines = vim.fn.readfile(profile.cache_path)
          return json_decode(table.concat(lines, "\n"))
        end)

        if not ok or type(decoded) ~= "table" then
          clear_profile_cache(profile, { silent = true })
          return nil
        end

        if type(decoded.password) ~= "string" or decoded.password == "" or type(decoded.expires_at) ~= "number" then
          clear_profile_cache(profile, { silent = true })
          return nil
        end

        if decoded.expires_at <= os.time() then
          clear_profile_cache(profile, { silent = true })
          return nil
        end

        return decoded
      end

      local function write_profile_passfile(profile, password)
        ensure_private_state_dir()

        local line = table.concat({
          profile.host,
          profile.port,
          profile.database,
          profile.user,
          pgpass_escape(password),
        }, ":")

        vim.fn.writefile({ line }, profile.passfile_path)
        set_private_permissions(profile.passfile_path)
        vim.env.PGPASSFILE = profile.passfile_path
      end

      local function apply_profile_runtime_auth(profile, password, expires_at)
        write_profile_passfile(profile, password)
        schedule_profile_expiry(profile, expires_at)
      end

      local function validate_profile_password(profile, password)
        local temp_passfile = vim.fn.tempname()
        local result

        vim.fn.writefile({
          table.concat({
            profile.host,
            profile.port,
            profile.database,
            profile.user,
            pgpass_escape(password),
          }, ":"),
        }, temp_passfile)
        set_private_permissions(temp_passfile)

        if vim.system then
          local env = {}
          if vim.fn.exists("*environ") == 1 then
            env = vim.fn.environ()
          end

          result = vim.system({
            "psql",
            "-w",
            "--no-psqlrc",
            "--dbname",
            profile.url,
            "-tAc",
            "select 1;",
          }, {
            env = vim.tbl_extend("force", env, {
              PGPASSFILE = temp_passfile,
            }),
            text = true,
          }):wait()
        else
          local original_pgpassfile = vim.env.PGPASSFILE

          vim.env.PGPASSFILE = temp_passfile
          local stdout = vim.fn.system({
            "psql",
            "-w",
            "--no-psqlrc",
            "--dbname",
            profile.url,
            "-tAc",
            "select 1;",
          })
          result = {
            code = vim.v.shell_error,
            stdout = stdout,
            stderr = stdout,
          }
          vim.env.PGPASSFILE = original_pgpassfile
        end

        vim.fn.delete(temp_passfile)

        if result.code == 0 then
          return true
        end

        local error_output = result.stderr
        if error_output == nil or error_output == "" then
          error_output = result.stdout or "Unknown authentication error."
        end

        return false, vim.trim(error_output)
      end

      local function store_profile_cache(profile, password)
        ensure_private_state_dir()

        local expires_at = os.time() + profile.cache_ttl
        vim.fn.writefile({
          json_encode({
            password = password,
            expires_at = expires_at,
          }),
        }, profile.cache_path)
        set_private_permissions(profile.cache_path)
        apply_profile_runtime_auth(profile, password, expires_at)
        dbui_reset_state()

        return expires_at
      end

      local function refresh_profile_cache(profile, password)
        local ok, error_output = validate_profile_password(profile, password)
        if not ok then
          clear_profile_runtime_auth(profile)
          return false, error_output
        end

        local expires_at = store_profile_cache(profile, password)
        return true, expires_at
      end

      local function prompt_for_profile_password(profile)
        local password = vim.fn.inputsecret(profile.password_prompt)
        if type(password) ~= "string" or password == "" then
          return nil
        end

        return password
      end

      local function ensure_profile_cache(profile, opts)
        opts = opts or {}

        local cached = read_profile_cache(profile)
        if cached ~= nil then
          apply_profile_runtime_auth(profile, cached.password, cached.expires_at)
          return true, "cached"
        end

        if opts.prompt == false then
          return false, "missing"
        end

        local password = prompt_for_profile_password(profile)
        if password == nil then
          clear_profile_runtime_auth(profile)
          return false, "cancelled"
        end

        local ok, result = refresh_profile_cache(profile, password)
        if not ok then
          notify("Authentication failed for " .. profile.name .. ": " .. result, vim.log.levels.ERROR)
          return false, "failed"
        end

        notify(
          "Cached password for " .. profile.name .. " until " .. os.date("%Y-%m-%d %H:%M:%S", result) .. ".",
          vim.log.levels.INFO
        )
        return true, "prompted"
      end

      local function profile_status_message(profile)
        local cached = read_profile_cache(profile)
        if cached == nil then
          return "No cached password for " .. profile.name .. "."
        end

        local seconds_remaining = math.max(0, cached.expires_at - os.time())
        local minutes_remaining = math.floor(seconds_remaining / 60)
        local hours_remaining = math.floor(minutes_remaining / 60)
        local remaining_minutes = minutes_remaining % 60

        return string.format(
          "Cached password for %s expires at %s (%dh %02dm remaining).",
          profile.name,
          os.date("%Y-%m-%d %H:%M:%S", cached.expires_at),
          hours_remaining,
          remaining_minutes
        )
      end

      local function prime_profile_expiry_timer(profile)
        local cached = read_profile_cache(profile)
        if cached == nil then
          return
        end

        schedule_profile_expiry(profile, cached.expires_at)
      end

      local function add_dbui_profile(name, url)
        if vim.g.dbs == nil then
          vim.g.dbs = { { name = name, url = url } }
          return
        end

        local current_dbs = vim.g.dbs

        if is_list(current_dbs) then
          for _, profile in ipairs(current_dbs) do
            if type(profile) == "table" and profile.name == name then
              return
            end
          end

          table.insert(current_dbs, { name = name, url = url })
          vim.g.dbs = current_dbs
          return
        end

        if current_dbs[name] == nil then
          current_dbs[name] = url
          vim.g.dbs = current_dbs
        end
      end

      local function resize_dbout_preview(win)
        if not vim.api.nvim_win_is_valid(win) then
          return
        end

        if not vim.wo[win].previewwindow then
          return
        end

        local target_height = math.max(12, math.floor(vim.o.lines * 0.4))
        pcall(vim.api.nvim_win_set_height, win, target_height)
      end

      local function patch_cached_profile_dbui_connect()
        if vim.fn.exists("*db_ui#drawer#get") == 0 then
          return
        end

        _G.__dadbod_cached_profile_ensure_cache = function(args)
          local profile = cached_profiles_by_name[args[1]]
          if profile == nil then
            return {
              handled = false,
              ok = true,
              reason = "unmanaged",
            }
          end

          local ok, reason = ensure_profile_cache(profile, { prompt = args[2] })
          return {
            handled = true,
            ok = ok,
            reason = reason,
          }
        end

        vim.cmd([[
          let g:dadbod_cached_profile_drawer = db_ui#drawer#get()
          if !empty(g:dadbod_cached_profile_drawer) && has_key(g:dadbod_cached_profile_drawer, 'dbui') && !empty(g:dadbod_cached_profile_drawer.dbui)
            let g:dadbod_cached_profile_dbui = g:dadbod_cached_profile_drawer.dbui
            if !get(g:dadbod_cached_profile_dbui, '_cached_profile_connect_patched', 0)
              let g:dadbod_cached_profile_dbui._cached_profile_original_connect = g:dadbod_cached_profile_dbui.connect
              let g:dadbod_cached_profile_dbui._cached_profile_connect_patched = 1

              function! g:dadbod_cached_profile_dbui.connect(db) dict abort
                let l:auth = luaeval('__dadbod_cached_profile_ensure_cache(_A)', [get(a:db, 'name', ''), v:true])
                if get(l:auth, 'handled', v:false) && !get(l:auth, 'ok', v:false)
                  let a:db.conn = ''
                  let a:db.conn_error = get(l:auth, 'reason', '') ==# 'failed'
                        \ ? 'Authentication failed for ' . get(a:db, 'name', '') . '.'
                        \ : ''
                  let a:db.conn_tried = get(l:auth, 'reason', '') ==# 'failed' ? 1 : 0
                  redraw!
                  return a:db
                endif

                return call(self._cached_profile_original_connect, [a:db], self)
              endfunction
            endif
          endif

          unlet! g:dadbod_cached_profile_dbui g:dadbod_cached_profile_drawer
        ]])
      end

      for _, profile in ipairs(cached_profiles) do
        profile.cache_path = dadbod_state_dir .. "/" .. profile.name .. "-cache.json"
        profile.passfile_path = dadbod_state_dir .. "/" .. profile.name .. ".pgpass"
        profile.expiry_timer = nil
        cached_profiles_by_name[profile.name] = profile
        add_dbui_profile(profile.name, profile.url)
        prime_profile_expiry_timer(profile)

        create_or_replace_user_command(profile.command_prefix .. "Login", function()
          local password = prompt_for_profile_password(profile)
          if password == nil then
            notify("Skipped refreshing cached password for " .. profile.name .. ".", vim.log.levels.INFO)
            return
          end

          local ok, result = refresh_profile_cache(profile, password)
          if not ok then
            notify("Authentication failed for " .. profile.name .. ": " .. result, vim.log.levels.ERROR)
            return
          end

          notify(
            "Cached password for " .. profile.name .. " until " .. os.date("%Y-%m-%d %H:%M:%S", result) .. ".",
            vim.log.levels.INFO
          )
        end, {
          desc = "Refresh the cached password for " .. profile.command_label,
        })

        create_or_replace_user_command(profile.command_prefix .. "Logout", function()
          clear_profile_cache(profile)
        end, {
          desc = "Clear the cached password for " .. profile.command_label,
        })

        create_or_replace_user_command(profile.command_prefix .. "CacheStatus", function()
          notify(profile_status_message(profile), vim.log.levels.INFO)
        end, {
          desc = "Show the cache status for " .. profile.command_label,
        })
      end

      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_help = 0
      vim.g.db_ui_use_postgres_views = 0
      vim.g.db_ui_winwidth = 36
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

      vim.api.nvim_create_autocmd("User", {
        group = dbout_preview_group,
        pattern = "DBUIOpened",
        callback = patch_cached_profile_dbui_connect,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = dbout_preview_group,
        pattern = "dbout",
        callback = function(args)
          local win = vim.fn.bufwinid(args.buf)
          if win == -1 then
            return
          end

          vim.schedule(function()
            resize_dbout_preview(win)
          end)
        end,
      })

      vim.api.nvim_create_autocmd("VimResized", {
        group = dbout_preview_group,
        callback = function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "dbout" then
              resize_dbout_preview(win)
            end
          end
        end,
      })
    end,
  },
}
