function GetRealPlayerName(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		if Config.EnableESXIdentity then
			if Config.OnlyFirstname then
				return xPlayer.get('firstName')
			else
				return xPlayer.getName()
			end
		else
			return GetPlayerName(playerId)
		end
	else
		return GetPlayerName(playerId)
	end
end

-- Helper function to capitalize the first letter of each word
local function capitalizeName(name)
    return name:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

local function sendTextRangeMessage(source, message, color, textRange)
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    local sourceBucket = GetPlayerRoutingBucket(source)

    -- Include the sender in the message distribution
    TriggerClientEvent('chat:addMessage', source, {args = {message}, color = color})

    for _, targetId in ipairs(GetPlayers()) do
        if tonumber(targetId) ~= source then
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            local targetBucket = GetPlayerRoutingBucket(targetId)

            if targetBucket == sourceBucket and #(sourceCoords - targetCoords) < textRange then
                TriggerClientEvent('chat:addMessage', targetId, {args = {message}, color = color})
            end
        end
    end
end

AddEventHandler('chatMessage', function(playerId, playerName, message)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    if string.sub(message, 1, string.len('/')) ~= '/' then
        CancelEvent()

        if message == '' then
            TriggerClientEvent('chat:addMessage', playerId, {args = {"^7[^1ERROR^7]: You must provide a message."}, color = {255, 0, 0}})
            return
        end

        -- Sanitize the message by removing ^ characters
        message = message:gsub("%^", "")

        playerName = capitalizeName(GetRealPlayerName(playerId))
        local playerBucket = GetPlayerRoutingBucket(playerId)
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        local textRange = 15.0 -- Set the text range for normal chat

        -- Send white message to the sender
        TriggerClientEvent('chat:addMessage', playerId, {args = {playerName .. " says: " .. message}, color = {255, 255, 255}})

        -- Send grey message to all other players in the same bucket and within text range
        for _, targetId in ipairs(GetPlayers()) do
            if tonumber(targetId) ~= playerId then
                local targetBucket = GetPlayerRoutingBucket(targetId)
                local targetCoords = GetEntityCoords(GetPlayerPed(targetId))

                if targetBucket == playerBucket and #(playerCoords - targetCoords) < textRange then
                    TriggerClientEvent('chat:addMessage', targetId, {args = {playerName .. " says: " .. message}, color = {198, 196, 196}})
                end
            end
        end
    end
end)

RegisterCommand('id', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local searchTerm = table.concat(args, ' '):lower() -- Get the search term from the command arguments
    local requesterId = source -- The player who issued the command

    if searchTerm == '' then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Please provide a player ID or at least three letters of the player's name."}, color = {255, 0, 0}})
        return
    end

    local foundPlayers = {}

    -- Check if the search term is a number (player ID)
    local searchId = tonumber(searchTerm)
    if searchId then
        -- Search by player ID
        for _, playerId in ipairs(GetPlayers()) do
            if tonumber(playerId) == searchId then
                local playerName = capitalizeName(GetRealPlayerName(playerId))
                table.insert(foundPlayers, {id = playerId, name = playerName})
                break
            end
        end
    elseif #searchTerm >= 3 then
        -- Search by player name
        for _, playerId in ipairs(GetPlayers()) do
            local playerName = GetRealPlayerName(playerId):lower()
            if string.find(playerName, searchTerm, 1, true) then
                table.insert(foundPlayers, {id = playerId, name = capitalizeName(playerName)})
            end
        end
    else
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Please provide at least three letters of the player's name."}, color = {255, 0, 0}})
        return
    end

    if #foundPlayers > 0 then
        for _, player in ipairs(foundPlayers) do
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1INFO^7]: Player ID ^1" .. player.id .. " ^7is ^1" .. player.name .. "^7."}, color = {255, 255, 255}})
        end
    else
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1INFO^7]: No players found with the search term: ^1" .. searchTerm .. "^7."}, color = {255, 255, 255}})
    end
end, false)

RegisterCommand('me', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 15.0 -- Set the text range for /me command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /me [action]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = "* " .. playerName .. " " .. message
    local color = {194, 163, 218} -- Purple color for /me messages

    sendTextRangeMessage(source, formattedMessage, color, textRange)
end, false)

RegisterCommand('my', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 15.0 -- Set the text range for /me command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /my [action]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = "* " .. playerName .. "'s " .. message
    local color = {194, 163, 218} -- Purple color for /me messages

    sendTextRangeMessage(source, formattedMessage, color, textRange)
end, false)

RegisterCommand('do', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 15.0 -- Set the text range for /do command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /do [description]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = "* " .. message .. " (( " .. playerName .. " ))"
    local color = {194, 163, 218} -- Same purple color as /me messages

    sendTextRangeMessage(source, formattedMessage, color, textRange)
end, false)

RegisterCommand('say', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 15.0 -- Set the text range for /say command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /say [message]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = playerName .. " says: " .. message
    local senderColor = {255, 255, 255} -- White color for the sender
    local othersColor = {198, 196, 196} -- Grey color for others

    -- Send white message to the sender
    TriggerClientEvent('chat:addMessage', source, {args = {formattedMessage}, color = senderColor})

    -- Send grey message to other players within text range and same bucket
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    local sourceBucket = GetPlayerRoutingBucket(source)

    for _, targetId in ipairs(GetPlayers()) do
        if tonumber(targetId) ~= source then
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            local targetBucket = GetPlayerRoutingBucket(targetId)

            if targetBucket == sourceBucket and #(sourceCoords - targetCoords) < textRange then
                TriggerClientEvent('chat:addMessage', targetId, {args = {formattedMessage}, color = othersColor})
            end
        end
    end
end, false)

