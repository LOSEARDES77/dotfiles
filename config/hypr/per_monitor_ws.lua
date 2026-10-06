WORKSPACES_PER_MONITOR = 10

-- Monitor description -> { name, base } (workspaces base+1 .. base+WORKSPACES_PER_MONITOR)
local monitors = {}
local game_mode = "scrolling" -- "scrolling" or "dwindle:<game workspace id>"

local function base_of(monitor)
    local m = monitors[monitor.description]
    return m and m.base or nil
end

-- Workspace rules bind each id to its monitor. Rules for the same workspace
-- replace each other, so the layout is always set together with the monitor.
-- skip_id keeps its current rule: changing the layout of a workspace drops its fullscreen window.
local function apply_rules(layout, skip_id)
    for _, m in pairs(monitors) do
        for j = 1, WORKSPACES_PER_MONITOR do
            local id = m.base + j
            if id ~= skip_id then
                hl.workspace_rule({ workspace = tostring(id), monitor = m.name, layout = layout })
            end
        end
    end
end

-- Workspaces of a monitor that hold windows, plus the active one (even if empty), sorted by id
local function occupied(monitor)
    local base = base_of(monitor)
    local active = monitor.active_workspace and monitor.active_workspace.id
    local list, nonempty = {}, 0
    for _, ws in ipairs(hl.get_workspaces()) do
        if not ws.special and ws.id > base and ws.id <= base + WORKSPACES_PER_MONITOR then
            if ws.windows > 0 then nonempty = nonempty + 1 end
            if ws.windows > 0 or ws.id == active then list[#list + 1] = ws.id end
        end
    end
    table.sort(list)
    return list, active, base, nonempty
end

-- Niri-like: no gaps. Empty workspaces you are not on disappear and the
-- following ones shift down (ws2 becomes ws1 once ws1 is empty and left).
local compacting = false
local function compact()
    if compacting then return end
    compacting = true
    for _, monitor in ipairs(hl.get_monitors()) do
        if base_of(monitor) then
            local list, active, base = occupied(monitor)
            for i, id in ipairs(list) do
                local target = base + i
                if id ~= target then
                    local wins = hl.get_workspace_windows(id)
                    -- Keep column order for the scrolling layout
                    table.sort(wins, function(a, b) return a.at.x < b.at.x end)
                    for _, w in ipairs(wins) do
                        hl.dispatch(hl.dsp.window.move({ workspace = target, window = w, follow = false }))
                    end
                    if id == active then
                        hl.dispatch(hl.dsp.focus({ workspace = target }))
                    end
                end
            end
        end
    end
    compacting = false
end

-- Workaround for hyprwm/Hyprland#16326: scrolling workspaces drop the pointer
-- lock of a fullscreen Xwayland game whenever a layer surface maps. While such
-- a game is fullscreen every workspace uses dwindle, then goes back to scrolling.
local function update_game_mode()
    local game = nil
    for _, w in ipairs(hl.get_windows()) do
        if w.xwayland and w.mapped and w.fullscreen ~= 0 then
            game = w
            break
        end
    end
    local game_ws = game and game.workspace and game.workspace.id
    local want = game_ws and ("dwindle:" .. game_ws) or "scrolling"
    if want == game_mode then return end
    game_mode = want

    -- The game's own workspace stays scrolling; only the others cause the bug
    apply_rules(game_ws and "dwindle" or "scrolling", game_ws)
    hl.exec_scheduled_prop_refresh_immediately()
    hl.notification.create({
        title   = "Modo juego",
        text    = game and ("dwindle activo: " .. game.class) or "scrolling restaurado",
        icon    = "info",
        timeout = 3000,
    })
end

-- Events fire before the state settles (a closing window still counts), so run deferred
local pending_timer = nil
local function schedule()
    if pending_timer then return end
    pending_timer = hl.timer(function()
        pending_timer = nil
        compact()
        update_game_mode()
    end, { timeout = 60, type = "oneshot" })
end

local function ch_workspace(key, move)
    local monitor = hl.get_active_monitor()
    if not monitor or not base_of(monitor) then
        hl.notification.create({
            title   = "Workspace Switch Error",
            text    = "No active monitor found.",
            icon    = "error",
            timeout = 3000,
        })
        return
    end

    -- Like niri, going past the last workspace lands on the single empty one after it
    local _, _, base, nonempty = occupied(monitor)
    key = math.min(key, nonempty + 1, WORKSPACES_PER_MONITOR)

    local action = move and hl.dsp.window.move or hl.dsp.focus
    hl.dispatch(action({
        workspace          = base + key,
        on_current_monitor = true,
    }))
end

local function apply_ws_monitors()
    local start_cursor_pos = hl.get_cursor_pos()
    local start_window = hl.get_active_window()

    for i, monitor in ipairs(hl.get_monitors()) do
        if not monitor.is_mirror and monitor.dpms_status then
            monitors[monitor.description] = { name = monitor.name, base = (i - 1) * WORKSPACES_PER_MONITOR }
        end
    end
    apply_rules("scrolling")

    for i = 1, WORKSPACES_PER_MONITOR do
        local key = i % WORKSPACES_PER_MONITOR -- 10 maps to key 0
        hl.bind("SUPER + " .. key, function()
            ch_workspace(i)
        end)
        hl.bind("SUPER + SHIFT + " .. key, function()
            ch_workspace(i, true)
        end)
    end

    if not (start_window == nil) then
        hl.dispatch(hl.dsp.focus({ window = start_window }))
    end

    if not (start_cursor_pos == nil) then
        hl.dispatch(hl.dsp.cursor.move({ x = start_cursor_pos.x, y = start_cursor_pos.y }))
    end
end

apply_ws_monitors()
schedule()

for _, event in ipairs({
    "workspace.active", "monitor.focused",
    "window.open", "window.close", "window.destroy",
    "window.move_to_workspace", "window.fullscreen",
}) do
    hl.on(event, schedule)
end

-- On monitor change reapply
hl.on("monitor.added", function()
    hl.exec_cmd("hyprctl reload")
end)
hl.on("monitor.removed", function()
    hl.exec_cmd("hyprctl reload")
end)
