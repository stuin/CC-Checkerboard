local files = {
	"cccheckerboard.lua",
	"tictactoe.lua",
	"othello.lua"
}

local git = "https://github.com/stuin/CC-Checkerboard/blob/main/"

for i = 1,#files do
	fs.delete(files[i])
	shell.run("wget "..git..files[i])
end

fs.delete("install.lua")