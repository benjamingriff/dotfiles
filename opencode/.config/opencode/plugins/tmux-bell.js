import { appendFile } from "node:fs/promises"
import { execFile } from "node:child_process"
import { promisify } from "node:util"

const execFileAsync = promisify(execFile)
const BELL = "\x07"
const DEBOUNCE_MS = 1000

export const TmuxBellPlugin = async () => {
  if (!process.env.TMUX || !process.env.TMUX_PANE) {
    return {}
  }

  let cachedPaneID = null
  let cachedPaneTTY = null
  let lastBellKey = ""
  let lastBellAt = 0

  async function getPaneTTY() {
    const paneID = process.env.TMUX_PANE
    if (!paneID) {
      return null
    }

    if (cachedPaneID === paneID && cachedPaneTTY) {
      return cachedPaneTTY
    }

    try {
      const { stdout } = await execFileAsync("tmux", [
        "display-message",
        "-p",
        "-t",
        paneID,
        "#{pane_tty}",
      ])
      const paneTTY = stdout.trim()

      if (!paneTTY) {
        return null
      }

      cachedPaneID = paneID
      cachedPaneTTY = paneTTY
      return paneTTY
    } catch {
      return null
    }
  }

  async function ring(key) {
    const now = Date.now()

    // Suppress duplicates from closely related attention events.
    if (key === lastBellKey && now - lastBellAt < DEBOUNCE_MS) {
      return
    }

    const paneTTY = await getPaneTTY()
    if (!paneTTY) {
      return
    }

    try {
      await appendFile(paneTTY, BELL)
      lastBellKey = key
      lastBellAt = now
    } catch {
      return
    }
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await ring(`idle:${event.properties.sessionID}`)
      }

      if (event.type === "session.error") {
        await ring(`error:${event.properties.sessionID ?? "unknown"}`)
      }

      if (event.type === "permission.asked") {
        await ring(`permission:${event.properties.sessionID}`)
      }

      if (event.type === "question.asked") {
        await ring(`question:${event.properties.sessionID}`)
      }
    },
  }
}
