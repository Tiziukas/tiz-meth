local started = false
local CurrentVehicle = nil
local temp = 100
local lithium = 0
local acetone = 0
local acid = 0
local qual = 0
local smoke = nil
local incar = false
local randomNumber = 15
local API_ProgressBar
local cam

if Config.ProgBar == 'clm' then
    API_ProgressBar = exports["clm_ProgressBar"]:GetAPI()
end

local function loadParticleEffect(asset)
    if not HasNamedPtfxAssetLoaded(asset) then
        RequestNamedPtfxAsset(asset)
        while not HasNamedPtfxAssetLoaded(asset) do
            Citizen.Wait(1)
        end
    end
end

RegisterNetEvent('tiz_meth:client:smoke')
AddEventHandler('tiz_meth:client:smoke', function(posx, posy, posz, bool)
    loadParticleEffect("core")
    SetPtfxAssetNextCall("core")
    if bool then
        if Config.Debug then print("Smoke Started") end
        smoke = StartParticleFxLoopedAtCoord(Config.SmokeColour, posx, posy, posz + Config.Particle.posZ, Config.Particle.xRot, Config.Particle.yRot, Config.Particle.zRot, Config.Particle.scale, false, false, false, false)
        SetParticleFxLoopedAlpha(smoke, 0.8)
        SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
        Citizen.Wait(Config.ox_libTimer)
        StopParticleFxLooped(smoke, 0)
    else
        if Config.Debug then print("Smoke stopped") end
        StopParticleFxLooped(smoke, 0)
    end
end)

local function UseGasMask(var)
    local animdict = 'mp_masks@on_foot'
    local animname = 'put_on_mask'
    local playerped = PlayerPedId()
    lib.requestAnimDict(animdict, 1000)
    TaskPlayAnim(playerped, animdict, animname, 8.0, -8.0, -1, 0, 0, false, false, false)
    RemoveAnimDict(animdict)
    Wait(260)
    if var then
        if Config.Debug then print("Gas mask on") end
        SetPedComponentVariation(playerped, 1, Config.GasMaskNumber, 0, 1)
    else
        if Config.Debug then print("Gas mask off") end
        SetPedComponentVariation(playerped, 1, 0, 0, 1)
    end
end

local function toggleCam(bool) -- Stole This from Daddy Randolio
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

local function getPlayerZone()
    local coords = GetEntityCoords(PlayerPedId())
    if Config.Debug then print("Player is in this zone: " .. GetNameOfZone(coords.x, coords.y, coords.z)) end
    return GetNameOfZone(coords.x, coords.y, coords.z)
end


local function isAllowedZone(zone)
    for _, z in ipairs(Config.AllowedZones) do
        if z == zone then
            if Config.Debug then print("Zone is allowed: " ..zone) end
            return true
        end
    end
    if Config.Debug then print("Zone is not allowed: " ..zone) end
    return false
end
-- Helper function to create keybinds
local function createKeybind(name, description, defaultKey, callback)
    return lib.addKeybind({
        name = name,
        description = description,
        defaultKey = defaultKey,
        onPressed = callback
    })
end

-- Function to generate a random number ending in 5 or 0

local function generateRandomEndingIn5Or0()
    local min, max = 15, 100
    while true do
        local randomNum = math.random(min, max)
        local remainder = randomNum % 10
        if remainder == 0 or remainder == 5 then
            return randomNum
        end
    end
end

local function CheckCar()
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

local function CheckItems()
    return lib.callback.await('tiz_meth:server:checkIngredients', false)
end

local function resetValues()
    temp = 100
    lithium = 0
    acetone = 0
    acid = 0
    qual = 0
    randomNumber = 15
    incar = false
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

-- Keybinds for adding ingredients and adjusting temperature
createKeybind('lithium', 'Add Lithium', 'A', function()
    if started then
        local count = lib.callback.await('tiz-meth:server:getItemCount', false, Config.ItemNames.lithium)
        if count >= 1 then
            lithium = lithium + 1
            lib.callback.await('tiz-meth:server:removeItem', false, Config.ItemNames.lithium)
            if Config.Debug then print("Lithium added") end
        else
            lib.notify({ title = Config.Language.notifyTitle, description = Config.Language.noLithium, type = 'error' })
        end
    end
end)

