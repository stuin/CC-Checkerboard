--Game object format (add more fields as needed)
local gameFormat = {
	name="Game Name",
	players={{
		name="Player i Name",
		color="Player i Color"
	}},
	width="Board Width",
	height="Board Height",
	edgeColor="Board Edge Color",
	gridColor="Grid Numbers Color",
	titleColor="Title Text Color",
	setupFunc="Function to map each grid space to",
	resetFunc="Function to run on startup and restart",
--Everything below this line is setup automatically
	turn="Current player index",
	playing="Is Game Running?",
	seed="Random number seed",
	board={{{
		"Text Character",
		"Function when selected",
		"Text Color",
		"Background Color"
	}}},
	moves={{
		"x","y","player","time"
	}}
}

cccheckerboardVersion="0.1.0"

--Substitute non-computercraft libraries
if term == nil then
	require 'ansi-term'
end

--Variables for drawing
local screenX,screenY = term.getSize()
local centerX,centerY = screenX/2,screenY/2
local startX,startY = 1,3
local gridX,gridY = 0,0
local monitor = nil

--Variables for multiplayer
local modem = nil
local connections = {}
local playerNum = 0
local baseProtocolName = "CCCheckerboard-"..cccheckerboardVersion
local protocolName = baseProtocolName

--Draw single cell to screen
local function drawCell(x,y,cell)
	term.setCursorPos(x+startX, y+startY)
	term.setTextColor(cell[3])
	term.setBackgroundColor(cell[4])
	term.write(cell[1])
end

--Draw entire grid to screen
local function drawGrid(game)
	--Draw cells and sides
	for x=1,gridX do
		drawCell(x,0, {string.char(96+x), nullFunc, game.gridColor, game.edgeColor})
		drawCell(x,gridY+1, {string.char(96+x), nullFunc, game.gridColor, game.edgeColor})
		for y=1,gridY do
			drawCell(x,y, game.board[x][y])
		end
	end

	--Draw top and bottom
	for y=1,gridY do
		drawCell(0,y, {""..(y%10), nullFunc, game.gridColor, game.edgeColor})
		drawCell(gridX+1,y, {""..(y%10), nullFunc, game.gridColor, game.edgeColor})
	end

	--Draw Corners
	drawCell(0,		  0, 	   {" ", nullFunc, game.gridColor, game.edgeColor})
	drawCell(gridX+1, 0, 	   {" ", nullFunc, game.gridColor, game.edgeColor})
	drawCell(0,		  gridY+1, {" ", nullFunc, game.gridColor, game.edgeColor})
	drawCell(gridX+1, gridY+1, {" ", nullFunc, game.gridColor, game.edgeColor})

	term.setCursorPos(1,gridY+startY+2)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.black)
end

