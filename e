local stuff = require("neverlose/stuff")
local cfg = require("neverlose/cfg")
local get_defensive = require("neverlose/get_defensive")

local dynamic_offset = vector(0,0)

local verdana_12 = render.load_font("verdana", 12, "d")
local lua_name = "Custom HUD"
local steam_name = panorama.loadstring([[ return MyPersonaAPI.GetName() ]])()

local groups = {
    main = ui.create("Main", "Main"),
    options = ui.create("Main", "Options"),
    main_cfg = ui.create("Main", "CFG"),
    bf = ui.create("Main", "Settings"),
    performance = ui.create("Main", "Performance"),
    visual_main = ui.create("Main", "Visuals"),
}

local main = {
    info = {
        sc = render.screen_size(),
        username = common.get_username(),
        mouse_pos = ui.get_mouse_position(),
        player = nil,
        can_shoot = false,
        game_rules = nil,
        player_flags = { },
        conditional = "Default",
        state = 1,
        antibrute_state = false,
        inverter = false,
        menu_state = false
    },
    trash = {
        fun_render = { },
        fun_createmove = { },
        weapon_select_pos = vector(0, 0),
        hp_bar_pos = vector(0, 0),
        weapon_clip = vector(0, 0),
        roundtime_pos = vector(0, 0),
        chat_pos = vector(0, 0),
        killfeed_pos = vector(0, 0),
        hud_state = false,
        chat_log = { },
        killfeed_log = { }
    },
    menu_items = {
        main = {
            master = groups.main:switch("Enable"),
            hide_type = groups.main:combo("Hide-Hud Type", {"Legacy"}),
            weapon_selector = groups.main:switch("Weapon Selector"),
            hp_armor = groups.main:switch("HP/Armor"),
            weapon_clip = groups.main:switch("Weapon Clip"),
            roundtime = groups.main:switch("Round Time"),
            chat = groups.main:switch("Chat"),
            killfeed = groups.main:switch("Killfeeds"),
            dynamic_pos = groups.main:switch("Dynamic Position")
        },
        options = {
            --dpi_scale = groups.options:slider("dpi scale", 50, 150, 100),
        },
        performance = {
            blur = groups.performance:switch("Disable Blur Effect"),
            glow = groups.performance:switch("Disable Glowing Effect")
        },
        trash = {
            hp_pos_x = groups.options:slider("hppx", 0, render.screen_size().x, render.screen_size().x/2),
            hp_pos_y = groups.options:slider("hppy", 0, render.screen_size().y, render.screen_size().y - 30),
            ws_pos_x = groups.options:slider("wspx", 0, render.screen_size().x, render.screen_size().x - 190),
            ws_pos_y = groups.options:slider("wspy", 0, render.screen_size().y, render.screen_size().y - 120),
            wc_pos_x = groups.options:slider("wcpx", 0, render.screen_size().x, render.screen_size().x - 120),
            wc_pos_y = groups.options:slider("wcpy", 0, render.screen_size().y, render.screen_size().y - 30),
            rt_pos_x = groups.options:slider("rtpx", 0, render.screen_size().x, render.screen_size().x/2),
            rt_pos_y = groups.options:slider("rtpy", 0, render.screen_size().y, 30),
            chat_pos_x = groups.options:slider("chatpx", 0, render.screen_size().x, 20),
            chat_pos_y = groups.options:slider("chatpy", 0, render.screen_size().y, render.screen_size().y/2),
            killfeed_pos_x = groups.options:slider("killfeedpx", 0, render.screen_size().x, render.screen_size().x - 20),
            killfeed_pos_y = groups.options:slider("killfeedpy", 0, render.screen_size().y, 40),
        }
    },
    fonts = {
        Battlefield = {
            font_text1 = render.load_font("verdana", 16, "ad"),
            font_ammo = render.load_font("verdana", 32, "ad"),
            font_ammo2 = render.load_font("verdana", 22, "ad"),
            font_bind = render.load_font("verdana", 15, nil)
        },
        Blur = {
            font_text1 = render.load_font("Segoe UI bold", 16, "ad"),
            font_ammo = render.load_font("Segoe UI bold", 32, "ad"),
            font_ammo2 = render.load_font("Segoe UI bold", 22, "ad"),
            font_bind = render.load_font("Segoe UI bold", 17, "a")
        },
        Signal = {
            font_text1 = render.load_font("verdana", 16, "ad"),
            font_ammo = render.load_font("verdana", 32, "ad"),
            font_ammo2 = render.load_font("verdana", 22, "ad"),
            font_bind = render.load_font("verdana", 15, nil)
        },
        Default = {
            font_text1 = render.load_font("Segoe UI bold", 16, "ad"),
            font_text2 = render.load_font("Segoe UI bold", 32, "ad"),
        },
        chat = {
            font_text = render.load_font("verdana", 17, "ad")
        },
        killfeed = {
            font_text = render.load_font("verdana", 17, "ad")
        }
    },
    colors = {
        bf = {
            weapon_select = { },
            weapon_clip = { },
            hp_armor = { },
            roundtime = { },
            chat = { },
            killfeed = { }
        },
        blur = {
            weapon_select = { },
            hp_armor = { },
            roundtime = { }
        },
        default = {
            hp_armor = { },
        }
    }
}

local menu = {
    visual = {
        main = {
            watermark = groups.visual_main:switch("Watermark"),
            logs = groups.visual_main:switch("Logs"),
            clantag = groups.visual_main:switch("Clantag")
        }
    },
    cfg = {

    }
}

local menu_items = {
    dt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap"),
    dt_opt = ui.find("Aimbot", "Ragebot", "Main", "Double Tap", "Lag Options"),
    hs = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots"),
    hs_opt = ui.find("Aimbot", "Ragebot", "Main", "Hide Shots", "Options")
}

groups.logs = menu.visual.main.logs:create()
menu.visual.main.logs_options = groups.logs:selectable("Options", {"Damage", "Purchases", "Bomb"})
menu.visual.main.logs_preview = groups.logs:switch("Preview")
menu.visual.main.logs_limit = groups.logs:slider("Limit", 3, 24, 8)

groups.watermark = menu.visual.main.watermark:create()
menu.visual.main.watermark_style = groups.watermark:combo("Style", {"Up", "Down"})
menu.visual.main.watermark_items = groups.watermark:selectable("Items", {"Username", "Loss", "Delay", "Time"})


local trash = {
    clantag_num = 0,
    clantag_last_update = 0,
    logs = {}
}

local hitbox = {
    [0] = "Generic",
    [1] = "Head",
    [2] = "Chest",
    [3] = "Stomach",
    [4] = "Left arm",
    [5] = "Right arm",
    [6] = "Left leg",
    [7] = "Right leg",
    [8] = "Neck",
    [10] = "Gear"
}

--main.menu_items.main.master:visibility(false)
main.menu_items.main.hide_type:visibility(false)
groups.hide_type = main.menu_items.main.hide_type:create()

groups.dynamic = main.menu_items.main.dynamic_pos:create()
main.menu_items.main.dynamic_speed = groups.dynamic:slider("Speed", 50, 200, 100, 1, "%")

groups.weapon_selector = main.menu_items.main.weapon_selector:create()
main.menu_items.main.weapon_selector_style = groups.weapon_selector:combo("Style", {"Battlefield", "Blur", "Signal"})
main.menu_items.options.combine_nades = groups.weapon_selector:switch("Combine nades in one column")
main.menu_items.options.combine_knife = groups.weapon_selector:switch("Combine zeus/knife in one column")
main.colors.bf.weapon_select = groups.weapon_selector:color_picker("BF Style", {
    ["Background"] = {
        color(255),
        color(0, 120)
    },
    ["Icon"] = {
        color(0),
        color(255)
    },
    ["Text"] = {
        color(255),
        color(0)
    },
    ["Text Background"] = {
        color(0),
        color(255)
    }
})

main.colors.blur.weapon_select = groups.weapon_selector:color_picker("Blur Style", {
    ["Background"] = {
        color(0, 125),
        color(0, 120)
    },
    ["Icon"] = {
        color(255),
        color(255, 50)
    },
    ["Text"] = {
        color(255),
        color(255)
    }
})

groups.hp_armor = main.menu_items.main.hp_armor:create()
main.menu_items.main.hp_armor_style = groups.hp_armor:combo("Style", {"Battlefield", "Blur", "Default"})
main.menu_items.options.hp_bar_center = groups.hp_armor:switch("Сenter on X")

main.colors.bf.hp_armor = groups.hp_armor:color_picker("BF Style", {
    ["Text"] = {
        color(255)
    },
    ["Separator"] = {
        color(255)
    },
    ["On Low"] = {
        color(255, 0, 0)
    },
})

main.colors.blur.hp_armor = groups.hp_armor:color_picker("Blur Style", {
    ["Background"] = {
        color(0, 100),
        color(0, 100)
    },
    ["HP Text"] = {
        color(255),
        color(255)
    },
    ["AR Text"] = {
        color(255),
        color(255)
    },
    ["AR Line"] = {
        color(255),
        color(255, 100)
    },
    ["HP Line"] = {
        color(255),
        color(255, 100)
    },
})

main.colors.default.hp_armor = groups.hp_armor:color_picker("Default Style", {
    ["Main"] = {
        color(255)
    }
})

groups.weapon_clip = main.menu_items.main.weapon_clip:create()
main.menu_items.main.weapon_clip_style = groups.weapon_clip:combo("Style", {"Battlefield", "Blur"})

main.colors.bf.weapon_clip.text = groups.weapon_clip:color_picker("Weapon Clip Style", {
    ["Text"] = {
        color(255)
    },
    ["Second Text"] = {
        color(125, 255)
    },
})


groups.roundtime = main.menu_items.main.roundtime:create()
main.menu_items.main.roundtime_style = groups.roundtime:combo("Style", {"Battlefield", "Blur"})
main.menu_items.options.roundtime_center = groups.roundtime:switch("Сenter on X")

main.colors.bf.roundtime = groups.roundtime:color_picker("BF Style", {
    ["Text"] = {
        color(255)
    },
    ["Separator"] = {
        color(255)
    },
    ["Enemies"] = {
        color(255, 166, 166, 255)
    },
    ["Teammates"] = {
        color(108, 217, 245, 255)
    },
})

main.colors.blur.roundtime = groups.roundtime:color_picker("Blur Style", {
    ["Text"] = {
        color(255)
    },
    ["Separator"] = {
        color(255)
    },
    ["Enemies"] = {
        color(255)
    },
    ["Teammates"] = {
        color(255)
    },
    ["Background"] = {
        color(0, 120),
        color(0, 120)
    },
    ["Elements"] = {
        color(108, 217, 245),
        color(255, 166, 166)
    }
})

groups.chat = main.menu_items.main.chat:create()
main.colors.bf.chat.text = groups.chat:color_picker("Chat Style", {
    ["Text"] = {
        color(255)
    },
    ["Text 2"] = {
        color(255)
    },
    ["Teammates"] = {
        color(108, 217, 245)
    },
    ["Enemies"] = {
        color(255, 166, 166)
    }
})

-- groups.chat = main.menu_items.main.chat:create()
-- main.menu_items.main.chat_style = groups.chat:combo("Style", {"Battlefield", "Blur"})

groups.killfeed = main.menu_items.main.killfeed:create()
main.menu_items.main.killfeed_style = groups.killfeed:combo("Style", {"Simple", "Fade"})
main.menu_items.main.killfeed_hl = groups.killfeed:switch("Highlight yourself", false)
main.menu_items.options.preserve_killfeed = groups.killfeed:switch("Preserve Killfeed")

