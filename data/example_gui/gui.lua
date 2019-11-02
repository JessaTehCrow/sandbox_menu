if not async then
    -- guard against multiple inclusion to prevent
    -- loss of async coroutines
    dofile( "data/scripts/lib/coroutines.lua" )
end

--[[
SUGGESTIONS

Infinite flasks
Keyboard filter
Improved infinite spells - which might be game bug


]]

dofile( "data/scripts/lib/utilities.lua" )
dofile( "data/scripts/perks/perk_list.lua")
dofile( "data/scripts/perks/perk.lua")
dofile( "files/utils.lua" )
dofile( "files/mobs.lua" )
dofile( "files/pickup.lua" )
dofile( "files/material.lua" )
dofile( "files/particles.lua" )
dofile( "files/props.lua" )
dofile( "files/projectiles.lua" )
dofile( "files/locations.lua" )
dofile( "files/spells.lua" )
dofile( "files/wand.lua" )

-- Start / setup
local GUI_created = false
local button,menu,wands,orbs,spells,perks,mobs,pickup,cheat_menu,props,locations,wands_saved
local flask_menu,flask_spawn
local godmode,infinite_spells,boost,spell_arr,super_boost = false,false,false,nil,false
local location = 'normal'
local custom_wand = empty_wand()
local wand_arr = {}
local wand_arr_2 = {}

local incr_val = 1
local always_cast = nil

for x=1,6
do
    wand_arr[x] = {path="data/entities/items/wand_level_0".. tostring(x) .. ".xml",name="Level "..tostring(x)}
end

for x=1,#wand_arr
do
    print(wand_arr[x].name)
end

local orb_arr = {}
for x=1,13
do
    local path = 'data/entities/items/orbs/orb_0'
    if x > 9 then
        path = 'data/entities/items/orbs/orb_'
    end
    orb_arr[x] = {path=path..tostring(x)..".xml",name="Orb "..tostring(x)}
end

if not _GUI then
    print("Creating example gui")
    GUI_created = true
    _GUI_menu = nil
    _GUI = GuiCreate()

else
    print("Loading existing gui")
end

local GUI = _GUI
local spawn_id = 342
local prev = nil

-- local functions
local function extra_function(data)
    --GuiLayoutBeginVertical(GUI,1,0)

end

