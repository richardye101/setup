-- Migrated from tmux (~/.config/tmux/tmux.conf) and Ghostty (~/.config/ghostty/config)

-- cmd+k clears the terminal; the session picker moves to shift+cmd+k
rex.bind("cmd+k", "com.superlogical.terminal.clear")
rex.bind("shift+cmd+k", "session.switch")

-- tmux prefix: ctrl+space
rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })

-- Splits
rex.bind("ctrl+space>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+space>-", "pane.split", { direction = "down" })
rex.bind("ctrl+space>x", "pane.close")

-- Pane focus: ctrl+hjkl (Rex takes these keys from every program in the pane)
rex.bind("ctrl+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+l", "pane.focus", { direction = "right" })
rex.bind("ctrl+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+j", "pane.focus", { direction = "down" })

-- Pane resizing: ctrl+option+hjkl
rex.bind("ctrl+alt+h", "pane.resize", { direction = "left" })
rex.bind("ctrl+alt+l", "pane.resize", { direction = "right" })
rex.bind("ctrl+alt+k", "pane.resize", { direction = "up" })
rex.bind("ctrl+alt+j", "pane.resize", { direction = "down" })

-- omp with a composer underneath: type in the composer while the omp pane stays
-- scrolled up (~/.local/bin/rex-composer).
local COMPOSER = "/Users/richardye/.local/bin/rex-composer"
local SHELL_FLAVOR = "com.superlogical.terminal.shell"

-- Working directory of the program in a pane, so new panes open where it is.
-- Nil (the shell block then starts in ~) when it can't be read.
local function pane_cwd(session_id, block_id)
  local proc = rex.call("block.method", { session_id = session_id, block_id = block_id, method = "process" })
  return proc and proc.foreground and proc.foreground.cwd or nil
end

local function add_composer(session_id, block_id, cwd)
  return rex.session.new_split{
    session_id = session_id,
    anchor_id = block_id,
    direction = "vertical",
    side = "after",
    ratio = 0.91,
    focus = false,
    layout = rex.layout.block{
      flavor = SHELL_FLAVOR,
      options = { command = { COMPOSER, session_id, block_id }, cwd = cwd },
    },
  }
end

rex.action{
  name = "add_composer",
  title = "Add Composer Below Pane",
  keywords = "omp compose input type scroll",
  run = function(ctx)
    return add_composer(ctx.session_id, ctx.block_id, pane_cwd(ctx.session_id, ctx.block_id))
  end,
}

rex.action{
  name = "omp_with_composer",
  title = "New omp Tab with Composer",
  keywords = "omp agent compose template",
  run = function(ctx)
    local cwd = pane_cwd(ctx.session_id, ctx.block_id)
    local window, err = rex.session.new_window{
      session_id = ctx.session_id,
      window_label = "omp",
      layout = rex.layout.block{ flavor = SHELL_FLAVOR, options = { initial_input = "omp\n", cwd = cwd } },
    }
    if not window then
      return nil, err
    end
    return add_composer(ctx.session_id, window.block_ids[1], cwd)
  end,
}

rex.bind("ctrl+space>c", "add_composer")
rex.bind("ctrl+space>o", "omp_with_composer")
