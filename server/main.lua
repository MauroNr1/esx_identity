local playerIdentity = {}
local alreadyRegistered = {}
local multichar = ESX.GetConfig().Multichar

local function deleteIdentityFromDatabase(xPlayer)
    MySQL.query.await(
        'UPDATE users SET firstname = ?, lastname = ?, dateofbirth = ?, sex = ?, height = ?, skin = ? WHERE identifier = ?',
        {nil, nil, nil, nil, nil, nil, xPlayer.identifier})

    if Config.FullCharDelete then
        MySQL.update.await('UPDATE addon_account_data SET money = 0 WHERE account_name IN (?) AND owner = ?',
            {{'bank_savings', 'caution'}, xPlayer.identifier})

        MySQL.prepare.await('UPDATE datastore_data SET data = ? WHERE name IN (?) AND owner = ?',
            {'\'{}\'', {'user_ears', 'user_glasses', 'user_helmet', 'user_mask'}, xPlayer.identifier})
    end
end

local function deleteIdentity(xPlayer)
    if not alreadyRegistered[xPlayer.identifier] then
        return
    end

    xPlayer.setName(('%s %s'):format(nil, nil))
    xPlayer.set('firstName', nil)
    xPlayer.set('lastName', nil)
    xPlayer.set('dateofbirth', nil)
    xPlayer.set('sex', nil)
    xPlayer.set('height', nil)
    deleteIdentityFromDatabase(xPlayer)
end

local function saveIdentityToDatabase(identifier, identity)
    MySQL.update.await(
        'UPDATE users SET firstname = ?, lastname = ?, dateofbirth = ?, sex = ?, height = ? WHERE identifier = ?',
        {identity.firstName, identity.lastName, identity.dateOfBirth, identity.sex, identity.height, identifier})
end

local function formatDate(str)
    local date
    if Config.DateFormat == "DD/MM/YYYY" then
        date = os.date('%d/%m/%Y', tonumber(str))
    elseif Config.DateFormat == "MM/DD/YYYY" then
        date = os.date('%m/%d/%Y', tonumber(str))
    elseif Config.DateFormat == "YYYY/MM/DD" then
        date = os.date('%Y/%m/%d', tonumber(str))
    end

    return date
end

local function convertToLowerCase(str)
    return string.lower(str)
end

local function convertFirstLetterToUpper(str)
    return str:gsub("^%l", string.upper)
end

local function formatName(name)
    local loweredName = convertToLowerCase(name)
    return convertFirstLetterToUpper(loweredName)
end

if Config.UseDeferrals then
    print("Deferrals are experimental and should not be used. Please put this to false in config.")
else
	local function setIdentity(xPlayer)
		if not alreadyRegistered[xPlayer.identifier] then
            return
        end
        local currentIdentity = playerIdentity[xPlayer.identifier]

        xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
        xPlayer.set('firstName', currentIdentity.firstName)
        xPlayer.set('lastName', currentIdentity.lastName)
        xPlayer.set('dateofbirth', currentIdentity.dateOfBirth)
        xPlayer.set('sex', currentIdentity.sex)
        xPlayer.set('height', currentIdentity.height)
        TriggerClientEvent('esx_identity:setPlayerData', xPlayer.source, currentIdentity)
        if currentIdentity.saveToDatabase then
            saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
        end

        playerIdentity[xPlayer.identifier] = nil
	end
	
	local function checkIdentity(xPlayer)
		MySQL.single('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ?', {xPlayer.identifier},
            function(result)
                if not result then
                    return TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
                end
                if not result.firstname then
                    playerIdentity[xPlayer.identifier] = nil
                    alreadyRegistered[xPlayer.identifier] = false
                    return TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
                end

                playerIdentity[xPlayer.identifier] = {
                    firstName = result.firstname,
                    lastName = result.lastname,
                    dateOfBirth = result.dateofbirth,
                    sex = result.sex,
                    height = result.height
                }

                alreadyRegistered[xPlayer.identifier] = true
                setIdentity(xPlayer)
            end
        )
	end

	ESX.RegisterServerCallback('esx_identity:registerIdentity', function(source, cb, data)
        data.dateofbirth = formatDate(data.dateofbirth) --We have to do this on the server because for some reason FiveM only allows os on the server
		local xPlayer = ESX.GetPlayerFromId(source)
	    if xPlayer then	
			if alreadyRegistered[xPlayer.identifier] then
				xPlayer.showNotification(TranslateCap('already_registered'), "error")
				return cb(false)
            end

            playerIdentity[xPlayer.identifier] = {
                firstName = formatName(data.firstname),
                lastName = formatName(data.lastname),
                dateOfBirth = formatDate(data.dateofbirth),
                sex = data.sex,
                height = data.height
            }

            local currentIdentity = playerIdentity[xPlayer.identifier]

            xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
            xPlayer.set('firstName', currentIdentity.firstName)
            xPlayer.set('lastName', currentIdentity.lastName)
            xPlayer.set('dateofbirth', currentIdentity.dateOfBirth)
            xPlayer.set('sex', currentIdentity.sex)
            xPlayer.set('height', currentIdentity.height)
            TriggerClientEvent('esx_identity:setPlayerData', xPlayer.source, currentIdentity)
            saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
            alreadyRegistered[xPlayer.identifier] = true
            playerIdentity[xPlayer.identifier] = nil
            return cb(true)
        end

        if not multichar then
            TriggerClientEvent("esx:showNotification", source, TranslateCap('data_incorrect'), "error")
            return cb(false)
        end

        local formattedFirstName = formatName(data.firstname)
        local formattedLastName = formatName(data.lastname)
        local formattedDate = formatDate(data.dateofbirth)

        data.firstname = formattedFirstName
        data.lastname = formattedLastName
        data.dateofbirth = formattedDate
        local Identity = {
            firstName = formattedFirstName,
            lastName = formattedLastName,
            dateOfBirth = formattedDate,
            sex = data.sex,
            height = data.height
        }

        TriggerEvent('esx_identity:completedRegistration', source, data)
        TriggerClientEvent('esx_identity:setPlayerData', source, Identity)
        cb(true)
	end)
