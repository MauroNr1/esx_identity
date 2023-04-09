local loadingScreenFinished = false
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

if not Config.UseDeferrals then
    local input

    function showRegistration(state)
        guiEnabled = state

        if state then
            SetTimecycleModifier(timecycleModifier)
        else
            lib.closeInputDialog()
            ClearTimecycleModifier()

            return
        end

        input = lib.inputDialog(TranslateCap('application_name'), {
            {type = 'input', label = TranslateCap('first_name'), description = TranslateCap('first_name_description'), required = true},
            {type = 'input', label = TranslateCap('last_name'), description = TranslateCap('last_name_description'), required = true},
            {type = 'number', label = TranslateCap('height'), min = Config.MinHeight, max = Config.MaxHeight, description = TranslateCap('height_description'), required = true},
            {type = 'date', label = TranslateCap('dob'), description = TranslateCap('dob_description'), format = Config.DateFormat, required = true},
            {type = 'select', label = TranslateCap('gender'), description = TranslateCap('gender_description'), options = {{value = "m", label = TranslateCap('gender_male')}, {value = "f", label = TranslateCap('gender_female')}}, required = true},
            {type = 'checkbox', label = TranslateCap('prepared_to_rp'), required = true}
        }, {
            allowCancel = false
        })

        local data = {}
        data.firstname = input[1]
        data.lastname = input[2]
        data.height = input[3]
        data.dateofbirth = math.floor(input[4]/1000) --ox_lib returns date with millisecond accuracy
        data.sex = input[5] --m or f

        ESX.TriggerServerCallback('esx_identity:registerIdentity', function(callback)
            if not callback then return end --Something is wrong with formating

            ClearTimecycleModifier()
            lib.notify({
                title = TranslateCap('application_name'),
                description = TranslateCap('application_accepted'),
                type = 'success',
                position = 'top',
            })
        end, data)
    end

    RegisterNetEvent('esx_identity:showRegisterIdentity', function()
        TriggerEvent('esx_skin:resetFirstSpawn')
        if not ESX.PlayerData.dead then showRegistration(true) end
    end)
end
