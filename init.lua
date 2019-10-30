-- all functions below are optional and can be left out
if not async then
	-- guard against multiple inclusion to prevent
	-- loss of async coroutines
	dofile( "data/scripts/lib/coroutines.lua" )
end
	
function OnPlayerSpawned( player_entity )
	EntityLoad('data/example_gui/guicontainer.xml')
end


-- This code runs when all mods' filesystems are registered
ModLuaFileAppend( "data/scripts/gun/gun_actions.lua", "mods/example/files/actions.lua" ) -- Basically dofile("mods/example/files/actions.lua") will appear at the end of gun_actions.lua
ModMagicNumbersFileAdd( "mods/example/files/magic_numbers.xml" ) -- Will override some magic numbers using the specified file
ModRegisterAudioEventMappings( "mods/example/files/audio_events.txt" ) -- Use this to register custom fmod events. Event mapping files can be generated via File -> Export GUIDs in FMOD Studio.
ModMaterialsFileAdd( "mods/example/files/materials_rainbow.xml" ) -- Adds a new 'rainbow' material to materials

--print("Example mod init done")
