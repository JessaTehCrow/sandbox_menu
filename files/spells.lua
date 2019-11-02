ACTION_TYPE_PROJECTILE	= 0
ACTION_TYPE_STATIC_PROJECTILE = 1
ACTION_TYPE_MODIFIER	= 2
ACTION_TYPE_DRAW_MANY	= 3
ACTION_TYPE_MATERIAL	= 4
ACTION_TYPE_OTHER		= 5
ACTION_TYPE_UTILITY		= 6
ACTION_TYPE_PASSIVE		= 7

dofile ( 'data/scripts/gun/gun_actions.lua' )

gun_actions = {}
local names = {
    "projectiles",
    "static",
    "modifier",
    "draw_many",
    "material",
    "other",
    "utility",
    "passive"
}

local function in_list(type)
    for x=0,7
    do
        if type == x then return true end
    end
    return false
end
gun_actions.all = {}
for i,x in ipairs(names)
do
    gun_actions[x] = {}
end

for i,x in ipairs(actions)
do
    local type = x.type
    local has_val = in_list(type)
    if has_val then
        table.insert(gun_actions[names[type+1]],x)
    else
        table.insert(gun_actions.other,x)
    end
    table.insert(gun_actions.all,x)
end

--[[
for spell=0,7
do
    local name = names[spell+1]
    local spells = {}

    for i,x in ipairs(actions)
    do
        local type = x.type
        if type == spell then
            table.insert(spells,x)
        end 
    end
    gun_actions[name] = spells
end
]]--

