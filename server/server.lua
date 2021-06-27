PantCore = nil
local itemSure = Config.BeklemeSuresi
TriggerEvent('PantCore:GetObject', function(obj) PantCore = obj end)
local esyaAlindi = false

RegisterServerEvent("ld-illegalev:sure-baslat")
AddEventHandler("ld-illegalev:sure-baslat",function()
    while itemSure > 1 do
        itemSure = itemSure - 5000
        Citizen.Wait(5000)
    end
end)

RegisterServerEvent("ld-illegalev:esya-alindi")
AddEventHandler("ld-illegalev:esya-alindi",function()
    local xPlayer = PantCore.Functions.GetPlayer(source)
    esyaAlindi = true
    TriggerClientEvent('ld-illegalev:esya-alindi-client', -1)
    xPlayer.Functions.AddItem('excoin', 25)
    TriggerClientEvent('inventory:client:ItemBox', xPlayer.PlayerData.source, PantCore.Shared.Items['excoin'], "add", 25)
    Citizen.Wait(60*60000) -- 1 Saat sonra ev içindeki markeri kapatmak için bekleme süresi. (Marker açık olsa bile eşyayı alamayacaklar, eşyanın alındığı yazacak)
    TriggerClientEvent('ld-illegalev:blip-kaldır', -1)
end)

-- üzümlü kekim ile ilklerimizden :(
PantCore.Functions.CreateCallback('ld-illegalev:sure-cek', function(source, cb)
    cb(itemSure, esyaAlindi, Config.evKordinat)
end)
