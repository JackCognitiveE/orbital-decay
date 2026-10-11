mods.co = {}


local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter


local co_aurora_beam = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_AURORA_BEAM")
local co_aurora_beam_enemy = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_AURORA_BEAM_ENEMY")
local co_athena_beam = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_ATHENA_BEAM")
local co_trigger_beam = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_TRIGGER_BEAM")
local co_destructor_beam = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_DESTRUCTOR_BEAM")

local coBurstsToBeams = {}
coBurstsToBeams.CO_PLASMA_AURORA = co_aurora_beam
coBurstsToBeams.CO_PLASMA_AURORA_ENEMY = co_aurora_beam_enemy
coBurstsToBeams.CO_PLASMA_ATHENA = co_athena_beam
coBurstsToBeams.CO_PLASMA_TRIGGER = co_trigger_beam
coBurstsToBeams.CO_PLASMA_DESTRUCTOR = co_destructor_beam


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local beamReplacement = coBurstsToBeams[weapon.blueprint.name]
    if beamReplacement then
        local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
        local projDesSp = projectile.destinationSpace
        local coBeam = spaceManager:CreateBeam(
            beamReplacement, projectile.position, projectile.currentSpace, projectile.ownerId,
            projectile.target, Hyperspace.Pointf(projectile.target.x, projectile.target.y + 1),
            projectile.destinationSpace, 1, projectile.heading)
        coBeam.sub_start.x = 500*math.cos(projectile.entryAngle)
        coBeam.sub_start.y = 500*math.sin(projectile.entryAngle)
        coBeam.entryAngle = projectile.entryAngle
        local shipManager = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
        projectile:Kill()
    end
end)


mods.co.coTriggerLikeShoot = {}
local coTriggerLikeShoot = mods.co.coTriggerLikeShoot
coTriggerLikeShoot["CO_PLASMA_TRIGGER"] = {maxShots = 49, pState = true}
coTriggerLikeShoot["CO_PLASMA_DESTRUCTOR"] = {maxShots = 49, pState = true}
coTriggerLikeShoot["CO_PLASMA_ATHENA"] = {maxShots = 7, pState = true}


script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local coPerkCharge = nil
    pcall(function() coPerkCharge = coTriggerLikeShoot[weapon.blueprint.name] end)
    if coPerkCharge then
        local perkDataTable = userdata_table(weapon, "mods.coTrigger.shots")
        if perkDataTable.pChargeProgress then
            local ship = Hyperspace.Global.GetInstance():GetShipManager(projectile.ownerId)
            local projDesSp = projectile.destinationSpace
            perkDataTable.pChargeProgress = math.max(perkDataTable.pChargeProgress - 1, 0)

            local trigger = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_TRIGGER_BOOM")
            local coTriggerPerk = {}
            coTriggerPerk.CO_PLASMA_TRIGGER = trigger
            local triggerProjReplacement = coTriggerPerk[weapon.blueprint.name]
            local destructor = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_DESTRUCTOR_BOOM")
            local coDestructorPerk = {}
            coDestructorPerk.CO_PLASMA_DESTRUCTOR = destructor
            local destructorProjReplacement = coDestructorPerk[weapon.blueprint.name]
            local athena = Hyperspace.Blueprints:GetWeaponBlueprint("CO_PLASMA_ATHENA_BOOM")
            local coAthenaPerk = {}
            coAthenaPerk.CO_PLASMA_ATHENA = athena
            local athenaProjReplacement = coAthenaPerk[weapon.blueprint.name]

            if perkDataTable.pChargeProgress == 44 then
                if triggerProjReplacement then
                    Hyperspace.Sounds:PlaySoundMix('co_trigger_long', -1, false)
                elseif destructorProjReplacement then
                    Hyperspace.Sounds:PlaySoundMix('co_destructor_long', -1, false)
                end

            elseif perkDataTable.pChargeProgress == 0 then
                perkDataTable.pChargeProgress = nil

                if triggerProjReplacement then
                    Hyperspace.Sounds:PlaySoundMix('co_trigger_shot', -1, false)
                    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                    local coBeam = spaceManager:CreateBeam(
                        triggerProjReplacement, projectile.position, projectile.currentSpace, projectile.ownerId, projectile.target, Hyperspace.Pointf(projectile.target.x, projectile.target.y + 1), projDesSp, 1, projectile.heading)
                    coBeam.sub_start.x = 500*math.cos(projectile.entryAngle)
                    coBeam.sub_start.y = 500*math.sin(projectile.entryAngle)
                    coBeam.entryAngle = projectile.entryAngle
                    projectile:Kill()
                elseif destructorProjReplacement then
                    Hyperspace.Sounds:PlaySoundMix('co_destructor_shot', -1, false)
                    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                    local coBeam = spaceManager:CreateBeam(
                        destructorProjReplacement, projectile.position, projectile.currentSpace, projectile.ownerId, projectile.target, Hyperspace.Pointf(projectile.target.x, projectile.target.y + 1), projDesSp, 1, projectile.heading)
                    coBeam.sub_start.x = 500*math.cos(projectile.entryAngle)
                    coBeam.sub_start.y = 500*math.sin(projectile.entryAngle)
                    coBeam.entryAngle = projectile.entryAngle
                    projectile:Kill()
                elseif athenaProjReplacement then
                    Hyperspace.Sounds:PlaySoundMix('co_athena_shot', -1, false)
                    local spaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
                    local coBeam = spaceManager:CreateBeam(
                        athenaProjReplacement, projectile.position, projectile.currentSpace, projectile.ownerId, projectile.target, Hyperspace.Pointf(projectile.target.x, projectile.target.y + 1), projDesSp, 1, projectile.heading)
                    coBeam.sub_start.x = 500*math.cos(projectile.entryAngle)
                    coBeam.sub_start.y = 500*math.sin(projectile.entryAngle)
                    coBeam.entryAngle = projectile.entryAngle
                    projectile:Kill()
                end
            elseif weapon.powered == false then
                perkDataTable.pChargeProgress = nil
            end
        else
            userdata_table(weapon, "mods.coTrigger.shots").pChargeProgress = coPerkCharge.maxShots
        end
    end
