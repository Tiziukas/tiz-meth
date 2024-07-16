function CallDispatch()
    if GetResourceState('cd_dispatch') == 'started' then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = {Config.PoliceJob}, 
            coords = data.coords,
            title = Config.Language.methProduction,
            message = 'A '..data.sex..Config.Language.methProduction..' at '..data.street, 
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = Config.DispatchBlip.sprite,
                scale = Config.DispatchBlip.scale,
                colour = Config.DispatchBlip.colour,
                flashes = Config.DispatchBlip.flashes, 
                text = Config.Language.blipText,
                time = Config.DispatchBlip.time,
                radius = Config.DispatchBlip.radius
            }
        })
    elseif GetResourceState('rcore_dispatch') == 'started' then
        local playerData = exports['rcore_dispatch']:GetPlayerData()
        local data = {
            code = '10-64', -- string -> The alert code, can be for example '10-64' or a little bit longer sentence like '10-64 - Shop robbery'
            default_priority = 'low', -- 'low' | 'medium' | 'high' -> The alert priority
            coords = playerData.coords, -- vector3 -> The coords of the alert
            job = Config.PoliceJob, -- string | table -> The job, for example 'police' or a table {'police', 'ambulance'}
            text = 'A '..playerData.sex..Config.Language.methProduction..' at '..playerData.street, -- string -> The alert text
            type = 'alerts', -- alerts | shop_robbery | car_robbery | bank_robbery -> The alert type to track stats
            blip_time = 5, -- number (optional) -> The time until the blip fades
            image = '', -- string (optional) -> The url to show an image
            custom_sound = '', -- string (optional) -> The url to the sound to play with the alert
            blip = { -- Blip table (optional)
                sprite = Config.DispatchBlip.sprite,
                colour = Config.DispatchBlip.colour,
                scale = Config.DispatchBlip.scale,
                text = Config.Language.blipText,
                flashes = Config.DispatchBlip.flashes, 
                radius = Config.DispatchBlip.radius
            }
        }
        TriggerServerEvent('rcore_dispatch:server:sendAlert', data)
    elseif GetResourceState('qs-dispatch') == 'started' then
        local playerData = exports['qs-dispatch']:GetPlayerInfo()
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = {Config.PoliceJob},
            callLocation = playerData.coords,
            callCode = { code = 'Cooking', snippet = 'Vehicle' }, -- Change this yourself
            message = 'A '..playerData.sex..Config.Language.methProduction..' at '..playerData.street,
            flashes = Config.DispatchBlip.flashes,
            image = nil,
            blip = {
                sprite = Config.DispatchBlip.sprite,
                scale = 1.5,
                colour = Config.DispatchBlip.colour,
                flashes = Config.DispatchBlip.flashes,
                text = Config.Language.blipText,
                time = (20 * 1000),     --20 secs
            }
        })
    else
        -- Integrate your dispatch here.
        --
        --
        --
        --
        --        
    end
end

function getPlayerZone()
    local jugador = PlayerPedId()
    local coords = GetEntityCoords(jugador)
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    return zone
end


function isAllowedZone(zone)
    for _, z in ipairs(Config.AllowedZones) do
        if z == zone then
            return true
        end
    end
    return false
end