groups.killfeed = main.menu_items.main.killfeed:create()
main.colors.bf.killfeed.text = groups.killfeed:color_picker("Killfeed Style", {
    ["Icons"] = {
        color(255)
    },
    ["Teammates"] = {
        color(108, 217, 245)
    },
    ["Enemies"] = {
        color(255, 166, 166)
    },
    ["Background"] = {
        color(255, 0),
        color(255)
    }
})


for i=1, 3 do
    main.trash.fun_render[i] = { }
    main.trash.fun_createmove[i] = { }
end

for k,v in pairs(main.menu_items.trash) do
    v:visibility(false)
end

local priority = {
    [40] = 1,
    [7] = 1,
    [9] = 1,
    [11] = 1,
    [38] = 1,
    [16] = 1,
    [60] = 1,
    [39] = 1,
    [8] = 1,
    [10] = 1,
    [13] = 1,
    [17] = 1,
    [34] = 1,
    [33] = 1,
    [24] = 1,
    [26] = 1,
    [19] = 1,
    [35] = 1,
    [25] = 1,
    [29] = 1,
    [27] = 1,
    [14] = 1,
    [28] = 1,

    [61] = 2,
    [64] = 2,
    [4] = 2,
    [63] = 2,
    [36] = 2,
    [1] = 2,
    [2] = 2,
    [30] = 2,
    [32] = 2,
    [3] = 2,

    [59] = 3,
    [42] = 3,
    [500] = 3,
    [503] = 3,
    [505] = 3,
    [506] = 3,
    [507] = 3,
    [508] = 3,
    [509] = 3,
    [512] = 3,
    [514] = 3,
    [515] = 3,
    [516] = 3,
    [517] = 3,
    [518] = 3,
    [519] = 3,
    [520] = 3,
    [521] = 3,
    [522] = 3,
    [523] = 3,
    [525] = 3,

    [31] = 3,

    [44] = 4,
    [45] = 4,
    [43] = 4,
    [47] = 4,
    [46] = 4,
    [48] = 4,
    
    [49] = 5,

    [57] = 6
}

ffi.cdef [[
typedef unsigned long HANDLE;
typedef HANDLE HWND;

HWND GetActiveWindow();
]]

local utf8 = {}

function utf8.charbytes (s, i)
    i = i or 1
    local c = string.byte(s, i)

   -- determine bytes needed for character, based on RFC 3629
   if c > 0 and c <= 127 then
      -- UTF8-1
      return 1
    elseif c >= 194 and c <= 223 then
      -- UTF8-2
      local c2 = string.byte(s, i + 1)
      return 2
    elseif c >= 224 and c <= 239 then
      -- UTF8-3
      local c2 = s:byte(i + 1)
      local c3 = s:byte(i + 2)
      return 3
    elseif c >= 240 and c <= 244 then
      -- UTF8-4
      local c2 = s:byte(i + 1)
      local c3 = s:byte(i + 2)
      local c4 = s:byte(i + 3)
      return 4
    end
  end

-- returns the number of characters in a UTF-8 string
function utf8.len (s)
    local pos = 1
    local bytes = string.len(s)
    local len = 0

    while pos <= bytes and len ~= chars do
        local c = string.byte(s,pos)
        len = len + 1

        pos = pos + utf8.charbytes(s, pos)
    end

    if chars ~= nil then
        return pos - 1
    end

    return len
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
function utf8.sub(s, i, j)
    j = j or -1

    if i == nil then
        return ""
    end

    local pos = 1
    local bytes = string.len(s)
    local len = 0

    local l = (i >= 0 and j >= 0) or utf8.len(s)
    local startChar = (i >= 0) and i or l + i + 1
    local endChar = (j >= 0) and j or l + j + 1

    if startChar > endChar then
        return ""
    end
    

    local startByte, endByte = 1, bytes
    
    while pos <= bytes do
        len = len + 1

        if len == startChar then
            startByte = pos
        end

        pos = pos + utf8.charbytes(s, pos)

        if len == endChar then
            endByte = pos - 1
            break
        end
    end
    
    return string.sub(s, startByte, endByte)
end


local loaded_icons = {}
local loaded_icons2 = {}

local loaded_icons3 = {}
local loaded_icons4 = {}

function create_fun(state, event, fun, menu_item, index)
    local value = nil
    if menu_item ~= nil then
        value = menu_item
    end
    if event == "render" then
        table.insert(main.trash.fun_render[state], {
            fun = fun,
            menu_item = value,
            index = index
        })
    elseif event == "createmove" then
        table.insert(main.trash.fun_createmove[state], {
            fun = fun,
            menu_item = value,
            index = index
        })
    end
end

function call()
    for t=1, main.info.state do
        for i=1, #main.trash.fun_render[t] do
            if main.trash.fun_render[t][i].menu_item == nil then
                main.trash.fun_render[t][i].fun()
            else
                if main.trash.fun_render[t][i].index ~= nil then
                    if main.trash.fun_render[t][i].menu_item:get(main.trash.fun_render[t][i].index) then
                        main.trash.fun_render[t][i].fun()
                    end
                else
                    if main.trash.fun_render[t][i].menu_item:get() then
                        main.trash.fun_render[t][i].fun()
                    end
                end
            end
        end
    end
end

function call_createmove(cmd)
    for t=1, main.info.state do
        for i=1, #main.trash.fun_createmove[t] do
            if main.trash.fun_createmove[t][i].menu_item == nil then
                main.trash.fun_createmove[t][i].fun(cmd)
            else
                if main.trash.fun_createmove[t][i].index ~= nil then
                    if main.trash.fun_createmove[t][i].menu_item:get(main.trash.fun_createmove[t][i].index) then
                        main.trash.fun_createmove[t][i].fun(cmd)
                    end
                else 
                    if main.trash.fun_createmove[t][i].menu_item:get() then
                        main.trash.fun_createmove[t][i].fun(cmd)
                    end
                end
            end
        end
    end
end

function custom_sidebar()
    local text = "Custom HUD"
    local icon = "wheelchair"
    local text_tmp = ""
    local grad = nil

    icon = "\a" .. color(185, 215, 255, 255):to_hex() .. ui.get_icon(icon)
    grad = stuff.gradient(color(185, 215, 255, 255), color(244, 200, 250, 255), text)

    for i=1, #text do
        text_tmp = text_tmp .. "\a" .. grad[i]:to_hex() .. text:sub(i, i)
    end

    ui.sidebar(text_tmp, icon)
end
custom_sidebar()
local dynamic_vec = vector(0,0,0)
local function anim_vec(id, vector_need, speed)
    local s = globals.frametime * (12*speed)
    if s < 0 then
        s = 0.01
    elseif s > 1 then
        s = 1
    end
    dynamic_vec.x = (vector_need.x - dynamic_vec.x) * s + dynamic_vec.x
    dynamic_vec.y = (vector_need.y - dynamic_vec.y) * s + dynamic_vec.y
    dynamic_vec.z = (vector_need.z - dynamic_vec.z) * s + dynamic_vec.z
    local vec = vector(dynamic_vec.x, dynamic_vec.y, dynamic_vec.z)
    return vec
end

local hud_state_ = panorama.loadstring([[
    let set_hud = function(weapon, hp_armor, counter, chat, killfeed){
        $.GetContextPanel().FindChildTraverse("HudBottomRight").style.opacity = weapon;
        $.GetContextPanel().FindChildTraverse("HudHealthArmor").style.opacity = hp_armor;
        $.GetContextPanel().FindChildTraverse("HudTeamCounter").style.opacity = counter;
        $.GetContextPanel().FindChildTraverse("StatusPanel").style.opacity = chat;
        $.GetContextPanel().FindChildTraverse("HudDeathNotice").style.opacity = killfeed;
    }

    return {
        set_hud: set_hud,
    }
    ]], "CSGOHud")()

    --[[
    HudBottomRight
    HudLowerLeft
    HudTopLeft
    HudTopRight

    HudTeamCounter
    HudHealthArmor
    HudMoney
    HudRadar
    
    HudWeaponSelection

    StatusPanel --chat messages
    ]]
--
function hud_state(bool, force_chat, force_killfeed)
    main.trash.hud_state = bool
    hud_state_.set_hud(
        ((main.menu_items.main.weapon_selector:get() or main.menu_items.main.weapon_clip:get()) and not bool) and 0 or 1,
        ((main.menu_items.main.hp_armor:get()) and not bool) and 0 or 1,
        ((main.menu_items.main.roundtime:get()) and not bool) and 0 or 1,
        ((main.menu_items.main.chat:get()) and (not bool or force_chat)) and 0 or 1,
        ((main.menu_items.main.killfeed:get()) and (not bool or force_killfeed)) and 0 or 1)
    
    --if main.menu_items.main.hide_type:get() == "Legacy" then
    --  local param2 = bit.lshift(1, 6)
    --  -- cvar.hidehud:int(main.menu_items.main.combo:get(6) and param2 or 0, true)
    --  -- cvar.cl_draw_only_deathnotices:int(bool and 0 or 1, true)
    --  -- cvar.cl_drawhud_force_radar:int(bool and 0 or 1, true)
    --  -- cvar.cl_drawhud_force_deathnotices:int(main.menu_items.main.combo:get(6) and 0 or 1, true)
    -- else
    --  cvar.hidehud:int(0)
    --  cvar.cl_draw_only_deathnotices:int(0)
    --  cvar.cl_drawhud_force_radar:int(0)
    --  cvar.cl_drawhud_force_deathnotices:int(0)
    -- end

    -- if main.menu_items.main.hide_type:get() == "New" then
    --  local param2 = bit.lshift(1, 3) + bit.lshift(1, 6)
    --  cvar.hidehud:int(bool and 0 or param2)
    -- elseif main.menu_items.main.hide_type:get() == "Old" then
    --  local param2 = bit.lshift(1, 3) + bit.lshift(1, 0)
    --  cvar.hidehud:int(bool and 0 or param2)
    -- else
    --  cvar.hidehud:int(0)
    -- end
end

function weapon_clip()
    local style = main.menu_items.main.weapon_clip_style:get()
    weap = main.info.player:get_player_weapon(false)
    if weap == nil then return end
    local text_sz = render.measure_text(main.fonts[style].font_ammo, nil, weap.m_iClip1)
    local text_sz2 = render.measure_text(main.fonts[style].font_ammo2, nil, "/" .. weap.m_iPrimaryReserveAmmoCount)
    local pos = main.trash.weapon_clip + dynamic_offset 
    if weap.m_iClip1 ~= -1 then
        render.text(main.fonts[style].font_ammo, vector(pos.x, pos.y - text_sz.y/2), main.colors.bf.weapon_clip.text:get("Text")[1], nil, weap.m_iClip1)
        render.text(main.fonts[style].font_ammo2,  vector(pos.x + text_sz.x, pos.y - text_sz2.y/2 + 3), main.colors.bf.weapon_clip.text:get("Second Text")[1], nil, "/" .. weap.m_iPrimaryReserveAmmoCount)
    end
    local pos = vector(main.menu_items.trash.wc_pos_x:get(), main.menu_items.trash.wc_pos_y:get())
    main.trash.weapon_clip = stuff.drag_drop("weapon_clip", pos, vector(5, text_sz.y/2), vector(text_sz.x + text_sz2.x, text_sz.y/2) + 5)
    main.menu_items.trash.wc_pos_x:set(main.trash.weapon_clip.x)
    main.menu_items.trash.wc_pos_y:set(main.trash.weapon_clip.y)
end

