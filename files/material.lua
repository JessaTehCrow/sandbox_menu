

local function id_to_name(id)
    id = id:gsub("_",' ')
    id = id:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
    return id
end
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