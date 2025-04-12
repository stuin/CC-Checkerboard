require("cccheckerboard")

--Initial game configuration
local checkers = {
	name="Checkers",
	players={
		{name='Red', color=colors.red, captured=0, selected={0,0}, playColor=colors.red},
		{name='Black', color=colors.gray, captured=0, selected={0,0}, playColor=colors.black}
	},
	width=8,
	height=8,
	edgeColor=colors.gray,
	gridColor=colors.white,
	titleColor=colors.white
}

--Check for promotion to Queen
local function checkEnd(game, x,y)
	if game.board[x][y][1] == '0' and y == 1 and game.turn == 2 then
		game.board[x][y][1] = 'Q'
	elseif game.board[x][y][1] == '0' and y == 8 and game.turn == 1 then
		game.board[x][y][1] = 'Q'
	end

	if game.players[game.turn].captured == 12 then
		mapBoard(game, clearSelect)
		game.playing = false
	end
end

--Move one spot
local function move(game, x,y)
	local selected = game.players[game.turn].selected
	game.board[x][y] = game.board[selected[1]][selected[2]]
	game.board[selected[1]][selected[2]] = {'_', nullFunc, colors.white, colors.gray}
	mapBoard(game, clearSelect)
	checkEnd(game,x,y)
	nextTurn(game)
end

--Jump opposing piece
local function jump(game, x,y)
	local selected = game.players[game.turn].selected
	local dx,dy = (selected[1]-x)/2,(selected[2]-y)/2
	game.board[x][y] = game.board[selected[1]][selected[2]]
	game.board[x+dx][y+dy] = {'_', nullFunc, colors.white, colors.gray}
	game.board[selected[1]][selected[2]] = {'_', nullFunc, colors.white, colors.gray}
	game.players[game.turn].captured = game.players[game.turn].captured + 1
	checkEnd(game,x,y)
	if game.playing and not game.board[x][y][2](game, x,y, true) then
		mapBoard(game, clearSelect)
		nextTurn(game)
	end
end

local function clearSelect(game, x,y)
	if game.board[x][y][1] == '_' and game.board[x][y][2] ~= nullFunc then
		return {'_', nullFunc, colors.white, colors.gray}
	end
	return game.board[x][y]
end

--Highlight available moves
local function select(game, x,y, capture)
	local color = game.players[game.turn].playColor
	local opColor = game.players[(game.turn % #game.players) + 1].playColor
	local captureFound = false

	if game.board[x][y][1] ~= '_' and game.board[x][y][3] == color then
		game.players[game.turn].selected = {x,y}
		mapBoard(game, clearSelect)

		local up = color == colors.black or game.board[x][y][1] == 'Q'
		local down = color == colors.red or game.board[x][y][1] == 'Q'

		--Up left
		if up and onBoard(x-1,y-1) and game.board[x-1][y-1][1] == '_' and capture == nil then
			game.board[x-1][y-1] = {'_', move, colors.green, colors.gray}
		elseif up and onBoard(x-2,y-2) and game.board[x-1][y-1][3] == opColor and game.board[x-2][y-2][1] == '_' then
			game.board[x-2][y-2] = {'_', jump, colors.green, colors.gray}
			captureFound = true
		end

		--Up right
		if up and onBoard(x+1,y-1) and game.board[x+1][y-1][1] == '_' and capture == nil then
			game.board[x+1][y-1] = {'_', move, colors.green, colors.gray}
		elseif up and onBoard(x+2,y-2) and game.board[x+1][y-1][3] == opColor and game.board[x+2][y-2][1] == '_' then
			game.board[x+2][y-2] = {'_', jump, colors.green, colors.gray}
			captureFound = true
		end

		--Down left
		if down and onBoard(x-1,y+1) and game.board[x-1][y+1][1] == '_' and capture == nil then
			game.board[x-1][y+1] = {'_', move, colors.green, colors.gray}
		elseif down and onBoard(x-2,y+2) and game.board[x-1][y+1][3] == opColor and game.board[x-2][y+2][1] == '_' then
			game.board[x-2][y+2] = {'_', jump, colors.green, colors.gray}
			captureFound = true
		end

		--Down right
		if down and onBoard(x+1,y+1) and game.board[x+1][y+1][1] == '_' and capture == nil then
			game.board[x+1][y+1] = {'_', move, colors.green, colors.gray}
		elseif down and onBoard(x+2,y+2) and game.board[x+1][y+1][3] == opColor and game.board[x+2][y+2][1] == '_' then
			game.board[x+2][y+2] = {'_', jump, colors.green, colors.gray}
			captureFound = true
		end
	end
	return captureFound
end

--Setup starting pieces and empty spaces
function checkers.setupFunc(game, x,y)
	local white = x%2==y%2
	if x%2==y%2 then
		--White space
		return {' ', nullFunc, colors.white, colors.white}
	elseif y < 4 then
		return {'0', select, colors.red, colors.gray}
	elseif y > 5 then
		return {'0', select, colors.black, colors.gray}
	else
		return {'_', nullFunc, colors.white, colors.gray}
	end
end

--Clear player data
function checkers.resetFunc(game)
	for i=1,#game.players do
		game.players[i].captured = 0
		game.players[i].selected = {0,0}
	end
end

--Start game
startGame(checkers)

