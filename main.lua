local config = {}

config.luaFileName = "positionsDB.lua"
config.moduleName = "positionsDB"
config.pathToModule = tes3mp.GetDataPath() .. "/custom/" .. config.luaFileName
config.SaveCmd = "savePos"





local positionsDB = {}

positionsDB.lines = {}
positionsDB.iBoxID = 6325


positionsDB.chatCmd = function(pid, cmd)

	if cmd[2] ~= nil then
		positionsDB.CreateRecord(pid, cmd[2])
	else
		tes3mp.InputDialog(pid, positionsDB.iBoxID, "Enter location tag: ", "")
	end
	
end
	
positionsDB.OnServerPostInit = function(EventStatus)

local f = io.open(config.pathToModule, "r")
	if f ~= nil then 
		io.close(f)
	else
		f = io.open(config.pathToModule, "w+")
		io.close(f)
	end
end

positionsDB.OnGuiAction = function(EventStatus, pid, idGui, data)

	if idGui == positionsDB.iBoxID then
		if data then
			positionsDB.CreateRecord(pid, data)
		end
	end

end
	
positionsDB.MakeTablefromFile = function()

	positionsDB.lines = {}
	
	for line in io.lines(config.pathToModule) do
		if line and line ~= "" then
			if not string.match(line, "return ".. config.moduleName) then
				table.insert(positionsDB.lines, line)
			end
		end
	end
	
	return positionsDB.lines
end
	
positionsDB.AddNewLines = function(tbl)

local iterator = 1
for key, line in ipairs(tbl) do
	if key > 1 and line ~= nil then
		if string.match(line, '"%w+"%]%[' .. iterator) then
			iterator = iterator + 1
		else
			tbl[key-1] = tbl[key-1] .. "\n"
			iterator = 1
		end
	end
end
end
	

positionsDB.CreateRecord = function(pid, label)

local isLoop = true
local iterator = 1
local posX = tes3mp.GetPosX(pid)
local posY = tes3mp.GetPosY(pid)
local posZ = tes3mp.GetPosZ(pid)
local rotX = tes3mp.GetRotX(pid)
local rotZ = tes3mp.GetRotZ(pid)
local tempCon = table.concat(positionsDB.MakeTablefromFile(), "\n")
local text = ""
local Writetext

local f = io.open(config.pathToModule, "w+")


while isLoop do

	
	if not string.match(tempCon, config.moduleName .. " %= %{%}") then
		local LbMdHeader = config.moduleName .. " = {}"
		table.insert(positionsDB.lines, LbMdHeader)
	end
	
	if not string.match(tempCon, config.moduleName .. '%["' .. label .. '"%] %= %{%}') then
		local labelHeader = config.moduleName .. '["' .. label .. '"] = {}'
		table.insert(positionsDB.lines, labelHeader)
	end
	
	if string.match(tempCon, config.moduleName .. '%["' .. label .. '"%]' .. "%[" .. iterator .. "%]") then
		iterator = iterator + 1
	else
		text = text .. config.moduleName .. '["' .. label .. '"]' .. "[" .. iterator .. "]" .. " = " .. "{posX = " .. posX .. ", posY = " .. posY .. ", posZ = " .. posZ .. ", rotX = " .. rotX .. ", rotZ = " .. rotZ .. "}"
		table.insert(positionsDB.lines, text)
		table.sort(positionsDB.lines)
		table.insert(positionsDB.lines, "return " .. config.moduleName)
		positionsDB.AddNewLines(positionsDB.lines)
		Writetext = table.concat(positionsDB.lines, "\n")
		isLoop = false
	end
end


f:write(Writetext)

f:close()

tes3mp.SendMessage(pid, "You have succesfully saved location " .. color.SkyBlue .. label .. "[" .. iterator .. "]" .. color.Default .. ".\n", false)
tes3mp.LogMessage(1, "[" .. config.moduleName .. "]: " .. label .. "[" .. iterator .. "] has been saved.")
end

customEventHooks.registerHandler("OnServerPostInit", positionsDB.OnServerPostInit)
customEventHooks.registerHandler("OnGUIAction", positionsDB.OnGuiAction)
customCommandHooks.registerCommand(config.SaveCmd, positionsDB.chatCmd)



return positionsDB 