stuff.anim("nades_rendered", 1, 1)
stuff.anim("knife_rendered", 1, 1)
stuff.anim("nades_sz", 1, 1)
stuff.anim("knife_sz", 1, 1)
function weapon_select_render()
    local weapons = { }
    weap = main.info.player:get_player_weapon(false)
    if weap == nil then return end
    local w = main.info.player:get_player_weapon(true)
    for k,v in pairs(w) do
        if v == nil or not v:is_weapon() or priority[v:get_weapon_index()] == nil then
            --print(v:get_name() .. "[" .. v:get_weapon_index() .. "] priority == nil")
            return
        end

        local weap_name = v:get_weapon_info().console_name
        weap_name = weap_name:gsub("weapon_", "")
        if loaded_icons[weap_name] == nil then
            loaded_icons[weap_name] = {img = nil, updated = globals.realtime}
            if loaded_icons[weap_name].img == nil then
                --print("1. "..weap_name .. " " .. globals.realtime)
                local img = render.load_image_from_file("materials/panorama/images/icons/equipment/" .. weap_name .. ".svg")
                loaded_icons[weap_name] = {img = img, updated = globals.realtime + 0.1}
            end
        elseif loaded_icons[weap_name].updated < globals.realtime and loaded_icons[weap_name].updated ~= 1488 then
            --print("2. "..weap_name .. " " .. globals.realtime)
            loaded_icons2[weap_name] = {img = render.load_image_from_file("materials/panorama/images/icons/equipment/" .. weap_name .. ".svg", vector(loaded_icons[weap_name].img.width, loaded_icons[weap_name].img.height)*1.25), updated = globals.realtime + 1}
            loaded_icons[weap_name].img = nil
            loaded_icons[weap_name].updated = 1488
        end

        if loaded_icons[weap_name].updated ~= 1488 then
            break
        end

        if loaded_icons2[weap_name].updated < globals.realtime then
            loaded_icons2[weap_name].updated = 1488
        end

        if loaded_icons2[weap_name].updated ~= 1488 then
            break
        end

        table.insert(weapons, {
            name = v:get_weapon_index(),
            priority = priority[v:get_weapon_index()],
            console_name = weap_name,
            weap = v
        })
    end

    table.sort(weapons, function(a,b) return a.priority > b.priority end)

    local style = main.menu_items.main.weapon_selector_style:get()
    local indent_y = 0
    local nades_rendered = 0
    local knife_rendered = 0
    local nades_sz = 0
    local knife_sz = 0

    for k,v in pairs(weapons) do 
        local weap_name = v.console_name
        weap_name = weap_name:gsub("weapon_", "")
        if loaded_icons2[weap_name] == nil or loaded_icons2[weap_name].img == nil then return end
        local img = loaded_icons2[weap_name].img
        local img_size = vector(img.width, img.height)
        local pos = vector(main.trash.weapon_select_pos.x, stuff.anim("w1" .. v.name, main.trash.weapon_select_pos.y + indent_y, 0.03, main.trash.weapon_select_pos.y + indent_y, 1)) + dynamic_offset
        if style == "Battlefield" then
            stuff.anim("w" .. v.name, v.weap == weap or (v.priority == 4 and v.priority == priority[weap:get_weapon_index()] and main.menu_items.options.combine_nades:get()) or (v.priority == 3 and v.priority == priority[weap:get_weapon_index()] and main.menu_items.options.combine_knife:get()), 0.03)

            if main.menu_items.options.combine_nades:get() and v.priority == 4 then
                nades_sz = nades_sz + (img_size.x*0.9) + 15
                nades_rendered = nades_rendered + 1
            end

            if main.menu_items.options.combine_knife:get() and v.priority == 3 then
                knife_sz = knife_sz + (img_size.x*0.9) + 5
                knife_rendered = knife_rendered + 1
            end
            
            --and (not main.menu_items.options.combine_nades:get() or not main.menu_items.options.combine_knife:get()) 
            if ((v.priority ~= 3 or not main.menu_items.options.combine_knife:get()) and (v.priority ~= 4 or not main.menu_items.options.combine_nades:get())) or (v.priority == 4 and main.menu_items.options.combine_nades:get() and nades_rendered == 1) or (v.priority == 3 and main.menu_items.options.combine_knife:get() and knife_rendered == 1) then
                if not main.menu_items.performance.blur:get() then render.blur(pos - 5, pos + vector(180, 45), 1, 1, 0) end
                render.rect(pos - 5, pos + vector(180, 45), main.colors.bf.weapon_select:get("Background")[2]:lerp(main.colors.bf.weapon_select:get("Background")[1], stuff.anal["w" .. v.name]))
                if not main.menu_items.performance.glow:get() then render.shadow(pos - 5, pos + vector(180, 45), main.colors.bf.weapon_select:get("Background")[2]:lerp(main.colors.bf.weapon_select:get("Background")[1], stuff.anal["w" .. v.name]), 20, 0, 0) end
                local text_sz = render.measure_text(main.fonts[style].font_bind, nil, tostring(v.priority))
                render.rect(vector(pos.x + 160 - 3, pos.y + 21 - text_sz.y/2), vector(pos.x + 160 + 3, pos.y - text_sz.y/2 + 21) + text_sz, main.colors.bf.weapon_select:get("Text Background")[2]:lerp(main.colors.bf.weapon_select:get("Text Background")[1], stuff.anal["w" .. v.name]))
                render.text(main.fonts[style].font_bind, vector(pos.x + 160, pos.y + 20 - text_sz.y/2), main.colors.bf.weapon_select:get("Text")[2]:lerp(main.colors.bf.weapon_select:get("Text")[1], stuff.anal["w" .. v.name]), "d", tostring(v.priority))
            end
            
            if main.menu_items.options.combine_nades:get() and v.priority == 4 then
                render.texture(img, vector(pos.x + 180/2 - (nades_sz-(stuff.anal["nades_sz"]/2)), pos.y + (45 - (v.priority == 4 and 5 or 0))/2 - img_size.y/2), img_size*0.9, main.colors.bf.weapon_select:get("Icon")[2]:lerp(main.colors.bf.weapon_select:get("Icon")[1], v.weap == weap and stuff.anal["w" .. v.name] or stuff.anal["w" .. v.name]/2), "f")
            elseif main.menu_items.options.combine_knife:get() and v.priority == 3 then
                render.texture(img, vector(pos.x + 180/2 - (knife_sz-(stuff.anal["knife_sz"]/2)), pos.y + (45 - (v.priority == 4 and 5 or 0))/2 - img_size.y/2), img_size*0.9, main.colors.bf.weapon_select:get("Icon")[2]:lerp(main.colors.bf.weapon_select:get("Icon")[1], v.weap == weap and stuff.anal["w" .. v.name] or stuff.anal["w" .. v.name]/2), "f")
            else
                render.texture(img, vector(pos.x + 160/2 - img_size.x/2, pos.y + (45 - (v.priority == 4 and 5 or 0))/2 - img_size.y/2), img_size, main.colors.bf.weapon_select:get("Icon")[2]:lerp(main.colors.bf.weapon_select:get("Icon")[1], stuff.anal["w" .. v.name]), "f")
            end

            if ((v.priority ~= 3 or not main.menu_items.options.combine_knife:get()) and (v.priority ~= 4 or not main.menu_items.options.combine_nades:get())) or (v.priority == 4 and main.menu_items.options.combine_nades:get() and nades_rendered == stuff.anal["nades_rendered"]) or (v.priority == 3 and main.menu_items.options.combine_knife:get() and knife_rendered == stuff.anal["knife_rendered"]) then
                indent_y = indent_y - 55
            end

        elseif style == "Blur" then
            stuff.anim("w" .. v.name, v.weap == weap, 0.03)
            pos.x = pos.x - 30
            local nade = (main.menu_items.options.combine_nades:get() and v.priority == 4) or (main.menu_items.options.combine_knife:get() and v.priority == 3)
            local size
            if main.menu_items.options.combine_nades:get() and v.priority == 4 then
                nades_sz = nades_sz + (img_size.x*0.9) + 15
                nades_rendered = nades_rendered + 1
            end

            if main.menu_items.options.combine_knife:get() and v.priority == 3 then
                knife_sz = knife_sz + (img_size.x*0.9) + 15
                knife_rendered = knife_rendered + 1
            end

            if ((v.priority ~= 3 or not main.menu_items.options.combine_knife:get()) and (v.priority ~= 4 or not main.menu_items.options.combine_nades:get())) or (v.priority == 4 and main.menu_items.options.combine_nades:get() and nades_rendered == 1) or (v.priority == 3 and main.menu_items.options.combine_knife:get() and knife_rendered == 1) then
                local xxxx = v.priority == 3 and vector(170 - stuff.anal["knife_sz"] - 15, 0) or vector(170 - stuff.anal["nades_sz"] - 15, 0)
                if not main.menu_items.performance.blur:get() then render.blur(pos + (nade and xxxx or vector(170 - img_size.x - 30, 0)), pos + vector(170, 45), 1, 1, 5) end
                render.rect(pos + (nade and xxxx or vector(170 - img_size.x - 30, 0)), pos + vector(170, 45), main.colors.blur.weapon_select:get("Background")[2]:lerp(main.colors.blur.weapon_select:get("Background")[1], stuff.anal["w" .. v.name]), 5)
                local text_sz = render.measure_text(main.fonts[style].font_bind, nil, tostring(v.priority))
                render.text(main.fonts[style].font_bind, vector(pos.x + 165 - text_sz.x, pos.y + 10 - text_sz.y/2), main.colors.blur.weapon_select:get("Text")[2]:lerp(main.colors.blur.weapon_select:get("Text")[1], stuff.anal["w" .. v.name]), "d", tostring(v.priority))
            end

            if main.menu_items.options.combine_nades:get() and v.priority == 4 then
                render.texture(img, vector(pos.x + 170 - nades_sz - 5, pos.y + (45 - (v.priority == 4 and 5 or 0))/2 - img_size.y/2), img_size*0.9, main.colors.blur.weapon_select:get("Icon")[2]:lerp(main.colors.blur.weapon_select:get("Icon")[1], stuff.anal["w" .. v.name]), "f")
            elseif main.menu_items.options.combine_knife:get() and v.priority == 3 then
                render.texture(img, vector(pos.x + 170 - knife_sz - 5, pos.y + (45)/2 - img_size.y/2), img_size*0.9, main.colors.blur.weapon_select:get("Icon")[2]:lerp(main.colors.blur.weapon_select:get("Icon")[1], stuff.anal["w" .. v.name]), "f")
            else
                render.texture(img, vector(pos.x + 170 - img_size.x - 20, pos.y + (45)/2 - img_size.y/2), img_size, main.colors.blur.weapon_select:get("Icon")[2]:lerp(main.colors.blur.weapon_select:get("Icon")[1], stuff.anal["w" .. v.name]), "f")
            end

            if ((v.priority ~= 3 or not main.menu_items.options.combine_knife:get()) and (v.priority ~= 4 or not main.menu_items.options.combine_nades:get())) or (v.priority == 4 and main.menu_items.options.combine_nades:get() and nades_rendered == stuff.anal["nades_rendered"]) or (v.priority == 3 and main.menu_items.options.combine_knife:get() and knife_rendered == stuff.anal["knife_rendered"]) then
                indent_y = indent_y - 55
            end
        elseif style == "Signal" then
            stuff.anim("w" .. v.name, v.weap == weap or (v.priority == 4 and v.priority == priority[weap:get_weapon_index()] and main.menu_items.options.combine_nades:get()) or (v.priority == 3 and v.priority == priority[weap:get_weapon_index()] and main.menu_items.options.combine_knife:get()), 0.03)
            local nade = (main.menu_items.options.combine_nades:get() and v.priority == 4) or (main.menu_items.options.combine_knife:get() and v.priority == 3)
            if main.menu_items.options.combine_nades:get() and v.priority == 4 then
                nades_sz = nades_sz + (img_size.x*0.9) + 15
                nades_rendered = nades_rendered + 1
            end

            if main.menu_items.options.combine_knife:get() and v.priority == 3 then
                knife_sz = knife_sz + (img_size.x*0.9) + 15
                knife_rendered = knife_rendered + 1
            end

            if ((v.priority ~= 3 or not main.menu_items.options.combine_knife:get()) and (v.priority ~= 4 or not main.menu_items.options.combine_nades:get())) or (v.priority == 4 and main.menu_items.options.combine_nades:get() and nades_rendered == 1) or (v.priority == 3 and main.menu_items.options.combine_knife:get() and knife_rendered == 1) then
                local xxxx = v.priority == 3 and vector(170 - stuff.anal["knife_sz"] - 15, 0) or vector(170 - stuff.anal["nades_sz"] - 15, 0)
                render.gradient(pos + (nade and xxxx or vector(170 - img_size.x - 30, 0)), pos + vector(170, 45), color(0, 0):lerp(color(255, 0), stuff.anal["w" .. v.name]), color(33), color(0, 0):lerp(color(255, 0), stuff.anal["w" .. v.name]), color(33))
                local text_sz = render.measure_text(main.fonts[style].font_bind, nil, tostring(v.priority))
                render.text(main.fonts[style].font_bind, vector(pos.x + 165 - text_sz.x, pos.y + 10 - text_sz.y/2), color(255):lerp(color(255), stuff.anal["w" .. v.name]), "d", tostring(v.priority))
            end

            if main.menu_items.options.combine_nades:get() and v.priority == 4 then
                render.texture(img, vector(pos.x + 170 - nades_sz - 5, pos.y + (45 - (v.priority == 4 and 5 or 0))/2 - img_size.y/2), img_size*0.9, color(255, 100):lerp(color(255), v.weap == weap and stuff.anal["w" .. v.name] or stuff.anal["w" .. v.name]/2), "f")
            elseif main.menu_items.options.combine_knife:get() and v.priority == 3 then
                render.texture(img, vector(pos.x + 170 - knife_sz - 5, pos.y + (45 - (v.priority == 4 and 5 or 0))/2 - img_size.y/2), img_size*0.9, color(255, 100):lerp(color(255), v.weap == weap and stuff.anal["w" .. v.name] or stuff.anal["w" .. v.name]/2), "f")
            else
                render.texture(img, vector(pos.x + 170 - img_size.x - 20, pos.y + (45 - (v.priority == 4 and 5 or 0))/2 - img_size.y/2), img_size, color(255, 100):lerp(color(255), stuff.anal["w" .. v.name]), "f")
            end

            if ((v.priority ~= 3 or not main.menu_items.options.combine_knife:get()) and (v.priority ~= 4 or not main.menu_items.options.combine_nades:get())) or (v.priority == 4 and main.menu_items.options.combine_nades:get() and nades_rendered == stuff.anal["nades_rendered"]) or (v.priority == 3 and main.menu_items.options.combine_knife:get() and knife_rendered == stuff.anal["knife_rendered"]) then
                indent_y = indent_y - 45
            end
        end
    end
    
    stuff.anim("nades_rendered", nades_rendered, 10)
    stuff.anim("nades_sz", nades_sz, 0.03)

    stuff.anim("knife_rendered", knife_rendered, 10)
    stuff.anim("knife_sz", knife_sz, 0.03)

    local pos = vector(main.menu_items.trash.ws_pos_x:get(), main.menu_items.trash.ws_pos_y:get())
    if style == "Battlefield" then
        main.trash.weapon_select_pos = stuff.drag_drop("weapon_select", pos, vector(10, -indent_y - 45), vector(180, 45) + 5)
    elseif style == "Blur" then
        main.trash.weapon_select_pos = stuff.drag_drop("weapon_select", pos, vector(40, -indent_y - 45), vector(140, 45) + 5)
    elseif style == "Signal" then
        main.trash.weapon_select_pos = stuff.drag_drop("weapon_select", pos, vector(5, -indent_y - 40), vector(170, 45) + 5)
    end
    main.menu_items.trash.ws_pos_x:set(main.trash.weapon_select_pos.x)
    main.menu_items.trash.ws_pos_y:set(main.trash.weapon_select_pos.y)
