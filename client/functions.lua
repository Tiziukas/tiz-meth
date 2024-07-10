-- Function to reset values
function resetValues()
    temp = 100
    lithium = 0
    acetone = 0
    acid = 0
    qual = 0
    randomNumber = 15
    lib.hideTextUI()
    FreezeEntityPosition(CurrentVehicle, false)
    lib.callback.await("tiz_meth:server:awaitsmoke", false, GetEntityCoords(PlayerPedId()), false)
    smoke = nil
    if IsVehicleSeatFree(CurrentVehicle, -1) then
        SetPedIntoVehicle(PlayerPedId(), CurrentVehicle, -1)
    end
    if Config.ProgBar == 'clm' then
        API_ProgressBar.clear()
    end
    if Config.PutOnGasMask then
        UseGasMask(false)
    end
    if Config.CamEnable then
        toggleCam(false)
    end
    if Config.Debug then print("Values reset") end
end

-- Helper function to create keybinds
function createKeybind(name, description, defaultKey, callback)
    return lib.addKeybind({
        name = name,
        description = description,
        defaultKey = defaultKey,
        onPressed = callback
    })
end

-- Helper function to load particle effects
function loadParticleEffect(asset)
    if not HasNamedPtfxAssetLoaded(asset) then
        RequestNamedPtfxAsset(asset)
        while not HasNamedPtfxAssetLoaded(asset) do
            Citizen.Wait(1)
        end
    end
end

local cam 
function toggleCam(bool) -- Stole This from Daddy Randolio
    if bool then
        local coords = GetEntityCoords(cache.ped)
        local x, y, z = coords.x + GetEntityForwardX(cache.ped) * 0.9, coords.y + GetEntityForwardY(cache.ped) * 0.9, coords.z + 0.92
        local rot = GetEntityRotation(cache.ped, 2)
        local camRotation = rot + vec3(0.0, 0.0, 175.0)
        cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', x, y, z, camRotation, 70.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 1000, 1, 1)
    else
        if cam then
            RenderScriptCams(false, true, 0, true, false)
            DestroyCam(cam, false)
            cam = nil
        end
    end
end

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

function UseGasMask(var)
    local animdict = 'mp_masks@on_foot'
    local animname = 'put_on_mask'
    local playerped = PlayerPedId()
    lib.requestAnimDict(animdict, 1000)
    TaskPlayAnim(playerped, animdict, animname, 8.0, -8.0, -1, 0, 0, false, false, false)
    RemoveAnimDict(animdict)
    Wait(260)
    if var then
        SetPedComponentVariation(playerped, 1, Config.GasMaskNumber, 0, 1)
    else
        SetPedComponentVariation(playerped, 1, 0, 0, 1)
    end
end

-- Function to generate a random number ending in 5 or 0

function generateRandomEndingIn5Or0()
    local min, max = 15, 100
    while true do
        local randomNum = math.random(min, max)
        local remainder = randomNum % 10
        if remainder == 0 or remainder == 5 then
            return randomNum
        end
    end
end

function CheckCar()
    CurrentVehicle = GetVehiclePedIsUsing(PlayerPedId())
    local model = GetEntityModel(CurrentVehicle)
    local modelName = GetDisplayNameFromVehicleModel(model)
    if modelName == Config.CarModel then
        if Config.Debug then print("Car correct: " .. modelName) end
        return true
    else
        if Config.Debug then print("Car incorrect") end
        return false
    end
end

function CheckItems()
    return lib.callback.await('tiz_meth:server:checkIngredients', false)
end