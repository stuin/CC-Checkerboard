local files = {
	"cccheckerboard.lua",
	"tictactoe.lua",
	"othello.lua",
	"binario-gen.lua",
	"binario.lua",
	"minesweeper.lua",
	"checkers.lua"
}

local git = "https://raw.githubusercontent.com/stuin/CC-Checkerboard/refs/heads/main/"

for i = 1,#files do
	fs.delete(shell.resolve(files[i]))
	shell.run("wget "..git..files[i])
end