local function grid(title,array,func)
    local collumn_length = 20
    local pages = math.ceil(#array/collumn_length)
    local offset = (_page-1)*collumn_length
    local close = 25

    if title ~= "Options:" then
        GuiLayoutBeginVertical(GUI,1,0)
        if GuiButton(GUI,25,0,'[Back]',spawn_id) then
            button_press('Back')
            _GUI_menu = prev
            prev = menu
        end
        close = 55
        GuiLayoutEnd(GUI)
    end
    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,close,0,'[Close]',spawn_id-1) then
        button_press('Close')
        _GUI_menu = button
    end
    GuiText(GUI,0,30,title)
    GuiLayoutEnd(GUI)

    GuiLayoutBeginVertical(GUI,1,15)
    for x=1,collumn_length
    do
        local obj = array[x+offset]
        if obj == nil then
            break
        end
        if GuiButton(GUI,0,0,obj.name or obj.ui_name,spawn_id + x + offset + 1) then
            if func ~= nil then
                func(obj)
            elseif obj.func ~= nil then
                obj.func(obj)
            end

            if obj.nvar ~= nil then
                _GUI_menu = obj.nvar    
            end
        end
    end
    GuiLayoutEnd(GUI)

    if pages > 1 then
        GuiLayoutBeginVertical(GUI,3,75)
        GuiText(GUI,4,5,tostring(_page).."/"..tostring(pages))
        GuiLayoutEnd(GUI)
    end 

    if _page > 1 then
        GuiLayoutBeginVertical(GUI,1,75)
        if GuiButton(GUI,0,5,"<-",spawn_id+#array + 10) then
            _page = _page - 1
        end
        GuiLayoutEnd(GUI)
    end
    if _page < pages then
        GuiLayoutBeginVertical(GUI,8,75)
        if GuiButton(GUI,0,5,"->",spawn_id+#array+ 11) then
            _page = _page + 1
        end
        GuiLayoutEnd(GUI)
    end 
end

function builder()
    local values = {
        {"Spells per cast","actions_per_round"},
        {"Reload time","reload_time"},
        {"Capacity","deck_capacity"},
        {"Mana max","mana_max"},
        {"Mana regen","mana_charge_speed"},
        {"Speed","speed_multiplier"},
        {"Shoot delay","fire_rate_wait"},
        {"Spread","spread_degrees"},
    }

    GuiLayoutBeginVertical(GUI,1,15)
    for i,x in ipairs(values)
    do
        GuiText(GUI,0,5,x[1])
    end
    GuiLayoutEnd(GUI)

    GuiLayoutBeginVertical(GUI,12,15)
    for i,x in ipairs(values)
    do
        if GuiButton(GUI,0,5,"\\/",spawn_id+1+i) then
            custom_wand[x[2]] = custom_wand[x[2]] - incr_val
        end
    end
    GuiLayoutEnd(GUI)

    GuiLayoutBeginVertical(GUI,15,15)
    for i,x in ipairs(values)
    do
        GuiText(GUI,0,5,tostring( custom_wand[x[2]] ) )
    end
    GuiLayoutEnd(GUI)

    GuiLayoutBeginVertical(GUI,25,15)
    for i,x in ipairs(values)
    do
        if GuiButton(GUI,0,5,"/\\",spawn_id -1 -i) then
            custom_wand[x[2]] = custom_wand[x[2]] + incr_val
        end
    end
    GuiLayoutEnd(GUI)

    GuiLayoutBeginVertical(GUI,1,50)
    local shuffle = false

    if custom_wand.shuffle_deck_when_empty ~= 0 then shuffle = true end

    if GuiButton(GUI,0,5,"Shuffle                    " .. bool_to_onoff(shuffle),999) then
        --custom_wand.shuffle_deck_when_empty = bool_to_01(not shuffle)
        custom_wand.shuffle_deck_when_empty = bool_to_01(not shuffle)
    end
    local cast = 'None'
    if custom_wand.always_cast ~= nil then
        cast = always_cast
    end

    if GuiButton(GUI,0,0,"Always Cast              ".. cast,1000) then
        _GUI_menu = select_spell
    end
    
    GuiLayoutEnd(GUI)

    GuiLayoutBeginVertical(GUI,2,60)
    if GuiButton(GUI,0,0,"[Reset]",-4) then
        custom_wand = empty_wand()
    end
    GuiLayoutEnd(GUI)

    GuiLayoutBeginVertical(GUI,15,60)
    if GuiButton(GUI,0,0,"[Spawn]",-1) then
        gen_wand(custom_wand)
    end
    GuiLayoutEnd(GUI)
end

local function spawn(obj)
    spawn_entity(obj,15,-10)
end

-- buttons / menu functions
button = function()
    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,25,0,'[Open]',spawn_id) then
        button_press('Open')
        _GUI_menu = menu
    end
    GuiLayoutEnd(GUI)
    prev = menu
end

menu = function()
    grid("Options:",{
        {name="-Wands",func=function() _GUI_menu = wands end},
        {name="-Spells",func=function() _GUI_menu = spells end},
        {name="-Perks",func=function() _GUI_menu = perks end},
        {name="-Orbs",func=function() _GUI_menu = orbs end},
        {name="-Mobs",func=function() _GUI_menu = mobs end},
        {name="-Pickups",func=function() _GUI_menu = pickup end},
        {name="-Props",func=function() _GUI_menu = props end},
        {name="-Flasks",func=function() _GUI_menu = flask_menu end},
        {name="-Particles",func=function() _GUI_menu = particles end},
        {name="-Locations",func=function() _GUI_menu = locations end},
        {name="-Cheats",func=function() _GUI_menu = cheat_menu end},
    })
end

spells = function()
    grid("Spells:",{
        {name="Projectiles",func=function() spell_arr = function() grid("Projectiles:",gun_actions.projectiles,spawn_spell)        end _GUI_menu = spell_arr; prev=spells end },
        {name="Static",func=function() spell_arr =  function()grid("Static:",gun_actions.static,spawn_spell)           end _GUI_menu = spell_arr; prev=spells end },
        {name="Modifiers",func=function() spell_arr = function() grid("Modifiers:",gun_actions.modifier,spawn_spell)  end _GUI_menu = spell_arr; prev=spells end },
        {name="Formations",func=function() spell_arr = function() grid("Formations:",gun_actions.draw_many,spawn_spell)  end _GUI_menu = spell_arr; prev=spells end },
        {name="Materials",func=function() spell_arr = function() grid("Materials:",gun_actions.material,spawn_spell)   end  _GUI_menu = spell_arr; prev=spells end },
        {name="Utility",func=function() spell_arr = function() grid("Utility:",gun_actions.utility,spawn_spell)        end _GUI_menu = spell_arr; prev=spells end },
        {name="Passive",func=function() spell_arr = function() grid("Passive:",gun_actions.passive,spawn_spell)        end _GUI_menu = spell_arr; prev=spells end },
        {name="Other",func=function() spell_arr = function() grid("Other:",gun_actions.other,spawn_spell)              end _GUI_menu = spell_arr; prev=spells end },
        {name="Random",func=random_spell},
    })
end

flask_menu = function() 
    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,25,0,'[Back]',spawn_id) then
        button_press('Back')
        _GUI_menu = menu
        prev = menu
    end
    GuiLayoutEnd(GUI)
    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,55,0,'[Close]',spawn_id-1) then
        button_press('Close')
        _GUI_menu = button
    end
    GuiText(GUI,0,30,'Options:')
    if GuiButton(GUI,0,5,"Liquids",spawn_id+1) then
        button_press("Liquids")
        _mat = "Liquids"
        _GUI_menu = flask_spawn
        prev = flask_menu
    end
    if GuiButton(GUI,0,0,"Solids",spawn_id+2) then
        button_press("Solids")
        _mat = "Solids"
        _GUI_menu = flask_spawn
        prev = flask_menu
    end
    if GuiButton(GUI,0,0,"Sands",spawn_id+3) then
        button_press("Sands")
        _mat = "Sands"
        _GUI_menu = flask_spawn
        prev = flask_menu
    end
    if GuiButton(GUI,0,0,"Gases",spawn_id+4) then
        button_press("Gases")
        _mat = "Gases"
        _GUI_menu = flask_spawn
        prev = flask_menu
    end
    if GuiButton(GUI,0,0,"Fires",spawn_id+5) then
        button_press("Fires")
        _mat = "Fires"
        _GUI_menu = flask_spawn
        prev = flask_menu
    end
    GuiLayoutEnd(GUI)
