require("boardloader")

--Initial game configuration
local othello = {
	name="Othello",
	players={
		{name='Black', color=colors.gray, placed=2},
		{name='White', color=colors.white, placed=2}
	},
	x=8,
	y=8,
	bColor=colors.green,
	eColor=colors.gray,
	tColor=colors.green
}

function checkWin(game, x,y)
	--All cells full
	if game.players[1].placed + game.players[2].placed == 8*8 then
		if game.players[1].placed > game.players[2].placed then
			game.turn = 1
		elseif game.players[1].placed < game.players[2].placed then
			game.turn = 2
		else
			game.turn = 0
		end
		game.playing = false
	end

	nextTurn(game)
end

directions = {
	{-1,-1}, {0,-1}, {1,-1},
	{-1, 0}, 		 {1, 0},
	{-1, 1}, {0, 1}, {1, 1}
}

function spread(game, startX,startY)
	local color = game.board[startX][startY][3]
	local other = game.turn - 1
	if other == 0 then
		other = #game.players
	end

	local placed1 = game.players[game.turn].placed
	local placed2 = game.players[other].placed

	for i=1,#directions do
		local x,y = startX+directions[i][1], startY+directions[i][2]

		while onBoard(x,y) and game.board[x][y][1] == 'O' and game.board[x][y][3] ~= color do
			x,y = x+directions[i][1], y+directions[i][2]
		end

		if onBoard(x,y) and game.board[x][y][1] == 'O' and game.board[x][y][3] == color then
			repeat
				game.board[x][y][3] = color
				placed1 = placed1 + 1
				placed2 = placed2 - 1
				x,y = x-directions[i][1], y-directions[i][2]
			until game.board[x][y][3] == color
		end
	end

	game.players[game.turn].placed = placed1
	game.players[other].placed = placed2
end

function play(game, x,y)
	local placed = game.players[game.turn].placed

	--Place O on grid
	if game.turn == 1 then
		setPiece(game, x,y, 'O', nullFunc, colors.black, colors.green)
		game.players[game.turn].placed = placed + 1
	else
		setPiece(game, x,y, 'O', nullFunc, colors.white, colors.green)
		game.players[game.turn].placed = placed + 1
	end

	spread(game, x,y)
	checkWin(game, x,y)
end

--Setup grid lines and empty spaces
function setupBoard(cell, x,y)
	if (x==4 and y==4) or (x==5 and y==5) then
		return {'O', nullFunc, colors.white, colors.green}
	elseif (x==4 and y==5) or (x==5 and y==4) then
		return {'O', nullFunc, colors.black, colors.green}
	else
		return {'_', play, colors.lime, colors.green}
	end
end

function resetGame(game)
	for i=1,#game.players do
		game.players[i].placed = 2
	end
end

--Start game
startGame(othello, setupBoard, resetGame)