RegisterCommand('sayto', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 15.0 -- Set the text range for /sayto command
    local targetPlayerId = tonumber(args[1]) -- Get the target player ID from the command arguments
    local message = table.concat(args, ' ', 2) -- Get the message starting from the second argument
    local requesterId = source -- The player who issued the command

    if not targetPlayerId or targetPlayerId <= 0 or message == '' then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1SYNTAX^7]: /sayto [Player ID] [message]"}, color = {255, 0, 0}})
        return
    end

    if targetPlayerId == requesterId then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: You cannot send a message to yourself."}, color = {255, 0, 0}})
        return
    end

    local requesterName = capitalizeName(GetRealPlayerName(requesterId))
    local targetName = capitalizeName(GetRealPlayerName(targetPlayerId))

    if targetName then
        local requesterBucket = GetPlayerRoutingBucket(requesterId)
        local targetBucket = GetPlayerRoutingBucket(targetPlayerId)

        if requesterBucket ~= targetBucket then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is in a different routing bucket."}, color = {255, 0, 0}})
            return
        end

        local requesterCoords = GetEntityCoords(GetPlayerPed(requesterId))
        local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))

        if #(requesterCoords - targetCoords) > textRange then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is too far away."}, color = {255, 0, 0}})
            return
        end

        -- Format the message
        local formattedMessage = requesterName .. " says to " .. targetName .. ": " .. message
        local targetFormattedMessage = "^7[^1!^7] " .. formattedMessage

        -- Send white message to the sender
        TriggerClientEvent('chat:addMessage', requesterId, {args = {formattedMessage}, color = {255, 255, 255}})

        -- Send highlighted message to the target player
        TriggerClientEvent('chat:addMessage', targetPlayerId, {args = {targetFormattedMessage}, color = {198, 196, 196}})

        -- Send grey message to other players in text range
        for _, otherPlayerId in ipairs(GetPlayers()) do
            if tonumber(otherPlayerId) ~= requesterId and tonumber(otherPlayerId) ~= targetPlayerId then
                local otherPlayerCoords = GetEntityCoords(GetPlayerPed(otherPlayerId))
                if #(requesterCoords - otherPlayerCoords) < textRange and GetPlayerRoutingBucket(otherPlayerId) == requesterBucket then
                    TriggerClientEvent('chat:addMessage', otherPlayerId, {args = {formattedMessage}, color = {198, 196, 196}})
                end
            end
        end
    else
        -- Inform the requester that the target player ID is invalid
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Invalid player ID: ^1" .. targetPlayerId .. "^7."}, color = {255, 0, 0}})
    end
end, false)

RegisterCommand('b', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 15.0 -- Set the text range for /say command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /b [message]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = "(( [LOOC] " .. playerName .. " says: " .. message .. " ))"
    local senderColor = {90, 90, 91} -- Purple color for the sender
    local othersColor = {90, 90, 91} -- Grey color for others

    -- Send white message to the sender
    TriggerClientEvent('chat:addMessage', source, {args = {formattedMessage}, color = senderColor})

    -- Send grey message to other players within text range and same bucket
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    local sourceBucket = GetPlayerRoutingBucket(source)

    for _, targetId in ipairs(GetPlayers()) do
        if tonumber(targetId) ~= source then
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            local targetBucket = GetPlayerRoutingBucket(targetId)

            if targetBucket == sourceBucket and #(sourceCoords - targetCoords) < textRange then
                TriggerClientEvent('chat:addMessage', targetId, {args = {formattedMessage}, color = othersColor})
            end
        end
    end
end, false)

RegisterCommand('blow', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 5.0 -- Set the text range for /say command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /blow [message]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = "(( [LOOC] " .. playerName .. " says (low): " .. message .. " ))"
    local senderColor = {90, 90, 91} -- White color for the sender
    local othersColor = {90, 90, 91} -- Grey color for others

    -- Send white message to the sender
    TriggerClientEvent('chat:addMessage', source, {args = {formattedMessage}, color = senderColor})

    -- Send grey message to other players within text range and same bucket
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    local sourceBucket = GetPlayerRoutingBucket(source)

    for _, targetId in ipairs(GetPlayers()) do
        if tonumber(targetId) ~= source then
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            local targetBucket = GetPlayerRoutingBucket(targetId)

            if targetBucket == sourceBucket and #(sourceCoords - targetCoords) < textRange then
                TriggerClientEvent('chat:addMessage', targetId, {args = {formattedMessage}, color = othersColor})
            end
        end
    end
end, false)

