# osdmodule
TeamSpeak 3 (TS3) OSD Module for Linux

This was written using TeamSpeak 3.0.17, API 20.  So if it doesn't work on a future version you have a reference point.

It uses dzen2 to produce the overlay window.  You can get that by typing (debian style systems):
1. sudo apt-get install dzen2

2. put the files into your /[ts3]/plugins/lua_plugin/osdmodule/ folder

--

3. You'll need to go to Settings - Plugins.

Check Lua Plugin.

Select Lua Plugin.

Click Settings.

Check osdmodule.

You can uncheck testmodule.

--

You may need to reload all, or just restart TS3.

To test it you can type "/lua run osdmodule.test" into the TS3 chat window.
