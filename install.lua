local files = {
	"cccheckerboard.lua",
	"tictactoe.lua",
	"othello.lua"
}

local git = "https://raw.githubusercontent.com/stuin/CC-Checkerboard/refs/heads/main/"

for i = 1,#files do
	shell.run("delete "..files[i])
	shell.run("wget "..git..files[i])
end

fs.delete("install.lua")