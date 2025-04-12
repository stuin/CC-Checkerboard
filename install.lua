local files = {
	"cccheckerboard.lua",
	"gamelist.lua"
}

local games = {
	"tictactoe.lua",
	"othello.lua",
	"binario-gen.lua",
	"binario.lua",
	"minesweeper.lua",
	"checkers.lua"
}

local git = "https://raw.githubusercontent.com/stuin/CC-Checkerboard/refs/heads/main/"

--Install library files
for i = 1,#files do
	fs.delete(shell.resolve(files[i]))
	shell.run("wget "..git..files[i])
end

--Install game files
for i = 1,#games do
	fs.delete(shell.resolve(games[i]))
	shell.run("wget "..git.."games/"..games[i])
end