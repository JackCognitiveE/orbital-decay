mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local is_first_shot = mods.multiverse.is_first_shot


--[[
local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end]]


local function get_random_point_in_radius(center, radius)
    local r = radius * math.sqrt(math.random())
    local theta = math.random() * 2 * math.pi
    return Hyperspace.Pointf(center.x + r * math.cos(theta), center.y + r * math.sin(theta))
end


mods.co.hitChargedPerks = {}
local hitChargedPerks = mods.co.hitChargedPerks
hitChargedPerks["CO_RAIL_ADAPTER"] = {
    initialize = {pState = 0, countPerkShot = true},
    maxHits = 2,
    pUse = 1,
    pAdd = 1,
    countFirst = true,
    countFirstPerkless = true
}
hitChargedPerks["CO_RAIL_CHARON"] = {
    initialize = {pState = 0, countPerkShot = false},
    maxHits = 2,
    pUse = 1,
    pAdd = 1,
    countFirst = false,
    countFirstPerkless = true,
    blueprint = Hyperspace.Blueprints:GetWeaponBlueprint("CO_RAIL_CHARON_PERK")
}
hitChargedPerks["CO_RAIL_THYRSUS"] = {
    initialize = {pState = 3, countPerkShot = false},
    maxHits = 4,
    pUse = 1,
    pAdd = 0.5,
    countFirst = true,
    countFirstPerkless = true
}
hitChargedPerks["CO_RAIL_KAIJU"] = {
    initialize = {pState = 0, countPerkShot = false},
    maxHits = 12,
    pUse = 1,
    pAdd = 1,
    countFirst = true,
    countFirstPerkless = true
}

local function reset_hitChargedPerks(weapon)
    local perk = hitChargedPerks[weapon.blueprint.name]
    if perk then
        userdata_table(weapon, "mods.co.hitChargeData").stateData = {}
        for varName, value in pairs(perk.initialize) do
            userdata_table(weapon, "mods.co.hitChargeData").stateData[varName] = value
        end
    end
end

script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(shipManager)
    for weapon in vter(shipManager:GetWeaponList()) do
        reset_hitChargedPerks(weapon)
    end
end)
script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local weapBL = weapon.blueprint.name
    local perk = hitChargedPerks[weapBL]
    if perk then
        local perkData = userdata_table(weapon, "mods.co.hitChargeData") and userdata_table(weapon, "mods.co.hitChargeData").stateData
        if perkData.countFirst then -- and perkData.pState < perk.pUse
            if is_first_shot(weapon, true) then
                userdata_table(weapon, "mods.co.volley").count = (userdata_table(weapon, "mods.co.volley").count or 0) + 1
            end
        end
        local shotNumber = weapon.blueprint.shots - weapon.queuedProjectiles:size()
        userdata_table(projectile, "mods.co.volley").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volley").count)
        userdata_table(projectile, "mods.co.volley").shotNumber = shotNumber
        if perkData.pState >= perk.pUse then
            if weapon.blueprint.name == "CO_RAIL_CHARON" then
                projectile:Kill()
                local spaceManager = Hyperspace.App.world.space
                local charonProj = spaceManager:CreateLaserBlast(
                perk.blueprint, projectile.position, projectile.currentSpace, projectile.ownerId,
                projectile.target, projectile.destinationSpace, projectile.heading)
                charonProj.entryAngle = projectile.entryAngle
                perkData.pState = perkData.pState - perk.pUse
                --perkData.countPerkShot = false
                print(tostring(weapBL).." current perk state"..tostring(perkData.pState))
            elseif weapon.blueprint.name == "CO_RAIL_THYRSUS" then
                weapon.weaponVisual:SetFireTime(0.00001)
                projectile.damage.iShieldPiercing = projectile.damage.iShieldPiercing + 1
                projectile.damage.iSystemDamage = projectile.damage.iSystemDamage + 1
                projectile.damage.iPersDamage = projectile.damage.iPersDamage + 1
                if shotNumber == perk.maxHits then
                    perkData.pState = perkData.pState - perk.pUse
                    --perkData.countPerkShot = false
                    weapon.weaponVisual:SetFireTime(0.125)
                    print(tostring(weapBL).." current perk state"..tostring(perkData.pState))
                end
            end
        end
        if weapon.powered == false then
            reset_hitChargedPerks(weapon)
            print(tostring(weapBL).."perk charge reset")
        end
        projectile.table.weapBL = weapon
    end
end)


