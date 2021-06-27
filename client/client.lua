local daireBoyutu, itemSure, canAzaltmaTetikle = 90, 0, 0
local PlayerData = {}
local iceride = false
local evAktif = false
local esyaAlindi = false
local esyaAlinabilir = false
local sureBasladi = false
local yazi = "[E] Eşyayı Kontrol Et"

PantCore = nil
Citizen.CreateThread(function()
    while PantCore == nil do
        TriggerEvent('PantCore:GetObject', function(obj) PantCore = obj end)
        Citizen.Wait(200)
    end
    coreLoaded = true
end)

RegisterNetEvent('PantCore:Client:OnPlayerLoaded')
AddEventHandler('PantCore:Client:OnPlayerLoaded', function()
    PlayerData = PantCore.Functions.GetPlayerData()
    PantCore.Functions.TriggerCallback('ld-illegalev:sure-cek', function(data)
        Config.Data = data
    end)
end)

-- Meslek Update
RegisterNetEvent('PantCore:Client:OnJobUpdate')
AddEventHandler('PantCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
end)

RegisterNetEvent("ld-illegalev-2:senkron-data")
AddEventHandler("ld-illegalev-2:senkron-data", function(data)
    Config.Data = data
end)

Citizen.CreateThread(function()
    local evBlip = AddBlipForCoord(Config.blipCoords)
    SetBlipSprite(evBlip, 84)
    SetBlipDisplay(evBlip, 2)
    SetBlipScale(evBlip, 0.7)
    SetBlipColour(evBlip, 1)
    SetBlipAsShortRange(evBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("KOH Bölgesi")
    EndTextCommandSetBlipName(evBlip)

    local evBlipDaire = AddBlipForRadius(Config.blipCoords, daireBoyutu+0.0)
    SetBlipSprite(evBlipDaire, 9)
    SetBlipColour(evBlipDaire, 49)
    SetBlipAlpha(evBlipDaire, 75)
end)

Citizen.CreateThread(function()
    while true do
        local sure = 1500
        local PlayerPed = PlayerPedId()
        local oyuncuKordinat = GetEntityCoords(PlayerPed)
        local evMesafe = #(Config.blipCoords - oyuncuKordinat)
        if evMesafe < daireBoyutu and coreLoaded then 
            if PlayerData.job == nil then PlayerData = PantCore.Functions.GetPlayerData() end

            icerdemiFunction(true)
            if PlayerData.job and PlayerData.job.name ~= "police" and PlayerData.job.name ~= "ambulance" then
                local inVeh = IsPedInAnyVehicle(PlayerPed)
                if inVeh then
                    SetEntityHealth(PlayerPed, GetEntityHealth(PlayerPed)-5)
                    PantCore.Functions.Notify("It hurts because you're in the car!", "error")
                else
                    sure = 1
                    local markermesafe = #(Config.evKordinat - oyuncuKordinat)
                    if markermesafe < 20 and evAktif then
                        DrawMarker(20, Config.evKordinat.x, Config.evKordinat.y, Config.evKordinat.z-0.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0,0, 100, false, true, 2, false, false, false, false)
                        if markermesafe < 2.0 then
                            if IsControlJustPressed(1, 38) then
                               PantCore.Functions.TriggerCallback('ld-illegalev:sure-cek', function(data)
                                    if not sureBasladi and not esyaAlinabilir then
                                        TriggerServerEvent("ld-illegalev:sure-baslat")
                                    elseif esyaAlinabilir and not esyaAlindi then
                                        TriggerServerEvent("ld-illegalev:esya-alindi")
                                        PantCore.Functions.Notify("you got it")    
                                    end
                                end)
                            end
                            PantCore.Functions.DrawText3D(Config.evKordinat.x, Config.evKordinat.y, Config.evKordinat.z, yazi, 0.45)
                        end
                    end
                end
            else             
                if canAzaltmaTetikle <= 8 then          
                    canAzaltmaTetikle = canAzaltmaTetikle + 1
                    if PlayerData.job and PlayerData.job.name == "police" or PlayerData.job.name == "ambulance" then
                        PantCore.Functions.Notify("You have no business here. After 10 Seconds Your Life Will Start To Go", "error")
                        SetEntityHealth(PlayerPed, GetEntityHealth(PlayerPed)-5)
                    end
                end
            end
        else
            icerdemiFunction(false)
        end
        Citizen.Wait(sure)
    end
end)

local disariCiktim = false
local disariCiktimSure = 0
function icerdemiFunction(data)
    canAzaltmaTetikle = 0
    if data and not iceride then
        disariCiktim = false
        disariCiktimSure = 0
        iceride = true
        PantCore.Functions.Notify("You feel nervous...", "error")
        TriggerEvent("ld-polisbidirim:bildirim-aktif", false)
        TriggerEvent("ld-kelepce:aktif-pasif", false)
        TriggerEvent("ld-stres:stres-aktif", false)
        AnimpostfxPlay("MenuMGSelectionTint", 1000, true)
    elseif not data and iceride then
        disariCiktim = true
        disariCiktimSure = GetGameTimer() + 300000
        iceride = false
        PantCore.Functions.Notify("You're starting to relax...", "success")
        TriggerEvent("ld-polisbidirim:bildirim-aktif", true)
        TriggerEvent("ld-kelepce:aktif-pasif", true)
        TriggerEvent("ld-stres:stres-aktif", true)
        AnimpostfxStop("MenuMGSelectionTint")
    end
end

Citizen.CreateThread(function()
    while true do
        local time = 500
        if disariCiktim then
            time = 1
            if GetGameTimer() > disariCiktimSure then
                disariCiktim = false
                disariCiktimSure = 0
            end

            DisablePlayerFiring(PlayerPedId(), true)
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 47, true) -- G
            DisableControlAction(0, 289, true) -- F2

            if IsDisabledControlJustPressed(0, 47) then
                PantCore.Functions.Notify("You Can't Look for a Body for 5 Minutes Because You're Fresh Out of the Field!", "error")
            elseif IsDisabledControlJustPressed(0, 257) or IsDisabledControlJustPressed(0, 25) or IsDisabledControlJustPressed(0, 24) then
                PantCore.Functions.Notify("You Can't Use A Weapon For 5 Minutes Because You're Fresh From The Field!", "error")
            elseif IsDisabledControlJustPressed(0, 289) then
                PantCore.Functions.Notify("You Can't Use Inventory For 5 Minutes Because You Just Left The Field!", "error")
            end
        end
        Citizen.Wait(time)
    end
end)

exports('illegalEvEngel', function(str)
    if disariCiktim then
        PantCore.Functions.Notify("You Can't Use Inventory For 5 Minutes Because You're Fresh From The Field!", "error")
    end
    return not disariCiktim
end)
