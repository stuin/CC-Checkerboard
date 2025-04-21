require("cccheckerboard")

--Initial game configuration
local chess = {
	name="Chess",
	players={
		{name='White', color=colors.white, captured=0, selected={0,0}, king={4,1}, playColor=colors.white, selectColor=colors.red},
		{name='Black', color=colors.gray, captured=0, selected={0,0}, king={4,8}, playColor=colors.black, selectColor=colors.orange}
	},
	width=8,
	height=8,
	edgeColor=colors.gray,
	gridColor=colors.lightGray,
	titleColor=colors.white
}

local function clearSelect(game, x,y)
	if game.board[x][y][1] == '_' and game.board[x][y][2] ~= nullFunc then
		return {'_', nullFunc, game.board[x][y][4], game.board[x][y][4], nil, 0}
	elseif game.board[x][y][2] ~= nullFunc and game.board[x][y][3] == game.players[1].selectColor then
		game.board[x][y][2] = game.selectFunc
		game.board[x][y][3] = game.players[2].playColor
	elseif game.board[x][y][2] ~= nullFunc and game.board[x][y][3] == game.players[2].selectColor then
		game.board[x][y][2] = game.selectFunc
		game.board[x][y][3] = game.players[1].playColor
	end
	return game.board[x][y]
end