end

stuff.anim("hp_bar_x", 0, 0.01)
stuff.anim("hp_bar_x2", 0, 0.01)
stuff.anim("armor", 0, 0.01)
stuff.anim("hp", 0, 0.01)
stuff.anim("hp_bar_indent_y", 0, 0.01)
function hp_bar_render()
    local hp = main.info.menu_state and stuff.bruh(0.3, 100, 0.8) or main.info.player.m_iHealth
    local armor = main.info.menu_state and stuff.bruh(0.3, 100, 0.8) or main.info.player.m_ArmorValue 
    local text_sz = vector(50, 25)
    local sz_x = 0
    local sz_y = 0
    local pos = main.trash.hp_bar_pos + dynamic_offset
    local style = main.menu_items.main.hp_armor_style:get()
    if style == "Battlefield" then
        local text = armor ~= 0 and math.floor(stuff.anim("hp", hp, 0.01, 0, 1)) .. " | " .. math.floor(stuff.anim("armor", armor, 0.01, 0, 1)) or math.floor(stuff.anim("hp", hp, 0.01, 0, 1))
        local multicolor_text = {{text = math.floor(stuff.anal["hp"]), color = main.colors.bf.hp_armor:get("On Low")[1]:lerp(main.colors.bf.hp_armor:get("Text")[1], math.min(1, stuff.anal["hp"]/100))}}
        if armor ~= 0 then multicolor_text = {{text = math.floor(stuff.anal["hp"]), color = main.colors.bf.hp_armor:get("On Low")[1]:lerp(main.colors.bf.hp_armor:get("Text")[1], math.min(1, stuff.anal["hp"]/100))}, {text = " | ", color = main.colors.bf.hp_armor:get("Separator")[1]} ,{text = math.floor(stuff.anal["armor"]), color = main.colors.bf.hp_armor:get("On Low")[1]:lerp(main.colors.bf.hp_armor:get("Text")[1], math.min(1, stuff.anal["armor"]/100))}} end
        text_sz = render.measure_text(main.fonts[style].font_text1, nil, text)
        --render.text(main.fonts[main.trash.cur_fonts].font_text1, pos, color(255, 0, 0):lerp(color(255), math.min(1, stuff.anal["hp"]/100)), nil, text)
        render.push_clip_rect(pos, pos + vector(stuff.anim("hparmor_push_clip", text_sz.x+1, 0.03, 0, 1), text_sz.y))
        stuff.multicolor(main.fonts[style].font_text1, pos, multicolor_text)
        render.pop_clip_rect()
        sz_x, sz_y = text_sz.x, text_sz.y
        stuff.anim("hp_bar_x", sz_x, 0.05)
        stuff.anim("hp_bar_x2", 0, 0.05)
    elseif style == "Blur" then
        sz_x = 5
        local text = "HP"
        text_sz = render.measure_text(main.fonts[style].font_text1, nil, text)
        if not main.menu_items.performance.blur:get() then render.blur(pos + vector(0,stuff.anal["hp_bar_indent_y"]), pos + vector(stuff.anal["hp_bar_x"], text_sz.y + 5 + stuff.anal["hp_bar_indent_y"]), 2, 255, 5) end
        render.rect(pos + vector(0, stuff.anal["hp_bar_indent_y"]), pos + vector(stuff.anal["hp_bar_x"], text_sz.y + 5 + stuff.anal["hp_bar_indent_y"]), main.colors.blur.hp_armor:get("Background")[1], 5)
        sz_y = text_sz.y + 5
        render.text(main.fonts[style].font_text1, pos + vector(sz_x, sz_y/2 - text_sz.y/2 - 1 + stuff.anal["hp_bar_indent_y"]), main.colors.blur.hp_armor:get("HP Text")[1], "d", tostring(text))
        sz_x = sz_x + text_sz.x
        
        render.rect(pos + vector(sz_x + 5, sz_y/2 - 2.5 + stuff.anal["hp_bar_indent_y"]), pos + vector(sz_x + 70, sz_y/2 + 2.5 + stuff.anal["hp_bar_indent_y"]), main.colors.blur.hp_armor:get("HP Line")[2], 2)
        render.rect(pos + vector(sz_x + 5, sz_y/2 - 2.5 + stuff.anal["hp_bar_indent_y"]), pos + vector(sz_x + (70*math.min(1, stuff.anal["hp"]/100)), sz_y/2 + 2.5 + stuff.anal["hp_bar_indent_y"]), main.colors.blur.hp_armor:get("HP Line")[1], 2)
        sz_x = sz_x + 75
        text = math.floor(stuff.anim("hp", hp, 0.01, 0, 1))
        text_sz = render.measure_text(main.fonts[style].font_text1, nil, text)
        render.text(main.fonts[style].font_text1, pos + vector(sz_x, sz_y/2 - text_sz.y/2 - 1 + stuff.anal["hp_bar_indent_y"]), main.colors.blur.hp_armor:get("HP Text")[2], "d", text)
        sz_x = sz_x + text_sz.x + 5
        stuff.anim("hp_bar_x", sz_x, 0.05)
        if armor > 0 then
            sz_x = 5
            local text = "AR"
            text_sz = render.measure_text(main.fonts[style].font_text1, nil, text)
            if not main.menu_items.performance.blur:get() then render.blur((pos + vector(0, 25)), (pos + vector(0, 25)) + vector(stuff.anal["hp_bar_x2"], text_sz.y + 5), 2, 255, 5) end
            render.rect((pos + vector(0, 25)), (pos + vector(0, 25)) + vector(stuff.anal["hp_bar_x2"], text_sz.y + 5), main.colors.blur.hp_armor:get("Background")[2], 5)
            sz_y = text_sz.y + 5
            render.text(main.fonts[style].font_text1, (pos + vector(0, 25)) + vector(sz_x, sz_y/2 - text_sz.y/2 - 1), main.colors.blur.hp_armor:get("AR Text")[1], "d", tostring(text))
            sz_x = sz_x + text_sz.x
            
            render.rect((pos + vector(0, 25)) + vector(sz_x + 5, sz_y/2 - 2.5), (pos + vector(0, 25)) + vector(sz_x + 70, sz_y/2 + 2.5), main.colors.blur.hp_armor:get("AR Line")[2], 2)
            render.rect((pos + vector(0, 25)) + vector(sz_x + 5, sz_y/2 - 2.5), (pos + vector(0, 25)) + vector(sz_x + (70*math.min(1, stuff.anal["armor"]/100)), sz_y/2 + 2.5), main.colors.blur.hp_armor:get("AR Line")[1], 2)
            sz_x = sz_x + 75
            text = math.floor(stuff.anim("armor", armor, 0.01, 0, 1))
            text_sz = render.measure_text(main.fonts[style].font_text1, nil, text)
            render.text(main.fonts[style].font_text1, (pos + vector(0, 25)) + vector(sz_x, sz_y/2 - text_sz.y/2 - 1), main.colors.blur.hp_armor:get("AR Text")[2], "d", text)
            sz_x = sz_x + text_sz.x + 5
            sz_y = sz_y + 25
            stuff.anim("hp_bar_x2", sz_x, 0.05)
        end
    elseif style == "Default" then
        sz_x = 5
        sz_y = 0
        local text = "HP"
        text_sz = render.measure_text(main.fonts[style].font_text1, nil, text)
        render.text(main.fonts[style].font_text1, (pos + vector(0, 10)) + vector(sz_x, sz_y/2 - text_sz.y/2), main.colors.default.hp_armor:get(), "", tostring(text))
        sz_x = sz_x + text_sz.x + 5
        text = math.floor(stuff.anim("hp", hp, 0.01, 0, 1))
        text_sz = render.measure_text(main.fonts[style].font_text2, nil, text)
        render.text(main.fonts[style].font_text2, (pos + vector(0, 5)) + vector(sz_x, sz_y/2 - text_sz.y/2), main.colors.default.hp_armor:get(), "", tostring(text))
        sz_x = sz_x + text_sz.x + 5

        render.rect((pos + vector(0, 8)) + vector(sz_x - 1, sz_y/2 - 4), (pos + vector(0, 8)) + vector(sz_x + 71, sz_y/2 + 4), color(22), 0)
        local hpp = (70*math.min(1, stuff.anal["hp"]/100))
        if hpp ~= 0 then
            render.rect((pos + vector(0, 8)) + vector(sz_x, sz_y/2 - 3), (pos + vector(0, 8)) + vector(sz_x + hpp, sz_y/2 + 3), main.colors.default.hp_armor:get(), 1, false)
        end
        sz_x = sz_x + 70 + 10

        local text = "AR"
        text_sz = render.measure_text(main.fonts[style].font_text1, nil, text)
        render.text(main.fonts[style].font_text1, (pos + vector(0, 10)) + vector(sz_x, sz_y/2 - text_sz.y/2), main.colors.default.hp_armor:get(), "", tostring(text))
        sz_x = sz_x + text_sz.x + 5
        text = math.floor(stuff.anim("armor", armor, 0.01, 0, 1))
        text_sz = render.measure_text(main.fonts[style].font_text2, nil, text)
        render.text(main.fonts[style].font_text2, (pos + vector(0, 5)) + vector(sz_x, sz_y/2 - text_sz.y/2), main.colors.default.hp_armor:get(), "", tostring(text))
        sz_x = sz_x + text_sz.x + 5
        render.rect((pos + vector(0, 8)) + vector(sz_x - 1, sz_y/2 - 4), (pos + vector(0, 8)) + vector(sz_x + 71, sz_y/2 + 4), color(22), 0)
        local arr = (70*math.min(1, stuff.anal["armor"]/100))
        if arr ~= 0 then
            render.rect((pos + vector(0, 8)) + vector(sz_x, sz_y/2 - 3), (pos + vector(0, 8)) + vector(sz_x + arr, sz_y/2 + 3), main.colors.default.hp_armor:get(), 1, false)
        end
        sz_x = sz_x + 70
        sz_y = sz_y + text_sz.y/2
        stuff.anim("hp_bar_x", sz_x, 0.05)
        stuff.anim("hp_bar_x2", 0, 0.05)
    end
    stuff.anim("hp_bar_indent_y", armor > 0 and 0 or sz_y, 0.03)
    local pos = vector(main.menu_items.trash.hp_pos_x:get(), main.menu_items.trash.hp_pos_y:get())
    main.trash.hp_bar_pos = stuff.drag_drop("hp/armor", pos, vector(5, 5), vector(math.max(stuff.anal["hp_bar_x2"], stuff.anal["hp_bar_x"]), sz_y)+5)
    main.menu_items.trash.hp_pos_x:set(main.menu_items.options.hp_bar_center:get() and stuff.anim("hparmor", main.info.sc.x/2 - sz_x/2, 0.03, main.info.sc.x/2) or main.trash.hp_bar_pos.x)
    main.menu_items.trash.hp_pos_y:set(main.trash.hp_bar_pos.y)
