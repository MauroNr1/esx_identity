local loadingScreenFinished = false
local ready = true
local guiEnabled = false
local timecycleModifier = "hud_def_blur"

RegisterNetEvent('esx_identity:alreadyRegistered', function()
    while not loadingScreenFinished do Wait(100) end
    TriggerEvent('esx_skin:playerRegistered')
end)

RegisterNetEvent('esx_identity:setPlayerData', function(data)
    SetTimeout(1, function()
        ESX.SetPlayerData("name", ('%s %s'):format(data.firstName, data.lastName))
        ESX.SetPlayerData('firstName', data.firstName)
        ESX.SetPlayerData('lastName', data.lastName)
        ESX.SetPlayerData('dateofbirth', data.dateOfBirth)
        ESX.SetPlayerData('sex', data.sex)
        ESX.SetPlayerData('height', data.height)
    end)
end)

AddEventHandler('esx:loadingScreenOff', function()
    loadingScreenFinished = true
end)

if not Config.UseDeferrals then ----
    RegisterNetEvent('esx_identity:showRegisterIdentity', function()
        TriggerEvent('esx_skin:resetFirstSpawn')
        if not ESX.PlayerData.dead then
            local input = lib.inputDialog('Identity', {
                {type = 'input', label = 'First name', description = "The first name of your character", required = true},
                {type = 'input', label = 'Last name', description = "The last name of your character", required = true},
                {type = 'number', label = 'Height', min = Config.MinHeight, max = Config.MaxHeight, description = 'The height of your character in centimeters', required = true},
                {type = 'date', label = 'Date of birth', description = "The date of birth of your character", format = Config.DateFormat, required = true},
                {type = 'select', label = 'Gender', description = "The gender of your character", options = {{value = "m", label = "Male"},{value = "f", label = "Female"}}, required = true}
            },{allowCancel = false}) --Do not allow the input dialog to be closed without input.

            --Formatting our data so we do not have weird names, heights or dates of birth.
            local data = {}
            data.firstname = string.sub(input[1]:gsub('%W',''):gsub('%d',''),1,Config.MaxNameLength)
            data.lastname = string.sub(input[2]:gsub('%W',''):gsub('%d',''),1,Config.MaxNameLength)
            data.height = input[3]
            data.dateofbirth = math.round(input[4]/1000) --For some reason ox_lib decides to return epoch time with milliseconds for a date?
            data.sex = input[5]

            ESX.TriggerServerCallback('esx_identity:registerIdentity', function(callback)
                if not callback then
                    return
                end

                ESX.ShowNotification(TranslateCap('thank_you_for_registering'))
                setGuiState(false)

                if not ESX.GetConfig().Multichar then
                TriggerEvent('esx_skin:playerRegistered')
                end
            end, data)
        end
    end)
end
