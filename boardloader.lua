--Game object format (add more fields as needed)
local gameFormat = {
	name="Game Name",
	players={{
		name="Player i Name",
		color="Player i Color"
	}},
	x="Board Width",
	y="Board Height",
	bColor="Default Background Color",
	eColor="Board Edge Color",
--Everything below this line is setup automatically
	turn="Current player index",
	playing="Is Game Running?",
	board={{{
		"Text Character",
		"Function when selected",
		"Text Color",
		"Background Color"
	}}}
}

--Variables for drawing
local startX,startY = 1,3
local gridX,gridY = 0,0
local monitor = nil

--Draw single cell to screen
local function drawCell(x,y,cell)
	term.setCursorPos(x+startX, y+startY)
	term.blit(cell[1],""..colors.toBlit(cell[3]),""..colors.toBlit(cell[4]))
end

--Game name and current player name
local function drawHeader(game)
	--term.clear()
	term.setCursorPos(1, 1)
	term.write(game.name)

	if game.turn > 0 and game.turn <= #game.players then
		local color = term.getTextColor()
		term.setTextColor(game.players[game.turn].color)
		term.setCursorPos(1, 2)
		term.write(game.players[game.turn].name)
		term.write("'s Turn")
		term.setTextColor(color)
	end

	--End buttons
	term.setCursorPos(1,gridY+startY+3)
	term.blit(" Restart   Quit  ", "00000000000000000", "555555555 eeeeee ")
	term.setCursorPos(1,gridY+startY+4)
end

--Draw entire grid to screen
local function drawGrid(game)
	paintutils.drawFilledBox(startX+1,startY+1, gridX+startX-1,gridY+startY-1, game.bColor)
	paintutils.drawBox(startX,startY, gridX+startX,gridY+startY, game.eColor)

	for x=1,gridX do
		for y=1,gridY do
			drawCell(x,y, game.board[x][y])
		end
	end

	term.setCursorPos(1,gridY+startY+2)
end

--Get mouse input and verify grid
local function input(game)
	local eventS = "mouse_click"
	if monitor ~= nil then
		eventS = "monitor_touch"
	end
	local event, button, mX, mY = os.pullEvent(eventS)
	local x = mX-startX
	local y = mY-startY

	if (mX < 10) and mY == (gridY+startY+3) then
		return 0,-1
	elseif (mX > 10) and (mX < 17) and mY == (gridY+startY+3) then
		return 0,-2
	elseif x > gridX or y > gridY or x < 1 or y < 1 then
		return 0,0
	else
		return x,y
	end
end

--Clear game and board to start
local function resetBoard(game, setupFunc, resetFunc)
	term.clear()
	game.turn = 1
	game.playing = true

	for x=1,gridX do
		for y=1,gridY do
			game.board[x][y] = setupFunc(defaultCell, x,y)
		end
	end

	if resetFunc ~= nil then
		resetFunc(game)
	end
end

----Start of User Available functions----

--Default cell function to do nothing
function nullFunc(game, x,y)

end

--Set value of a cell on the board
function setPiece(game, x,y, text, func, fColor, bColor)
	if bColor == nil then
		bColor = game.board[x][y][4]
	end

	game.board[x][y] = {text, func, fColor, bColor}
end

--Move to next turn
function nextTurn(game)
	if game.playing then
		game.turn = game.turn + 1
		if game.turn > #game.players then
			game.turn = 1
		end
	end
end

--Run function on every cell
function mapBoard(func)
	for x=1,gridX do
		for y=1,gridY do
			board[x][y] = func(board[x][y], x,y)
		end
	end
end

--Setup and play game
function startGame(game, setupFunc, resetFunc)
	gridX = game.x
	gridY = game.y

	--Calculate maximum game board size
	local maxX = gridX+startX+2
	local maxY = gridY+startY+3
	if #game.name > maxX then
		maxX = #game.name
	end
	if 16 > maxX then
		maxX = 16
	end

	--Use monitor and set scale
	local monitors = { peripheral.find("monitor") }
	if #monitors > 0 then
		monitor = monitors[1]
		monitor.setTextScale(1)
		local screenX,screenY = monitor.getSize()
		local scaleX = screenX/maxX
		local scaleY = screenY/maxY
		term.write(maxX.." "..maxY.." ")
		term.write(screenX.." "..screenY.." ")
		term.write(scaleX.." "..scaleY)

		if scaleX < scaleY then
			monitor.setTextScale(scaleX)
		else
			monitor.setTextScale(scaleY)
		end

		term.redirect(monitor)
	end


	term.clear()
	term.setBackgroundColor(game.bColor)

	--Initial variables
	game.turn = 1
	game.playing = true
	game.board = {}

	--Backup setup function
	if setupFunc == nil then
		setupFunc = function()
			return {' ', nullFunc, game.bColor, game.bColor}
		end
	end

	--Create board using setup function
	for x=1,gridX do
		game.board[x] = {}
		for y=1,gridY do
			game.board[x][y] = setupFunc(defaultCell, x,y)
		end
	end

	--Play game
	while game.playing do
		--Draw board
		drawHeader(game)
		drawGrid(game)

		--Get input
		local x,y = input()
		if x == 0 then
			if y == -1 then
				resetBoard(game, setupFunc, resetFunc)
			elseif y == -2 then
				game.playing = false
				term.write("Quit")
				term.setCursorPos(1,gridY+startY+4)
			end
		else
			--Run function from seleted cell
			game.board[x][y][2](game,x,y)

			--Check for game end
			if not game.playing then
				drawGrid(game)
				if game.turn == 0 then
					term.write("It's a Tie ")
				else
					term.write(game.players[game.turn].name)
					term.write(" Wins! ")
				end

				--Replay button
				local x,y = input()
				if y == -1 then
					resetBoard(game, setupFunc, resetFunc)
				else
					game.playing = false
					term.write("Quit")
					term.setCursorPos(1,gridY+startY+4)
				end
			end
		end
	end
end
