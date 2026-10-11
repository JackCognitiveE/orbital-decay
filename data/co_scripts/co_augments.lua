mods.co = {}


local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
--[[
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    if shipManager:HasAugmentation("CO_RAVAGER_ENERSHIELD")>0 then

        local shieldPower = shipManager.shieldSystem.shields.power
        local coShdPw = shieldPower.second
        --print("You could have", coShdPw, "bubbles rn")
        if shieldPower.first > 0 then
            for coEshd = 1, coShdPw do
                shieldPower.first = math.max(0, shieldPower.first - 1)
                shipManager.shieldSystem:AddSuperShield(shipManager.shieldSystem.superUpLoc)
            end
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE, function(shipManager, augName, augValue)
    if augName == "SHIELD_RECHARGE" and shipManager:HasAugmentation("CO_RAVAGER_ENERSHIELD")>0 then
        local shieldPower = shipManager:GetShieldPower()
        augValue = augValue + (shieldPower.second*0.25)
        --print(shieldPower.second)
    end
    return Defines.Chain.CONTINUE, augValue
end, -100)]]

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    if shipManager:HasAugmentation("CO_RAVAGER_PLATING_FORGOTTEN") > 0 then
        local maxHull = Hyperspace.ships(shipManager.iShipId).ship.hullIntegrity.second
        local currentHull = Hyperspace.ships(shipManager.iShipId).ship.hullIntegrity.first
        local hullDif = maxHull - currentHull
        if hullDif == 5 then
            Hyperspace.ships(shipManager.iShipId).ship.hullIntegrity.second = currentHull
        elseif hullDif > 5 then
            Hyperspace.ships(shipManager.iShipId).ship.hullIntegrity.second = maxHull - 5
        end
    end
end)


local function handle_reduction_armor(ship, projectile, location, damage)
    if ship:HasAugmentation("CO_RAVAGER_PLATING_FORGOTTEN") > 0 then
        if damage.iDamage > 1 then
            damage.iDamage = 1
        end
    end
end
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, handle_reduction_armor)
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(ship, projectile, location, damage, realNewTile, beamHitType)
    if beamHitType == Defines.BeamHit.NEW_ROOM then
        handle_reduction_armor(ship, projectile, location, damage)
    end
end)


script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(shipManager)
    if shipManager:HasAugmentation("CO_RAVAGER_MODULE_HUMPBACK") > 0 then
        local startHull = Hyperspace.ships(shipManager.iShipId).ship.hullIntegrity.first
        userdata_table("mods.co.humpbackPerk").startHull = startHull
    end
end)

--[[mods.co.humpbackModules = {}
local humpbackModules = mods.co.humpbackModules
humpbackModules["CO_RAVAGER_MODULE_HUMPBACK"] = {
    dmgRequired = 10,
    dmgUpChance = 0.3
}]]
local function handle_humpback_armor(ship, projectile, location, damage)
    if Hyperspace.ships(1 - ship.iShipId):HasAugmentation("CO_RAVAGER_MODULE_HUMPBACK") > 0 then
        local startHull = userdata_table("mods.co.humpbackPerk").startHull
        local currentHull = ship.hullIntegrity.first
        local hullDif = startHull - currentHull
        
        local dmgUpChance = math.random()
        if dmgUpChance > 0.7 then
            damage.iDamage = damage.iDamage + 1
        end
    end
end