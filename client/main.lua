Framework = exports["d3MBA-lib"]:GetFrameworkObject()
local bl_ui = exports.bl_ui

local printerOnGround = false
local lockedDown = false
local skimmersInstalled = 0
local signingCheck = false

RegisterNetEvent(Config.AtmOpenEvent)
AddEventHandler(Config.AtmOpenEvent, function()
    local atm = getClosestAtm()
    local coords = GetEntityCoords(atm)
    TriggerServerEvent("d4m13n:server:scamming:skimCard", coords)
end)

RegisterNetEvent("d4m13n:client:scamming:signcheck")
AddEventHandler("d4m13n:client:scamming:signcheck", function()
    if(signingCheck==true)then return end
    signingCheck=true
    local successCount = 0
    for i=1, Config.CheckSignatureMinigameCount, 1 do
        local success = bl_ui:Progress(1, 40)
        Citizen.Wait(1000)
        if(success)then
            successCount = successCount + 1
        end
    end
    TriggerServerEvent("d4m13n:server:scamming:signcheck",Config.CheckSignatureQuality[successCount])
    signingCheck=false
end)

RegisterNetEvent("d4m13n:client:scamming:pickup-printer")
AddEventHandler("d4m13n:client:scamming:pickup-printer", function()
    local dict = "anim@heists@ornate_bank@hack"
    local anim = "hack_loop"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    
    local ped = PlayerPedId()
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    Framework.ProgressBar("pickup-printer", "Picking up printer off the ground...", Config.PickupPrinterTime, {movement=true,carMovement=true,mouse=true,combat=true})

    
    
    ClearPedTasks(ped)
	local closestPrinter = 0
    local entityCoords = GetEntityCoords(PlayerPedId())
	closestPrinter = GetClosestObjectOfType(entityCoords, 10.0, GetHashKey(Config.PrinterProp), false, false, false)
    if closestPrinter ~= 0 then
        DeleteEntity(closestPrinter)
        TriggerServerEvent("d4m13n:server:scamming:pickup-printer")
    end
end)
RegisterNetEvent("d4m13n:client:scamming:print-checks")
AddEventHandler("d4m13n:client:scamming:print-checks", function()
    local dict = "anim@heists@ornate_bank@hack"
    local anim = "hack_loop"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    
    local ped = PlayerPedId()
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    Framework.ProgressBar("pickup-printer", "Picking up printer off the ground...", Config.CheckPrintTime, {movement=true,carMovement=true,mouse=true,combat=true})

    
    
    ClearPedTasks(ped)
	local closestPrinter = 0
    local entityCoords = GetEntityCoords(PlayerPedId())
	closestPrinter = GetClosestObjectOfType(entityCoords, 10.0, GetHashKey(Config.PrinterProp), false, false, false)
    if closestPrinter ~= 0 then
        TriggerServerEvent("d4m13n:server:scamming:print-checks")
    end
end)

RegisterNetEvent("d4m13n:client:scamming:place-printer")
AddEventHandler("d4m13n:client:scamming:place-printer", function()
    local dict = "anim@heists@ornate_bank@hack"
    local anim = "hack_loop"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    
    local ped = PlayerPedId()
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    Framework.ProgressBar("place-printer", "Placing printer on the ground...", Config.PlacePrinterTime, {movement=true,carMovement=true,mouse=true,combat=true})

    
    
    ClearPedTasks(ped)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerForwardVector = GetEntityForwardVector(playerPed)
    local spawnCoords = playerCoords + playerForwardVector * 1 -- Adjust the distance as needed
    local propHash = GetHashKey(Config.PrinterProp)
    local propObject = CreateObject(propHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, true)
    PlaceObjectOnGroundProperly(propObject)
    printerOnGround = true
end)

RegisterNetEvent("d4m13n:scamming:client:lockdown")
AddEventHandler("d4m13n:scamming:client:lockdown", function()
    spawnSecurityGuard()
    callPolice()
end)