--Check for promotion to Queen
local function checkEnd(game, x,y)
	if game.board[x][y][1] == 'P' and y == 1 and game.turn == 2 then
		game.board[x][y][1] = 'Q'
	elseif game.board[x][y][1] == 'P' and y == 8 and game.turn == 1 then
		game.board[x][y][1] = 'Q'
	end

	local opKing = game.players[(game.turn % #game.players) + 1].king
	if game.players[game.turn].captured == 16 or (x == opKing[1] and y == opKing[2]) then
		mapBoard(game, clearSelect)
		game.playing = false
	end
end

--Move to selected spot
local function move(game, x,y)
	local selected = game.players[game.turn].selected
	if game.board[selected[1]][selected[2]][1] ~= '_' then
		game.players[game.turn].captured = game.players[game.turn].captured + 1
	end

	local background1 = game.board[x][y][4]
	local background2 = game.board[selected[1]][selected[2]][4]
	game.board[x][y] = game.board[selected[1]][selected[2]]
	game.board[x][y][6] = game.board[x][y][6] + 1
	game.board[x][y][4] = background1
	game.board[selected[1]][selected[2]] = {'_', nullFunc, background2, background2, nil, 0}

	if game.board[x][y][1] == 'K' then
		game.players[game.turn].king = {x,y}
	end

	mapBoard(game, clearSelect)
	checkEnd(game, x,y)
	nextTurn(game)
end

--Castle
local function castle(game, x,y)
	move(game, x,y)
	nextTurn(game)

	if x == 2 then
		game.players[game.turn].selected = {1,y}
		move(game, 3,y)
	elseif x == 6 then
		game.players[game.turn].selected = {8,y}
		move(game, 5,y)
	end
end

--En passant
local function passant(game, x,y)
	local _y = game.players[game.turn].selected[2]
	local background = game.board[x][_y][4]
	game.board[x][_y] = {'_', nullFunc, background, background, nil, 0}
	game.players[game.turn].captured = game.players[game.turn].captured + 1
	move(game,x,y)
end

local knightDirections = {
		{-1,-2}, { 1,-2},
	{-2,-1},		{ 2,-1},
	{-2, 1},		{ 2, 1},
		{-1, 2}, { 1, 2}
}

--Highlight available moves
local function select(game, x,y, capture)
	local color = game.players[game.turn].playColor
	local opColor = game.players[(game.turn % #game.players) + 1].playColor
	local selectColor = game.players[game.turn].selectColor

	if game.board[x][y][1] ~= '_' and game.board[x][y][3] == color then
		game.players[game.turn].selected = {x,y}
		mapBoard(game, clearSelect)

		local type = game.board[x][y][1]
		local moved = game.board[x][y][6]

		--Pawn
		if type == 'P' then
			local forward = 1
			if color == colors.black then
				forward = -1
			end

			--Forward
			if onBoard(x,y+forward) and game.board[x][y+forward][1] == '_' then
				game.board[x][y+forward][2] = move
				game.board[x][y+forward][3] = selectColor

				if moved == 0 and game.board[x][y+forward*2][1] == '_' then
					game.board[x][y+forward*2][2] = move
					game.board[x][y+forward*2][3] = selectColor
				end
			end

			--Capture
			if onBoard(x+1,y+forward) and game.board[x+1][y+forward][1] ~= '_' and game.board[x+1][y+forward][3] == opColor then
				game.board[x+1][y+forward][2] = move
				game.board[x+1][y+forward][3] = selectColor
			end
			if onBoard(x-1,y+forward) and game.board[x-1][y+forward][1] ~= '_' and game.board[x-1][y+forward][3] == opColor then
				game.board[x-1][y+forward][2] = move
				game.board[x-1][y+forward][3] = selectColor
			end

			--En Passant
			if onBoard(x+1,y) and game.board[x+1][y][1] == 'P' and game.board[x+1][y][3] == opColor and
				game.board[x+1][y][6] == 1 and game.board[x+1][y+forward][1] == '_' then

				game.board[x+1][y+forward][2] = passant
				game.board[x+1][y+forward][3] = selectColor
			end
			if onBoard(x-1,y) and game.board[x-1][y][1] == 'P' and game.board[x-1][y][3] == opColor and
				game.board[x-1][y][6] == 1 and game.board[x+1][y+forward][1] == '_' then

				game.board[x-1][y+forward][2] = passant
				game.board[x-1][y+forward][3] = selectColor
			end
		end

		--Knight
		if type == 'N' then
			for i=1,#knightDirections do
				local _x,_y = x+knightDirections[i][1], y+knightDirections[i][2]
				if onBoard(_x,_y) and (game.board[_x][_y][1] == '_' or game.board[_x][_y][3] == opColor) then
					game.board[_x][_y][2] = move
					game.board[_x][_y][3] = selectColor
				end
			end
		end

		--Rook/Bishop/Queen
		if type == 'R' or type == 'B' or type == 'Q' then
			for i=1,#directions do
				local diagonal = directions[i][1] ~= 0 and directions[i][2] ~= 0
				if type == 'Q' or (type == 'R' and not diagonal) or (type == 'B' and diagonal) then
					local _x,_y = x+directions[i][1], y+directions[i][2]

					--Check row of empty spaces
					while onBoard(_x,_y) and game.board[_x][_y][1] == '_' do
						game.board[_x][_y][2] = move
						game.board[_x][_y][3] = selectColor
						_x,_y = _x+directions[i][1], _y+directions[i][2]
					end

					--Check capture last space
					if onBoard(_x,_y) and game.board[_x][_y][3] == opColor then
						game.board[_x][_y][2] = move
						game.board[_x][_y][3] = selectColor
					end
				end
			end
		end

		--King
		if type == 'K' then
			for i=1,#directions do
				local _x,_y = x+directions[i][1], y+directions[i][2]
				if onBoard(_x,_y) and (game.board[_x][_y][1] == '_' or game.board[_x][_y][3] == opColor) then
					game.board[_x][_y][2] = move
					game.board[_x][_y][3] = selectColor
				end
			end

			--Castling
			if moved == 0 and game.board[1][y][1] == 'R' and game.board[1][y][6] == 0 and
				game.board[2][y][1] == '_' and game.board[3][y][1] == '_' then

				game.board[2][y][2] = castle
				game.board[2][y][3] = selectColor
			end
			if moved == 0 and game.board[8][y][1] == 'R' and game.board[8][y][6] == 0 and
				game.board[7][y][1] == '_' and game.board[6][y][1] == '_' and game.board[5][y][1] == '_' then

				game.board[6][y][2] = castle
				game.board[6][y][3] = selectColor
			end
		end
	end
end
chess.selectFunc = select

local lastRank = {'R', 'N', 'B', 'K', 'Q', 'B', 'N', 'R'}

--Setup starting pieces and empty spaces
function chess.setupFunc(game, x,y)
	local background = colors.gray
	if x%2==y%2 then
		background = colors.lightGray
	end

	if y == 1 then
		return {lastRank[x], select, colors.white, background, nil, 0}
	elseif y == 2 then
		return {'P', select, colors.white, background, nil, 0}
	elseif y == 7 then
		return {'P', select, colors.black, background, nil, 0}
	elseif y == 8 then
		return {lastRank[x], select, colors.black, background, nil, 0}
	else
		return {'_', nullFunc, background, background, nil, false}
	end
end

--Clear player data
function chess.resetFunc(game)
	for i=1,#game.players do
		game.players[i].captured = 0
		game.players[i].selected = {0,0}
	end
end

--Start game
startGame(chess)