RegisterCommand('bto', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 15.0 -- Set the text range for /sayto command
    local targetPlayerId = tonumber(args[1]) -- Get the target player ID from the command arguments
    local message = table.concat(args, ' ', 2) -- Get the message starting from the second argument
    local requesterId = source -- The player who issued the command

    if not targetPlayerId or targetPlayerId <= 0 or message == '' then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1SYNTAX^7]: /bto [Player ID] [message]"}, color = {255, 0, 0}})
        return
    end

    if targetPlayerId == requesterId then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: You cannot send a message to yourself."}, color = {255, 0, 0}})
        return
    end

    local requesterName = capitalizeName(GetRealPlayerName(requesterId))
    local targetName = capitalizeName(GetRealPlayerName(targetPlayerId))

    if targetName then
        local requesterBucket = GetPlayerRoutingBucket(requesterId)
        local targetBucket = GetPlayerRoutingBucket(targetPlayerId)

        if requesterBucket ~= targetBucket then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is in a different routing bucket."}, color = {255, 0, 0}})
            return
        end

        local requesterCoords = GetEntityCoords(GetPlayerPed(requesterId))
        local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))

        if #(requesterCoords - targetCoords) > textRange then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is too far away."}, color = {255, 0, 0}})
            return
        end

        -- Format the message
        local formattedMessage = "(( [LOOC] " .. requesterName .. " says to " .. targetName .. ": " .. message .. " ))"
        local targetFormattedMessage = "^7[^1!^7] " .. formattedMessage

        -- Send white message to the sender
        TriggerClientEvent('chat:addMessage', requesterId, {args = {formattedMessage}, color = {90, 90, 91}})

        -- Send highlighted message to the target player
        TriggerClientEvent('chat:addMessage', targetPlayerId, {args = {targetFormattedMessage}, color = {90, 90, 91}})

        -- Send grey message to other players in text range
        for _, otherPlayerId in ipairs(GetPlayers()) do
            if tonumber(otherPlayerId) ~= requesterId and tonumber(otherPlayerId) ~= targetPlayerId then
                local otherPlayerCoords = GetEntityCoords(GetPlayerPed(otherPlayerId))
                if #(requesterCoords - otherPlayerCoords) < textRange and GetPlayerRoutingBucket(otherPlayerId) == requesterBucket then
                    TriggerClientEvent('chat:addMessage', otherPlayerId, {args = {formattedMessage}, color = {90, 90, 91}})
                end
            end
        end
    else
        -- Inform the requester that the target player ID is invalid
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Invalid player ID: ^1" .. targetPlayerId .. "^7."}, color = {255, 0, 0}})
    end
end, false)

RegisterCommand('blowto', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 5.0 -- Set the text range for /sayto command
    local targetPlayerId = tonumber(args[1]) -- Get the target player ID from the command arguments
    local message = table.concat(args, ' ', 2) -- Get the message starting from the second argument
    local requesterId = source -- The player who issued the command

    if not targetPlayerId or targetPlayerId <= 0 or message == '' then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1SYNTAX^7]: /blowto [Player ID] [message]"}, color = {255, 0, 0}})
        return
    end

    if targetPlayerId == requesterId then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: You cannot send a message to yourself."}, color = {255, 0, 0}})
        return
    end

    local requesterName = capitalizeName(GetRealPlayerName(requesterId))
    local targetName = capitalizeName(GetRealPlayerName(targetPlayerId))

    if targetName then
        local requesterBucket = GetPlayerRoutingBucket(requesterId)
        local targetBucket = GetPlayerRoutingBucket(targetPlayerId)

        if requesterBucket ~= targetBucket then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is in a different routing bucket."}, color = {255, 0, 0}})
            return
        end

        local requesterCoords = GetEntityCoords(GetPlayerPed(requesterId))
        local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))

        if #(requesterCoords - targetCoords) > textRange then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is too far away."}, color = {255, 0, 0}})
            return
        end

        -- Format the message
        local formattedMessage = "(( [LOOC] " .. requesterName .. " says to " .. targetName .. ": " .. message .. " ))"
        local targetFormattedMessage = "^7[^1!^7] " .. formattedMessage

        -- Send white message to the sender
        TriggerClientEvent('chat:addMessage', requesterId, {args = {formattedMessage}, color = {90, 90, 91}})

        -- Send highlighted message to the target player
        TriggerClientEvent('chat:addMessage', targetPlayerId, {args = {targetFormattedMessage}, color = {90, 90, 91}})

        -- Send grey message to other players in text range
        for _, otherPlayerId in ipairs(GetPlayers()) do
            if tonumber(otherPlayerId) ~= requesterId and tonumber(otherPlayerId) ~= targetPlayerId then
                local otherPlayerCoords = GetEntityCoords(GetPlayerPed(otherPlayerId))
                if #(requesterCoords - otherPlayerCoords) < textRange and GetPlayerRoutingBucket(otherPlayerId) == requesterBucket then
                    TriggerClientEvent('chat:addMessage', otherPlayerId, {args = {formattedMessage}, color = {90, 90, 91}})
                end
            end
        end
    else
        -- Inform the requester that the target player ID is invalid
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Invalid player ID: ^1" .. targetPlayerId .. "^7."}, color = {255, 0, 0}})
    end
end, false)

RegisterCommand('melow', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 5.0 -- Set the text range for /me command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /melow [action]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = "* " .. playerName .. " " .. message
    local color = {194, 163, 218} -- Purple color for /me messages

    sendTextRangeMessage(source, formattedMessage, color, textRange)
end, false)

RegisterCommand('mylow', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 5.0 -- Set the text range for /me command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /mylow [action]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = "* " .. playerName .. "'s " .. message
    local color = {194, 163, 218} -- Purple color for /me messages

    sendTextRangeMessage(source, formattedMessage, color, textRange)
end, false)

