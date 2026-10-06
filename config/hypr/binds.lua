-- Fullscreen togle
hl.bind("ALT + RETURN", hl.dsp.window.fullscreen_state({ internal = 1, client = 0, action = "toggle" }))
hl.bind("ALT + SHIFT + RETURN", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }))

hl.bind("ALT + V", hl.dsp.window.float("activewindow"))

-- Screenshot
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("gradia --screenshot=INTERACTIVE"))

-- Switch monitors
hl.bind("SUPER + GRAVE", hl.dsp.focus({ monitor = "+1" }))
hl.bind("SUPER + SHIFT + GRAVE", hl.dsp.window.move({ monitor = "+1" }))

-- Open apps
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("uwsm app -- kitty"))
hl.bind("CTRL + SHIFT + SPACE", hl.dsp.exec_cmd("1password --quick-access"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("uwsm app -- nautilus"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("uwsm app -- zen-browser"))
hl.bind("SUPER + Z", hl.dsp.exec_cmd("uwsm app -- code-insiders"))

-- App launcher
hl.bind("ALT + SPACE", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))

-- Clipboard history
hl.bind("SUPER + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))

-- Windows style settings
hl.bind("SUPER + I", hl.dsp.exec_cmd("noctalia msg settings-toggle"))

-- Kill active window
hl.bind("SUPER + Q", hl.dsp.window.close("activewindow"))


-- Move/resize windows with SUPER + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Window Switching
hl.bind("ALT + Tab", hl.dsp.exec_cmd("noctalia msg window-switcher"))

-- Scratchpad workspace
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + CTRL + S", hl.dsp.window.move({ workspace = "special:magic" }))


-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("noctalia msg volume-mute"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia msg brightness-up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Arrow key movment
hl.bind("SUPER + left", hl.dsp.layout("move -col"))
hl.bind("SUPER + right", hl.dsp.layout("move +col"))
hl.bind("SUPER + up", hl.dsp.layout("focus up"))
hl.bind("SUPER + down", hl.dsp.layout("focus down"))


-- Scroll workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Quit
hl.bind("SUPER + M",
    hl.dsp.exec_cmd("hyprshutdown"))

-- Calculator
hl.bind("SUPER + C", hl.dsp.exec_cmd("noctalia msg panel-toggle yuuto/calculator:panel"))

-- Notes
hl.bind("SUPER + N", hl.dsp.exec_cmd("noctalia msg panel-toggle noctalia/notes:panel"))

-- Change kb layout
local function ch_kb_layout(layout)
    if layout then
        hl.config({ input = { kb_layout = layout } })
        return
    end
    local next = (hl.get_config("input.kb_layout") == "us") and "es" or "us"
    hl.config({ input = { kb_layout = next } })
    hl.exec_cmd("noctalia msg notification-show \"Switched to " .. string.upper(next) .. "\"")
end

ch_kb_layout("us")
hl.bind("SUPER + P", ch_kb_layout)
hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