end

function roundtime_render()
    local style = main.menu_items.main.roundtime_style:get()

    local pos = main.trash.roundtime_pos + dynamic_offset
    local roundtime = main.info.game_rules.m_iRoundTime
    local roundstarttime = main.info.game_rules.m_fRoundStartTime
    local remaining = stuff.anim("roundtime", (roundtime + roundstarttime) - globals.curtime, 0.01, 0, 1)
    local roundtimer = string.format("%.2d:%.2d", math.floor(remaining/60), remaining%60)

    local players = entity.get_players(false, true)
    local players_stat = {enemies = 0, teammates = 0}
    for k,v in pairs(players) do
        if v:is_alive() then
            local cur = v.m_iTeamNum == entity.get_local_player().m_iTeamNum and "teammates" or "enemies"
            players_stat[cur] = players_stat[cur] + 1
        end
    end
    local indent_x = 0
    local indent_y = 0
    local text_sz = vector(0,0)
    if style == "Battlefield" then
        text_sz = render.measure_text(main.fonts[style].font_text1, nil, string.format("%s · %s · %s", players_stat.teammates, roundtimer, players_stat.enemies))
        local multicolor_text = {{text = players_stat.teammates, color = main.colors.bf.roundtime:get("Teammates")[1]}, {text = " · ", color = main.colors.bf.roundtime:get("Separator")[1]}, {text = roundtimer, color = main.colors.bf.roundtime:get("Text")[1]},{text = " · ", color = main.colors.bf.roundtime:get("Separator")[1]}, {text = players_stat.enemies, color = main.colors.bf.roundtime:get("Enemies")[1]}}
        stuff.multicolor(main.fonts[style].font_text1, pos, multicolor_text)
        indent_x = text_sz.x
        indent_y = text_sz.y
    elseif style == "Blur" then
        text_sz = render.measure_text(main.fonts[style].font_text1, nil, string.format("  %s      |      %s  ", players_stat.teammates, players_stat.enemies))
        if not main.menu_items.performance.blur:get() then render.blur(pos, pos + text_sz + 15, 1, 1, 5) end
        render.rect(pos, pos + text_sz + 15, main.colors.blur.roundtime:get("Background")[1], 5)
        local multicolor_text = {{text = string.format("  %s      ", players_stat.teammates), color = main.colors.blur.roundtime:get("Teammates")[1]}, {text = "|", color = main.colors.blur.roundtime:get("Separator")[1]}, {text = string.format("      %s  ", players_stat.enemies), color = main.colors.blur.roundtime:get("Enemies")[1]}}
        stuff.multicolor(main.fonts[style].font_text1, pos + 7.5, multicolor_text)
        --render.text(main.fonts[cur_fonts].font_text1, pos + 7.5, color(255), nil, string.format("  %s      |      %s  ", players_stat.teammates, players_stat.enemies))

        if not main.menu_items.performance.glow:get() then render.shadow(pos + vector(0,5), pos + vector(0, text_sz.y + 10), main.colors.blur.roundtime:get("Elements")[1], 50, 0, 0) end
        render.rect(pos + vector(0,5), pos + vector(0, text_sz.y + 10), main.colors.blur.roundtime:get("Elements")[1], 5)

        if not main.menu_items.performance.glow:get() then render.shadow(pos + vector(text_sz.x+15,5), pos + vector(text_sz.x+15, text_sz.y + 10), main.colors.blur.roundtime:get("Elements")[2], 50, 0, 0) end
        render.rect(pos + vector(text_sz.x+15,5), pos + vector(text_sz.x+15, text_sz.y + 10), main.colors.blur.roundtime:get("Elements")[2], 5)

        indent_y = text_sz.y + 15 + 3
        indent_x = text_sz.x + 15

        text_sz = render.measure_text(main.fonts[style].font_text1, nil, roundtimer)
        if not main.menu_items.performance.blur:get() then render.blur(pos + vector(0,indent_y), pos + vector(indent_x,indent_y + text_sz.y + 8), 1, 1, 5) end
        render.rect(pos + vector(0,indent_y), pos + vector(indent_x,indent_y + text_sz.y + 8), main.colors.blur.roundtime:get("Background")[2], 5)
        render.text(main.fonts[style].font_text1, pos + vector(0 + indent_x/2 - text_sz.x/2,indent_y + 4), main.colors.blur.roundtime:get("Text")[1], nil, roundtimer)

        indent_y = indent_y + text_sz.y + 8
    end

    local pos = vector(main.menu_items.trash.rt_pos_x:get(), main.menu_items.trash.rt_pos_y:get())
    main.trash.roundtime_pos = stuff.drag_drop("round time", pos, vector(5, 5), vector(indent_x, indent_y) + 5)
    main.menu_items.trash.rt_pos_x:set(main.menu_items.options.roundtime_center:get() and stuff.anim("roundtime_pos", main.info.sc.x/2 - indent_x/2, 0.03, main.info.sc.x/2) or main.trash.roundtime_pos.x)
    main.menu_items.trash.rt_pos_y:set(main.trash.roundtime_pos.y)
end

--Я НЕ УПОТРЕБЛЯЮ
--Я УЖЕ НЕДЕЛЮ БУДТО ЧИСТ

local flag_icons = {
    ["hs"] = {path = "materials/panorama/images/hud/deathnotice/icon_headshot.svg", priority = 4},
    ["suicide"] = "materials/panorama/images/hud/deathnotice/icon_suicide.svg",
    ["ns"] = {path = "materials/panorama/images/hud/deathnotice/noscope.svg", priority = 1},
    ["penetrate"] = {path = "materials/panorama/images/hud/deathnotice/penetrate.svg", priority = 3},
    ["smoke"] = {path = "materials/panorama/images/hud/deathnotice/smoke_kill.svg", priority = 2},
    ["blind"] = "materials/panorama/images/hud/deathnotice/blind_kill.svg"
}

