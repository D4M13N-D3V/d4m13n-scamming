Framework = exports["d3MBA-lib"]:GetFrameworkObject()


local atmsWithSkimmers={}
local playerWithdrawCounts = {}
local playerWithPrinters = {}


Framework.CreateUseableItem(Config.CheckPrinterItem, function(playerId)
    Framework.RemoveItem(playerId,Config.CheckPrinterItem, 1)
	TriggerClientEvent("d4m13n:client:scamming:place-printer",playerId,Config.CheckPrinterItem)
end)
Framework.CreateUseableItem(Config.UnsignedCheckItem, function(playerId)
    TriggerClientEvent("d4m13n:client:scamming:signcheck", playerId)
end)


Citizen.CreateThread(function()
    while true do
        playerWithdrawCounts = {}
        Citizen.Wait(Config.CheckCooldownResetInterval)
    end
end)



RegisterNetEvent("d4m13n:server:scamming:skimCard")
AddEventHandler("d4m13n:server:scamming:skimCard", function(coords)
    if(Config.EnablePlayerFraud)then
        local coordsChosen = nil
        for index,value in pairs(atmsWithSkimmers)do
            if(calculateDistance(index,coords,true)<3.0)then
                coordsChosen = index
                break
            end
        end
        if( atmsWithSkimmers[coordsChosen]==nil) then return end
        atmsWithSkimmers[coordsChosen].cards[#atmsWithSkimmers[coordsChosen].cards+1] = {
            name=Framework.GetPlayerName(source),
            targetId = source
        }
    end
end)

RegisterNetEvent("d4m13n:server:scamming:signcheck")
AddEventHandler("d4m13n:server:scamming:signcheck", function(quality)
	local item = Framework.GetInventory(source)
    for i,v in ipairs(item)do
        if(v.name==Config.UnsignedCheckItem)then
            item = v
            break
        end
    end
    Framework.RemoveItem(source,Config.UnsignedCheckItem,1)
    Framework.AddItem(source,Config.SignedCheckItem,1,{
        name=item.info.name,
        amount=math.random(Config.CheckMinimum,Config.CheckMaximum),
        signed=true,
        signaturequality = quality,
        identifier=item.info.identifier
    })
end)


RegisterNetEvent("d4m13n:server:scamming:print-checks")
AddEventHandler("d4m13n:server:scamming:print-checks", function()
	local items = Framework.GetInventory(source)
	local target = nil
	for i,v in ipairs(items)do

		if(v.name==Config.SkimmerUsedItem and v.info.bankInfo~=nil)then
			Framework.RemoveItem(source, Config.SkimmerUsedItem, 1)
		for x,d in ipairs(v.info.bankInfo)do
			if(d~=nil)then
				target = d
				Framework.AddItem(source, Config.UnsignedCheckItem, 1, {
					name=target.name,
					amount=0,
					signed=false,
					signaturequality = 0,
					identifier=target.identifier
				})
			end
		end
	end
	end
end)

RegisterNetEvent("d4m13n:server:scamming:pickup-printer")
AddEventHandler("d4m13n:server:scamming:pickup-printer", function()
    Framework.AddItem(source,Config.CheckPrinterItem, 1)
end)

RegisterServerEvent("d4m13n:server:scamming:install-skimmer")
AddEventHandler("d4m13n:server:scamming:install-skimmer", function(coords)
    local src = source
	if(atmsWithSkimmers[coords]~=nil)then
        TriggerClientEvent("d3MBA-lib:sendNotification", source, 
            'Someone seems to have already put a skimmer on this...',
            'error',
             4000
        )
		return
	end
    
    if(Framework.HasItem(src, Config.SkimmerItem, 1)==false)then
        TriggerClientEvent("d3MBA-lib:sendNotification", source,
            'You dont have a skimmer...',
            'error',
             4000
        )
        return
    end

    TriggerClientEvent("d3MBA-lib:sendNotification", source,
        'The skimmer has been installed on the ATM.',
        'success',
         4000
    )
    local player = Framework.GetPlayerData(src)
	atmsWithSkimmers[coords]={owner=src,cards={}} -- player loot 
    Framework.RemoveItem(src,Config.SkimmerItem, 1)
	TriggerClientEvent("d4m13n:skimmer-installed", src)
	Citizen.CreateThread(function()
		AutoDestroySkimmer(coords)
	end)
end)	


function calculateDistance(vector1, vector2)
    local xDiff = vector1.x - vector2.x
    local yDiff = vector1.y - vector2.y
    local zDiff = vector1.z - vector2.z

    local distance = math.sqrt(xDiff * xDiff + yDiff * yDiff + zDiff * zDiff)
    return distance
