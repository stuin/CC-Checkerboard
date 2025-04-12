require("cccheckerboard")

run_main = false
require("binario-gen")

--Initial game configuration
local binario = {
	name="Binario",
	players={
		{name='Player', color=colors.white},
	},
	width=6,
	height=6,
	maxSize=12,
	generated=nil,
	blank=0,
	edgeColor=colors.black,
	gridColor=colors.white,
	titleColor=colors.white
}

local function checkWin(game)
	local board = {}
	for x=1,game.width do
		board[x] = {}
		for y=1,game.height do
			board[x][y] = game.board[x][y][1]
		end
	end

	if count_blanks(board) == 0 and valid_board(board) then
		game.playing = false
	end
end

--Play in an empty cell
local function play(game, x,y)
	if game.board[x][y][1] == '_' then
		game.board[x][y] = {'0', play, colors.white, colors.black}
		game.blank = game.blank - 1
	elseif game.board[x][y][1] == '0' then
		game.board[x][y] = {'1', play, colors.lime, colors.gray}
	elseif game.board[x][y][1] == '1' then
		game.board[x][y] = {'_', play, colors.white, colors.black}
		game.blank = game.blank + 1
	end

	if game.blank == 0 then
		checkWin(game)
	end
end

--Setup starting pieces and empty spaces
function binario.setupFunc(game, x,y)
	--Assign specific cell
	local t = game.generated[x][y]
	if t == BLANK then
		return {'_', play, colors.white, colors.black}
	elseif t == ZERO then
		return {'0', nullFunc, colors.lightGray, colors.black}
	elseif t == ONE then
		return {'1', nullFunc, colors.green, colors.gray}
	end
end

--Generate new board
function binario.resetFunc(game)
	local board = nil
	local tries = 10

	--keeps trying to generate puzzles until it creates a successful one.
	--this normally doesn't need to loop, but it's still an edge case to test for
	while board == nil and tries > 0 do
		--creates the board of the correct size
		board = {}
		for i=1,game.width do
			board[i] = {}
			for j=1,game.height do
				board[i][j] = '_'
			end
		end

		game.generated = generate_puzzle(board)
		tries = tries - 1
	end

	game.blank = count_blanks(game.generated)
end

--Start game
startGame(binario)