--Game name and current player name
local function drawHeader(game)
	--term.clear()
	term.setCursorPos(centerX-#game.name/2, 1)
	term.setBackgroundColor(colors.black)
	term.setTextColor(game.titleColor)
	term.write(game.name)
	term.setTextColor(colors.white)

	--Turn indicator
	term.setCursorPos(1, 2)
	term.clearLine()
	if game.turn > 0 and game.turn <= #game.players then
		local name = game.players[game.turn].name
		term.setTextColor(game.players[game.turn].color)
		term.setCursorPos(centerX-(#name+9)/2, 2)
		if playerNum ~= 0 and game.turn == playerNum then
			term.setBackgroundColor(colors.green)
		elseif playerNum ~= 0 and game.turn ~= playerNum then
			term.setBackgroundColor(colors.red)
		end
		term.write(" ")
		term.setBackgroundColor(colors.black)
		term.write(name)
		term.write("'s Turn")
		if playerNum ~= 0 and game.turn == playerNum then
			term.setBackgroundColor(colors.green)
		elseif playerNum ~= 0 and game.turn ~= playerNum then
			term.setBackgroundColor(colors.red)
		end
		term.write(" ")
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.black)
	end

	--First turn own name
	if #game.moves == 0 and playerNum ~= 0 then
		local name = game.players[playerNum].name
		term.setCursorPos(centerX-(#name+11)/2, gridY+startY+2)
		term.setTextColor(game.players[playerNum].color)
		term.write("Playing as ")
		term.write(name)
		term.setTextColor(colors.white)
	end

	--End buttons
	term.setCursorPos(centerX-8,gridY+startY+3)
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.green)
	term.write(" Restart ")
	term.setBackgroundColor(colors.black)
	term.write(" ")
	term.setBackgroundColor(colors.red)
	term.write(" Quit ")
	term.setBackgroundColor(colors.black)
	term.write(" ")
	term.setCursorPos(1,gridY+startY+4)
end

--Get mouse input and verify grid
local function input(remote)
	--Wait for mouse or keyboard input
	local eventS = "mouse_click"
	if monitor ~= nil then
		eventS = "monitor_touch"
	end
	local event, code, mX, mY = os.pullEvent()
	while event ~= eventS and event ~= "char" and event ~= "rednet_message" do
		event, code, mX, mY = os.pullEvent()
	end
	term.setCursorPos(1,gridY+startY+2)
	term.clearLine()
	local x,y = 0,0

	--Multiplayer input
	if event == "rednet_message" then
		if (remote or mX[1] == -1) and mY == protocolName then
			local x,y = mX[1],mX[2]
			return x,y
		else
			return 0,0
		end
	end

	--Keyboard input x letter
	if event == "char" then
		term.setCursorPos(centerX-1,gridY+startY+2)
		term.write(code)
		x = string.byte(code)-96

		--Quit/Restart
		if code == "R" then
			return 0,-1
		elseif code == "Q" then
			return 0,-2
		end

		--Keyboard input y number
		event, code, mX, mY = os.pullEvent()
		while event ~= eventS and event ~= "char" and event ~= "rednet_message" do
			event, code, mX, mY = os.pullEvent()
		end
		if event == "char" then
			term.write(code)
			term.setCursorPos(1,gridY+startY+2)

			y = tonumber(code)
			if code == "R" then
				--Restart
				return 0,-1
			elseif code == "Q" then
				--Quit
				return 0,-2
			elseif onBoard(x,y) and not remote then
				--Select cell
				return x,y
			else
				--Skip
				return 0,0
			end
		end
	end

	--Check mouse position
	x,y = mX-startX, mY-startY
	if (mX > centerX-9) and (mX < centerX) and mY == (gridY+startY+3) then
		--Restart
		return 0,-1
	elseif (mX > centerX+1) and (mX < centerX+7) and mY == (gridY+startY+3) then
		--Quit
		return 0,-2
	elseif onBoard(x,y) and not remote then
		--Select cell
		return x,y
	else
		--Skip
		return 0,0
	end
end

--Send message to all other players
local function broadcast(message)
	if playerNum ~= 0 then
		for i=1,#connections do
			if i ~= playerNum then
				rednet.send(connections[i], message, protocolName)
			end
		end
	end
end

--Setup multiplayer game
local function setupNetwork(game, modemW)
	--Start multiplayer setup
	print("Found modem, setting up multiplayer")
	protocolName = baseProtocolName.."-"..game.name
	print(protocolName)
	modem = peripheral.getName(modemW)
	rednet.open(modem)
	rednet.unhost(protocolName)

	local other = rednet.lookup(protocolName)
	if other ~= nil then
		--Join as secondary player
		print("Found host")
		if type(other) == "table" then
			other = other[1]
		end
		rednet.send(other, "Join", protocolName)
		local id, message = rednet.receive(protocolName)
		connections = message
		playerNum = #connections
		print("Joined as player "..playerNum)
		id, message = rednet.receive(protocolName)
		print("All players found, starting game")
	else
		--Start as host
		print("Waiting for players")
		playerNum = 1
		connections[1] = os.getComputerID()
		rednet.host(protocolName, ""..os.getComputerID())

		--Wait for all players
		for i=2,#game.players do
			local id, message = rednet.receive(protocolName, 10+os.getComputerID())
			while id == nil do
				rednet.unhost(protocolName)
				other = rednet.lookup(protocolName)

				--Try other host
				if i==2 and other ~= nil then
					print("Found other host to try")
					rednet.send(other, "Join", protocolName)
				else
					rednet.host(protocolName, ""..os.getComputerID())
				end
				id, message = rednet.receive(protocolName, os.getComputerID())
			end

			if message == "Join" then
				--Allow player to join as host
				connections[i] = id
				print("Found player "..i)
				rednet.send(id, connections, protocolName)
			else
				--Swap to being secondary player
				rednet.unhost(protocolName)
				connections = message
				playerNum = #connections
				print("Joined as player "..playerNum)
				id, message = rednet.receive(protocolName)
				print("All players found, starting game")
			end
		end

		--Confirm to all players
		if playerNum == 1 then
			rednet.unhost(protocolName)
			for i=2,#connections do
				rednet.send(connections[i], connections, protocolName)
			end
		end
		print("All players found, starting game")
	end
end

--Clear game and board to start
local function resetBoard(game)
	term.clear()
	game.turn = 1
	game.playing = true
	game.board = {}
	game.moves = {}
	game.seed = os.epoch()

	--Multiplayer distribute seed/start
	if playerNum == 1 then
		game.moves[#game.moves+1] = {0,0,0,game.seed}
		broadcast({0,0,0,game.seed})
	elseif playerNum ~= 0 then
		local id, message = rednet.receive(protocolName)
		game.moves[#game.moves+1] = message
		game.seed = message[4]
	end
	math.randomseed(game.seed)

	--Game specific reset
	if game.resetFunc ~= nil then
		game.resetFunc(game)
	end

	--Create board using setup function
	game.board = {}
	for x=1,gridX do
		game.board[x] = {}
		for y=1,gridY do
			game.board[x][y] = game.setupFunc(game, x,y)
		end
	end
end

----Start of User Available functions----

--Default cell function to do nothing
function nullFunc(game, x,y)

end

--List of 8 neighboring positions
directions = {
	{-1,-1}, {0,-1}, {1,-1},
	{-1, 0}, 		 {1, 0},
	{-1, 1}, {0, 1}, {1, 1}
}

--Move to next turn
function nextTurn(game)
	if game.playing then
		game.turn = (game.turn % #game.players) + 1
	end
end

--Run function on every cell and replace
function mapBoard(game, func)
	for x=1,gridX do
		for y=1,gridY do
			game.board[x][y] = func(game, x,y)
		end
	end
end

--Check if coords are inside grid
function onBoard(x,y)
	return not (x > gridX or y > gridY or x < 1 or y < 1)
end

--Setup and play game
function startGame(game)
	--Save game to list
	if list_game ~= nil then
		list_game[#list_game + 1] = game
		return
	end

	--Check command arguments
	for i=1,#arg do
		if arg[i] == "-m" and #game.players > 1 then
			--Enable modem multiplayer
			local modem = peripheral.find("modem")
			if modem ~= nil then
				setupNetwork(game, modem)
			else
				print("No modem found for remote multiplayer")
				return
			end
		elseif arg[i] == "-s" and i < #arg and game.maxSize ~= nil then
			--Adjust board size
			local s = tonumber(arg[i + 1])
			i = i + 1
			if s > game.maxSize then
				s = game.maxSize
			end
			if s > game.width and s < game.maxSize then
				game.height = game.height + (s - game.width)
				game.width = s
				print("Set size to "..s)
			end
		elseif arg[i] == "-u" then
			--Download updates from git
			shell.run("wget run https://raw.githubusercontent.com/stuin/CC-Checkerboard/refs/heads/main/install.lua")
			return
		end
	end

	--Calculate maximum game board size
	gridX,gridY = game.width,game.height
	local maxX,maxY = gridX+startX+2, gridY+startY+3
	if #game.name > maxX then
		maxX = #game.name
	end
	for i=1,#game.players do
		if #game.players[i].name+9 > maxX then
			maxX = #game.players[i].name+9
		end
	end
	if 16 > maxX then
		maxX = 16
	end

	--Use monitor and set scale
	local termRedirect = term.current()
	monitor = peripheral.find("monitor")
	if monitor ~= nil then
		monitor.setTextScale(1)
		screenX,screenY = monitor.getSize()
		local scaleX,scaleY = screenX/maxX, screenY/maxY

		if scaleX < scaleY then
			monitor.setTextScale(scaleX)
		else
			monitor.setTextScale(scaleY)
		end

		screenX,screenY = monitor.getSize()
		centerX,centerY = screenX/2+1, screenY/2+1
		term.redirect(monitor)
	end

	--Center board
	startX = math.floor(centerX-gridX/2-1)

	--Setup game
	resetBoard(game)

	--Play game
	while game.playing do
		--Draw board
		drawHeader(game)
		drawGrid(game)

		--Get input
		local remote = playerNum ~= 0 and game.turn ~= playerNum
		local x,y = input(remote)
		if x == 0 or x == -1 then
			if y == -1 then
				if x == 0 then
					broadcast({-1,y,playerNum,os.epoch()})
				end
				resetBoard(game)
				term.setCursorPos(centerX-4,gridY+startY+2)
				term.write("Restarted")
			elseif y == -2 then
				if x == 0 then
					broadcast({-1,y,playerNum,os.epoch()})
				end
				game.playing = false
				term.setCursorPos(centerX-2,gridY+startY+2)
				term.write("Quit")
				term.setCursorPos(1,gridY+startY+4)
			end
		else
			if game.board[x][y][2] ~= nullFunc then
				--Record move
				game.moves[#game.moves+1] = {x,y,game.turn,os.epoch()}

				--Run function from seleted cell
				game.board[x][y][2](game,x,y)

				--Send to other players
				broadcast({x,y,game.turn,os.epoch()})
			end

			--Check for game end
			if not game.playing then
				drawGrid(game)
				if game.turn == 0 then
					term.setCursorPos(centerX-5,gridY+startY+2)
					term.write("It's a Tie ")
				else
					local name = game.players[game.turn].name
					term.setCursorPos(centerX-(#name+7)/2,gridY+startY+2)
					term.setTextColor(game.players[game.turn].color)
					term.write(name)
					term.write(" Wins! ")
					term.setTextColor(colors.white)
				end

				--Replay button
				local x,y = input()
				if y == -1 then
					if x == 0 then
						broadcast({-1,y,playerNum,os.epoch()})
					end
					resetBoard(game)
					term.setCursorPos(centerX-4,gridY+startY+2)
					term.write("Restarted")
				elseif y == -2 then
					if x == 0 then
						broadcast({-1,y,playerNum,os.epoch()})
					end
					game.playing = false
					term.setCursorPos(centerX-2,gridY+startY+2)
					term.clearLine()
					term.write("Quit")
					term.setCursorPos(1,gridY+startY+4)
				end
			end
		end
	end

	--Cleanup monitor and modem
	term.redirect(termRedirect)
	if modem ~= nil then
		rednet.close(modem)
		modem = nil
		playerNum = 0
		connections = {}
	end
end
