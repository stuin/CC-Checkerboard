list_game = {}

print("Listing installed games")

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
	print(list_game[i].name)
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
		else
			print("No modem found for remote multiplayer")
			return
		end
	elseif arg[i] == "-u" then
		--Download updates from git
		shell.run("wget run https://raw.githubusercontent.com/stuin/CC-Checkerboard/refs/heads/main/install.lua")
		return
	end
end