createKeybind('acetone', 'Add Acetone', 'S', function()
    if started then
        local count = lib.callback.await('tiz-meth:server:getItemCount', false, Config.ItemNames.acetone)
        if count >= 1 then
            acetone = acetone + 1
            lib.callback.await('tiz-meth:server:removeItem', false, Config.ItemNames.acetone)
            if Config.Debug then print("Acetone added") end
        else
            lib.notify({ title = Config.Language.notifyTitle, description = Config.Language.noAcetone, type = 'error' })
        end
    end
end)

createKeybind('acid', 'Add Sulfuric Acid', 'D', function()
    if started then
        local count = lib.callback.await('tiz-meth:server:getItemCount', false, Config.ItemNames.acid)
        if count >= 1 then
            acid = acid + 1
            lib.callback.await('tiz-meth:server:removeItem', false, Config.ItemNames.acid)
            if Config.Debug then print("Acid added") end
        else
            lib.notify({ title = Config.Language.notifyTitle, description = Config.Language.noAcid, type = 'error' })
        end
    end
end)

createKeybind('tempup', 'Increase the temperature', 'G', function()
    if started and temp < 100 then
        temp = temp + 5
    end
end)

createKeybind('tempdown', 'Decrease the temperature', 'H', function()
    if started and temp > 0 then
        temp = temp - 5
    end
end)

createKeybind('startmeth', 'Start the meth cooking process', 'E', function()
    if incar then
        if not started then
            if Config.OnlyAllowedZones then
                if isAllowedZone(getPlayerZone()) then
                    Wait(300)
                    lib.hideTextUI()
                    lib.callback.await("tiz_meth:server:cookthisbitchup", false)
                else
                    lib.notify({ title = Config.Language.zoneErrorTitle, description = Config.Language.zoneErrorDescription, type = 'error' })
                end
            else
                Wait(300)
                lib.hideTextUI()
                lib.callback.await("tiz_meth:server:cookthisbitchup", false)
            end
        end
    end
end)

lib.onCache('seat', function(seat)
    if seat == -1 then
        incar = CheckCar()
        local hasRequired = CheckItems()
        if incar and hasRequired then
            lib.showTextUI(Config.Language.startCook)
            Citizen.Wait(500)
        end
    else
        lib.hideTextUI()
    end
end)


-- Thread to handle the cooking process
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if started then
            if Config.ProgBar == 'clm' then
                local bar_BarTimerBar = API_ProgressBar.add("BarTimerBar", Config.Language.progBarMsg)
                bar_BarTimerBar.Func.lib.BarTimerBar.setForegroundColor({241, 26, 238, 255})

                local progress = 0.0

                repeat
                    Citizen.Wait(Config.TickLength)
                    bar_BarTimerBar.Func.lib.BarTimerBar.setProgress(progress)
                    progress = progress + 0.01
                until progress >= 1.0 or not started
                if started then
                    started = false
                    lib.callback.await('tiz-meth:server:FinishThisShit', false, qual)
                    lib.hideTextUI()
                    resetValues()
                    if Config.Debug then print("Timer finished") end
                end
            elseif Config.ProgBar == 'ox_bar' then
                if lib.progressBar({
                    duration = Config.ox_libTimer,
                    label = Config.Language.progBarMsg,
                    useWhileDead = false,
                    canCancel = true,
                }) then
                    started = false
                    lib.callback.await('tiz-meth:server:FinishThisShit', false, qual)
                    resetValues()
                    lib.hideTextUI()
                    if Config.Debug then print("Timer finished") end 
                else
                    started = false
                    lib.hideTextUI()
                    resetValues()
                    if Config.Debug then print("Operation Cancelled") end
                end
            elseif Config.ProgBar == 'ox_circle' then
                if lib.progressCircle({
                    duration = Config.ox_libTimer,
                    label = Config.Language.progBarMsg,
                    useWhileDead = false,
                    canCancel = true,
                }) then
                    started = false
                    lib.callback.await('tiz-meth:server:FinishThisShit', false, qual)
                    resetValues()
                    lib.hideTextUI()
                    if Config.Debug then print("Timer finished") end 
                else
                    started = false
                    lib.hideTextUI()
                    resetValues()
                    if Config.Debug then print("Operation Cancelled") end
                end
            end
        end
    end
