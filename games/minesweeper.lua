require("cccheckerboard")

--Initial game configuration
local minesweeper = {
	name="Minesweeper",
	players={
		{name='Player', color=colors.white}
	},
	width=7,
	height=7,
	maxSize=20,
	mines=-1,
	revealed=-1,
	edgeColor=colors.gray,
	gridColor=colors.white,
	titleColor=colors.white
}

--Recursively reveal spaces
local function reveal(game, x,y)
	local count = 0
	game.revealed = game.revealed + 1

	--Reveal Mine
	if game.board[x][y][5] then
		game.board[x][y] = {"*", nullFunc, colors.red, colors.black, true}
	elseif game.board[x][y][1] == '_' then
		--Count mines
		for i=1,#directions do
			local _x,_y = x+directions[i][1],y+directions[i][2]
			if onBoard(_x,_y) and game.board[_x][_y][5] then
				count = count + 1
			end
		end

		--Show number
		if count == 0 then
			game.board[x][y] = {".", nullFunc, colors.blue, colors.black, false}
		else
			game.board[x][y] = {""..count, nullFunc, colors.green, colors.black, false}
		end
	end

	--Reveal neighbors
	if count == 0 and game.playing then
		for i=1,#directions do
			local _x,_y = x+directions[i][1],y+directions[i][2]
			if onBoard(_x,_y) and game.board[_x][_y][1] == '_' then
				reveal(game, _x,_y)
			end
		end
	end
	return game.board[x][y]
end

--Play in an empty cell
local function play(game, x,y)
	if game.revealed == -1 then
		--Generate new board
		for i=1,game.mines do
			local valid = false
			while not valid do
				local _x,_y = math.random(1, game.width), math.random(1, game.height)
				if game.board[_x][_y][5] == false and (_x < x-1 or _x > x+1 or _y < y-1 or _y > y+1) then
					valid = true
					game.board[_x][_y][5] = true
				end
			end
		end
		game.revealed = 0
	end

	--Reveal square
	if game.board[x][y][5] then
		--Lose on mine
		game.turn = 0
		game.playing = false
		mapBoard(game, reveal)
	else
		reveal(game, x,y)
	end

	--Check for win
	if game.revealed + game.mines == game.width * game.height then
		game.playing = false
		mapBoard(game, reveal)
	end
end

--Set blank board
function minesweeper.setupFunc(game, x,y)
	return {'_', play, colors.white, colors.black, false}
end

--Clear board data
function minesweeper.resetFunc(game)
	game.mines = game.width * game.height / 6.4 + 0.5
	game.mines = math.floor(game.mines)
	game.revealed = -1
end

--Start game
startGame(minesweeper)

