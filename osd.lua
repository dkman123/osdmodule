-- /osdmodule/osd.lua
-- dkman123@hotmail.com
-- 2015.08.15 created. current TS version 3.0.17, api 20
-- 

--
-- Some TeamSpeak 3 functions for testing and demonstration (just trimmed version of testModule)
--

require("ts3defs")
require("ts3errors")

--
-- Call these function from the TeamSpeak 3 client console via: /lua run osdmodule.<function>
-- Note the serverConnectionHandlerID of the current server is always passed.
--
-- You might want to pass the "-console" option when starting the TeamSpeak 3 client to get a console where a lot
-- of plugin related debug output will appear.
--

-- Run with "/lua run osdmodule.test"
local function test(serverConnectionHandlerID)
	ts3.printMessageToCurrentTab("Test on serverConnectionHandlerID: " .. serverConnectionHandlerID)

	-- Get own client ID
	local myClientID, error = ts3.getClientID(serverConnectionHandlerID)
	if error ~= ts3errors.ERROR_ok then
		print("Error getting own client ID: " .. error)
		return
	end
	if myClientID == 0 then
		ts3.printMessageToCurrentTab("Not connected")
		return
	end
	ts3.printMessageToCurrentTab("My client ID: " .. myClientID)

	-- Get own nickname
	local myNickname, error = ts3.getClientVariableAsString(serverConnectionHandlerID, myClientID, ts3defs.ClientProperties.CLIENT_NICKNAME)
	if error ~= ts3errors.ERROR_ok then
		print("Error getting own client nickname: " .. error)
		return
	end
	ts3.printMessageToCurrentTab("My nickname: " .. myNickname)

	-- Get which channel we are in
	local myChannelID, error = ts3.getChannelOfClient(serverConnectionHandlerID, myClientID)
	if error ~= ts3errors.ERROR_ok then
		print("Error getting own channel: " .. error)
		return
	end

	-- Get the name of my channel
	local myChannelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, myChannelID, ts3defs.ChannelProperties.CHANNEL_NAME)
	if error ~= ts3errors.ERROR_ok then
		print("Error getting channel name: " .. error)
		return
	end
	ts3.printMessageToCurrentTab("I am in channel ID: " .. myChannelName .. " (" .. myChannelID .. ")")
end

-- Run with "/lua run osdmodule.argsTest <arg1> <arg2> <arg3>", args can be numbers or strings
local function argsTest(serverConnectionHandlerID, arg1, arg2, arg3)
	ts3.printMessageToCurrentTab("argsTest: " .. serverConnectionHandlerID .. " - " .. arg1 .. " " .. arg2 .. " " .. arg3)
end

-- Run with "/lua run osdmodule.showClients"
local function showClients(serverConnectionHandlerID)
	local clients, error = ts3.getClientList(serverConnectionHandlerID)
	if error == ts3errors.ERROR_not_connected then
		ts3.printMessageToCurrentTab("Not connected")
		return
	elseif error ~= ts3errors.ERROR_ok then
		print("Error getting client list: " .. error)
		return
	end

	local msg = ("There are currently " .. #clients .. " visible clients:")
	for i=1, #clients do
		local clientName, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clients[i], ts3defs.ClientProperties.CLIENT_NICKNAME)
		if error == ts3errors.ERROR_ok then
			msg = msg .. "\n " .. clients[i] .. " " .. clientName
		else
			clientName = "Error getting client name"
		end
	end
	ts3.printMessageToCurrentTab(msg)
end

--[[ LUA notes
Conditionals:
	~= not equal
	== equal


	-- Get own client ID
	local myClientID, error = ts3.getClientID(serverConnectionHandlerID)

	-- As we need the databaseID for some server commands, get own database ID from own client ID
	local myDatabaseID, error = ts3.getClientVariableAsUInt64(serverConnectionHandlerID, myClientID, ts3defs.ClientProperties.CLIENT_DATABASE_ID)

]]

-- Run with "/lua run osdmodule.showClientsInChannel <channelID>"
local function showClientsInChannel(serverConnectionHandlerID, channelID)
	-- Get list of clients in channelID passes as parameter
	local clientList, error = ts3.getChannelClientList(serverConnectionHandlerID, channelID)
	if error ~= ts3errors.ERROR_ok then
		print("Error getting channel client list: " .. error)
		return
	end

	-- Get name of this channel
	local channelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, channelID, ts3defs.ChannelProperties.CHANNEL_NAME)
	if error ~= ts3errors.ERROR_ok then
		print("Error getting channel name: " .. error)
		return
	end

	-- Loop through all clients in list and assemble message from their clientID and nickname
	msg = "Visible clients in channel " .. channelName
	for i=1, #clientList do
		local clientName, error = ts3.getClientVariableAsString(serverConnectionHandlerID, clientList[i], ts3defs.ClientProperties.CLIENT_NICKNAME)
		if error == ts3errors.ERROR_ok then
			msg = msg .. "\n " .. clientList[i] .. " " .. clientName
		else
			clientName = "Error getting client name"
		end
	end	
	ts3.printMessageToCurrentTab(msg)
end

-- Run with "/lua run osdmodule.muteClient <clientID>"
local function muteClient(serverConnectionHandlerID, clientID)
	local clientIDs = { clientID }  -- Array of clientIDs to mute. You can define multiple clientIDs here, like: clientIds = { 1, 2, 3 }
	local error = ts3.requestMuteClients(serverConnectionHandlerID, clientIDs)
	if error == ts3errors.ERROR_ok then
		ts3.printMessageToCurrentTab("Client " .. clientID .. " muted")
	else
		print("Error requesting client mute: " .. error)
	end
end

-- Run with "/lua run osdmodule.unmuteClient <clientID>"
local function unmuteClient(serverConnectionHandlerID, clientID)
	local clientIDs = { clientID }  -- Array of clientIDs to unmute. You can define multiple clientIDs here, like: clientIds = { 1, 2, 3 }
	local error = ts3.requestUnmuteClients(serverConnectionHandlerID, clientIDs)
	if error == ts3errors.ERROR_ok then
		ts3.printMessageToCurrentTab("Client " .. clientID .. " unmuted")
	else
		print("Error requesting client unmute: " .. error)
	end
end

-- Run with "/lua run osdmodule.getClientDisplayName <clientID>"
local function getClientDisplayName(serverConnectionHandlerID, clientID)
	local displayName, error = ts3.getClientDisplayName(serverConnectionHandlerID, clientID)
	if error == ts3errors.ERROR_ok then
		ts3.printMessageToCurrentTab("Client display name: " .. displayName)
	else
		print("Error getting client display name: " .. error)
	end
end


osdmodule = {
	test = test,
	argsTest = argsTest,
	showClients = showClients,
	showClientsInChannel = showClientsInChannel,
	muteClient = muteClient,
	unmuteClient = unmuteClient,
	getClientDisplayName = getClientDisplayName
}