RegisterCommand('dolow', function(source, args, rawCommand)
    local textRange = 5.0 -- Set the text range for /do command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /dolow [description]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = "* " .. message .. " (( " .. playerName .. " ))"
    local color = {194, 163, 218} -- Same purple color as /me messages

    sendTextRangeMessage(source, formattedMessage, color, textRange)
end, false)

RegisterCommand('low', function(source, args, rawCommand)
    local textRange = 5.0 -- Set the text range for /say command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /low [message]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = playerName .. " says (low): " .. message
    local senderColor = {147, 151, 153} -- White color for the sender
    local othersColor = {90, 90, 91} -- Grey color for others

    -- Send white message to the sender
    TriggerClientEvent('chat:addMessage', source, {args = {formattedMessage}, color = senderColor})

    -- Send grey message to other players within text range and same bucket
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    local sourceBucket = GetPlayerRoutingBucket(source)

    for _, targetId in ipairs(GetPlayers()) do
        if tonumber(targetId) ~= source then
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            local targetBucket = GetPlayerRoutingBucket(targetId)

            if targetBucket == sourceBucket and #(sourceCoords - targetCoords) < textRange then
                TriggerClientEvent('chat:addMessage', targetId, {args = {formattedMessage}, color = othersColor})
            end
        end
    end
end, false)

RegisterCommand('lowto', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 5.0 -- Set the text range for /sayto command
    local targetPlayerId = tonumber(args[1]) -- Get the target player ID from the command arguments
    local message = table.concat(args, ' ', 2) -- Get the message starting from the second argument
    local requesterId = source -- The player who issued the command

    if not targetPlayerId or targetPlayerId <= 0 or message == '' then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1SYNTAX^7]: /lowto [Player ID] [message]"}, color = {255, 0, 0}})
        return
    end

    if targetPlayerId == requesterId then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: You cannot send a message to yourself."}, color = {255, 0, 0}})
        return
    end

    local requesterName = capitalizeName(GetRealPlayerName(requesterId))
    local targetName = capitalizeName(GetRealPlayerName(targetPlayerId))

    if targetName then
        local requesterBucket = GetPlayerRoutingBucket(requesterId)
        local targetBucket = GetPlayerRoutingBucket(targetPlayerId)

        if requesterBucket ~= targetBucket then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is in a different routing bucket."}, color = {255, 0, 0}})
            return
        end

        local requesterCoords = GetEntityCoords(GetPlayerPed(requesterId))
        local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))

        if #(requesterCoords - targetCoords) > textRange then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is too far away."}, color = {255, 0, 0}})
            return
        end

        -- Format the message
        local formattedMessage = requesterName .. " says to " .. targetName .. " (low): " .. message
        local targetFormattedMessage = "^7[^1!^7] " .. formattedMessage

        -- Send white message to the sender
        TriggerClientEvent('chat:addMessage', requesterId, {args = {formattedMessage}, color = {147, 151, 153}})

        -- Send highlighted message to the target player
        TriggerClientEvent('chat:addMessage', targetPlayerId, {args = {targetFormattedMessage}, color = {90, 90, 91}})

        -- Send grey message to other players in text range
        for _, otherPlayerId in ipairs(GetPlayers()) do
            if tonumber(otherPlayerId) ~= requesterId and tonumber(otherPlayerId) ~= targetPlayerId then
                local otherPlayerCoords = GetEntityCoords(GetPlayerPed(otherPlayerId))
                if #(requesterCoords - otherPlayerCoords) < textRange and GetPlayerRoutingBucket(otherPlayerId) == requesterBucket then
                    TriggerClientEvent('chat:addMessage', otherPlayerId, {args = {formattedMessage}, color = {90, 90, 91}})
                end
            end
        end
    else
        -- Inform the requester that the target player ID is invalid
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Invalid player ID: ^1" .. targetPlayerId .. "^7."}, color = {255, 0, 0}})
    end
end, false)

RegisterCommand('whisper', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 2.0 -- Set the text range for /say command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /whisper [message]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = playerName .. " whispers: " .. message
    local senderColor = {237, 168, 65} -- White color for the sender
    local othersColor = {237, 168, 65} -- Grey color for others

    -- Send white message to the sender
    TriggerClientEvent('chat:addMessage', source, {args = {formattedMessage}, color = senderColor})

    -- Send grey message to other players within text range and same bucket
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    local sourceBucket = GetPlayerRoutingBucket(source)

    for _, targetId in ipairs(GetPlayers()) do
        if tonumber(targetId) ~= source then
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            local targetBucket = GetPlayerRoutingBucket(targetId)

            if targetBucket == sourceBucket and #(sourceCoords - targetCoords) < textRange then
                TriggerClientEvent('chat:addMessage', targetId, {args = {formattedMessage}, color = othersColor})
            end
        end
    end
end, false)