function killfeed_render()
    local indent_y = 0
    local indent_x = 0
    local pos = main.trash.killfeed_pos + dynamic_offset
    local style = main.menu_items.main.killfeed_style:get()
    
    for k,v in pairs(main.trash.killfeed_log) do

        if stuff.anal["flags_length" .. k] == nil then
            stuff.anal["flags_length" .. k] = 0
        end

        local allow_render = v.time > globals.realtime
        local weap_name = v.weap_console_name
        weap_name = weap_name:gsub("weapon_", "")
        if loaded_icons3[weap_name] == nil then
            --print("3. "..weap_name .. " " .. globals.realtime)
            local img = render.load_image_from_file("materials/panorama/images/icons/equipment/" .. weap_name .. ".svg")
            loaded_icons3[weap_name] = {img = img, updated = globals.realtime + 1}
        elseif loaded_icons3[weap_name].updated < globals.realtime and loaded_icons3[weap_name].updated ~= 1488 then
            --print("3. "..weap_name .. " " .. globals.realtime)
            local img = render.load_image_from_file("materials/panorama/images/icons/equipment/" .. weap_name .. ".svg", vector(loaded_icons3[weap_name].img.width, loaded_icons3[weap_name].img.height)*0.6)
            loaded_icons3[weap_name] = {img = img, updated = 1488}
        end

        if loaded_icons3[weap_name] == nil or loaded_icons3[weap_name].img == nil then return end

        if loaded_icons3[weap_name].updated < globals.realtime then
            loaded_icons3[weap_name].updated = 1488
        end

        if loaded_icons3[weap_name].updated ~= 1488 then
            break
        end

        local img = loaded_icons3[weap_name].img
        local img_size = vector(img.width, img.height)

        local text = string.format("%s", v.killer)
        local text_sz = render.measure_text(main.fonts.killfeed.font_text, nil, text)
        
        local text2 = string.format("%s", v.death)
        local text_sz2 = render.measure_text(main.fonts.killfeed.font_text, nil, text2)
        stuff.anim("killfeed" .. k, allow_render and 255 or 0, 0.03, 0, 1)
        stuff.anim("killfeed_y" .. k, indent_y, 0.03, 0, 1)

        if style == "Fade" then
            local bg_color, bg_color2 = main.colors.bf.killfeed.text:get("Background")[1], main.colors.bf.killfeed.text:get("Background")[2]
            bg_color.a = math.min(bg_color.a, stuff.anal["killfeed" .. k])
            bg_color2.a = math.min(bg_color2.a, stuff.anal["killfeed" .. k])
            render.gradient(vector(pos.x - text_sz.x - text_sz2.x - img_size.x - stuff.anal["flags_length" .. k] - 5, pos.y + stuff.anal["killfeed_y" .. k]), vector(pos.x + 5, pos.y + stuff.anal["killfeed_y" .. k] + text_sz.y + 5), bg_color, bg_color2, bg_color, bg_color2, 0)
        end

        if main.menu_items.main.killfeed_hl:get() then
            if v.killer == main.info.username or v.killer == entity.get_local_player():get_name() then
                render.shadow(vector(pos.x - text_sz.x - text_sz2.x - img_size.x - stuff.anal["flags_length" .. k] - 5, pos.y + stuff.anal["killfeed_y" .. k] + text_sz.y/2), vector(pos.x - text_sz2.x - img_size.x - stuff.anal["flags_length" .. k] - 5, pos.y + stuff.anal["killfeed_y" .. k] + text_sz.y/2), color(255, 0, 0, stuff.anal["killfeed" .. k]), 70, 0, 0)
            end
            if v.death == main.info.username or v.death == entity.get_local_player():get_name() then
                render.shadow(vector(pos.x - text_sz2.x, pos.y + stuff.anal["killfeed_y" .. k] + text_sz2.y/2), vector(pos.x, pos.y + stuff.anal["killfeed_y" .. k] + text_sz2.y/2), color(255, 0, 0, stuff.anal["killfeed" .. k]), 70, 0, 0)
            end
        end
        
        local icon_color = main.colors.bf.killfeed.text:get("Icons")[1]
        icon_color.a = math.min(icon_color.a, stuff.anal["killfeed" .. k])

        local flags_length = 5
        for k2,v2 in pairs(v.flags) do
            table.sort(v.flags, function(a,b) return flag_icons[a].priority > flag_icons[b].priority end)
            local icon_path = flag_icons[v2].path
            if loaded_icons4[v2] == nil then
                --print("4. "..weap_name .. " " .. globals.realtime)
                local img = render.load_image_from_file(icon_path)
                loaded_icons4[v2] = {img = img, updated = globals.realtime + 1}
            elseif loaded_icons4[v2].updated < globals.realtime and loaded_icons4[v2].updated ~= 1488 then
                --print("4. "..weap_name .. " " .. globals.realtime)
                local img = render.load_image_from_file(icon_path, vector(loaded_icons4[v2].img.width, loaded_icons4[v2].img.height)*0.6)
                loaded_icons4[v2] = {img = img, updated = 1488}
            end

            if loaded_icons4[v2] == nil or loaded_icons4[v2].img == nil then return end

            if loaded_icons4[v2].updated < globals.realtime and loaded_icons4[v2].updated ~= 1488 then
                loaded_icons4[v2].updated = 1488
                return
            end

            if loaded_icons3[weap_name].updated ~= 1488 then
                break
            end

            local icon = loaded_icons4[v2].img
            local icon_size = vector(icon.width, icon.height)

            render.texture(icon, vector(pos.x - text_sz2.x - icon_size.x - flags_length, pos.y + stuff.anal["killfeed_y" .. k]), icon_size, icon_color, "f")

            flags_length = flags_length + icon_size.x + 5
        end

        local team_color, enemy_color = main.colors.bf.killfeed.text:get("Teammates")[1], main.colors.bf.killfeed.text:get("Enemies")[1]
        team_color.a = math.min(team_color.a, stuff.anal["killfeed" .. k])
        enemy_color.a = math.min(enemy_color.a, stuff.anal["killfeed" .. k])
        stuff.anim("flags_length" .. k, flags_length, 0.03, 0, 1)
        render.texture(img, vector(pos.x - text_sz2.x - img_size.x - flags_length, pos.y + stuff.anal["killfeed_y" .. k]), img_size, icon_color, "f")
        render.text(main.fonts.killfeed.font_text, vector(pos.x - text_sz.x - text_sz2.x - img_size.x - flags_length - 5, pos.y + stuff.anal["killfeed_y" .. k]), v.killer_team and team_color or enemy_color, "d", text)
        render.text(main.fonts.killfeed.font_text, vector(pos.x - text_sz2.x, pos.y + stuff.anal["killfeed_y" .. k]), v.death_team and team_color or enemy_color, "d", text2)
        if allow_render or stuff.anal["killfeed" .. k] > 20 then
            indent_y = indent_y + text_sz.y + 5 + (style == "Simple" and 0 or 5)
            indent_x = math.max(indent_x, text_sz.x + text_sz2.x + img_size.x + flags_length + 10)
        end
    end

    if indent_y == 0 then
        main.trash.killfeed_log = { }
    end
    local pos = vector(main.menu_items.trash.killfeed_pos_x:get(), main.menu_items.trash.killfeed_pos_y:get())
    main.trash.killfeed_pos = stuff.drag_drop("killfeed", pos, vector(math.max(120, stuff.anim("killfeed_sz_x", indent_x + 5, 0.03)), 5), vector((style == "Simple" and 5 or 10), math.max(80, stuff.anim("killfeed_sz_y", indent_y + 5, 0.03))))
    main.menu_items.trash.killfeed_pos_x:set(main.trash.killfeed_pos.x)
    main.menu_items.trash.killfeed_pos_y:set(main.trash.killfeed_pos.y)

    if main.info.menu_state and #main.trash.killfeed_log < 6 then
        local texts = {
            "weapon_awp",
            "weapon_ak47",
            "weapon_usp_silencer",
            "weapon_revolver",
            "weapon_g3sg1",
            "weapon_scar20",
            "weapon_ssg08"
        }

        local flags_r = {
            { },
            {"hs"},
            {"penetrate"},
            {"ns"},

            {"hs", "penetrate"},
            {"hs", "ns"},

            {"hs", "penetrate"},
            {"ns", "penetrate"},

            {"ns", "penetrate"},
            {"ns", "hs"},
            {"hs", "penetrate", "ns"}
        }
        if #main.trash.killfeed_log == 0 then
            table.insert(main.trash.killfeed_log, {
                weap = "AWP",
                weap_console_name = texts[utils.random_int(1, #texts)],
                flags = flags_r[utils.random_int(1, #flags_r)],
                death = "Enemy",
                death_team = false,
                killer = common.get_username(),
                killer_team = true,
                time = globals.realtime + 4 + (0.6 * #main.trash.killfeed_log),
            })
        else
            table.insert(main.trash.killfeed_log, {
                weap = "AWP",
                weap_console_name = texts[utils.random_int(1, #texts)],
                flags = flags_r[utils.random_int(1, #flags_r)],
                death = "300$ invite + ban",
                death_team = false,
                killer = "Neverlose",
                killer_team = true,
                time = globals.realtime + 4 + (0.6 * #main.trash.killfeed_log),
            })
        end
    end
end

events.player_death:set(function(event)
    local death = entity.get(event.userid, true)
    local killer = entity.get(event.attacker, true)
    local weap = killer:get_player_weapon(false)
    if weap == nil then return end
    if event.weapon == "world" then return end
    local flags = { }
    if event.headshot then table.insert(flags, "hs") end
    if event.penetrated ~= 0 then table.insert(flags, "penetrate") end
    if event.noscope then table.insert(flags, "ns") end
    table.insert(main.trash.killfeed_log, {
        weap = weap:get_name(),
        --weap_console_name = weap:get_weapon_info().console_name,
        weap_console_name = event.weapon,
        flags = flags,
        death = death:get_name(),
        death_team = death.m_iTeamNum == entity.get_local_player().m_iTeamNum,
        killer = killer:get_name(),
        killer_team = killer.m_iTeamNum == entity.get_local_player().m_iTeamNum,
        time = globals.realtime + ((main.menu_items.options.preserve_killfeed:get() and killer == entity.get_local_player()) and 300 or 8) + (death == entity.get_local_player() and 300 or 0),
    })

    local active_kf = 0
    for k,v in pairs(main.trash.killfeed_log) do
        if v.time > globals.realtime then
            active_kf = active_kf + 1
        end
    end

    if active_kf > 8 then
        for k,v in pairs(main.trash.killfeed_log) do
            if v.time > globals.realtime then
                v.time = 0
                break
            end
        end
    end

end)

function chat_render()
    local indent_x = 80
    local indent_y = 0
    local pos = main.trash.chat_pos + dynamic_offset
    for k,v in pairs(main.trash.chat_log) do

        local limit_string = 70

        if utf8.len(v.text) > limit_string and not v.text_r then
            local out = utf8.sub(v.text, 1, limit_string) .. "...\n" .. utf8.sub(v.text, limit_string + 1)
            v.text = out
            v.text_r = true
        end

        local allow_render = v.time > globals.realtime
        local text_sz = render.measure_text(main.fonts.chat.font_text, nil, (v.alive and v.name or "dead " .. v.name) .. ": " .. v.text)
        stuff.anim("chat_y" .. k, indent_y, 0.03, 0, 1)
        stuff.anim("chat" .. k, allow_render and text_sz.x+1 or 0, 0.02, 0, 1)
        if allow_render or stuff.anal["chat" .. k] > 0 then
            indent_y = indent_y + text_sz.y
            indent_x = math.max(indent_x, text_sz.x)
        end
        render.push_clip_rect(vector(pos.x, pos.y + stuff.anal["chat_y" .. k]), vector(pos.x, pos.y + stuff.anal["chat_y" .. k]) + vector(stuff.anal["chat" .. k], text_sz.y + 2))
        local multicolor_text = {{text = v.alive and "" or "dead ", color = main.colors.bf.chat.text:get("Text 2")[1]},{text = v.name, color = v.team == entity.get_local_player().m_iTeamNum and main.colors.bf.chat.text:get("Teammates")[1] or main.colors.bf.chat.text:get("Enemies")[1]}, {text = ": " .. v.text, color = main.colors.bf.chat.text:get("Text")[1]}}
        stuff.multicolor(main.fonts.chat.font_text, vector(pos.x, pos.y + stuff.anal["chat_y" .. k]), multicolor_text)
        render.pop_clip_rect()
    end
    local pos = vector(main.menu_items.trash.chat_pos_x:get(), main.menu_items.trash.chat_pos_y:get())
    main.trash.chat_pos = stuff.drag_drop("chat", pos, vector(0, 0), vector(stuff.anim("chat_sz_x", indent_x + 5, 0.03), math.max(80, stuff.anim("chat_sz_y", indent_y + 5, 0.03))))
    main.menu_items.trash.chat_pos_x:set(main.trash.chat_pos.x)
    main.menu_items.trash.chat_pos_y:set(main.trash.chat_pos.y)

    if indent_y == 0 then
        main.trash.chat_log = { }
    end

    if main.info.menu_state and #main.trash.chat_log < 4 then
        local usernames = {
            "soufiw",
            "O_o",
            "Хуйпачос",
            "Лютый Хуесос",
            "Allah",
            "Biba + Boba",
            "pussy",
            "kto kto",
            "лютая печка",
            "лох забористый",
            "Big Floppa",
            "adolf",
            "dead rave",
            "SWAGGGG",
            "4mo 1844",
            "10 iq peek",
            "huesosatel",
            "котэ_под_наркотэ",
            "chaina head",
            "amerima burgir",
            "zhopan kotana",
            "dildotron 3100",
            "maga_4e4enec",
            "гуфраджон",
            "Rahmadullo",
            "Ходжирахматуллов",
            "Dro4y_4len_Mamke"
        }
        --"это темный брил я насрал в лесополосе 1338",
        -- А Я БЛШЯТЬ ЕЕБАЛ КАШТАНОМ СЕБЯ КОГДА ТО ВЕДЬБ ПАЛЬЧИК В ПОПУ НЕ ПРИГОВОР СУЧАРЫ БЛЯ ЕБВАЛ КЛАБ И ХЭВ ГЛОК ИН МАЙ ASS (холокост) (https://youtu.be/5otSuupCJdc)
        local texts = {
            "ненавижу сиськи",
            "я бы хотел быть собой",
            "крутые парни: ковбои, пираты, роботы, динозавры, скелеты, самураи, ниндзя, еще наркоманы",
            "мало кто знал но первый троллфейс был наскальным рисунком",
            "хочу чтобы животные научились играть в видеоигры",
            "фурион фурион по фарму чемпион",
            "если тебе не смешно с картинок крутых демонов я не знаю о чем с тобой разговаривать",
            "я отжимаю,у меня прыгает стол",
            "ну какими же выкупающими будут мои дети",
            "Тебя уничтожил кентавр. сексуальная ты ебаная шлюха",
            "Ищу мальчика чтобы избивал и унижал меня Он бы ломал мне ноги а я мило бы делала вид, что мне не больно,и говорила бы что хочу еще. Он бы брал кастрюлю, надевал бы ее мне на голову и хуярил бы по ней",
            "бро я в ските был забанен ещё по причине андермайнинга, кряк не мой уровень, даже оплачивать его не собираюсь. Ты посты просто высираешь по какой-то хуйне, буквально. На и про форсы какие-то ещё натянул что-то, рик овенсы какие-то ещё. Бля, старый, пей таблетки почаще",
            "зачем нужна капуста когда есть картошка",
            "видеоигры это равзлечение для детей, я предпочитаю алкоголизм и казино"
        }
        table.insert(main.trash.chat_log, {
            time = globals.realtime + 5 + (0.6 * #main.trash.chat_log),
            name = "*" .. usernames[utils.random_int(1, #usernames)],
            team = utils.random_int(2, 3),
            text = texts[utils.random_int(1, #texts)],
            alive = utils.random_int(0, 1) > 0
        })
    end
end

function dynamic_render()
    if not main.menu_items.main.dynamic_pos:get() then dynamic_offset = vector(0,0); return end
    local eye_pos = render.camera_position()
    local camera_ang = render.camera_angles()
    local out = eye_pos + (vector():angles(camera_ang)*150)
    local anim_out = anim_vec("0", out, main.menu_items.main.dynamic_speed:get()/100)
    local screen = anim_out:to_screen()
    if screen == nil then return end
    dynamic_offset = screen - (main.info.sc/2)
end

events.player_say:set(function(e)
    table.insert(main.trash.chat_log, {
        time = globals.realtime + 10,
        name = entity.get(e.userid, true):get_name(),
        team = entity.get(e.userid, true).m_iTeamNum,
        text = e.text,
        alive = entity.get(e.userid, true):is_alive()
    })
    --print(entity.get(e.userid, true):get_name() .. " " .. e.text)
end)

events.render:set(function(ctx)
    if ffi.C.GetActiveWindow()==0 then return end
    main.info.menu_state = ui.get_alpha() == 1
    main.info.player = entity.get_local_player()
    main.info.game_rules = entity.get_game_rules()
    main.info.mouse_pos = ui.get_mouse_position()

    if not globals.is_connected then main.info.state = 1; call(); return end
    if not globals.is_in_game then main.info.state = 1; call(); return end

    if not main.info.player:is_alive() then 
        main.info.player = main.info.player.m_hObserverTarget
    end
    
    if main.info.player == nil then main.info.state = 1; return end

    if not main.info.player:is_alive() then 
        main.info.state = 2; 
        call(); 
        return 
    end
    if main.trash.hud_state then main.info.state = 2; call(); return end
    main.info.state = 3
    call()
end)

menu.visual.main.clantag:set_callback(function()
    common.set_clan_tag(" ")
end)

menu.cfg.list = groups.main_cfg:list("", {})
menu.cfg.name = groups.main_cfg:input("name")
menu.cfg.load = groups.main_cfg:button("load")
menu.cfg.save = groups.main_cfg:button("save")
menu.cfg.create = groups.main_cfg:button("create")

groups.main_cfg:button("export", function()
    stuff.clipboard_set(cfg.export())
    common.add_notify("HUD", "Exporting CFG")
end)

groups.main_cfg:button("import", function()
    cfg.import(stuff.clipboard_get())
    common.add_notify("HUD", "Importing CFG")
end)

menu.cfg.remove = groups.main_cfg:button("remove")



local data = db.custom_hud or { }

function cfg_update()
    local config_list = {}
    for k,v in pairs(data) do
        table.insert(config_list, v.name)
    end
    menu.cfg.list:update(#config_list < 1 and {"no configs"} or config_list)
end
cfg_update()

function cfg_save()
    local config_data = cfg.export()
    for k,v in pairs(data) do
        if menu.cfg.list:get() == k then
            v.cfg = cfg.export()
        end
    end
    cfg_update()
end

function cfg_load()
    for k,v in pairs(data) do
        if menu.cfg.list:get() == k then
            cfg.import(v.cfg) 
        end
    end
    cfg_update()
end

function cfg_create()
    table.insert(data, {name = menu.cfg.name:get(), cfg = cfg.export()})
    cfg_update()
end

function cfg_remove()
    for k,v in pairs(data) do
        if menu.cfg.list:get() == k then
            table.remove(data, k)
        end
    end
    cfg_update()
end

for k,v in pairs(main.menu_items) do
    if type(v) == "table" then
        for k2,v2 in pairs(v) do
            if type(v2) == "userdata" then
                cfg.inalizate(v2)
            end
        end
    end
end

for k,v in pairs(main.colors) do
    if type(v) == "table" then
        for k2,v2 in pairs(v) do
            if type(v2) == "userdata" then
                cfg.inalizate(v2)
            elseif type(v2) == "table" then
                for k3,v3 in pairs(v2) do
                    if type(v3) == "userdata" then
                        cfg.inalizate(v3)
                    end
                end
            end
        end
    end
end

for k,v in pairs(menu) do
    if type(v) == "table" then
        for k2,v2 in pairs(v) do
            if type(v2) == "table" then
                for k3,v3 in pairs(v2) do
                    if type(v3) == "userdata" then
                        cfg.inalizate(v3)
                    end
                end
            end
        end
    end
end

menu.cfg.create:set_callback(cfg_create)
menu.cfg.save:set_callback(cfg_save)
menu.cfg.load:set_callback(cfg_load)
menu.cfg.remove:set_callback(cfg_remove)


function indicator()

end

function clantag()
    local local_player = entity.get_local_player()
    if not local_player then return end
    if stuff.check_flag(local_player, stuff.flags.IsFrozen) then
        local num = 1
        if num ~= trash.clantag_num then
            common.set_clan_tag(lua_name)
            trash.clantag_num = num
        end
    else
        local net = utils.net_channel()
        if net == nil then return end

        local times_visible = 4

        local tag = lua_name
        local st = string.format("%s%s%s", string.rep(" ", #tag+times_visible), tag, string.rep(" ", #tag))

        local time = globals.tickcount + (net.latency[0]/globals.tickinterval)
        local i = time/stuff.time_to_ticks(0.3)
        i = math.floor(i % ((#tag*2)+times_visible+2))

        local tagg = string.sub(st, i, i+#tag+times_visible)

        if i ~= trash.clantag_num and trash.clantag_last_update < globals.realtime then
            common.set_clan_tag(tagg)
            trash.clantag_num = i
            trash.clantag_last_update = globals.realtime + 0.1
        end
    end
end


stuff.anal["wt_exploit_alpha"]=1
function watermark()
    local time = common.get_system_time()
    time = string.format(" | %02d:%02d:%02d", time.hours, time.minutes, time.seconds)
    local local_player = entity.get_local_player()
    local net = utils.net_channel()
    local ping = net == nil and "" or math.floor(net.latency[1] * 1000) ~= 0 and " | delay: " .. math.floor(stuff.anim("ping", net.latency[1] * 1000, 0.02)) .."ms" or ""
    local loss = net == nil and "" or math.floor(math.max(net.loss[1], net.loss[0]) * 100) > 0 and " | loss: " .. math.floor(stuff.anim("loss", math.max(net.loss[1], net.loss[0]) * 100, 0.02)) or ""
    local items = {
        a = {
            ["Username"] = " | " .. steam_name,
            ["Loss"] = loss,
            ["Delay"] = ping,
            ["Time"] = time
        },
        b = {

        }
    }
    
    for k,v in pairs(menu.visual.main.watermark_items:get()) do
        table.insert(items.b, items.a[v])
    end

    local st = string.format(string.rep("%s", #items.b + 1), lua_name, unpack(items.b))
    local ss = render.screen_size()
    local pos_y = stuff.anim("wt_y", menu.visual.main.watermark_style:get() == "Up" and ss.y/12 or ss.y/1.05, 0.04)
    local text_sz = render.measure_text(verdana_12, nil, st)
    stuff.anim("wt_sz_x", text_sz.x, 0.04)
    local rect_sz = {vector(ss.x/2 - stuff.anal["wt_sz_x"]/2 - 5, pos_y - text_sz.y/2 - 3), vector(ss.x/2 + stuff.anal["wt_sz_x"]/2 + 5, pos_y + text_sz.y/2 + 3)}

    if local_player and (menu_items.dt:get() or menu_items.hs:get() or stuff.anal["wt_exploit_alpha"] ~= 0) then
        stuff.anim("wt_exploit_alpha", ((menu_items.dt:get() or menu_items.hs:get()) and local_player:is_alive()) and 1 or 0, 0.04)
        local st = "exploit"
        local text_sz_exploit = render.measure_text(verdana_12, nil, st)
        stuff.anim("wt_exploit", 1, 0.1)
        local rect_sz = {vector(ss.x/2 - ((stuff.anal["wt_sz_x"]/2)*stuff.anal["wt_exploit_alpha"]) - text_sz_exploit.x - 20, pos_y - text_sz.y/2 - 3), vector(ss.x/2 - ((stuff.anal["wt_sz_x"]/2)*stuff.anal["wt_exploit_alpha"]) - 10, pos_y + text_sz.y/2 + 3)}
        render.push_clip_rect(rect_sz[1], rect_sz[2], false)
        render.blur(rect_sz[1], rect_sz[2], 1, stuff.anal["wt_exploit_alpha"], 3)
        render.rect(rect_sz[1], rect_sz[2], color(44, 100*stuff.anal["wt_exploit_alpha"]), 3, true)
        render.text(verdana_12, vector(ss.x/2 - ((stuff.anal["wt_sz_x"]/2)*stuff.anal["wt_exploit_alpha"]) - text_sz_exploit.x - 15, pos_y - text_sz.y/2), color(255,0,0, 255*stuff.anal["wt_exploit_alpha"]):lerp(color(255, 255*stuff.anal["wt_exploit_alpha"]), stuff.anal["wt_exploit"]), nil, st)
        render.pop_clip_rect()
        if get_defensive() then
            stuff.anal["wt_exploit"] = 0.5
        end
    end

    render.blur(rect_sz[1], rect_sz[2], 1, 255, 3)
    render.rect(rect_sz[1], rect_sz[2], color(44, 100), 3, true)
    render.push_clip_rect(rect_sz[1], rect_sz[2], false)
    render.text(verdana_12, vector(ss.x/2 - stuff.anal["wt_sz_x"]/2, pos_y - text_sz.y/2), color(255), nil, st)
    render.pop_clip_rect()
    local indent = 11 + text_sz.y
    local actives_logs = 0

    for k,v in pairs(trash.logs) do
        local st = v.text
        local text_sz = render.measure_text(verdana_12, nil, st)
        stuff.anim("logs_alpha"..v.id, v.active and 1 or 0, 0.03)
        stuff.anim("logs_x"..v.id, v.active and text_sz.x+10 or 0, 0.03)
        stuff.anim("logs_y"..v.id, menu.visual.main.watermark_style:get() == "Up" and indent or -indent, 0.04)
        local rect_sz = {vector(ss.x/2 - stuff.anal["logs_x"..v.id]/2 - 5, pos_y - text_sz.y/2 - 3 + stuff.anal["logs_y"..v.id]), vector(ss.x/2 + stuff.anal["logs_x"..v.id]/2 + 5, pos_y + text_sz.y/2 + 3 + stuff.anal["logs_y"..v.id])}
        render.blur(rect_sz[1], rect_sz[2], 1, stuff.anal["logs_alpha"..v.id], 3)
        render.rect(rect_sz[1], rect_sz[2], color(44, 120*stuff.anal["logs_alpha"..v.id]), 3, true)
        render.push_clip_rect(rect_sz[1], rect_sz[2], false)
        render.text(verdana_12, vector(ss.x/2 - stuff.anal["logs_x"..v.id]/2, pos_y - text_sz.y/2 + stuff.anal["logs_y"..v.id]), color(255, 255*stuff.anal["logs_alpha"..v.id]), nil, st)
        render.circle_outline(vector(ss.x/2 + text_sz.x/2 + 2, pos_y + stuff.anal["logs_y"..v.id]), color(120, 255*stuff.anal["logs_alpha"..v.id]), 5, 0, 1, 2)
        render.circle_outline(vector(ss.x/2 + text_sz.x/2 + 2, pos_y + stuff.anal["logs_y"..v.id]), color(255, 255*stuff.anal["logs_alpha"..v.id]), 5, 0, (v.time-globals.realtime)/v.time_max, 2)
        render.pop_clip_rect()
        if v.time-globals.realtime < 0 or not v.active then
            v.active = false
            if stuff.anal["logs_alpha"..v.id] ~= 0 then
                actives_logs = actives_logs + 1
            else
                table.remove(trash.logs, k)
            end
        else
            actives_logs = actives_logs + 1
        end

        if stuff.anal["logs_alpha"..v.id] ~= 0 then
            indent = indent + 11 + text_sz.y
        end
    end

    if menu.visual.main.logs:get() and menu.visual.main.logs_preview:get() and #trash.logs < 3 and ui.get_alpha() > 0 then
        local texts = {
            "example log",
            "other example log...",
            "Hit Big Boy in the Big Balls for 9999 [aimed: Big Cock:99999, hc: 101, bt: 80]",
            "Missed Allah's Head due to never_hit_Allah (is haram) [damage: 100, hc: 0, bt: 1]"
        }
        log("*"..texts[utils.random_int(1, #texts)], 2 + (1 * (#trash.logs+1)), nil, true)
    end
end

local log_counter = 0
function log(text, time, clr, only_screen, only_console)
    if time == nil then time = 10 end
    if clr == nil then clr = color(255) end
    log_counter = log_counter + 1
    if not only_console then
        table.insert(trash.logs, {id = log_counter, text = text, time = globals.realtime + time, time_max = time, active = true})
    end

    if not only_screen then
        print_raw(string.format("\aFFFFFFFF[%s] \a%s%s", lua_name, clr:to_hex(), text))
    end
    
    local actives_logs = 0
    for k,v in pairs(trash.logs) do
        if v.active then
            actives_logs = actives_logs + 1
        end
    end

    if actives_logs > menu.visual.main.logs_limit:get() then
        for k,v in pairs(trash.logs) do
            if v.active then
                v.active = false
                break
            end
        end
    end

    if log_counter >= 64 then
        log_counter = 0
    end
end

log("Welcome " .. common.get_username() .. "!", 5)

events.aim_ack:set(function(v)
    if not menu.visual.main.logs:get() then return end
    if not menu.visual.main.logs_options:get("Damage") then return end
    if not v.state then
        --spread: %s°
        --\ad2f0fc[%s] \a00FF00
        local player = v.target
        local s = string.format("Hit %s in the %s for %s [aimed: %s:%s, hc: %s, bt: %s]", player:get_name(), hitbox[v.hitgroup], v.damage, hitbox[v.wanted_hitgroup], v.wanted_damage, v.hitchance, v.backtrack)
        log(s, 8, color(134, 252, 104))
    else
        --\ad2f0fc[%s] \aFF0000
        local s = string.format("Missed %s's %s due to %s [damage: %s, hc: %s, bt: %s]", v.target:get_name(), hitbox[v.wanted_hitgroup], v.state, v.wanted_damage, v.hitchance, v.backtrack)
        log(s, 8, color(252, 104, 104))
    end
end)

events.round_start:set(function(e)
    if not menu.visual.main.logs:get() then return end
    log("New round started", cvar.mp_freezetime:int())
end)

events.bomb_beginplant:set(function(e)
    if not menu.visual.main.logs:get() then return end
    if not menu.visual.main.logs_options:get("Bomb") then return end
    local CCSPlayerResource = entity.get_entities("CCSPlayerResource", true)[1]
    local site_A, site_B = CCSPlayerResource.m_bombsiteCenterA, CCSPlayerResource.m_bombsiteCenterB
    local site = entity.get(e.userid, true):get_origin():distsqr(site_A)<entity.get(e.userid, true):get_origin():distsqr(site_B) and "A" or "B"
    
    log(string.format("%s started planting the bomb on %s", entity.get(e.userid, true):get_name(), site), 6)
end)

events.bomb_planted:set(function(e)
    if not menu.visual.main.logs:get() then return end
    if not menu.visual.main.logs_options:get("Bomb") then return end
    local CCSPlayerResource = entity.get_entities("CCSPlayerResource", true)[1]
    local site_A, site_B = CCSPlayerResource.m_bombsiteCenterA, CCSPlayerResource.m_bombsiteCenterB
    local site = entity.get(e.userid, true):get_origin():distsqr(site_A)<entity.get(e.userid, true):get_origin():distsqr(site_B) and "A" or "B"
    
    log(string.format("Bomb planted on %s", site), 6)
end)

events.bomb_abortplant:set(function(e)
    if not menu.visual.main.logs:get() then return end
    if not menu.visual.main.logs_options:get("Bomb") then return end
    log(string.format("%s aborted planting of the bomb", entity.get(e.userid, true):get_name()), 6)
end)

events.player_hurt:set(function(e)
    if not menu.visual.main.logs:get() then return end
    if not menu.visual.main.logs_options:get("Damage") then return end
    local local_player = entity.get_local_player()
    if not e.attacker or not e.userid then return end
    if entity.get(e.attacker, true) == local_player then
        if e.weapon == "hegrenade" then
            local player = entity.get(e.userid, true)
            local s = string.format("Naded %s for %s", player:get_name(), e.dmg_health)
            log(s, 8, color(134, 252, 104))
        end

        if e.weapon == "inferno" then
            local player = entity.get(e.userid, true)
            local s = string.format("Burned %s for %s", player:get_name(), e.dmg_health)
            log(s, 8, color(134, 252, 104))
        end

        if e.weapon == "smokegrenade" then
            local player = entity.get(e.userid, true)
            local s = string.format("Blant passed to %s for %s", player:get_name(), e.dmg_health)
            log(s, 8, color(134, 252, 104))
        end
    end

    if entity.get(e.userid, true) == local_player then
        local player = entity.get(e.attacker, true)
        local s = string.format("Received %s damage from %s", e.dmg_health, player:get_name())
        log(s, 8, color(252, 104, 104))
    end
end)

events.item_purchase:set(function(e)
    if not menu.visual.main.logs:get() then return end
    if not menu.visual.main.logs_options:get("Purchases") then return end
    local player = entity.get(e.userid, true)
    if not player:is_enemy() then return end
    local s = string.format("%s purchased %s", player:get_name(), e.weapon)
    log(s, 8, nil, false)
end)

create_fun(3, "render", weapon_select_render, main.menu_items.main.weapon_selector)
create_fun(3, "render", hp_bar_render, main.menu_items.main.hp_armor)
create_fun(3, "render", weapon_clip, main.menu_items.main.weapon_clip)
create_fun(3, "render", roundtime_render, main.menu_items.main.roundtime)
create_fun(2, "render", chat_render, main.menu_items.main.chat)
create_fun(2, "render", killfeed_render, main.menu_items.main.killfeed)
create_fun(3, "render", dynamic_render) 

create_fun(2, "render", clantag, menu.visual.main.clantag)
create_fun(1, "render", watermark, menu.visual.main.watermark)

main.menu_items.main.weapon_selector:set_callback(function()
    hud_state(not (main.menu_items.main.master:get()))
end)

main.menu_items.main.hp_armor:set_callback(function()
    hud_state(not (main.menu_items.main.master:get()))
end)

main.menu_items.main.weapon_clip:set_callback(function()
    hud_state(not (main.menu_items.main.master:get()))
end)

main.menu_items.main.roundtime:set_callback(function()
    hud_state(not (main.menu_items.main.master:get()))
end)

main.menu_items.main.chat:set_callback(function()
    hud_state(not (main.menu_items.main.master:get()))
end)

main.menu_items.main.killfeed:set_callback(function()
    hud_state(not (main.menu_items.main.master:get()))
end)



main.menu_items.main.master:set_callback(function()
    hud_state(not (main.menu_items.main.master:get()))
end)

main.menu_items.main.hide_type:set_callback(function()
    hud_state(not (main.menu_items.main.master:get()))
end)

-- menu.visual.main.watermark:set_callback(function()
--  menu.visual.main.logs:visibility(menu.visual.main.watermark:get())
-- end)

events.player_death:set(function(a)
    if entity.get(a.userid, true) == entity.get_local_player() then
        hud_state(not (main.menu_items.main.master:get()))
    end
end)

events.round_start:set(function(a)
    for k,v in pairs(main.trash.killfeed_log) do
        v.time = 0
    end
end)

-- main.menu_items.options.auto_pos:set_callback(function()
--  for k,v in pairs(main.menu_items.trash) do
--      v:visibility(not main.menu_items.options.auto_pos:get())
--  end
-- end)

events.player_spawn:set(function(a)
    if entity.get(a.userid, true) == entity.get_local_player() then
        -- loaded_icons = {}
        -- loaded_icons2 = {}
        for k,v in pairs(main.trash.killfeed_log) do
            v.time = 0
        end
        hud_state(not (main.menu_items.main.master:get()))
    end
end)

events.mouse_input:set(function(e)
    --return not (main.info.menu_state)
    return (stuff.hovered_drag_drop == nil or (not main.info.menu_state))
end)

events.shutdown:set(function()
    hud_state(true)
    common.set_clan_tag(" ")
    menu_items.dt_opt:override(nil)
    menu_items.hs_opt:override(nil)
    db.custom_hud = data
end)

--menu.visual.main.logs:visibility(menu.visual.main.watermark:get())