end)


mods.co.athenaEPRST = {}
local athenaEPRST = mods.co.athenaEPRST
athenaEPRST["CO_PLASMA_ATHENA"] = {maxShots = 31, power = 3, cDown = 12.5}

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local overHeatData = nil
    pcall(function() overHeatData = athenaEPRST[weapon.blueprint.name] end)
    if overHeatData then
        local oHTable = userdata_table(weapon, "mods.athenaEPRST.shots")
        if oHTable.oHShots then
            oHTable.oHShots = math.max(oHTable.oHShots - 1, 0)
            if oHTable.oHShots == 0 then
                oHTable.oHShots = nil
                weapon.powered = false
                weapon.requiredPower = 16
                oHTable.oHCDown = overHeatData.cDown
            end
        else
            userdata_table(weapon, "mods.athenaEPRST.shots").oHShots = overHeatData.maxShots
        end
    end
end)
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    local weaponData = nil
    for weapon in vter(shipManager:GetWeaponList()) do
        pcall(function() weaponData = athenaEPRST[weapon.blueprint.name] end)
        if weaponData then
            local oHTable = userdata_table(weapon, "mods.athenaEPRST.shots")
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


script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(shipManager)
    local triggerWeaponData = nil
    local athenaWeaponData = nil
    for weapon in vter(shipManager:GetWeaponList()) do
        pcall(function() triggerWeaponData = coTriggerLikeShoot[weapon.blueprint.name] end)
        if triggerWeaponData then
            local perkDataTable = userdata_table(weapon, "mods.coTrigger.shots")
            if perkDataTable.pChargeProgress then
                perkDataTable.pChargeProgress = nil
            end
        end
        pcall(function() athenaWeaponData = athenaEPRST[weapon.blueprint.name] end)
        if athenaWeaponData then
            local perkDataTable = userdata_table(weapon, "mods.athenaEPRST.shots")
            if perkDataTable.pChargeProgress then
                perkDataTable.pChargeProgress = nil
            end
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    local triggerWeaponData = nil
    local athenaWeaponData = nil
    for weapon in vter(shipManager:GetWeaponList()) do
        pcall(function() triggerWeaponData = coTriggerLikeShoot[weapon.blueprint.name] end)
        if triggerWeaponData then
            local perkDataTable = userdata_table(weapon, "mods.coTrigger.shots")
            if perkDataTable.pChargeProgress then
                if weapon.powered == false then
                    perkDataTable.pChargeProgress = nil
                end
            end
        end
        pcall(function() athenaWeaponData = athenaEPRST[weapon.blueprint.name] end)
        if athenaWeaponData then
            local perkDataTable = userdata_table(weapon, "mods.athenaEPRST.shots")
            if perkDataTable.pChargeProgress then
                perkDataTable.pChargeProgress = nil
            end
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.WEAPON_RENDERBOX, function(weapon, cooldown, maxCooldown, chargeString, damageString, shotLimitString)
    if weapon.blueprint.name == "CO_PLASMA_ATHENA" then
        local first, second = chargeString:match("([%d%.]+)%s*/%s*([%d%.]+)")
        local third, fourth = chargeString:match("([%d%.]+)%s*/%s*([%d%.]+)")
        fourth = 4
        local overHeatData = nil
        pcall(function() overHeatData = athenaEPRST[weapon.blueprint.name] end)
        if overHeatData then
            local oHTable = userdata_table(weapon, "mods.athenaEPRST.shots")
            if oHTable.oHShots then
                third = oHTable.oHShots // 8
                chargeString = string.format("%.1f/%.1f", first, second) .. string.format(" | %.0f/%.0f", third, fourth)
            end
        else
            --chargeString = string.format("%.1f/%.1f | %.2f/%.0f", first, second, fourth, fourth)
        end
    end
    return Defines.Chain.CONTINUE, chargeString, damageString, shotLimitString
end)