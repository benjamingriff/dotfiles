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
      local redshift_dev_name = "redshift-dev"
      local redshift_dev_url = "postgresql://db_user@127.0.0.1:4000/dev?sslmode=require"
      local redshift_dev_host = "localhost"
      local redshift_dev_port = "4000"
      local redshift_dev_database = "dev"
      local redshift_dev_user = "ben_griffiths"
      local redshift_dev_cache_ttl = 4 * 60 * 60
      local redshift_dev_state_dir = vim.fn.stdpath("state") .. "/dadbod"
      local redshift_dev_cache_path = redshift_dev_state_dir .. "/redshift-dev-cache.json"
      local redshift_dev_passfile_path = redshift_dev_state_dir .. "/redshift-dev.pgpass"
      local dbout_preview_group = vim.api.nvim_create_augroup("dadbod_ui_dbout_preview", { clear = true })
      local redshift_dev_expiry_timer

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
        vim.fn.mkdir(redshift_dev_state_dir, "p", "0700")
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

      local function stop_redshift_dev_expiry_timer()
        if redshift_dev_expiry_timer == nil then
          return
        end

        redshift_dev_expiry_timer:stop()
        redshift_dev_expiry_timer:close()
        redshift_dev_expiry_timer = nil
      end

      local function clear_redshift_dev_runtime_auth()
        stop_redshift_dev_expiry_timer()
        vim.env.PGPASSFILE = nil
        if vim.fn.filereadable(redshift_dev_passfile_path) == 1 then
          vim.fn.delete(redshift_dev_passfile_path)
        end
      end

      local function clear_redshift_dev_cache(opts)
        opts = opts or {}

        clear_redshift_dev_runtime_auth()
        if vim.fn.filereadable(redshift_dev_cache_path) == 1 then
          vim.fn.delete(redshift_dev_cache_path)
        end

        dbui_reset_state()

        if not opts.silent then
          notify("Cleared cached password for " .. redshift_dev_name .. ".", vim.log.levels.INFO)
        end
      end

      local function schedule_redshift_dev_expiry(expires_at)
        if uv == nil or uv.new_timer == nil then
          return
        end

        stop_redshift_dev_expiry_timer()

        local delay = math.max(0, (expires_at - os.time()) * 1000)
        redshift_dev_expiry_timer = uv.new_timer()
        redshift_dev_expiry_timer:start(delay, 0, vim.schedule_wrap(function()
          clear_redshift_dev_cache({ silent = true })
          notify("Password cache expired for " .. redshift_dev_name .. ".", vim.log.levels.INFO)
        end))
      end

      local function read_redshift_dev_cache()
        if vim.fn.filereadable(redshift_dev_cache_path) == 0 then
          return nil
        end

        local ok, decoded = pcall(function()
          local lines = vim.fn.readfile(redshift_dev_cache_path)
          return json_decode(table.concat(lines, "\n"))
        end)

        if not ok or type(decoded) ~= "table" then
          clear_redshift_dev_cache({ silent = true })
          return nil
        end

        if type(decoded.password) ~= "string" or decoded.password == "" or type(decoded.expires_at) ~= "number" then
          clear_redshift_dev_cache({ silent = true })
          return nil
        end

        if decoded.expires_at <= os.time() then
          clear_redshift_dev_cache({ silent = true })
          return nil
        end

        return decoded
      end

      local function pgpass_escape(value)
        return value:gsub("\\", "\\\\"):gsub(":", "\\:")
      end

      local function write_redshift_dev_passfile(password)
        ensure_private_state_dir()

        local line = table.concat({
          redshift_dev_host,
          redshift_dev_port,
          redshift_dev_database,
          redshift_dev_user,
          pgpass_escape(password),
        }, ":")

        vim.fn.writefile({ line }, redshift_dev_passfile_path)
        set_private_permissions(redshift_dev_passfile_path)
        vim.env.PGPASSFILE = redshift_dev_passfile_path
      end

      local function apply_redshift_dev_runtime_auth(password, expires_at)
        write_redshift_dev_passfile(password)
        schedule_redshift_dev_expiry(expires_at)
      end

      local function validate_redshift_dev_password(password)
        local temp_passfile = vim.fn.tempname()
        local result

        vim.fn.writefile({
          table.concat({
            redshift_dev_host,
            redshift_dev_port,
            redshift_dev_database,
            redshift_dev_user,
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
            redshift_dev_url,
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
            redshift_dev_url,
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

      local function store_redshift_dev_cache(password)
        ensure_private_state_dir()

        local expires_at = os.time() + redshift_dev_cache_ttl
        vim.fn.writefile({
          json_encode({
            password = password,
            expires_at = expires_at,
          }),
        }, redshift_dev_cache_path)
        set_private_permissions(redshift_dev_cache_path)
        apply_redshift_dev_runtime_auth(password, expires_at)
        dbui_reset_state()

        return expires_at
      end

      local function refresh_redshift_dev_cache(password)
        local ok, error_output = validate_redshift_dev_password(password)
        if not ok then
          clear_redshift_dev_runtime_auth()
          return false, error_output
        end

        local expires_at = store_redshift_dev_cache(password)
        return true, expires_at
      end

      local function prompt_for_redshift_dev_password()
        local password = vim.fn.inputsecret("Redshift dev password: ")
        if type(password) ~= "string" or password == "" then
          return nil
        end

        return password
      end

      local function ensure_redshift_dev_cache(opts)
        opts = opts or {}

        local cached = read_redshift_dev_cache()
        if cached ~= nil then
          apply_redshift_dev_runtime_auth(cached.password, cached.expires_at)
          return true, "cached"
        end

        if opts.prompt == false then
          return false, "missing"
        end

        local password = prompt_for_redshift_dev_password()
        if password == nil then
          clear_redshift_dev_runtime_auth()
          return false, "cancelled"
        end

        local ok, result = refresh_redshift_dev_cache(password)
        if not ok then
          notify("Authentication failed for " .. redshift_dev_name .. ": " .. result, vim.log.levels.ERROR)
          return false, "failed"
        end

        notify("Cached password for " .. redshift_dev_name .. " until " .. os.date("%Y-%m-%d %H:%M:%S", result) .. ".", vim.log.levels.INFO)
        return true, "prompted"
      end

      local function redshift_dev_status_message()
        local cached = read_redshift_dev_cache()
        if cached == nil then
          return "No cached password for " .. redshift_dev_name .. "."
        end

        local seconds_remaining = math.max(0, cached.expires_at - os.time())
        local minutes_remaining = math.floor(seconds_remaining / 60)
        local hours_remaining = math.floor(minutes_remaining / 60)
        local remaining_minutes = minutes_remaining % 60

        return string.format(
          "Cached password for %s expires at %s (%dh %02dm remaining).",
          redshift_dev_name,
          os.date("%Y-%m-%d %H:%M:%S", cached.expires_at),
          hours_remaining,
          remaining_minutes
        )
      end

      local function add_dbui_profile(name, url)
        if vim.g.dbs == nil then
          vim.g.dbs = { { name = name, url = url } }
          return
        end

        if vim.tbl_islist(vim.g.dbs) then
          for _, profile in ipairs(vim.g.dbs) do
            if type(profile) == "table" and profile.name == name then
              return
            end
          end

          table.insert(vim.g.dbs, { name = name, url = url })
          return
        end

        if vim.g.dbs[name] == nil then
          vim.g.dbs[name] = url
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

      local function patch_redshift_dev_dbui_connect()
        if vim.fn.exists("*db_ui#drawer#get") == 0 then
          return
        end

        _G.__redshift_dev_ensure_cache = function(prompt)
          local ok, reason = ensure_redshift_dev_cache({ prompt = prompt })
          return {
            ok = ok,
            reason = reason,
          }
        end

        vim.cmd(string.format([[
          let g:redshift_dev_drawer = db_ui#drawer#get()
          if !empty(g:redshift_dev_drawer) && has_key(g:redshift_dev_drawer, 'dbui') && !empty(g:redshift_dev_drawer.dbui)
            let g:redshift_dev_dbui = g:redshift_dev_drawer.dbui
            if !get(g:redshift_dev_dbui, '_redshift_dev_connect_patched', 0)
              let g:redshift_dev_dbui._redshift_dev_original_connect = g:redshift_dev_dbui.connect
              let g:redshift_dev_dbui._redshift_dev_connect_patched = 1

              function! g:redshift_dev_dbui.connect(db) dict abort
                if get(a:db, 'name', '') ==# '%s'
                  let l:auth = luaeval('__redshift_dev_ensure_cache(_A)', v:true)
                  if !get(l:auth, 'ok', v:false)
                    let a:db.conn = ''
                    let a:db.conn_error = get(l:auth, 'reason', '') ==# 'failed'
                          \ ? 'Authentication failed for %s.'
                          \ : ''
                    let a:db.conn_tried = get(l:auth, 'reason', '') ==# 'failed' ? 1 : 0
                    redraw!
                    return a:db
                  endif
                endif

                return call(self._redshift_dev_original_connect, [a:db], self)
              endfunction
            endif
          endif

          unlet! g:redshift_dev_dbui g:redshift_dev_drawer
        ]], redshift_dev_name, redshift_dev_name))
      end

      add_dbui_profile(redshift_dev_name, redshift_dev_url)

      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_help = 0
      vim.g.db_ui_use_postgres_views = 0
      vim.g.db_ui_winwidth = 36
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

      vim.api.nvim_create_autocmd("User", {
        group = dbout_preview_group,
        pattern = "DBUIOpened",
        callback = patch_redshift_dev_dbui_connect,
      })

      create_or_replace_user_command("RedshiftDevLogin", function()
        local password = prompt_for_redshift_dev_password()
        if password == nil then
          notify("Skipped refreshing cached password for " .. redshift_dev_name .. ".", vim.log.levels.INFO)
          return
        end

        local ok, result = refresh_redshift_dev_cache(password)
        if not ok then
          notify("Authentication failed for " .. redshift_dev_name .. ": " .. result, vim.log.levels.ERROR)
          return
        end

        notify("Cached password for " .. redshift_dev_name .. " until " .. os.date("%Y-%m-%d %H:%M:%S", result) .. ".", vim.log.levels.INFO)
      end, {
        desc = "Refresh the cached password for redshift-dev",
      })

      create_or_replace_user_command("RedshiftDevLogout", function()
        clear_redshift_dev_cache()
      end, {
        desc = "Clear the cached password for redshift-dev",
      })

      create_or_replace_user_command("RedshiftDevCacheStatus", function()
        notify(redshift_dev_status_message(), vim.log.levels.INFO)
      end, {
        desc = "Show the cache status for redshift-dev",
      })

      ensure_redshift_dev_cache({ prompt = false })

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
