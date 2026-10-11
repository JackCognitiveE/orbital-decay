mods.co = {}

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local is_first_shot = mods.multiverse.is_first_shot
--[[local damage_messages = mods.multiverse.damage_messages
local create_damage_message = mods.multiverse.create_damage_message

do
    local function setup_damage_message(path)
        local messageTex = Hyperspace.Resources:GetImageId(path)
        return Hyperspace.Resources:CreateImagePrimitive(messageTex, -messageTex.width/2, -messageTex.height/2, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false)
    end
    damage_messages.DMG1 = setup_damage_message("numbers/Text_1_L.png")
end]]


local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end


mods.co.luciferTable = {}
local luciferTable = mods.co.luciferTable
luciferTable["CO_ROCKET_LUCIFER"] = {maxShots = 19, power = 3, cDown = 15}

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    if projectile and weapon.blueprint.name == "CO_ROCKET_LUCIFER" or weapon.blueprint.name == "CO_ROCKET_LUCIFER_ARTI" then
        projectile.table.CO_ROCKET_LUCIFER = weapon
        if is_first_shot(weapon, true) then
            userdata_table(weapon, "mods.co.volleyLucifer").count = (userdata_table(weapon, "mods.co.volleyLucifer").count or 0) + 1
        end
        userdata_table(projectile, "mods.co.volleyLucifer").identifier = tostring(weapon) .. tostring(userdata_table(weapon, "mods.co.volleyLucifer").count)
    end

    local overHeatData = nil
    pcall(function() overHeatData = luciferTable[weapon.blueprint.name] end)
    if overHeatData then
        local oHTable = userdata_table(weapon, "mods.luciferTable.shots")
        if oHTable.oHShots then
            oHTable.oHShots = math.max(oHTable.oHShots - 1, 0)
            --print("shots before cooldown: ", oHTable.oHShots)
            if oHTable.oHShots == 0 then
                oHTable.oHShots = nil
                weapon.powered = false
                weapon.requiredPower = 16
                oHTable.oHCDown = overHeatData.cDown
            end
        else
            userdata_table(weapon, "mods.luciferTable.shots").oHShots = overHeatData.maxShots
        end
    end

end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location)
    if projectile and projectile.extend.name == "CO_ROCKET_LUCIFER" or projectile.extend.name == "CO_ROCKET_LUCIFER_ARTI" then
        local weapon = projectile.table.CO_ROCKET_LUCIFER
        local ship_volleyLucifer_table = userdata_table(ship, "mods.co.volleyLucifer")
        local identifier = userdata_table(projectile, "mods.co.volleyLucifer").identifier
        ship_volleyLucifer_table[identifier] = (ship_volleyLucifer_table[identifier] or 0) + 1
        --print("hits in volley", ship_volleyLucifer_table[identifier])
        if ship_volleyLucifer_table[identifier] % 2 == 0 then
            --[[projectile.damage.iDamage = projectile.damage.iDamage + 1]]
            local roomId = get_room_at_location(ship, location, true)
            ship:DamageHull(1, true)
            ship:GetSystemInRoom(roomId):AddDamage(1)
            --create_damage_message(ship.iShipId, damage_messages.DMG1, location.x, location.y)
        end
        if ship_volleyLucifer_table[identifier] == 4 then
            ship_volleyLucifer_table[identifier] = 0
            local overHeatData = nil
            pcall(function() overHeatData = luciferTable[weapon.blueprint.name] end)
            if overHeatData then
                local oHTable = userdata_table(weapon, "mods.luciferTable.shots")
                if oHTable.oHShots then
                    oHTable.oHShots = math.max(oHTable.oHShots + 2, 0)
                    --print("0.5 charges restored")
                    --print("shots before cooldown: ", oHTable.oHShots)
                end
            end
        end
    end
end)


script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    local weaponData = nil
    for weapon in vter(shipManager:GetWeaponList()) do
        pcall(function() weaponData = luciferTable[weapon.blueprint.name] end)
        if weaponData then
            local oHTable = userdata_table(weapon, "mods.luciferTable.shots")
            if oHTable.oHCDown then
                oHTable.oHCDown = math.max(oHTable.oHCDown - Hyperspace.FPS.SpeedFactor/16, 0)
                if oHTable.oHCDown == 0 then
                    oHTable.oHCDown = nil
                    weapon.requiredPower = weaponData.power
                    weapon.powered = true
                else
                    weapon.powered = false
                end
            end
        end
    end
end)


script.on_internal_event(Defines.InternalEvents.WEAPON_RENDERBOX, function(weapon, cooldown, maxCooldown, chargeString, damageString, shotLimitString)
    if weapon.blueprint.name == "CO_ROCKET_LUCIFER" then
        local first, second = chargeString:match("([%d%.]+)%s*/%s*([%d%.]+)")
        local third, fourth = chargeString:match("([%d%.]+)%s*/%s*([%d%.]+)")
        fourth = 5
        local overHeatData = nil
        pcall(function() overHeatData = luciferTable[weapon.blueprint.name] end)
        if overHeatData then
            local oHTable = userdata_table(weapon, "mods.luciferTable.shots")
            if oHTable.oHShots then
                third = oHTable.oHShots / 4
                chargeString = string.format("%.1f/%.1f", first, second) .. string.format(" | %.2f/%.0f", third, fourth):gsub(".00", ""):gsub("50", "5")
            end
        end
    end
    return Defines.Chain.CONTINUE, chargeString, damageString, shotLimitString
end)