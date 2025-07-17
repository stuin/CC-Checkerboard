list_game = {}

print("Listing installed games:")

require("tictactoe")
require("checkers")
require("chess")
require("connect4")
require("battleship")
require("othello")
require("minesweeper")
require("binario")

local baseProtocolName = "CCCheckerboard-"..cccheckerboardVersion

--List found games
for i=1,#list_game do
	print(i..". "..list_game[i].name)
end

function joinGame(modems)
	modem = peripheral.getName(modems[1])
	rednet.open(modem)
	print("Looking for joinable games")

	while true do
		for i=1,#list_game do
			local protocolName = baseProtocolName.."-"..list_game[i].name
			print(protocolName)
			rednet.unhost(protocolName)
			local other = rednet.lookup(protocolName)

			--Play game
			if other ~= nil then
				print("Found host")
				print(protocolName)

				local gameList = list_game
				list_game = nil
				startGame(gameList[i])

				list_game = gameList
			end
		end
		print("Sleep 3 seconds and restart")
		os.sleep(3)
	end
end

--Check command arguments
for i=1,#arg do
	if arg[i] == "-m" then
		--Search for joinable games
		local modems = { peripheral.find("modem") }
		if #modems > 0 then
			joinGame(modems)
			return
		else
			print("No modem found for remote multiplayer")
			return
		end
	elseif arg[i] == "-mc" then
		local modems = { peripheral.find("modem") }
		if #modems > 0 then
			print("Clearing modem")
			modem = peripheral.getName(modems[1])
			rednet.open(modem)
			for i=1,#list_game do
				local protocolName = baseProtocolName.."-"..list_game[i].name
				print(protocolName)
				rednet.unhost(protocolName)
			end
			rednet.close(modem)
		end
		return
	elseif arg[i] == "-u" then
		--Download updates from git
		shell.run("wget run https://raw.githubusercontent.com/stuin/CC-Checkerboard/refs/heads/main/install.lua")
		return
	end
end

--Wait for mouse or keyboard input
print("Quit")
while true do
	local event, code, mX, mY = os.pullEvent()
	while event ~= "mouse_click" and event ~= "char" do
		event, code, mX, mY = os.pullEvent()
	end
	local y = 0
	if event == "char" then
		if code == "q" or code == "Q" then
			return
		end
		y = tonumber(code)
	elseif event == "mouse_click" then
		local sX,sY = term.getCursorPos()
		y = #list_game - (sY-mY) + 2
		if y > #list_game then
			return
		end
	end

	--Play selected game
	if y <= #list_game and y > 0 then
		local gameList = list_game
		list_game = nil
		startGame(gameList[y])

		list_game = gameList
		for i=1,#list_game do
			print(i..". "..list_game[i].name)
		end
		print("Quit")
	end
end