RegisterCommand('whisperto', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 2.0 -- Set the text range for /sayto command
    local targetPlayerId = tonumber(args[1]) -- Get the target player ID from the command arguments
    local message = table.concat(args, ' ', 2) -- Get the message starting from the second argument
    local requesterId = source -- The player who issued the command

    if not targetPlayerId or targetPlayerId <= 0 or message == '' then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1SYNTAX^7]: /whisperto [Player ID] [message]"}, color = {255, 0, 0}})
        return
    end

    if targetPlayerId == requesterId then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: You cannot send a message to yourself."}, color = {255, 0, 0}})
        return
    end

    local requesterName = capitalizeName(GetRealPlayerName(requesterId))
    local targetName = capitalizeName(GetRealPlayerName(targetPlayerId))

    if targetName then
        local requesterBucket = GetPlayerRoutingBucket(requesterId)
        local targetBucket = GetPlayerRoutingBucket(targetPlayerId)

        if requesterBucket ~= targetBucket then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is in a different routing bucket."}, color = {255, 0, 0}})
            return
        end

        local requesterCoords = GetEntityCoords(GetPlayerPed(requesterId))
        local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))

        if #(requesterCoords - targetCoords) > textRange then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is too far away."}, color = {255, 0, 0}})
            return
        end

        -- Format the message
        local formattedMessage = requesterName .. " whispers to " .. targetName .. " : " .. message
        local targetFormattedMessage = "^7[^1!^7] " .. formattedMessage

        -- Send white message to the sender
        TriggerClientEvent('chat:addMessage', requesterId, {args = {formattedMessage}, color = {237, 168, 65}})

        -- Send highlighted message to the target player
        TriggerClientEvent('chat:addMessage', targetPlayerId, {args = {targetFormattedMessage}, color = {237, 168, 65}})
    else
        -- Inform the requester that the target player ID is invalid
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Invalid player ID: ^1" .. targetPlayerId .. "^7."}, color = {255, 0, 0}})
    end
end, false)

RegisterCommand('shout', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 15.0 -- Set the text range for /say command
    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /say [message]"}, color = {255, 0, 0}})
        return
    end

    -- Sanitize the message by removing ^ characters
    message = message:gsub("%^", "")

    local playerName = capitalizeName(GetRealPlayerName(source))
    local formattedMessage = playerName .. " shouts: " .. message
    local senderColor = {255, 255, 255} -- White color for the sender
    local othersColor = {198, 196, 196} -- Grey color for others

    -- Send white message to the sender
    TriggerClientEvent('chat:addMessage', source, {args = {formattedMessage}, color = senderColor})

    -- Send grey message to other players within text range and same bucket
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    local sourceBucket = GetPlayerRoutingBucket(source)

    for _, targetId in ipairs(GetPlayers()) do
        if tonumber(targetId) ~= source then
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            local targetBucket = GetPlayerRoutingBucket(targetId)

            if targetBucket == sourceBucket and #(sourceCoords - targetCoords) < textRange then
                TriggerClientEvent('chat:addMessage', targetId, {args = {formattedMessage}, color = othersColor})
            end
        end
    end
end, false)

RegisterCommand('shoutto', function(source, args, rawCommand)

    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local textRange = 30.0 -- Set the text range for /sayto command
    local targetPlayerId = tonumber(args[1]) -- Get the target player ID from the command arguments
    local message = table.concat(args, ' ', 2) -- Get the message starting from the second argument
    local requesterId = source -- The player who issued the command

    if not targetPlayerId or targetPlayerId <= 0 or message == '' then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1SYNTAX^7]: /shoutto [Player ID] [message]"}, color = {255, 0, 0}})
        return
    end

    if targetPlayerId == requesterId then
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: You cannot send a message to yourself."}, color = {255, 0, 0}})
        return
    end

    local requesterName = capitalizeName(GetRealPlayerName(requesterId))
    local targetName = capitalizeName(GetRealPlayerName(targetPlayerId))

    if targetName then
        local requesterBucket = GetPlayerRoutingBucket(requesterId)
        local targetBucket = GetPlayerRoutingBucket(targetPlayerId)

        if requesterBucket ~= targetBucket then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is in a different routing bucket."}, color = {255, 0, 0}})
            return
        end

        local requesterCoords = GetEntityCoords(GetPlayerPed(requesterId))
        local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayerId))

        if #(requesterCoords - targetCoords) > textRange then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Target player is too far away."}, color = {255, 0, 0}})
            return
        end

        -- Format the message
        local formattedMessage = requesterName .. " shouts to " .. targetName .. ": " .. message
        local targetFormattedMessage = "^7[^1!^7] " .. formattedMessage

        -- Send white message to the sender
        TriggerClientEvent('chat:addMessage', requesterId, {args = {formattedMessage}, color = {255, 255, 255}})

        -- Send highlighted message to the target player
        TriggerClientEvent('chat:addMessage', targetPlayerId, {args = {targetFormattedMessage}, color = {198, 196, 196}})

        -- Send grey message to other players in text range
        for _, otherPlayerId in ipairs(GetPlayers()) do
            if tonumber(otherPlayerId) ~= requesterId and tonumber(otherPlayerId) ~= targetPlayerId then
                local otherPlayerCoords = GetEntityCoords(GetPlayerPed(otherPlayerId))
                if #(requesterCoords - otherPlayerCoords) < textRange and GetPlayerRoutingBucket(otherPlayerId) == requesterBucket then
                    TriggerClientEvent('chat:addMessage', otherPlayerId, {args = {formattedMessage}, color = {198, 196, 196}})
                end
            end
        end
    else
        -- Inform the requester that the target player ID is invalid
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Invalid player ID: ^1" .. targetPlayerId .. "^7."}, color = {255, 0, 0}})
    end
end, false)

local pmStatus = {} -- Table to track PM status for each player

-- Ensure PMs are enabled by default when a player connects
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local playerId = source
    pmStatus[playerId] = true
end)

