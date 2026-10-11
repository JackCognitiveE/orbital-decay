
local added = false
script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
	if (not mods.og) or added then return end
	added = true
	local turretBlueprintsList = mods.og.turretBlueprintsList
	table.insert(turretBlueprintsList, "OG_TURRET_RAIL_KAIJU")
	table.insert(turretBlueprintsList, "OG_TURRET_RAIL_THYRSUS")
	table.insert(turretBlueprintsList, "OG_TURRET_PLASMA_ATHENA")
	table.insert(turretBlueprintsList, "OG_TURRET_XBOW_ARTEMIS")

	local defence_types = mods.og.defence_types
	local chain_types = mods.og.chain_types

	local turrets = mods.og.turrets
	
	turrets["OG_TURRET_RAIL_THYRSUS"] = {
		enemy_burst = 4,
		aim_cone = 1,
		shot_radius = 2,
		image = "turret_rail_thyrsus_firing",
		multi_anim = 4,
		glow = "turret_rail_thyrsus_charging_glow",
		autofire = {offence = true, defence = true},
		charge_image = Hyperspace.Resources:CreateImagePrimitiveString( "weapons_og/turret_rail_thyrsus_charge.png", -102, -102, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),
		fire_points = {{x = -24, y = -90, fire_delay = 0.125}, {x = 25, y = -90, fire_delay = 0.125}},
		defence_type = defence_types.DRONES_PROJECTILES,
		blueprint_type = 1,
		blueprint = "CO_RAIL_THYRSUS",
		charges = 4,
		charges_per_charge = 4,
		rotation_speed = 180,
		charge_time = {[0] = 5, 5, 4.7, 4.4, 4.1, 3.9, 3.7, 3.6, 3.5},
	}
	turrets["OG_TURRET_RAIL_KAIJU"] = {
		enemy_burst = 8,
		aim_cone = 1,
		shot_radius = 2,
		image = "turret_rail_kaiju_firing",
		glow = "turret_rail_kaiju_charging_glow",
		autofire = {offence = true, defence = true},
		custom_animations = {
			turret_rail_kaiju_heatup = {charging = true, looping = false},
			turret_rail_kaiju_charging = {charging = true, charged = true, looping = true},
		},
		fire_points = {{x = 0, y = -88, fire_delay = 0.095}},
		defence_type = defence_types.DRONES,
		blueprint_type = 1,
		blueprint = "CO_RAIL_KAIJU",
		charges = 15,
		charges_per_charge = 2,
		rotation_speed = 40,
		charge_time = {[0] = 3, 3, 2.75, 2.5, 2.25, 2, 1.8, 1.6, 1.5},
		--enemy_charge_time = {[0] = 3, 3, 2.8, 2.6, 2.4, 2.2, 2, 1.85, 1.7},
	}
	turrets["OG_TURRET_PLASMA_ATHENA"] = {
		enemy_burst = 8,
		aim_cone = 0.1,
		shot_radius = 2,
		hold_time = 0.5,
		speed_reduction = 0.5,
		autofire = {offence = true, defence = false},
		image = "turret_plasma_athena_firing",
		charging_anim = "turret_plasma_athena_charging",
		glow = "turret_plasma_athena_charging_glow",
		--charge_image = Hyperspace.Resources:CreateImagePrimitiveString( "weapons_og/turret_plasma_athena_charge.png", -102, -102, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false),
		fire_points = {{x = -0, y = -62, fire_delay = 0.1}},
		defence_type = defence_types.PROJECTILES_MISSILES,
		blueprint_type = 3,
		blueprint = "CO_PLASMA_ATHENA",
		blueprint_fake = "CO_PLASMA_ATHENA_BOOM",
		charges = 8,
		charges_per_charge = 8,
		rotation_speed = 270,
		charge_time = {[0] = 3, 3, 2.75, 2.5, 2.25, 2, 1.8, 1.6, 1.5},
	}
	turrets["OG_TURRET_XBOW_ARTEMIS"] = {
		enemy_burst = 7,
		aim_cone = 1,
		shot_radius = 2,
		image = "turret_xbow_artemis_firing",
		multi_anim = 5,
		charging_anim = "turret_xbow_artemis_charging",
		fire_points = {{x = -0, y = -24, fire_delay = 0.2}},
		defence_type = defence_types.DRONES,
		blueprint_type = 1,
		blueprint = "CO_XBOW_ARTEMIS",
		charges = 7,
		charges_per_charge = 1,
		rotation_speed = 180,
		charge_time = {[0] = 3, 3, 2.75, 2.5, 2.25, 2, 1.8, 1.6, 1.5},
	}

	local craftedCategories = mods.og.craftedCategories


	local craftedOrbitalDecay = {name = "Orbital Decay", id = "CO", items = {}}
	table.insert(craftedCategories, craftedOrbitalDecay)
	table.insert(craftedOrbitalDecay.items, {weapon = "OG_TURRET_RAIL_THYRSUS", match_cost = true, component_amounts = {1}, components = {{"CO_RAIL_THYRSUS"}}} )
	--table.insert(craftedOrbitalDecay, {weapon = "OG_TURRET_RAIL_THYRSUS", match_cost = true, component_amounts = {2}, components = {{"CO_RAIL_ADAPTER", "CO_PLASMA_AURORA"}}} )
	table.insert(craftedOrbitalDecay.items, {weapon = "OG_TURRET_RAIL_KAIJU", match_cost = true, component_amounts = {1}, components = {{"CO_RAIL_KAIJU"}}} )
	--table.insert(craftedOrbitalDecay, {weapon = "OG_TURRET_RAIL_KAIJU", match_cost = true, component_amounts = {2}, components = {{"CO_RAIL_ADAPTER", "CO_RAIL_ASTREAUS"}}} )
	table.insert(craftedOrbitalDecay.items, {weapon = "OG_TURRET_PLASMA_ATHENA", match_cost = false, component_amounts = {1}, components = {{"CO_PLASMA_ATHENA"}}} )
	--table.insert(craftedOrbitalDecay, {weapon = "OG_TURRET_RAIL_KAIJU", match_cost = true, component_amounts = {2}, components = {{"CO_PLASMA_AURORA", "CO_PLASMA_TRIGGER"}}} )
	table.insert(craftedOrbitalDecay.items, {weapon = "OG_TURRET_XBOW_ARTEMIS", match_cost = false, component_amounts = {1}, components = {{"CO_XBOW_ARTEMIS"}}} )
	--table.insert(craftedOrbitalDecay, {weapon = "OG_TURRET_RAIL_KAIJU", match_cost = true, component_amounts = {2}, components = {{"CO_RAIL_ADAPTER", "CO_RAIL_ACARI"}}} )

end)
