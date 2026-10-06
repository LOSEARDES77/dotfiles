hl.config({
    input = {
        kb_variant    = "",
        kb_model      = "",
        kb_options    = "",
        kb_rules      = "",

        follow_mouse  = 1,
        mouse_refocus = false,

        sensitivity   = 0,

        touchpad      = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "workspace"
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "scroll_move"
})
