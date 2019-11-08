all_draw_materials = {Solids={}}

--[[
for i,cat in ipairs{"Fires","Solids","Gases","Sands","Liquids"}
do
    local temp = {}
    local mats = getfenv()["CellFactory_GetAll"..cat]()
    table.sort(mats)
    for i,x in ipairs(mats)
    do 
        table.insert(temp,{id=x,name=id_to_name(x)})
    end
    all_materials[cat] = temp
end 
]]

local function id_to_name(id)
    id = id:gsub("_",' ')
    id = id:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
    return id
end

local function check_static(str)
    if string.match(str, "static") then return true else return false end
end

for i,cat in ipairs{"Fires","Solids","Gases","Sands","Liquids"}
do
    local temp = {}
    local mats = getfenv()["CellFactory_GetAll"..cat]()
    table.sort(mats)

    for i,x in ipairs(mats)
    do  
        if cat == "Solids" then
            if check_static(x) then
                table.insert(all_draw_materials.Solids,{id=x,name=id_to_name(x)})
            end
        else
            if check_static(x) then
                table.insert(all_draw_materials.Solids,{id=x,name=id_to_name(x)})
            else
                table.insert(temp,{id=x,name=id_to_name(x)})
            end 
        end
    end
    if cat ~= "Solids" then
        all_draw_materials[cat] = temp
    end
end