end

wand_build = function()
    local nums = {
        0.1,
        1,
        10,
        100,
        1000
    }

    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,25,0,'[Back]',spawn_id-31) then
        button_press('Back')
        _GUI_menu = prev
        prev = menu
    end
    GuiLayoutEnd(GUI)
    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,55,0,'[Close]',spawn_id-30) then
        button_press('Close')
        _GUI_menu = button
    end
    GuiLayoutEnd(GUI)

    GuiLayoutBeginVertical(GUI,35,15)
    for i,x in ipairs(nums)
    do
        local name = tostring(x)
        if x == incr_val then name = '('.. name .. ')' end
        if GuiButton(GUI,0,5,name,spawn_id - 32 - i) then
            incr_val = x
        end
    end 
    GuiLayoutEnd(GUI)

    builder()
end

orbs = function()
    grid("Orbs:",orb_arr,spawn_entity)
end

wands = function()
    grid("Wands:",{
        {name="Buildin",nvar=wands_saved,func=function() prev = wands end},
        {name="Custom",nvar=wand_build,func=function() prev = wands end}
    })
end

wands_saved = function()
    grid("Wands",wand_arr,spawn_entity)
end

perks = function()
    grid("Perks:",perk_list,spawn_perk)
end

particles = function()
    grid("Particles",all_particles,particle_spawn)
end

mobs = function()
    grid("Mobs:",animals,spawn)
end 

local function set_cast(obj)
    always_cast = obj.id:lower()
    custom_wand.always_cast = always_cast
    _GUI_menu = wand_build
    prev = menu
end

