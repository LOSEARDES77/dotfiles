hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 6,

        border_size = 2,

        layout      = "scrolling",
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 4,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3,
        },

        blur             = {
            enabled  = true,
            size     = 3,
            passes   = 2,
            vibrancy = 0.1696,
        },
    },
})

require("monitors")
require("animations")
require("input")
require("per_monitor_ws")
require("binds")
require("windowrules")
-- Entorno: ~/.config/uwsm/env y env-hyprland (sesion uwsm)


-- Autoarranque via uwsm: noctalia.service (systemd --user) y ~/.config/autostart (Steam, etc.)



-- For Noctalia Color templates
require("noctalia").apply_theme()