RegisterCommand('togglepm', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    -- Check current PM status and toggle it
    local currentStatus = pmStatus[source] or true -- Default to true if not set
    pmStatus[source] = not currentStatus

    local statusMessage = pmStatus[source] and "enabled" or "disabled"
    TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: PMs are now " .. statusMessage .. "."}, color = {255, 255, 255}})
end, false)

RegisterCommand('pm', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    if #args < 2 then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /pm [Player ID or Name] [message]"}, color = {255, 0, 0}})
        return
    end

    local searchTerm = args[1]:lower() -- Get the search term from the first argument
    local message = table.concat(args, ' ', 2) -- Get the message starting from the second argument
    local requesterId = source -- The player who issued the command

    local foundPlayerId = nil
    local foundPlayerName = nil

    -- Check if the search term is a number (player ID)
    local searchId = tonumber(searchTerm)
    if searchId and searchId > 0 then
        -- Search by player ID
        for _, playerId in ipairs(GetPlayers()) do
            if tonumber(playerId) == searchId then
                foundPlayerId = playerId
                foundPlayerName = capitalizeName(GetRealPlayerName(playerId))
                break
            end
        end
    elseif #searchTerm >= 3 then
        -- Search by player name
        for _, playerId in ipairs(GetPlayers()) do
            local playerName = GetRealPlayerName(playerId):lower()
            if string.find(playerName, searchTerm, 1, true) then
                foundPlayerId = playerId
                foundPlayerName = capitalizeName(playerName)
                break
            end
        end
    else
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: Please provide at least three letters of the player's name."}, color = {255, 0, 0}})
        return
    end

    if foundPlayerId then
        if foundPlayerId == requesterId then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: You cannot send a message to yourself."}, color = {255, 0, 0}})
            return
        end

        if pmStatus[foundPlayerId] == false then
            TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: The player has disabled PMs."}, color = {255, 0, 0}})
            return
        end

        local requesterName = capitalizeName(GetRealPlayerName(requesterId))
        local formattedMessageToSender = "(( PM sent to " .. foundPlayerName .. ": " .. message .. " ))"
        local formattedMessageToReceiver = "(( PM received from " .. requesterName .. ": " .. message .. " ))"

        -- Send confirmation message to the sender
        TriggerClientEvent('chat:addMessage', requesterId, {args = {formattedMessageToSender}, color = {251, 247, 36}})

        -- Send private message to the target player
        TriggerClientEvent('chat:addMessage', foundPlayerId, {args = {formattedMessageToReceiver}, color = {251, 226, 36}})
    else
        -- Inform the requester that no player was found
        TriggerClientEvent('chat:addMessage', requesterId, {args = {"^7[^1ERROR^7]: No player found with the search term: ^1" .. searchTerm .. "^7."}, color = {255, 0, 0}})
    end
end, false)

RegisterCommand('online', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local playerCount = #GetPlayers() -- Get the number of players online
    local message = "^7[^1INFO^7]: There are currently ^1" .. playerCount .. " ^7players online."

    -- Send the message to the player who issued the command
    TriggerClientEvent('chat:addMessage', source, {args = {message}, color = {255, 255, 255}})
end, false)

RegisterCommand('admins', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local rankNames = {
        admin = "Super Admin",
        probationary_admin = "Probationary Admin",
        administrator = "Administrator",
        senior_administrator = "Senior Administrator",
        lead_administrator = "Lead Administrator",
        management = "Management"
    }

    local adminList = {}
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local playerGroup = xPlayer.getGroup()
            if rankNames[playerGroup] then
                local playerName = GetRealPlayerName(playerId)
                table.insert(adminList, {id = playerId, name = playerName, group = rankNames[playerGroup]})
            else
                TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: Player ID ^1" .. playerId .. " ^7has an undefined admin rank: ^1" .. playerGroup .. "^7."}, color = {255, 0, 0}})
            end
        end
    end

    if #adminList > 0 then
        for _, admin in ipairs(adminList) do
            TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ADMIN^7]: ID ^1" .. admin.id .. " ^7- ^1" .. admin.name .. " ^7(Rank: ^1" .. admin.group .. "^7)"}, color = {255, 255, 255}})
        end
    else
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: No admins are currently online."}, color = {255, 255, 255}})
    end
end, false)

RegisterCommand('testers', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local rankNames = {
        tester = "Tester"
    }

    local testerList = {}
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local playerGroup = xPlayer.getGroup()
            if rankNames[playerGroup] then
                local playerName = GetRealPlayerName(playerId)
                table.insert(testerList, {id = playerId, name = playerName, group = rankNames[playerGroup]})
            else
                TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: Rank ^1Tester^7 is ^1undefined^7."}, color = {255, 0, 0}})
            end
        end
    end

    if #testerList > 0 then
        for _, tester in ipairs(testerList) do
            TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1TESTER^7]: ID ^1" .. tester.id .. " ^7- ^1" .. tester.name .. " ^7(Rank: ^1" .. tester.group .. "^7)"}, color = {255, 255, 255}})
        end
    else
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: No testers are currently online."}, color = {255, 255, 255}})
    end
end, false)

local reports = {} -- Table to store reports