script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location, damage, shipFriendlyFire)
    local weapBL = projectile.extend.name
    local perk = hitChargedPerks[weapBL]
    if perk then
        local weapon = projectile.table.weapBL
        local perkData = userdata_table(weapon, "mods.co.hitChargeData") and userdata_table(weapon, "mods.co.hitChargeData").stateData
        local ship_volley_table = userdata_table(shipManager, "mods.co.volley")
        local identifier = userdata_table(projectile, "mods.co.volley").identifier
        --local shotNumber = userdata_table(projectile, "mods.co.volley").shotNumber
        ship_volley_table[identifier] = (ship_volley_table[identifier] or 0) + 1
        print("hits in volley", ship_volley_table[identifier])
        if ship_volley_table[identifier] == perk.maxHits and perkData.pState < perk.pUse then -- and ship_volley_table[identifier] == shotNumber
            if perk.initialize.countPerkShot then
                perkData.pState = perkData.pState + perk.pAdd
                print(tostring(weapBL).." perk charged to "..tostring(perkData.pState))
            else
                if perk.countFirstPerkless then
                    if perkData.countPerkShot then
                        perkData.pState = perkData.pState + perk.pAdd
                        print(tostring(weapBL).." perk charged to "..tostring(perkData.pState))
                    else
                        perkData.countPerkShot = true
                    end
                end
            end
            ship_volley_table[identifier] = 0
            --[[]]
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(shipManager, projectile, location, damage, shipFriendlyFire)
    local weapBL = projectile.extend.name
    local perk = hitChargedPerks[weapBL]
    if perk then
        local weapon = projectile.table.weapBL
        local perkData = userdata_table(weapon, "mods.co.hitChargeData") and userdata_table(weapon, "mods.co.hitChargeData").stateData
        local ship_volley_table = userdata_table(shipManager, "mods.co.volley")
        local identifier = userdata_table(projectile, "mods.co.volley").identifier
        local shotNumber = userdata_table(projectile, "mods.co.volley").shotNumber
        if ship_volley_table[identifier] % 3 == 2 and ship_volley_table[identifier] == shotNumber - 1 and perkData.pState >= perk.pUse then -- 
            if projectile and weapBL == "CO_RAIL_ADAPTER" then
                damage.iDamage = damage.iDamage + 1
                perkData.pState = perkData.pState - perk.pUse
                ship_volley_table[identifier] = 0
                print(tostring(weapBL).." current perk state"..tostring(perkData.pState))
            elseif projectile and weapBL == "CO_RAIL_KAIJU" then
                damage.iDamage = damage.iDamage + 1
                if shotNumber == perk.maxHits then
                    perkData.pState = perkData.pState - perk.pUse
                    ship_volley_table[identifier] = 0
                    print(tostring(weapBL).." current perk state"..tostring(perkData.pState))
                end
            end
        end
    end
end)


local function weapon_center(weapon, offsetX, offsetY)
    local emitPointX = 0
    local emitPointY = 0
    local rotate = false
    local mirror = false
    local vertMod = 1
    if weapon then
        rotate = weapon.mount.rotate
        mirror = weapon.mount.mirror
        if mirror then vertMod = -1 end
        
        -- Calculate weapon coodinates
        local weaponAnim = weapon.weaponVisual
        local ship = Hyperspace.ships(weapon.iShipId).ship
        local shipGraph = Hyperspace.ShipGraph.GetShipInfo(weapon.iShipId)
        local slideOffset = weaponAnim:GetSlide()
        emitPointX = emitPointX + ship.shipImage.x + shipGraph.shipBox.x + weaponAnim.renderPoint.x + slideOffset.x
        emitPointY = emitPointY + ship.shipImage.y + shipGraph.shipBox.y + weaponAnim.renderPoint.y + slideOffset.y

        -- Add emitter and mount point offset
        if rotate then
            emitPointX = emitPointX - offsetY + weaponAnim.mountPoint.y
            emitPointY = emitPointY + (offsetX - weaponAnim.mountPoint.x)*vertMod
        else
            emitPointX = emitPointX + (offsetX - weaponAnim.mountPoint.x)*vertMod
            emitPointY = emitPointY + offsetY - weaponAnim.mountPoint.y
        end
        return Hyperspace.Pointf(emitPointX, emitPointY)
    end
    return 0
end


mods.co.statChargers = {}
local statChargers = mods.co.statChargers
statChargers["CO_RAIL_ASTREAUS"] = {{damageType = "iDamage"}, {damageType = "breachChance"}, {damageType = "iShieldPiercing"}}
statChargers["CO_EMITTER_ASSEMBLER"] = {{damageType = "iDamage"}, {damageType = "fireChance"}}

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local statBoosts = statChargers[weapon and weapon.blueprint and weapon.blueprint.name]
    if statBoosts then
        local boost = weapon.queuedProjectiles:size()
        weapon.queuedProjectiles:clear() -- Delete all other projectiles
        for _, statBoost in ipairs(statBoosts) do -- Apply all damageType boosts
            if weapon.blueprint.name == "CO_RAIL_ASTREAUS" then
                projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod + 10 * boost
                if statBoost.calc then
                    projectile.damage[statBoost.damageType] = statBoost.calc(0.67 * boost, projectile.damage[statBoost.damageType])
                else
                    projectile.damage[statBoost.damageType] = 0.67 * boost + projectile.damage[statBoost.damageType]
                end
            end
            if weapon.blueprint.name == "CO_EMITTER_ASSEMBLER" then
                if statBoost.calc then
                    projectile.damage[statBoost.damageType] = statBoost.calc(1 + boost, projectile.damage[statBoost.damageType])
                else
                    projectile.damage[statBoost.damageType] = 1 + boost + projectile.damage[statBoost.damageType]
                end
                projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod + 15 * boost
                projectile.speed_magnitude = projectile.speed_magnitude + projectile.speed_magnitude * boost * 0.5
                projectile.target = get_random_point_in_radius(projectile.target, 50 - 10 * boost)
            end
        end
    end
