dofile( "files/utils.lua" )

saved_locations = {
    { normal={ name="Spawn",x=250,y=-100},                east={ name="East Spawn",x=35000,y=-100},        west={ name="West Spawn",x=-35000,y=-100}},
    { normal={ name="Temple",x=8890,y=-250},              east={ name="East Temple",x=43700,y=-250},       west={ name="West Temple",x=-25920,y=-250}},
    { normal={ name="Essence of Earth",x=16120,y=-1830},  east={ name="Essence of Spirits",x=20730,y=13540},  west={ name="Essence of Fire",x=-14000,y=171}},
    { normal={ name="The Vault",x=-9920,y=450}},
    { normal={ name="The Work",x=1140,y=-9805}}
}
saved_custom_locations = {
}

function get_locations(name)
    local out = {}
    for i,x in ipairs(saved_locations)
    do
        local var = x[name]
        if var == nil then var = x.normal end
        out[#out+1] = var
    end
    return out
end
