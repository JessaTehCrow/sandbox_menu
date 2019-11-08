function get_player_obj()
    return EntityGetWithTag( "player_unit" )[1]
end

function test_player(obj)
    return IsPlayer(get_player_obj())
end


function get_player_data(component,toget)
    local data_components = EntityGetComponent( get_player_obj(), component )
    local output = {}
    if data_components ~= nil then
        for i,data_component in ipairs(data_components) do
            for i,x in ipairs(toget)
            do
                local value = ComponentGetValue(data_component,x)
                output[x] = value
            end 
        end
    end
    return output
end

function get_meta_custom(component,toget)
    local data_components = EntityGetComponent( get_player_obj(), component )
    local output = {}
    if data_components ~= nil then
        for i,data_component in ipairs(data_components) do
            for i,x in ipairs(toget)
            do
                local value = ComponentGetMetaCustom(data_component,x)
                output[x] = value
            end 
        end
    end
    return output
end

function save_location()
    local x,y = get_player_coords()
    local name = "Custom location " .. #saved_custom_locations + 1

    table.insert(saved_custom_locations,{name=name,x=x,y=y,func=teleport})
end

function set_player_data(component,values)
    local data_components = EntityGetComponent( get_player_obj(), component )
    if data_components ~= nil then
        for i,data_component in ipairs(data_components)
        do
            for i,x in ipairs(values)
            do
                ComponentSetValue(data_component,x.var,x.value)
            end
        end
    end
end

function set_player_meta(component,values)
    local data_components = EntityGetComponent( get_player_obj(), component )
    if data_components ~= nil then
        for i,data_component in ipairs(data_components)
        do
            for i,x in ipairs(values)
            do
                ComponentSetMetaCustom(data_component,x.var,x.value)
            end
        end
    end
end

function string_to_bool(var)
    if var == "1" then
        return true
    else
        return false 
    end
end

function test_crouch()
    local crouch = get_player_data("ControlsComponent",{"mButtonDownFire2"})

    return string_to_bool(crouch.mButtonDownFire2)
end

local spawned = false
function spawn_item(item)
    if item.name == "None" then
        return 0
    end
    local x,y = DEBUG_GetMouseWorld()
    if test_crouch() then
        if not spawned then
            EntityLoad(item,x,y)
            spawned = true
        end
    else 
        spawned = false
    end
end 

function emit(material,size)
    local crouch = test_crouch()
    if test_crouch() then
        local x,y = DEBUG_GetMouseWorld()
        local enew = EntityCreateNew()
        EntitySetTransform(enew, x, y)
        EntityAddComponent(enew, "ParticleEmitterComponent", {
            emitted_material_name=material,
            create_real_particles="1",
            lifetime_min="1",
            lifetime_max="1",
            count_min="1",
            count_max="1",
            render_on_grid="1",
            fade_based_on_lifetime="1",
            cosmetic_force_create="0",
            airflow_force="0.251",
            airflow_time="1.01",
            airflow_scale="0.05",
            emission_interval_min_frames="1",
            emission_interval_max_frames="1",
            emit_cosmetic_particles="0",
            image_animation_file="files/draw_".. size ..".png",
            image_animation_speed="1",
            image_animation_loop="0",
            image_animation_raytrace_from_center="1",
            collide_with_gas_and_fire="0",
            set_magic_creation="1",
            is_emitting="1"
        })
    end
end

function get_all_components(component)
    local data_components = EntityGetComponent( get_player_obj(), component )
    if data_components ~= nil  then
        for i,comp in ipairs(data_components)
        do
            local members = ComponentGetMembers(comp)
            for i,x in pairs(members)
            do
                print(i,x)
            end
        end
    end
end

function get_player_coords()
    local player = get_player_obj()
    return EntityGetTransform(player)
end

function spawn_flask(matobj)
    local mat = matobj.id
    local x,y = get_player_coords()
    local flask = EntityLoad('files/flask_empty.xml',x,y)
    AddMaterialInventoryMaterial( flask, mat, 1000 )
end

function teleport(location)
    local x,y = location.x,location.y
    local player = get_player_obj()
    EntitySetTransform(player,x,y)
end 

