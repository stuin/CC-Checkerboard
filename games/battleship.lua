require("cccheckerboard")

--Initial game configuration
local battleship = {
	name="Battleship",
	players={
		{name='Red', color=colors.red, hit=0, placing=1, rotate=false},
		{name='Blue', color=colors.blue, hit=0, placing=1, rotate=false}
	},
	width=19,
	height=9,
	edgeColor=colors.lightBlue,
	gridColor=colors.black,
	titleColor=colors.blue
}

local ships = {
	{'carrier', 	'C', 5},
	{'battleship', 	'B', 4},
	{'destroyer', 	'D', 3},
	{'submarine', 	'S', 3},
	{'patrol', 		'P', 2}
}

local function shoot(game, x,y)
	local pOther = (game.turn % #game.players) + 1
	if game.board[x+10][y][5][pOther] ~= nil then
		game.board[x+10][y][5][pOther] = {'*', nil, colors.red, colors.gray}
		game.board[x][y][5][game.turn] = {'*', nullFunc, colors.red, colors.gray}
		game.players[game.turn].hit = game.players[game.turn].hit + 1
	else
		game.board[x+10][y][5][pOther] = {'*', nil, colors.white, colors.blue}
		game.board[x][y][5][game.turn] = {'*', nullFunc, colors.white, colors.blue}
	end

	if game.players[game.turn].hit == 17 then
		game.playing = false
	else
		nextTurn(game)
	end
end

local function mirror(game,x,y)
	if game.board[x-10][y][5][game.turn] == nil then
		game.board[x-10][y][2](game,x-10,y)
	end
end

local function playSetup(game,x,y)
	if x < 10 then
		return {'~', shoot, colors.black, colors.blue, {nil, nil}}
	elseif x > 10 then
		game.board[x][y][2] = mirror
		return game.board[x][y]
	else
		return game.board[x][y]
	end
end

--Ship placement functions
local function rotate(game, x,y)
	local p = game.players[game.turn]
	if p.rotate then
		for i=2,ships[p.placing][3] do
			game.board[1][i][5][game.turn] = nil
		end
		for i=2,ships[p.placing][3] do
			game.board[i][1][5][game.turn] = {ships[p.placing][2], rotate, colors.white, colors.gray}
		end
		p.rotate = false
	else
		for i=2,ships[p.placing][3] do
			game.board[i][1][5][game.turn] = nil
		end
		for i=2,ships[p.placing][3] do
			game.board[1][i][5][game.turn] = {ships[p.placing][2], rotate, colors.white, colors.gray}
		end
		p.rotate = true
	end
end

local function nextShip(game, x,y)
	local p = game.players[game.turn]
	--Remove previous ship
	if p.rotate then
		for i=1,ships[p.placing][3] do
			game.board[1][i][5][game.turn] = nil
		end
	else
		for i=1,ships[p.placing][3] do
			game.board[i][1][5][game.turn] = nil
		end
	end
	p.rotate = false
	p.placing = p.placing + 1

	--Move on after last ship
	if p.placing > #ships then
		nextTurn(game)
		if game.turn == 1 then
			mapBoard(game, playSetup)
			return
		end
	end

	--Prepare next ship
	local p = game.players[game.turn]
	for i=1,ships[p.placing][3] do
		game.board[i][1][5][game.turn] = {ships[p.placing][2], rotate, colors.white, colors.gray}
	end
end

local function place(game, x,y)
	local p = game.players[game.turn]
	if p.rotate and onBoard(x,y+ships[p.placing][3]-1) then
		for i=1,ships[p.placing][3] do
			if game.board[x][y+i-1][5][game.turn] ~= nil then
				return
			end
		end

		for i=1,ships[p.placing][3] do
			game.board[x][y+i-1][5][game.turn] = {ships[p.placing][2], nil, colors.white, colors.gray}
		end
		nextShip(game, x,y)
	elseif not p.rotate and onBoard(x+ships[p.placing][3]-1, y) then
		for i=1,ships[p.placing][3] do
			if game.board[x+i-1][y][5][game.turn] ~= nil then
				return
			end
		end

		for i=1,ships[p.placing][3] do
			game.board[x+i-1][y][5][game.turn] = {ships[p.placing][2], nil, colors.white, colors.gray}
		end
		nextShip(game, x,y)
	end
end

--Setup starting pieces and empty spaces
function battleship.setupFunc(game, x,y)
	if x == 10 then
		--return {string.char(96+x), nullFunc, game.gridColor, game.edgeColor}
		return {y, nullFunc, game.gridColor, game.edgeColor}
	elseif y == 1 and x < 6 then
		return {'~', nullFunc, colors.black, colors.blue, {{'C', rotate, colors.white, colors.gray}, nil}}
	elseif x > 10 then
		return {'~', place, colors.black, colors.blue, {nil, nil}}
	else
		return {'~', nullFunc, colors.black, colors.blue, {nil, nil}}
	end
end

--Clear player data
function battleship.resetFunc(game)
	for i=1,#game.players do
		game.players[i].hit = 0
		game.players[i].placing = 1
		game.players[i].rotate = false
	end
end

--Start game
startGame(battleship)

