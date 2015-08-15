-- /osdmodule/events.lua
-- dkman123@hotmail.com
-- 2015.08.15 created. current TS version 3.0.17, api 20

-- osdmodule callback functions
--
-- To avoid function name collisions, you should use local functions and export them with a unique package name.
--

-- REQUIRED SOFTWARE:
-- dzen2 is used for the message window. in debian-based linux systems use:
-- sudo apt-get install dzen2

-----------------------------------------------------------------------------

require("ts3defs")

-- I'm not sure how to create the menu window, so I can't move the settings there
local MenuIDs = {
	MENU_ID_GLOBAL_1  = 1
}

-- Will store factor to add to menuID to calculate the real menuID used in the TeamSpeak client (to support menus from multiple Lua modules)
-- Add this value to above menuID when passing the ID to setPluginMenuEnabled. See demo.lua for an example.
local moduleMenuItemID = 0

local clients = {}

local numClients=0;

-- added local
local function onTalkStatusChangeEvent(serverConnectionHandlerID, status, isReceivedWhisper, clientID)
	-- variable, you can safely change this part
	-- (x,y) coordinates for the top left corner of the window.  
	local x="50";		-- is the left to right position. 0 is left, your resolution defines the right coordinate (ex assuming 1920x1200, 1920 is the maximum x)
	local y="300";	-- is the up-down position. 0 is top, your resolution defines the bottom coordinate (ex assuming 1920x1200, 1200 is the maximum y)
	local w="160";	-- width of the window.  make this wide enough to fit the names
	local fontSize="12";
	
	-- you can use Gimp and put the HTML notation value for colors you like
	local bgColor="6699FF";
	local talkingColor="ff0000"; -- maybe FFF2C7
	local silentColor="00ff00";  -- maybe FF69F2
	local talkingWhileDisabledColor="00ffff";

	-- begin code
	numClients=0;
	local msg="";

	-- set the client status for the event received
	clients[clientID]=status;

	-- get the list of clients
	for key,val in pairs(clients) do
		-- based on the status color the client's name
--[[
local TalkStatus = {
	STATUS_NOT_TALKING = 0,
	STATUS_TALKING = 1,
	STATUS_TALKING_WHILE_DISABLED = 2
}
]]
		if (val==0) then  -- 0 = not talking/transmitting
			local clientName, error = ts3.getClientVariableAsString(serverConnectionHandlerID, key, ts3defs.ClientProperties.CLIENT_NICKNAME);
			msg = msg .. "\n^fg(#" .. silentColor .. ")" .. clientName;
			numClients = numClients + 1;
		end

		if (val==1) then  -- 1 = talking (really either voice activated transmitting or push-to-talk is pressed)
			local clientName, error = ts3.getClientVariableAsString(serverConnectionHandlerID, key, ts3defs.ClientProperties.CLIENT_NICKNAME);
			msg = msg .. "\n^fg(#" .. talkingColor .. ")" .. clientName;
			numClients = numClients + 1;
		end

		if (val==2) then  -- 2 = talking While Disabled (muted but attempting to transmit)
			local clientName, error = ts3.getClientVariableAsString(serverConnectionHandlerID, key, ts3defs.ClientProperties.CLIENT_NICKNAME);
			msg = msg .. "\n^fg(#" .. talkingWhileDisabledColor .. ")" .. clientName;
			numClients = numClients + 1;
		end
	end

	-- if there is nothing to put in the window, remove it
	if (msg=="") then
		os.execute("pkill -TERM -f \"dzen2.*TeamSpeak\"")
		return
	end

	-- display the window
	os.execute("pkill -TERM -f \"dzen2.*TeamSpeak\"")
	os.execute("echo \"TeamSpeak " .. msg .. "\" | dzen2 -p 0 -y " .. y .. " -x " .. x .. " -w " .. w .. " -bg '#" .. bgColor .. "' -fg '#161616' -fn '-*-bitstream vera sans mono-medium-r-normal-*-" .. fontSize .. "-*-*-*-*-*-*-*' -l " .. numClients .. " -e \"onstart=uncollapse\" -title-name \"TeamSpeak\" &")
--	os.execute("echo \"DEBUG TeamSpeak " .. msg .. "\" >> ~/Documents/ts3debug.log")