function merge_tables(tables)
    local temp_table = {}
    for i,x in ipairs(tables)
    do
        for i,t in ipairs(x)
        do
            table.insert(temp_table,t)
        end
    end
    return temp_table
end

function bool_to_onoff(bool)
    if bool then
        return "On"
    else
        return "Off"
    end
end

function bool_to_01(bool)
    if bool then return 1 else return 0 end
end

function heal()
    local player_data = get_player_data("DamageModelComponent",{"hp","max_hp"})
    set_player_data("DamageModelComponent",{
        {var='hp',value=player_data.max_hp},
        {var="is_on_fire",value='0'},
    })
end

function do_usain_bolt(bool)
    local data = get_meta_custom("CharacterPlatformingComponent",{"velocity_max_x","run_velocity"})
    local incr = 4
    if bool then
        set_player_meta("CharacterPlatformingComponent",{
            {var="run_velocity",  value=    tonumber(data.run_velocity) * incr      },
            {var="velocity_max_x",value=  tonumber(data.velocity_max_x) * incr      },
            {var="velocity_min_x",value= (tonumber(data.velocity_max_x) * incr) *-1 },
        })
    else
        set_player_meta("CharacterPlatformingComponent",{
            {var="run_velocity",  value=    tonumber(data.run_velocity) / incr      },
            {var="velocity_max_x",value=  tonumber(data.velocity_max_x) / incr      },
            {var="velocity_min_x",value= (tonumber(data.velocity_max_x) / incr) *-1 },
        })
    end
end

function god_mode()
    -- air_in_lungs="7" 
    -- air_in_lungs_max
    set_player_data("DamageModelComponent",{
        {var='invincibility_frames',value='99999999999999999'},
        {var='air_in_lungs_max',value="9999999999999999"},
        {var='air_in_lungs',value="9999999999999999"}
    })
end

function empty_wand()
    return {
        actions_per_round =         1,
        reload_time =               30,
        shuffle_deck_when_empty =   0,
        deck_capacity =             5,
        max_charged_actions =       5,
        mana_max =                  200,
        mana_charge_speed =         50,
        speed_multiplier =          1,
        always_cast =               nil,
        fire_rate_wait =            15,
        spread_degrees =            0
    }
end

function mortal_mode()
    set_player_data("DamageModelComponent",{
        {var='invincibility_frames',value='60'},
        {var='air_in_lungs_max',value="7"},
        {var='air_in_lungs',value="7"}
    })
end

function infinite_boost()
    set_player_data("CharacterDataComponent",{
        {var="mFlyingTimeLeft",value='3'},
    })
end

function superinv(bool)
    if bool then
        set_player_data("Inventory2Component",{
            {var="full_inventory_slots_y",value="15"},
            {var="full_inventory_slots_x",value="18"}
        })
    else
        set_player_data("Inventory2Component",{
            {var="full_inventory_slots_y",value="1"},
            {var="full_inventory_slots_x",value="16"}
        })
    end
end

function button_press(name)
    _page = 1
    --print('[SPAWN MENU] Button pressed: "[' .. name ..  ']" ')
end

function spawn_spell(obj)
    local x,y = get_player_coords()
    CreateItemActionEntity(obj.id:lower(),x,y)
end

function random_spell()
    local spell_int = Random(1,#gun_actions.all)
    spawn_spell(gun_actions.all[spell_int])
end 

function particle_spawn(obj)
    spawn_entity(obj,0,0,false)
end

function loads_of_gold(k)
    local x,y = get_player_coords()
    local path = 'data/entities/items/pickup/goldnugget.xml'
    for i=1,(k*100)
    do
        EntityLoad(path,x,y-10)
    end

end

function spawn_perk(obj)
    local x,y = get_player_coords()
    perk_spawn(x,y-5,obj.id)
end 

function spawn_entity(obj,offx,offy,particle)
    offx = offx or 20
    offy = offy or 0

    local path = obj.path
    local x,y = get_player_coords()
    if particle ~= false then
        EntityLoad("data/entities/particles/image_emitters/shop_effect.xml",x+offx,y+offy)
    end
    EntityLoad(path,x+offx,y+offy)
end