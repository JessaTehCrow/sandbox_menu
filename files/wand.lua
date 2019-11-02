dofile('data/scripts/gun/procedural/gun_utilities.lua')
dofile("data/scripts/gun/procedural/gun_procedural.lua")

function get_info(wand)
    return {
        actions_per_round =         wand.actions_per_round          or  0.1,
        reload_time =               wand.reload_time                or  0,
        shuffle_deck_when_empty =   wand.shuffle_deck_when_empty    or  0,
        deck_capacity =             wand.deck_capacity              or  1,
        max_charged_actions =       wand.max_charged_actions        or  5,
        mana_max =                  wand.mana_max                   or  200,
        mana_charge_speed =         wand.mana_charge_speed          or  50,
        speed_multiplier =          wand.speed_multiplier           or  1,
        always_cast =               wand.always_cast                or  0,
        fire_rate_wait =            wand.fire_rate_wait             or  2,
        spread_degrees =            wand.spread_degrees             or  0
    }
end

function gen_wand(wand)
    local x,y = get_player_coords()
    local entity = EntityLoad("files/wand_empty.xml",x,y)
    local ability = EntityGetFirstComponent( entity, "AbilityComponent" )
    local wand_info = get_info(wand)
    wand_info.name = "Custom"

    ComponentSetValue( ability, "ui_name", wand_info.name )
	ComponentObjectSetValue( ability, "gun_config", "actions_per_round", wand_info.actions_per_round )
	ComponentObjectSetValue( ability, "gun_config", "reload_time", wand_info.reload_time )
	ComponentObjectSetValue( ability, "gun_config", "deck_capacity", wand_info.deck_capacity )
	ComponentObjectSetValue( ability, "gun_config", "shuffle_deck_when_empty", wand_info.shuffle_deck_when_empty )
	ComponentObjectSetValue( ability, "gunaction_config", "fire_rate_wait", wand_info.fire_rate_wait )
	ComponentObjectSetValue( ability, "gunaction_config", "spread_degrees", wand_info.spread_degrees )
	ComponentObjectSetValue( ability, "gunaction_config", "speed_multiplier", wand_info.speed_multiplier )
	ComponentSetValue( ability, "mana_charge_speed", wand_info.mana_charge_speed)
	ComponentSetValue( ability, "mana_max", wand_info.mana_max)
	ComponentSetValue( ability, "mana", wand_info.mana_max)
    ComponentSetValue( ability, "item_recoil_recovery_speed", 15.0 )

    if wand.always_cast then
        AddGunActionPermanent( entity, wand.always_cast )
    end

    local wand = GetWand(wand_info)
    SetWandSprite( entity, ability, wand.file, wand.grip_x, wand.grip_y, (wand.tip_x - wand.grip_x), (wand.tip_y - wand.grip_y) )
end
