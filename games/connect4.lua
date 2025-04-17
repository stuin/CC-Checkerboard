require("cccheckerboard")

--Initial game configuration
local connect4 = {
	name="Connect 4",
	players={
		{name='Red', color=colors.red, placed=0},
		{name='Yello', color=colors.yellow, placed=0}
	},
	width=7,
	height=7,
	edgeColor=colors.blue,
	gridColor=colors.white,
	titleColor=colors.blue
}

local function checkWin(game, startX,startY)
	local other = (game.turn % #game.players) + 1
	local color = game.players[game.turn].color

	for i=1,4 do
		local count = 1

		--Find first end point
		local x,y = startX+directions[i][1], startY+directions[i][2]
		while onBoard(x,y) and game.board[x][y][1] == '0' and game.board[x][y][3] == color do
			x,y = x+directions[i][1], y+directions[i][2]
			count = count + 1
		end

		--Find opposite end point
		x,y = startX-directions[i][1], startY-directions[i][2]
		while onBoard(x,y) and game.board[x][y][1] == '0' and game.board[x][y][3] == color do
			x,y = x-directions[i][1], y-directions[i][2]
			count = count + 1
		end

		--Check for win
		if count >= 4 then
			return true
		end
	end
end

--Play in an empty column
local function play(game, x,y)
	y = game.height

	--Find top of column
	while game.board[x][y][1] == '0' and y > 0 do
		y = y - 1
	end

	--Set piece at position
	if y > 0 then
		game.board[x][y] = {'0', play, game.players[game.turn].color, colors.blue}

		if checkWin(game, x,y) then
			game.playing = false
		else
			nextTurn(game)
		end
	end
end

--Setup starting pieces and empty spaces
function connect4.setupFunc(game, x,y)
	if y < game.height then
		return {' ', play, colors.white, colors.blue}
	else
		return {'_', play, colors.white, colors.blue}
	end
end

--Clear player data
function connect4.resetFunc(game)
	for i=1,#game.players do
		game.players[i].placed = 0
	end
end

--Start game
startGame(connect4)