RegisterCommand('report', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /report [message]"}, color = {255, 0, 0}})
        return
    end

    if reports[source] then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: You already have a pending report."}, color = {255, 0, 0}})
        return
    end

    local playerName = GetRealPlayerName(source)
    reports[source] = {message = message, status = "pending", name = playerName}
    TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: Your report has been submitted."}, color = {255, 255, 255}})

    -- Notify admins about the new report
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local playerGroup = xPlayer.getGroup()
            if playerGroup == 'admin' or playerGroup == 'probationary_admin' or playerGroup == 'administrator' or
               playerGroup == 'senior_administrator' or playerGroup == 'lead_administrator' or playerGroup == 'management' then
                TriggerClientEvent('chat:addMessage', playerId, {args = {"^7[^1REPORT^7]: New report from ^1" .. playerName .. " (ID: " .. source .. ")^7: " .. message}, color = {255, 255, 0}})
            end
        end
    end
end, false)

RegisterCommand('acceptreport', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not reports[targetId] then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: Invalid report ID."}, color = {255, 0, 0}})
        return
    end

    local targetName = reports[targetId].name
    local adminName = GetRealPlayerName(source)
    reports[targetId] = nil
    TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: Report from ^1" .. targetName .. " (ID: " .. targetId .. ") ^7has been accepted."}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', targetId, {args = {"^7[^1INFO^7]: Your report has been accepted by admin ^1" .. adminName .. "^7."}, color = {255, 255, 255}})

    -- Notify other admins
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local playerGroup = xPlayer.getGroup()
            if playerGroup == 'admin' or playerGroup == 'probationary_admin' or playerGroup == 'administrator' or
               playerGroup == 'senior_administrator' or playerGroup == 'lead_administrator' or playerGroup == 'management' then
                if playerId ~= source then
                    TriggerClientEvent('chat:addMessage', playerId, {args = {"^7[^1REPORT^7]: Report from ^1" .. targetName .. " (ID: " .. targetId .. ") ^7has been accepted by admin ^1" .. adminName .. " (ID: " .. source .. ")^7."}, color = {255, 255, 0}})
                end
            end
        end
    end
end, false)

RegisterCommand('trashreport', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not reports[targetId] then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: Invalid report ID."}, color = {255, 0, 0}})
        return
    end

    local targetName = reports[targetId].name
    local adminName = GetRealPlayerName(source)
    reports[targetId] = nil
    TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: Report from ^1" .. targetName .. " (ID: " .. targetId .. ") ^7has been trashed."}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', targetId, {args = {"^7[^1INFO^7]: Your report has been trashed by admin ^1" .. adminName .. "^7."}, color = {255, 0, 0}})

    -- Notify other admins
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            local playerGroup = xPlayer.getGroup()
            if playerGroup == 'admin' or playerGroup == 'probationary_admin' or playerGroup == 'administrator' or
               playerGroup == 'senior_administrator' or playerGroup == 'lead_administrator' or playerGroup == 'management' then
                if playerId ~= source then
                    TriggerClientEvent('chat:addMessage', playerId, {args = {"^7[^1REPORT^7]: Report from ^1" .. targetName .. " (ID: " .. targetId .. ") ^7has been trashed by admin ^1" .. adminName .. " (ID: " .. source .. ")^7."}, color = {255, 255, 0}})
                end
            end
        end
    end
end, false)

RegisterCommand('listreports', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: You do not have permission to use this command."}, color = {255, 0, 0}})
        return
    end

    local playerGroup = xPlayer.getGroup()
    if playerGroup ~= 'admin' and playerGroup ~= 'probationary_admin' and playerGroup ~= 'administrator' and
       playerGroup ~= 'senior_administrator' and playerGroup ~= 'lead_administrator' and playerGroup ~= 'management' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: You do not have permission to use this command."}, color = {255, 0, 0}})
        return
    end

    local hasReports = false
    for playerId, report in pairs(reports) do
        hasReports = true
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1REPORT^7]: ^1" .. report.name .. " (ID: " .. playerId .. ") ^7- Message: ^1" .. report.message .. "^7."}, color = {255, 255, 255}})
    end

    if not hasReports then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: There are no pending reports."}, color = {255, 255, 255}})
    end
end, false)

local helpRequests = {} -- Table to store help requests

RegisterCommand('helpme', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local message = table.concat(args, ' ')
    if message == '' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /helpme [question]"}, color = {255, 0, 0}})
        return
    end

    if helpRequests[source] then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: You already have a pending help request."}, color = {255, 0, 0}})
        return
    end

    local playerName = GetRealPlayerName(source)
    helpRequests[source] = {message = message, status = "pending", name = playerName}
    TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: Your help request has been submitted."}, color = {255, 255, 255}})

    -- Notify testers about the new help request
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.getGroup() == 'tester' then
            TriggerClientEvent('chat:addMessage', playerId, {args = {"^7[^1HELP REQUEST^7]: New help request from ^1" .. playerName .. " (ID: " .. source .. ")^7: " .. message}, color = {255, 255, 0}})
        end
    end
end, false)

RegisterCommand('accepthelpme', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not helpRequests[targetId] then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: Invalid help request ID."}, color = {255, 0, 0}})
        return
    end

    local targetName = helpRequests[targetId].name
    local testerName = GetRealPlayerName(source)
    helpRequests[targetId] = nil
    TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: Help request from ^1" .. targetName .. " (ID: " .. targetId .. ") ^7has been accepted."}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', targetId, {args = {"^7[^1INFO^7]: Your help request has been accepted by tester ^1" .. testerName .. "^7."}, color = {255, 255, 255}})

    -- Notify other testers
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.getGroup() == 'tester' and playerId ~= source then
            TriggerClientEvent('chat:addMessage', playerId, {args = {"^7[^1HELP REQUEST^7]: Help request from ^1" .. targetName .. " (ID: " .. targetId .. ") ^7has been accepted by tester ^1" .. testerName .. " (ID: " .. source .. ")^7."}, color = {255, 255, 0}})
        end
    end
end, false)

