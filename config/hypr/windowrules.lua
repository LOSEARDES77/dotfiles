hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})
hl.window_rule({
    -- Fix some dragging issues with XWayland
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.layer_rule({
    name         = "noctalia",
    match        = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim      = true,
    ignore_alpha = 0.5,
    blur         = true,
    blur_popups  = true,
})
hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size  = { 1080, 920 },
})

-- Focus on urgent request
hl.on("window.urgent", function(w)
    if w.class == nil or w.layershell then
        return
    end
    hl.dispatch(hl.dsp.focus({ window = w }))
end)

hl.on("window.open", function(w)
    
    if w.xwayland == true then
        hl.notification.create({
            title = "xwayland window",
            text = w.class .. " is using xwayland",
            timeout = 10000,
            icon =
            "error"
        })
    end
end)

hl.window_rule({ match = { class = "^com\\.jankeesvw\\.OmarchyMeetingRecorder$" }, float = true })
hl.window_rule({ match = { class = "^com\\.jankeesvw\\.OmarchyMeetingRecorder$" }, size = { 480, 700 } })
hl.window_rule({ match = { class = "^com\\.jankeesvw\\.OmarchyMeetingRecorder$" }, center = true })