end)


mods.co.cooldownChargers = {}
local cooldownChargers = mods.co.cooldownChargers
cooldownChargers["CO_RAIL_ASTREAUS"] = 2
cooldownChargers["CO_EMITTER_ASSEMBLER"] = 1.5

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
    local weapons = ship and ship.weaponSystem and ship.weaponSystem.weapons
    if weapons then
        for weapon in vter(weapons) do
            if weapon.chargeLevel ~= 0 and weapon.chargeLevel < weapon.weaponVisual.iChargeLevels then
                local cdBoost = cooldownChargers[weapon and weapon.blueprint and weapon.blueprint.name]
                if cdBoost then
                    local cdLast = userdata_table(weapon, "mods.co.weaponStuff").cdLast
                    if cdLast and weapon.cooldown.first > cdLast then
                        local chargeUpdate = weapon.cooldown.first - cdLast
                        local chargeNew = weapon.cooldown.first - chargeUpdate + cdBoost^weapon.chargeLevel*chargeUpdate
                        if chargeNew >= weapon.cooldown.second then
                            weapon.chargeLevel = weapon.chargeLevel + 1
                            if weapon.chargeLevel == weapon.weaponVisual.iChargeLevels then
                                --print(weapon.chargeLevel, "weapon is fully charged")
                                weapon.cooldown.first = weapon.cooldown.second
                                if weapon.blueprint.name == "CO_RAIL_ASTREAUS" then
                                    Hyperspace.Sounds:PlaySoundMix("co_charon_shot", -1, false)
                                    ship:DamageHull(1, true)
                                    ship:GetSystem(3):AddDamage(1)
                                    if Hyperspace.ships.enemy then
                                        local spaceManager = Hyperspace.App.world.space
                                        local otherShip = Hyperspace.ships(1 - ship.iShipId)
                                        local target = otherShip:GetRandomRoomCenter()
                                        local astreausShot = spaceManager:CreateLaserBlast(
                                            Hyperspace.Blueprints:GetWeaponBlueprint("CO_RAIL_ASTREAUS"),
                                            weapon_center(weapon, 42, -32), -- -14, 28
                                            ship.iShipId,
                                            ship.iShipId,
                                            target,
                                            otherShip.iShipId,
                                            0
                                        )
                                        astreausShot.damage.iDamage = 4
                                        astreausShot.damage.breachChance = 4
                                        astreausShot.damage.iShieldPiercing = 4
                                    end
                                    weapon.chargeLevel = 0
                                    weapon.cooldown.first = 0
                                end
                                if weapon.blueprint.name == "CO_EMITTER_ASSEMBLER" then
                                    Hyperspace.Sounds:PlaySoundMix("co_trigger_shot", -1, false)
                                    weapon.chargeLevel = 0
                                    weapon.cooldown.first = 0
                                    local roomWeapons = ship:GetSystemRoom(3)
                                    ship:StartFire(roomWeapons)
                                end
                            else
                                --print(weapon.chargeLevel, "charges are charged")
                                weapon.cooldown.first = 0
                            end
                        else
                            weapon.cooldown.first = chargeNew
                        end
                    end
                    userdata_table(weapon, "mods.co.weaponStuff").cdLast = weapon.cooldown.first
                end
            end
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.WEAPON_RENDERBOX, function(weapon, cooldown, maxCooldown, chargeString, damageString, shotLimitString)
    local chargerBoost = cooldownChargers[weapon and weapon.blueprint and weapon.blueprint.name]
    if chargerBoost then
        local first, second = chargeString:match("([%d%.]+)%s*/%s*([%d%.]+)")
        local boostLevel = math.min(weapon.chargeLevel, weapon.weaponVisual.iChargeLevels - 1)
        first = first / chargerBoost ^ boostLevel
        second = second / chargerBoost ^ boostLevel
        chargeString = string.format("%.1f/%.1f", first, second)
    end
    return Defines.Chain.CONTINUE, chargeString, damageString, shotLimitString
end)