end)

-- Thread to handle random ingredient consumption
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(12000)
        if started then
            math.randomseed(GetGameTimer()) -- Seed the random number generator
            randomNumber = generateRandomEndingIn5Or0()
        end
    end
end)

-- Event to start the production process
RegisterNetEvent('tiz-meth:client:startprod')
AddEventHandler('tiz-meth:client:startprod', function()
    if started then
        lib.notify({
            title = Config.Language.notifyTitle,
            description = Config.Language.cookInProg,
            type = 'error'
        })
        return
    end

    if not CheckCar() then
        lib.notify({
            title = Config.Language.notifyTitle,
            description = Config.Language.wrongCar,
            type = 'error'
        })
        return
    end

    if IsVehicleSeatFree(CurrentVehicle, 3) then
        SetPedIntoVehicle(PlayerPedId(), CurrentVehicle, 3)
    else
        lib.notify({
            title = Config.Language.notifyTitle,
            description = Config.Language.seatOccupied,
            type = 'error'
        })
        return
    end

    FreezeEntityPosition(CurrentVehicle, true)
    lib.callback.await("tiz_meth:server:awaitsmoke", false, GetEntityCoords(PlayerPedId()), true)
    started = true
    if Config.Dispatch == true then
        CallDispatch()
    end
    if Config.PutOnGasMask then
        UseGasMask(true)
    end
    if Config.CamEnable then
        toggleCam(true)
    end

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10)
            if qual == 0 and started then
                local blowme = 0.0
                repeat
                    Citizen.Wait(500)
                    blowme = blowme + 0.1
                until blowme >= 1.0 or qual ~= 0
                if blowme >= 1.0 then
                    ExplodeVehicle(CurrentVehicle, true, true)
                end
            end
        end
    end)
    
    Citizen.CreateThread(function()
        while started do
            Citizen.Wait(0)

            if Config.HelpText == 'helptext' then
                AddTextEntry('msgtiz', '~INPUT_DETONATE~ '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                    ' \n~INPUT_VEH_HEADLIGHT~ '..Config.Language.decreaseTempMsg ..
                    ' \n~INPUT_PARACHUTE_TURN_LEFT_ONLY~ '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                    ' \n~INPUT_VEH_PUSHBIKE_REAR_BRAKE~ '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                    ' \n~INPUT_PARACHUTE_TURN_RIGHT_ONLY~ '..Config.Language.addAcid..' (' .. acid .. ')')

                if IsPedInVehicle(PlayerPedId(), CurrentVehicle, false) then
                    DisplayHelpTextThisFrame("msgtiz", false)
                    
                    if temp == randomNumber and lithium == Config.lowQualRecipe.lithium and Config.lowQualRecipe.acid == 5 and Config.lowQualRecipe.acetone == 4 then
                        lib.showTextUI(Config.Language.batchStable)
                        qual = 1
                    elseif temp < randomNumber and lithium == 3 and acid == 5 and acetone == 4 then
                        lib.showTextUI(Config.Language.increaseTemp)
                        qual = 0
                    elseif temp > randomNumber and lithium == 3 and acid == 5 and acetone == 4 then
                        lib.showTextUI(Config.Language.decreaseTemp)
                        qual = 0
                    elseif temp == randomNumber and lithium == Config.midQualRecipe.lithium and acid == Config.midQualRecipe.acid and acetone == Config.midQualRecipe.acetone then
                        lib.showTextUI(Config.Language.batchStable)
                        qual = 2
                    elseif temp < randomNumber and lithium == 2 and acid == 5 and acetone == 14 then
                        lib.showTextUI(Config.Language.increaseTemp)
                        qual = 0
                    elseif temp > randomNumber and lithium == 2 and acid == 5 and acetone == 14 then
                        lib.showTextUI(Config.Language.decreaseTemp)
                        qual = 0
                    elseif temp == randomNumber and lithium == Config.highQualRecipe.lithium and acid == Config.highQualRecipe.acid and acetone == Config.highQualRecipe.acetone then
                        lib.showTextUI(Config.Language.batchStable)
                        qual = 3
                    elseif temp < randomNumber and lithium == 4 and acid == 3 and acetone == 8 then
                        lib.showTextUI(Config.Language.increaseTemp)
                        qual = 0
                    elseif temp > randomNumber and lithium == 4 and acid == 3 and acetone == 8 then
                        lib.showTextUI(Config.Language.decreaseTemp)
                        qual = 0
                    else
                        qual = 0
                        lib.showTextUI(Config.Language.batchWeird)
                    end
                else
                    started = false
                    lib.hideTextUI()

                    if Config.ProgBar == 'ox_bar' or Config.ProgBar == 'ox_circle' then
                        lib.cancelProgress()
                    end

                    resetValues()
                end
            elseif Config.HelpText == 'ox_lib' then
                if IsPedInVehicle(PlayerPedId(), CurrentVehicle, false) then
                    DisplayHelpTextThisFrame("msgtiz", false)
                    
                    if temp == randomNumber and lithium == Config.lowQualRecipe.lithium and Config.lowQualRecipe.acid == 5 and Config.lowQualRecipe.acetone == 4 then
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.batchStable,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                        qual = 1
                    elseif temp < randomNumber and lithium == 3 and acid == 5 and acetone == 4 then
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.increaseTemp,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                        qual = 0
                    elseif temp > randomNumber and lithium == 3 and acid == 5 and acetone == 4 then
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.decreaseTemp,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                        qual = 0
                    elseif temp == randomNumber and lithium == Config.midQualRecipe.lithium and acid == Config.midQualRecipe.acid and acetone == Config.midQualRecipe.acetone then
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.batchStable,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                        qual = 2
                    elseif temp < randomNumber and lithium == 2 and acid == 5 and acetone == 14 then
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.increaseTemp,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                        qual = 0
                    elseif temp > randomNumber and lithium == 2 and acid == 5 and acetone == 14 then
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.decreaseTemp,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                        qual = 0
                    elseif temp == randomNumber and lithium == Config.highQualRecipe.lithium and acid == Config.highQualRecipe.acid and acetone == Config.highQualRecipe.acetone then
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.batchStable,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                        qual = 3
                    elseif temp < randomNumber and lithium == 4 and acid == 3 and acetone == 8 then
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.increaseTemp,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                        qual = 0
                    elseif temp > randomNumber and lithium == 4 and acid == 3 and acetone == 8 then
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.decreaseTemp,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                        qual = 0
                    else
                        qual = 0
                        lib.showTextUI('[G]  '..Config.Language.increaseTempMsg..' (' .. temp .. '%)' ..
                        '                                           \n'..'[H]  '..Config.Language.decreaseTempMsg ..
                        '                                           \n'..'[A]  '..Config.Language.addLithium..' (' .. lithium .. ')' ..
                        '                                           \n'..'[S]  '..Config.Language.addAcetone..' (' .. acetone .. ')' ..
                        '                                           \n'..'[D]  '..Config.Language.addAcid..' (' .. acid .. ')' ..
                        '                                           \n'..
                        '                                           \n'.. Config.Language.batchWeird,
                        {
                            position = 'right-center',
                            icon = 'fa-solid fa-syringe',
                            iconColor = 'white',
                            style = {
                                borderRadius = '8px',
                                backgroundColor = '#212121',
                                color = '#FFFFFF',           
                                padding = '8px',
                            }
                        })
                    end
                else
                    started = false
                    lib.hideTextUI()

                    if Config.ProgBar == 'ox_bar' or Config.ProgBar == 'ox_circle' then
                        lib.cancelProgress()
                    end
                    resetValues()
                end
            end
        end
    end)
end)