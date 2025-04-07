require("boardloader")

--Initial game configuration
local tictactoe = {
	name="Tic Tac Toe",
	players={
		{name='X', color=colors.red, placed=0},
		{name='O', color=colors.white, placed=0}
	},
	x=5,
	y=5,
	bColor=colors.black,
	eColor=colors.black
}

function checkWin(game, x,y)
	local turn = game.board[x][y][1]

	--Check rows+columns+diagonals for matches
	if (game.board[x][1][1] == turn and game.board[x][3][1] == turn and game.board[x][5][1] == turn) or
		(game.board[1][y][1] == turn and game.board[3][y][1] == turn and game.board[5][y][1] == turn) or
		(x==y and game.board[1][1][1] == turn and game.board[3][3][1] == turn and game.board[5][5][1] == turn) or
		(x==6-y and game.board[1][5][1] == turn and game.board[3][3][1] == turn and game.board[5][1][1] == turn) then

		game.playing=false
	elseif game.players[1].placed + game.players[2].placed == 9 then
		--All cells full = tie
		game.turn = 0
		game.playing = false
	end

	nextTurn(game)
end

function play(game, x,y)
	local placed = game.players[game.turn].placed

	--Place X or O on grid
	if game.turn == 1 then
		setPiece(game, x,y, 'X', nullFunc, colors.red, colors.black)
		game.players[game.turn].placed = placed + 1
	else
		setPiece(game, x,y, 'O', nullFunc, colors.white, colors.black)
		game.players[game.turn].placed = placed + 1
	end

	checkWin(game, x,y)
end

--Setup grid lines and empty spaces
function setupBoard(cell, x,y)
	if (x%2==0) and (y%2==0) then
		return {'+', nullFunc, colors.gray, colors.black}
	elseif x%2==0 then
		return {'|', nullFunc, colors.gray, colors.black}
	elseif y%2==0 then
		return {'-', nullFunc, colors.gray, colors.black}
	else
		return {' ', play, colors.white, colors.black}
	end
end

function resetGame(game)
	for i=1,#game.players do
		game.players[i].placed = 0
	end
end

--Start game
startGame(tictactoe, setupBoard, resetGame)