RegisterCommand('trashhelpme', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId or not helpRequests[targetId] then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: Invalid help request ID."}, color = {255, 0, 0}})
        return
    end

    local targetName = helpRequests[targetId].name
    local testerName = GetRealPlayerName(source)
    helpRequests[targetId] = nil
    TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: Help request from ^1" .. targetName .. " (ID: " .. targetId .. ") ^7has been trashed."}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', targetId, {args = {"^7[^1INFO^7]: Your help request has been trashed by tester ^1" .. testerName .. "^7."}, color = {255, 0, 0}})

    -- Notify other testers
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.getGroup() == 'tester' and playerId ~= source then
            TriggerClientEvent('chat:addMessage', playerId, {args = {"^7[^1HELP REQUEST^7]: Help request from ^1" .. targetName .. " (ID: " .. targetId .. ") ^7has been trashed by tester ^1" .. testerName .. " (ID: " .. source .. ")^7."}, color = {255, 255, 0}})
        end
    end
end, false)

RegisterCommand('listhelpmes', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.getGroup() ~= 'tester' then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: You do not have permission to use this command."}, color = {255, 0, 0}})
        return
    end

    local hasHelpRequests = false
    for playerId, request in pairs(helpRequests) do
        hasHelpRequests = true
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1HELP REQUEST^7]: ^1" .. request.name .. " (ID: " .. playerId .. ") ^7- Question: ^1" .. request.message .. "^7."}, color = {255, 255, 255}})
    end

    if not hasHelpRequests then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: There are no pending help requests."}, color = {255, 255, 255}})
    end
end, false)

RegisterCommand('stats', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1ERROR^7]: Unable to retrieve player data."}, color = {255, 0, 0}})
        return
    end

    -- Retrieve player information
    local firstName = xPlayer.get('firstName') or "N/A"
    local lastName = xPlayer.get('lastName') or "N/A"
    local playerId = source
    local bankMoney = xPlayer.getAccount('bank').money or 0
    local cashMoney = xPlayer.getMoney() or 0
    local health = GetEntityHealth(GetPlayerPed(source)) or 0
    local armor = GetPedArmour(GetPlayerPed(source)) or 0
    local coords = GetEntityCoords(GetPlayerPed(source))
    local routingBucket = GetPlayerRoutingBucket(source)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")

    -- Send each line as a separate chat message
    TriggerClientEvent('chat:addMessage', source, {args = {"|---- [^1" .. firstName .. " " .. lastName .. "^7] [ID: ^1" .. playerId .. "^7]----| TIMESTAMP: ^1" .. timestamp .. "^7"}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', source, {args = {"HP: ^1" .. health .. "^7"}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', source, {args = {"AP: ^1" .. armor .. "^7"}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', source, {args = {"Cash: ^1$" .. cashMoney .. "^7"}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', source, {args = {"Bank: ^1$" .. bankMoney .. "^7"}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', source, {args = {"Coords: ^1(" .. string.format("%.2f", coords.x) .. ", " .. string.format("%.2f", coords.y) .. ", " .. string.format("%.2f", coords.z) .. ")^7"}, color = {255, 255, 255}})
    TriggerClientEvent('chat:addMessage', source, {args = {"Bucket (Dimension): ^1" .. routingBucket .. "^7"}, color = {255, 255, 255}})
end, false)

RegisterCommand('clearchat', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    -- Trigger a client event to clear the chat for the player
    TriggerClientEvent('chat:clear', source)
    TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1INFO^7]: Your chat has been cleared."}, color = {255, 255, 255}})
end, false)

RegisterCommand('flipcoin', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local result = math.random(2) == 1 and "heads" or "tails"
    local playerName = capitalizeName(GetRealPlayerName(source))
    local message = "* " .. playerName .. " flips a coin and it lands on ^1" .. result .. "^7."
    local color = {194, 163, 218} -- Purple color for /me messages
    local textRange = 15.0 -- Set the text range for proximity

    -- Use the existing function to send the message to players within proximity
    sendTextRangeMessage(source, message, color, textRange)
end, false)

RegisterCommand('dice', function(source, args, rawCommand)
    if source == 0 then
        print("^1ERROR: This command cannot be used from the console.^0")
        return
    end

    local numDice = tonumber(args[1])
    if not numDice or numDice < 1 or numDice > 3 then
        TriggerClientEvent('chat:addMessage', source, {args = {"^7[^1SYNTAX^7]: /dice [1-3]"}, color = {255, 0, 0}})
        return
    end

    local maxRoll = numDice * 6
    local rollResult = math.random(1, maxRoll)
    local playerName = capitalizeName(GetRealPlayerName(source))
    local message = "* " .. playerName .. " rolls " .. numDice .. " dice and gets a total of ^1" .. rollResult .. "^7."
    local color = {194, 163, 218} -- Purple color for /me messages
    local textRange = 15.0 -- Set the text range for proximity

    -- Use the existing function to send the message to players within proximity
    sendTextRangeMessage(source, message, color, textRange)
end, false)