RegisterNetEvent("d4m13n:skimmer-installed")
AddEventHandler("d4m13n:skimmer-installed", function()
    skimmersInstalled = skimmersInstalled + 1
	ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent("d4m13n:skimmer-uninstalled")
AddEventHandler("d4m13n:skimmer-uninstalled", function()
    skimmersInstalled = skimmersInstalled - 1
	ClearPedTasks(GetPlayerPed(-1))
end)


function setupPrinter()
    local atmOptions = {
        {
            label = "Print Check",
            icon= 'fas fa-credit-card',
            event="d4m13n:client:scamming:print-checks",
        },
        {
            label = "Pickup Printer",
            icon= 'fas fa-hand',
            event="d4m13n:client:scamming:pickup-printer",
        },
    }
	local options= {{
        label = "Pickup Printer",
        icon= 'fas fa-hand',
        event="d4m13n:client:scamming:pickup-printer",
		-- With CanInteract if the player is dead or in a vehicle, it will return false and he will not be able to open the atm even if he has the item
		canInteract = function(entity) 
			return not isDead and not IsPedInAnyVehicle(PlayerPedId())
		end,
	},{
        label = "Print Check",
        icon= 'fas fa-credit-card',
        event="d4m13n:client:scamming:print-checks",
		-- With CanInteract if the player is dead or in a vehicle, it will return false and he will not be able to open the atm even if he has the item
		canInteract = function(entity) 
			return not isDead and not IsPedInAnyVehicle(PlayerPedId())
		end,
	}}
    exports[Framework.Target]:AddTargetModel(Config.PrinterProp, {
		options = atmOptions,
		distance = 2
	})
end

RegisterNetEvent("d4m13n:client:scamming:install")
AddEventHandler("d4m13n:client:scamming:install", function()
    local atm = getClosestAtm()
    local atmCoords = GetEntityCoords(atm)
    local dict = "mini@safe_cracking"
    local anim = "idle_base"
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    
    local ped = PlayerPedId()
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    Framework.ProgressBar("skimmer-install", "Installing skimmer on ATM...", Config.SkimmerInstallTime, {movement=true,carMovement=true,mouse=true,combat=true})

    
    
    ClearPedTasks(ped)
    TriggerServerEvent("d4m13n:server:scamming:install-skimmer", atmCoords)
end)
RegisterNetEvent("d4m13n:client:scamming:uninstall")
AddEventHandler("d4m13n:client:scamming:uninstall", function()

    local atm = getClosestAtm()
    local atmCoords = GetEntityCoords(atm)
    local dict = "mini@safe_cracking"
    local anim = "idle_base"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    
    local ped = PlayerPedId()
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    Framework.ProgressBar("skimmer-install", "Uninstalling skimmer from the ATM...", Config.SkimmerUninstallTime, {movement=true,carMovement=true,mouse=true,combat=true})
    
    ClearPedTasks(ped)
    TriggerServerEvent("d4m13n:server:scamming:uninstall-skimmer", atmCoords)
end)

function setupAtms()
    
	local options= {{
		name = "atmskimminguninstall",
		icon = 'fas fa-minus',
		label = "Uninstall card skimmer",
        event="d4m13n:client:scamming:uninstall",
		-- With CanInteract if the player is dead or in a vehicle, it will return false and he will not be able to open the atm even if he has the item
		canInteract = function(entity) 
			return not isDead and not IsPedInAnyVehicle(PlayerPedId())
		end
	},{
		name = "atmskiminstall",
		icon = 'fas fa-plus',
		label = "Install card skimmer",
        event = "d4m13n:client:scamming:install",
		-- With CanInteract if the player is dead or in a vehicle, it will return false and he will not be able to open the atm even if he has the item
		canInteract = function(entity) 
			return not isDead and not IsPedInAnyVehicle(PlayerPedId())
		end
	}}

	-- Create target model.
	-- You can call this exports when you used ox_target because it's supported by him.
    for i,v in ipairs(Config.AtmModels)do
        exports[Framework.Target]:AddTargetModel(v.model, {
            options = options,
            distance = 2
        })
    end

end

function getClosestAtm()
    local closestATM = 0
    local entityCoords = GetEntityCoords(PlayerPedId())
    
    for _, atm in ipairs(Config.AtmModels) do
        closestATM = GetClosestObjectOfType(entityCoords, 10.0, atm.model, true, true, true)
        if closestATM ~= 0 then
            break
        end
    end
    return closestATM
end

function setupCashCheckingLocations()
    
        local zoneId = exports[Framework.Target]:AddBoxZone("d4mi13n:cash-check", Config.CheckCashingLocation.Location, 2, 2, {
            name = boxName,
            heading =  0,
            debugPoly = Config.Debug,
            minZ =  220,
            maxZ = 228,
            useZ = false,
        }, {
            options = {{
                icon = 'fas fa-piggy-bank',
                label = "Cash check",
                -- With CanInteract if the player is dead or in a vehicle, it will return false and he will not be able to open the bank.
                canInteract = function(entity)
                    return not isDead and not IsPedInAnyVehicle(PlayerPedId())
                end,
                action = function(entity)
                    local dict = "anim@amb@board_room@diagram_blueprints@"
                    local anim = "idle_01_amy_skater_01"
                    RequestAnimDict(dict)
                    while not HasAnimDictLoaded(dict) do
                        Citizen.Wait(0)
                    end
                    
                    local ped = PlayerPedId()
                    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
                    Framework.ProgressBar("skimmer-install", "Sliding the check to the teller...", 5, {movement=true,carMovement=true,mouse=true,combat=true})
                    
                    TriggerServerEvent("d4m13n:server:scamming:cashcheck")
                    ClearPedTasks(ped)
                end
            }},
            distance = Config.TargetBankDistance,
        })

    if(Config.CheckCashingLocation.Blip.Enabled)then
        -- Create a blip for the cash checking location
        local blip = AddBlipForCoord(Config.CheckCashingLocation.Location.x, Config.CheckCashingLocation.Location.y, Config.CheckCashingLocation.Location.z)
        SetBlipSprite(blip, Config.CheckCashingLocation.Blip.Sprite) -- Set the blip sprite to the money icon
        SetBlipDisplay(blip, 4) -- Set the blip display to show on both the minimap and the main map
        SetBlipScale(blip, Config.CheckCashingLocation.Blip.Scale) -- Set the blip scale
        SetBlipColour(blip, Config.CheckCashingLocation.Blip.Colour) -- Set the blip color to green
        SetBlipAsShortRange(blip, true) -- Set the blip to only show when the player is nearby
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.CheckCashingLocation.Blip.Label)
        EndTextCommandSetBlipName(blip)
    end
end

function spawnSecurityGuard()
    -- Replace 'csb_cop' with the model name of the security guard NPC you want to spawn
    local model = Config.SecurityPedModel
    
    -- Request model load to ensure the model is available
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
    
    -- Get player's position to spawn the NPC nearby
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    
    -- Create the NPC
    local npc = CreatePed(4, model, Config.SecurityPedCoords.x, Config.SecurityPedCoords.y,Config.SecurityPedCoords.z, true, true)
    local weaponHash = GetHashKey(Config.SecurityPedWeapon)
    GiveWeaponToPed(npc, weaponHash, 1, false, true)
    
    -- Set the NPC to attack the player
    TaskCombatPed(npc, playerPed, 0, 16)
    
    -- Set the NPC to be hostile to the player
    SetPedCombatAttributes(npc, 46, true)
    SetPedCombatAttributes(npc, 5, true)
    SetPedCombatAttributes(npc, 17, true)
    SetPedCombatAttributes(npc, 1, true)
    
    
    -- Mark the model as no longer needed
    SetModelAsNoLongerNeeded(model)
end



Citizen.CreateThread(function()
    setupCashCheckingLocations()
    setupAtms()
    setupPrinter()
end)