--[[
	-- see http://forum.teamspeak.com/showthread.php/55173-OSD-For-linux for original (uses a different library to create the window)
	--os.execute("echo \"" .. msg .. "\" | osd_cat --pos=" .. osd_pos .. " --offset=" .. osd_offset .. " --align=" .. osd_align .. " --indent=" .. osd_indent .. " --font=" .. osd_font .. " --colour=" .. osd_colour .. " --delay=" .. osd_delay .. " --lines=" .. osd_lines .. " --shadow=" .. osd_shadow .. " --shadowcolour=" .. osd_shadowcolour .. " --outline=" .. osd_outline .. " --outlinecolour=" .. osd_outlinecolour .. " --age=" .. osd_age .. " &")
]]
end

local function onConnectStatusChangeEvent(serverConnectionHandlerID, status, errorNumber)
--[[
local ConnectStatus = {
	STATUS_DISCONNECTED = 0,            -- There is no activity to the server, this is the default value
	STATUS_CONNECTING = 1,              -- We are trying to connect, we haven't got a clientID yet, we haven't been accepted by the server
	STATUS_CONNECTED = 2,               -- The server has accepted us, we can talk and hear and we got a clientID, but we don't have the channels and clients yet, we can get server infos (welcome msg etc.)
	STATUS_CONNECTION_ESTABLISHING = 3, -- we are CONNECTED and we are visible
	STATUS_CONNECTION_ESTABLISHED = 4   -- we are CONNECTED and we have the client and channels available
}
]]

    --ts3.printMessageToCurrentTab("osdModule: onConnectStatusChangeEvent: " .. serverConnectionHandlerID .. " " .. status .. " " .. errorNumber)
	--os.execute("echo \"DEBUG TeamSpeak connect event " .. status .. "\" >> ~/Documents/ts3debug.log")

	-- when disconnecting from the server kill the window (otherwise it will sit there on top until manually killed)
	if (status==0) then
		os.execute("pkill -TERM -f \"dzen2.*TeamSpeak\"")
		return
	end
end

local function onNewChannelEvent(serverConnectionHandlerID, channelID, channelParentID)
    ts3.printMessageToCurrentTab("osdModule: onNewChannelEvent: " .. serverConnectionHandlerID .. " " .. channelID .. " " .. channelParentID)

	-- Get name of this channel
	local channelName, error = ts3.getChannelVariableAsString(serverConnectionHandlerID, channelID, ts3defs.ChannelProperties.CHANNEL_NAME)
	--os.execute("echo \"DEBUG TeamSpeak channel event " .. channelID .. ", " .. channelName .. "\" >> ~/Documents/ts3debug.log")
	-- I could save the channel name and display that instead of "TeamSpeak" at the top of the window
end

--
-- Called when a plugin menu item (see ts3plugin_initMenus) is triggered. Optional function, when not using plugin menus, do not implement this.
--
-- Parameters:
--  serverConnectionHandlerID: ID of the current server tab
--  type: Type of the menu (ts3defs.PluginMenuType.PLUGIN_MENU_TYPE_CHANNEL, ts3defs.PluginMenuType.PLUGIN_MENU_TYPE_CLIENT or ts3defs.PluginMenuType.PLUGIN_MENU_TYPE_GLOBAL)
--  menuItemID: Id used when creating the menu item
--  selectedItemID: Channel or Client ID in the case of PLUGIN_MENU_TYPE_CHANNEL and PLUGIN_MENU_TYPE_CLIENT. 0 for PLUGIN_MENU_TYPE_GLOBAL.
--
local function onMenuItemEvent(serverConnectionHandlerID, menuType, menuItemID, selectedItemID)
	--ts3.printMessageToCurrentTab("osdmodule: onMenuItemEvent: " .. serverConnectionHandlerID .. " " .. menuType .. " " .. menuItemID .. " " .. selectedItemID)
	ts3.printMessageToCurrentTab("The Settings menu hasn't been implemented.  To change settings edit the /osdmodule/events.lua file.\nSearch for \"variable\".")
	--os.execute("echo \"DEBUG TeamSpeak menu event\" >> ~/Documents/ts3debug.log")
end

osdmodule_events = {
	MenuIDs = MenuIDs,
	moduleMenuItemID = moduleMenuItemID,
	onMenuItemEvent = onMenuItemEvent,
	onConnectStatusChangeEvent = onConnectStatusChangeEvent,
	onNewChannelEvent = onNewChannelEvent,
	onTalkStatusChangeEvent = onTalkStatusChangeEvent
}
