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

if Config.ProgBar == 'clm' then
    API_ProgressBar = exports["clm_ProgressBar"]:GetAPI()
end

RegisterNetEvent('tiz_meth:client:smoke')
AddEventHandler('tiz_meth:client:smoke', function(posx, posy, posz, bool)
    loadParticleEffect("core")
    SetPtfxAssetNextCall("core")
    if bool then
        smoke = StartParticleFxLoopedAtCoord(Config.SmokeColour, posx, posy, posz + Config.Particle.posZ, Config.Particle.xRot, Config.Particle.yRot, Config.Particle.zRot, Config.Particle.scale, false, false, false, false)
        SetParticleFxLoopedAlpha(smoke, 0.8)
        SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
        Citizen.Wait(Config.ox_libTimer)
        StopParticleFxLooped(smoke, 0)
    else
        StopParticleFxLooped(smoke, 0)
    end
end)

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
            Wait(300)
            lib.hideTextUI()
            lib.callback.await("tiz_meth:server:cookthisbitchup", false)
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