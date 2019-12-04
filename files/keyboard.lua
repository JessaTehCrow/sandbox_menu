dofile("data/example_gui/sand_mod.lua")
dofile( "mods/sandbox_menu-"..version.."/files/utils.lua" )

local keyboard = {
    {'q','w','e','r','t','y','u','i','o','p','<--'},
    {'a','s','d','f','g','h','j','k','l'}    ,
    {'z','x','c','v','b','n','m'},
    {"----"}
}
--[[
    GuiLayoutBeginVertical(GUI,1,0)
    if GuiButton(GUI,close,0,'[Close]',spawn_id-1) then
        button_press('Close')
        _GUI_menu = button
        tp = false
    end
    GuiText(GUI,0,30,title)
    GuiLayoutEnd(GUI)
]]
local spawn = 123
local filter = {}
local space = "----"
local back = "<--"
_filter = nil
local function get_text(table)
    if table == nil then return "" end
    local string = ""
    for i,x in ipairs(filter)
    do
        string = string.. x
    end
    return string
end

function filter_clear()
    _filter = nil
    filter = {}
end

_keyboard_test = function()
    _filter = get_text(filter)
    GuiLayoutBeginVertical(_GUI,40,1)
    GuiText(_GUI,0,0,get_text(filter).."_")
    GuiLayoutEnd(_GUI)
    for at=1,#keyboard
    do
        for x=1, #keyboard[at]
        do
            local char = keyboard[at][x]
            GuiLayoutBeginVertical(_GUI,35+(at+x),3+(at*2))
            if GuiButton(_GUI,3,4," "..char.." ",spawn+((at*20)+x)) then
                if char == space then
                    table.insert(filter,' ')
                elseif char == back then
                    filter [#filter] = nil  
                else
                    table.insert(filter,char)
                end
            end 
            GuiLayoutEnd(_GUI)

        end
    end
end