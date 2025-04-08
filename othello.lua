require("cccheckerboard")

--Initial game configuration
local othello = {
	name="Othello",
	version="0.1.0",
	cccVersion="0.1.0",
	players={
		{name='Black', color=colors.gray, placed=2, playColor=colors.black},
		{name='White', color=colors.white, placed=2, playColor=colors.white}
	},
	width=8,
	height=8,
	backColor=colors.green,
	edgeColor=colors.gray,
	gridColor=colors.green,
	titleColor=colors.green
}

local directions = {
	{-1,-1}, {0,-1}, {1,-1},
	{-1, 0}, 		 {1, 0},
	{-1, 1}, {0, 1}, {1, 1}
}

--Check all lines to convert
function spread(game, startX,startY, color, test)
	local other = (game.turn % #game.players) + 1

	--Score counters
	local placed1 = game.players[game.turn].placed
	local placed2 = game.players[other].placed
	local total = 0

	--For each direction
	for i=1,#directions do
		local x,y = startX+directions[i][1], startY+directions[i][2]

		--Find end point
		while onBoard(x,y) and game.board[x][y][1] == 'O' and game.board[x][y][3] ~= color do
			x,y = x+directions[i][1], y+directions[i][2]
		end

		--Flip pieces on the way back
		if onBoard(x,y) and game.board[x][y][1] == 'O' and game.board[x][y][3] == color then
			x,y = x-directions[i][1], y-directions[i][2]
			while x~=startX or y~=startY do
				total = total + 1
				if test == nil then
					game.board[x][y][3] = color
					placed1 = placed1 + 1
					placed2 = placed2 - 1
				end
				x,y = x-directions[i][1], y-directions[i][2]
			end
		end
	end

	--Update scores
	game.players[game.turn].placed = placed1
	game.players[other].placed = placed2
	return total
end

--Figure out score and end game
function endGame(game)
	if game.players[1].placed > game.players[2].placed then
			game.turn = 1
	elseif game.players[1].placed < game.players[2].placed then
		game.turn = 2
	else
		game.turn = 0
	end
	game.playing = false
end

function checkWin(game)
	--Check for win
	if game.players[1].placed == 0 or game.players[2].placed == 0 or
		(game.players[1].placed + game.players[2].placed == 8*8) then
		endGame(game)
	end

	local color1 = game.players[game.turn].playColor
	local color2 = game.players[(game.turn % #game.players) + 1].playColor

	--Make sure open moves exist for both players
	for x=1,game.width do
		for y=1,game.height do
			if game.board[x][y][1] == '_' and spread(game, x,y, color2, true) > 0 then
				nextTurn(game)
				return
			end
		end
	end
	for x=1,game.width do
		for y=1,game.height do
			if game.board[x][y][1] == '_' and spread(game, x,y, color1, true) > 0 then
				return
			end
		end
	end

	endGame(game)
end

--Play in an empty cell
function play(game, x,y)
	if game.turn == 1 then
		--Check if move is valid before placing
		if spread(game, x,y, colors.black) > 0 then
			game.board[x][y] = {'O', nullFunc, colors.black, colors.green}
			game.players[game.turn].placed = game.players[game.turn].placed + 1
			checkWin(game)
		end
	else
		if spread(game, x,y, colors.white) > 0 then
			game.board[x][y] = {'O', nullFunc, colors.white, colors.green}
			game.players[game.turn].placed = game.players[game.turn].placed + 1
			checkWin(game)
		end
	end
end

--Setup starting pieces and empty spaces
function setupBoard(cell, x,y)
	if (x==4 and y==4) or (x==5 and y==5) then
		return {'O', nullFunc, colors.white, colors.green}
	elseif (x==4 and y==5) or (x==5 and y==4) then
		return {'O', nullFunc, colors.black, colors.green}
	else
		return {'_', play, colors.lime, colors.green}
	end
end

--Clear player data
function resetGame(game)
	for i=1,#game.players do
		game.players[i].placed = 2
	end
end

--Start game
startGame(othello, setupBoard, resetGame)