select_spell = function()
    grid("Select:", {
        {name="Projectiles",func=function() spell_arr = function() grid("Projectiles:",gun_actions.projectiles,set_cast)        end _GUI_menu = spell_arr; prev = select_spell end },
        {name="Static",func=function() spell_arr =  function()grid("Static:",gun_actions.static,set_cast)           end _GUI_menu = spell_arr; prev = select_spell end },
        {name="Modifiers",func=function() spell_arr = function() grid("Modifiers:",gun_actions.modifier,set_cast)  end _GUI_menu = spell_arr; prev = select_spell end },
        {name="Formations",func=function() spell_arr = function() grid("Formations:",gun_actions.draw_many,set_cast)  end _GUI_menu = spell_arr; prev = select_spell end },
        {name="Materials",func=function() spell_arr = function() grid("Materials:",gun_actions.material,set_cast)   end  _GUI_menu = spell_arr; prev = select_spell end },
        {name="Utility",func=function() spell_arr = function() grid("Utility:",gun_actions.utility,set_cast)        end _GUI_menu = spell_arr; prev = select_spell end },
        {name="Passive",func=function() spell_arr = function() grid("Passive:",gun_actions.passive,set_cast)        end _GUI_menu = spell_arr; prev = select_spell end },
        {name="Other",func=function() spell_arr = function() grid("Other:",gun_actions.other,set_cast)              end _GUI_menu = spell_arr; prev = select_spell end },
    })
end

flask_spawn = function()
    grid(_mat..":",all_materials[_mat],spawn_flask)
end

props = function()
    grid('Props:',all_props,spawn_entity)
end

pickup = function()
    grid('Pickups:',pickupable,spawn)
end

saved_locations_menu = function()
    grid("Saved locations:",get_locations(location),teleport)
    local west = "(West"
    local normal = "Normal"
    local north = "East)"

    if location == "west" then
        west = "(WEST"
    elseif location == "normal" then
        normal = "NORMAL"
    else
        north = "EAST)"
    end

    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,70,41.5,west,spawn_id-9) then
        location = 'west'
    end 
    GuiLayoutEnd(GUI)
    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,110,41.5,normal,spawn_id-8) then
        location = 'normal'
    end 
    GuiLayoutEnd(GUI)
    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,150,41.5,north,spawn_id-7) then
        location = 'east'
    end 
    GuiLayoutEnd(GUI)
end

custom_locations = function()
    local off = 0
    if #saved_custom_locations > 20 then off = 80 else off = 17 + (#saved_custom_locations * 3) end
    GuiLayoutBeginVertical(GUI,2,off)
    if GuiButton(GUI,0,0,"(Save)",spawn_id-100) then
        save_location()
    end
    GuiLayoutEnd(GUI)
    grid("Custom:",saved_custom_locations,teleport)
end

locations = function()
    grid("Locations:",{
        {name="Saved",nvar=saved_locations_menu,func=function() prev = locations end},
        {name="Custom",nvar=custom_locations,func=function() prev = locations end}
    })
end

cheat_menu = function()
    grid("Cheats:",{
        {name="Godmode (".. bool_to_onoff(godmode) ..")",func=function() godmode = not godmode; if godmode then god_mode() else mortal_mode() end; end},
        {name="Infinite spells (".. bool_to_onoff(infinite_spells) ..")", func= function() infinite_spells = not infinite_spells end},
        {name="Infinite boost (".. bool_to_onoff(boost) ..")",func= function() boost = not boost end},
        {name="Super inventory (".. bool_to_onoff(super_boost) ..")",func=function() super_boost = not super_boost; superinv(super_boost); end},
        {name ="GOLD EVERYTHING",func=function() ConvertEverythingToGold() end},
        {name="500 Gold",func=function() loads_of_gold(0.5) end},
        {name="1K Gold",func=function() loads_of_gold(1) end},
        --{name="testPlayer",func=function() local player = get_player_obj(); local is_player = test_player(player); GamePrint(tostring(is_player)) end}
    })
end

local function cheat()
    if infinite_spells then
        GameRegenItemActionsInPlayer( get_player_obj() )
    end
    if boost then
        infinite_boost(boost)
    end

    if GUI ~= nil then
        GuiStartFrame(GUI)
    end
end 

-- GUI loop
if GUI_created then
    print("Starting example gui loop")
    async_loop(function()

        cheat()
        if _GUI_menu ~= nil then
            local bool,error = pcall(_GUI_menu)
            if not bool then
                print('Example GUI error: ' .. error)
                _GUI_menu = button
            end
        else
            print("ERR: _GUI_menu = nil")
            _GUI_menu = button
        end
        wait(0)
    end)
end