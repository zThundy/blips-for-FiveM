local radarEsteso = false
local mostrablip = false
local mostranomi = false

RegisterNetEvent('mostraBlips')
AddEventHandler('mostraBlips', function()
    mostrablip = not mostrablip
    if mostrablip then
        mostrablip = true
        -- notifica blips abilitati
        TriggerEvent('chatMessage', 'Blips', {0, 255, 0}, "Abilitati.")
    else
        mostrablip = false
        -- notifica blips disabilitati
        TriggerEvent('chatMessage', 'Blips', {255, 0, 0}, "Disabilitati.")
    end
end)

RegisterNetEvent('mostraNomi')
AddEventHandler('mostraNomi', function()
    mostranomi = not mostranomi
    if mostranomi then
        mostranomi = true
        -- notifica blips abilitati
        TriggerEvent('chatMessage', 'Names', {0, 255, 0}, "Abilitati.")
    else
        mostranomi = false
        -- notifica blips disabilitati
        TriggerEvent('chatMessage', 'Names', {255, 0, 0}, "Disabilitati.")
    end
end)

Citizen.CreateThread(function()
    while true do
    Wait(1)
    -- controllo del giocatore, se esiste e ha un id.
    for i = 0, 255 do
        if NetworkIsPlayerActive(i) and GetPlayerPed(i) ~= GetPlayerPed(-1) then
            ped = GetPlayerPed(i)
            blip = GetBlipFromEntity(ped)
            -- Crea il nome sulla testa del giocatore
            idTesta = Citizen.InvokeNative(0xBFEFE3321A3F5015, ped, GetPlayerName(i), false, false, "", false)

            if mostranomi then
                Citizen.InvokeNative(0x63BB75ABEDC1F6A0, idTesta, 0, true) -- Aggiunge il nome de giocatore sulla testa
                -- Mostra se il giocatore sta parlando.
                if NetworkIsPlayerTalking(i) then
                    Citizen.InvokeNative(0x63BB75ABEDC1F6A0, idTesta, 9, true)
                else
                    Citizen.InvokeNative(0x63BB75ABEDC1F6A0, idTesta, 9, false)
                end
            else -- Rimuove tutti i blip se mostranomi = false
                Citizen.InvokeNative(0x63BB75ABEDC1F6A0, idTesta, 9, false)
                Citizen.InvokeNative(0x63BB75ABEDC1F6A0, idTesta, 0, false)
            end

            if mostrablip then
                if not DoesBlipExist(blip) then -- Con questo aggiungo i blip sulla testa dei giocatori.
                    blip = AddBlipForEntity(ped)
                    SetBlipSprite(blip, 1) -- imposto il blip sulla posizione "blip" con l'id 1
                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) -- Aggiunge effettivamente il blip
                else -- se il blip esiste, allora lo aggiorno
                    veh = GetVehiclePedIsIn(ped, false) -- questo lo uso per aggiornare ogni volta il veicolo su cui il ped è salito
                    blipSprite = GetBlipSprite(blip)
                    if not GetEntityHealth(ped) then -- controllo se il giocatore è morto o no
                        if blipSprite ~= 274 then
                            SetBlipSprite(blip, 274)
                            Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Aggiunge effettivamente il blip
                        end
                    elseif veh then -- controllo se il giocatore è su un veicolo.
                        calsseVeicolo = GetVehicleClass(veh)
                        modelloVeicolo = GetEntityModel(veh)
                        if calsseVeicolo == 15 then -- La classe 15 indica un veicolo volante
                            if blipSprite ~= 422 then -- controllo se il blip non è il 422, ovvero l'aereo
                                SetBlipSprite(blip, 422) -- se true lo imposto.
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Aggiunge effettivamente il blip
                            end
                        elseif calsseVeicolo == 16 then -- controllo se il ped sta su un aereo
                            if modelloVeicolo == GetHashKey("besra") or modelloVeicolo == GetHashKey("hydra") or modelloVeicolo == GetHashKey("lazer") then -- controllo se il modello è un jet militare
                                if blipSprite ~= 424 then
                                    SetBlipSprite(blip, 424)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Aggiunge effettivamente il blip
                                end
                            elseif blipSprite ~= 423 then
                                SetBlipSprite(blip, 423)
                                Citizen.InvokeNative (0x5FBCA48327B914DF, blip, false) -- Aggiunge effettivamente il blip
                            end
                        elseif calsseVeicolo == 14 then -- boat
                            if blipSprite ~= 427 then
                                SetBlipSprite(blip, 427)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Aggiunge effettivamente il blip
                            end
                        elseif modelloVeicolo == GetHashKey("insurgent") or modelloVeicolo == GetHashKey("insurgent2") or modelloVeicolo == GetHashKey("limo2") then
                                if blipSprite ~= 426 then
                                    SetBlipSprite(blip, 426)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Aggiunge effettivamente il blip
                                end
                            elseif modelloVeicolo == GetHashKey("rhino") then -- tank
                                if blipSprite ~= 421 then
                                    SetBlipSprite(blip, 421)
                                    Citizen.InvokeNative(0x5FBCA48327B914DF, blip, false) -- Aggiunge effettivamente il blip
                                end
                            elseif blipSprite ~= 1 then -- default blip
                                SetBlipSprite(blip, 1)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) -- Aggiunge effettivamente il blip
                            end
                            -- Show number in case of passangers
                            passengers = GetVehicleNumberOfPassengers(veh)
                            if passengers then
                                if not IsVehicleSeatFree(veh, -1) then
                                    passengers = passengers + 1
                                end
                                ShowNumberOnBlip(blip, passengers)
                            else
                                HideNumberOnBlip(blip)
                            end
                        else
                            -- Se nessuno degli else per le auto viene verificato, allora setto il blip normale.
                            HideNumberOnBlip(blip)
                            if blipSprite ~= 1 then -- il blip default è 1
                                SetBlipSprite(blip, 1)
                                Citizen.InvokeNative(0x5FBCA48327B914DF, blip, true) -- Aggiunge effettivamente il blip
                            end
                        end
                        SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) -- con questo aggiorno la rotazione a seconda del veicolo
                        SetBlipNameToPlayerName(blip, i) -- aggirono il blip del giocatore
                        SetBlipScale(blip, 0.85) -- dimensione
                        -- se il menù con la mappa grande è aperto, allora setto il blip con un alpha massimo
                        -- con questo poi controllo la distanza dal giocatore per il nome sulla testa
                        if IsPauseMenuActive() then
                            SetBlipAlpha(blip, 255)
                        else -- se la prima non è confermata
                            x1, y1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true)) -- non ho messo la z perché non mi serve
                            x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(i), true)) -- uguale qua sotto
                            distanza = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
                            -- lo ho fatto così perché si....
                            if distanza < 0 then
                                distanza = 0
                            elseif distanza > 255 then
                                distanza = 255
                            end
                            SetBlipAlpha(blip, distanza)
                        end
                    end
                else
                    RemoveBlip(blip)
                end
            end
        end
    end
end)