end

if Config.EnableCommands then
	ESX.RegisterCommand('char', 'user', function(xPlayer, args, showError)
        if xPlayer and xPlayer.getName() then
            xPlayer.showNotification(TranslateCap('active_character', xPlayer.getName()))
        else
            xPlayer.showNotification(TranslateCap('error_active_character'))
        end
    end, false, {help = TranslateCap('show_active_character')})

	ESX.RegisterCommand('chardel', 'user', function(xPlayer, args, showError)
        if xPlayer and xPlayer.getName() then
            if Config.UseDeferrals then
                xPlayer.kick(TranslateCap('deleted_identity'))
                Wait(1500)
                deleteIdentity(xPlayer)
                xPlayer.showNotification(TranslateCap('deleted_character'))
                playerIdentity[xPlayer.identifier] = nil
                alreadyRegistered[xPlayer.identifier] = false
            else
                deleteIdentity(xPlayer)
                xPlayer.showNotification(TranslateCap('deleted_character'))
                playerIdentity[xPlayer.identifier] = nil
                alreadyRegistered[xPlayer.identifier] = false
                TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
            end
        else
            xPlayer.showNotification(TranslateCap('error_delete_character'))
        end
    end, false, {help = TranslateCap('delete_character')})
end

if Config.EnableDebugging then
    ESX.RegisterCommand('xPlayerGetFirstName', 'user', function(xPlayer, args, showError)
        if xPlayer and xPlayer.get('firstName') then
            xPlayer.showNotification(TranslateCap('return_debug_xPlayer_get_first_name', xPlayer.get('firstName')))
        else
            xPlayer.showNotification(TranslateCap('error_debug_xPlayer_get_first_name'))
        end
    end, false, {help = TranslateCap('debug_xPlayer_get_first_name')})

    ESX.RegisterCommand('xPlayerGetLastName', 'user', function(xPlayer, args, showError)
        if xPlayer and xPlayer.get('lastName') then
            xPlayer.showNotification(TranslateCap('return_debug_xPlayer_get_last_name', xPlayer.get('lastName')))
        else
            xPlayer.showNotification(TranslateCap('error_debug_xPlayer_get_last_name'))
        end
    end, false, {help = TranslateCap('debug_xPlayer_get_last_name')})

    ESX.RegisterCommand('xPlayerGetFullName', 'user', function(xPlayer, args, showError)
        if xPlayer and xPlayer.getName() then
            xPlayer.showNotification(TranslateCap('return_debug_xPlayer_get_full_name', xPlayer.getName()))
        else
            xPlayer.showNotification(TranslateCap('error_debug_xPlayer_get_full_name'))
        end
    end, false, {help = TranslateCap('debug_xPlayer_get_full_name')})

    ESX.RegisterCommand('xPlayerGetSex', 'user', function(xPlayer, args, showError)
        if xPlayer and xPlayer.get('sex') then
            xPlayer.showNotification(TranslateCap('return_debug_xPlayer_get_sex', xPlayer.get('sex')))
        else
            xPlayer.showNotification(TranslateCap('error_debug_xPlayer_get_sex'))
        end
    end, false, {help = TranslateCap('debug_xPlayer_get_sex')})

    ESX.RegisterCommand('xPlayerGetDOB', 'user', function(xPlayer, args, showError)
        if xPlayer and xPlayer.get('dateofbirth') then
            xPlayer.showNotification(TranslateCap('return_debug_xPlayer_get_dob', xPlayer.get('dateofbirth')))
        else
            xPlayer.showNotification(TranslateCap('error_debug_xPlayer_get_dob'))
        end
    end, false, {help = TranslateCap('debug_xPlayer_get_dob')})

    ESX.RegisterCommand('xPlayerGetHeight', 'user', function(xPlayer, args, showError)
        if xPlayer and xPlayer.get('height') then
            xPlayer.showNotification(TranslateCap('return_debug_xPlayer_get_height', xPlayer.get('height')))
        else
            xPlayer.showNotification(TranslateCap('error_debug_xPlayer_get_height'))
        end
    end, false, {help = TranslateCap('debug_xPlayer_get_height')})
end