end


RegisterServerEvent("d4m13n:server:scamming:uninstall-skimmer")
AddEventHandler("d4m13n:server:scamming:uninstall-skimmer", function(coords)
	local coordsChosen = nil
    local src = source
	for index,value in pairs(atmsWithSkimmers)do
		if(calculateDistance(index,coords,true)<3.0)then
			coordsChosen = index
			break
		end
	end

	local skimmer = atmsWithSkimmers[coordsChosen]

	if(skimmer==nil)then
        TriggerClientEvent("d3MBA-lib:sendNotification", source, 
            'There is no skimmer on this ATM...',
            'error',
             4000
        )
		return
	end
	if(skimmer.owner~=source)then
        TriggerClientEvent("d3MBA-lib:sendNotification", source, 
            'There is not your skimmer, seems risky to try to take it off right now...',
            'error',
             4000
        )
		return
	end
    TriggerClientEvent("d3MBA-lib:sendNotification", source,
        'The skimmer has been uninstalled on the ATM.',
        'success',
         4000
    )
   Framework.AddItem(src,Config.SkimmerUsedItem, 1,{bankInfo=skimmer.cards})
	TriggerClientEvent("d4m13n:skimmer-uninstalled", source)
	atmsWithSkimmers[coordsChosen] = nil
end)

RegisterNetEvent("d4m13n:server:scamming:cashcheck")
AddEventHandler("d4m13n:server:scamming:cashcheck", function()
    local src = source
    local items = Framework.GetInventory(source)
    for i,item in ipairs(items)do
        if(item.name==Config.SignedCheckItem)then 
            local name = item.name
            local slot = item.slot
            local amount = item.info.amount
            local identifier = item.info.targetId
            local chance = math.random(1, 100)
            local door = exports[Config.DoorResource]:getDoorFromName(Config.DoorName)
            local quality = item.info.signaturequality
            local failed = false
            if(quality<chance)then
                failed = true
            end
            if (playerWithdrawCounts[source] == nil) then
                playerWithdrawCounts[source] = 1
            else
                playerWithdrawCounts[source] = playerWithdrawCounts[source] + 1
                if (playerWithdrawCounts[source] >
                    Config.MaxChecksBeforeCooldown) then return end
            end
           Framework.RemoveItem(source,Config.SignedCheckItem, 1)
            if (failed == true) then
                Citizen.CreateThread(function()
                    exports[Config.DoorResource]:setDoorState(door.id, 1)
                    Citizen.Wait(90000)
                    exports[Config.DoorResource]:setDoorState(door.id, 0)
                end)
                TriggerClientEvent("d3MBA-lib:sendNotification", source, 
                    'Quick, get out! They know something is up!',
                    'error',
                    4000
                )
                if(Config.EnableLockdown==true)then
                    TriggerClientEvent("d4m13n:scamming:client:lockdown", source)
                end
            else
                if(Config.RewardItem~=false)then
                    Framework.AddItem(source, Config.RewardItem, amount)
                else
                    Framework.AddMoney(source,Config.RewardAccount, amount)
                end
                TriggerClientEvent("d3MBA-lib:sendNotification", source, 
                    'You have cashed the check successfully.',
                    'success',
                    4000
                )
            end

            if (targetId ~= nil) then
                if (targetPlayer ~= nil) then
                    Framework.RemoveMoney(targetId, "bank", amount)
                end
            end
            return
        end
    end
    TriggerClientEvent("d3MBA-lib:sendNotification", source, 
        'You dont have any checks to cash!',
        'error',
        4000
    )
end)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.SkimmingRate)
        IncrementAtms()
    end
end)
function IncrementAtms()
    for i,v in pairs(atmsWithSkimmers)do
        print(i)
        print(json.encode(v))
        local chance = math.random(1,100)
        print(chance.." "..Config.SkimmingChance)
        if(chance>Config.SkimmingChance)then
            if(v==nil)then
                return
            end
            v.cards[#v.cards+1] = {
                name=Config.LocalFirstNames[math.random(1,#Config.LocalFirstNames)].." "..Config.LocalLastNames[math.random(1,#Config.LocalLastNames)]
            }
        end
        atmsWithSkimmers[i]=v
    end
end

function AutoDestroySkimmer(coords)
	Citizen.Wait(3600000)
	if(atmsWithSkimmers[coords]~=nil)then
		atmsWithSkimmers[coords]=nil
	end
end