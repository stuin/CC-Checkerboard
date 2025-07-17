# CCCheckerboard

A lua library for creating small text grid turn based games for the ComputerCraft Minecraft mod

### Game Features

- Fully mouse controllable with `Restart` and `Quit` buttons
- Accepts keyboard control
	- `a1` = 1,1
	- `h8` = 8,8
	- `R` to Restart game
	- `Q` to Quit game
	- For more than 9 rows:
		- `a10` = 1,10 
		- `a01` or `a1 ` = 1,1
- Connects to monitor and resizes to fill screen
- Supports any number of players per game
	- Defaults to shared screen that swaps between players
	- Add `-m` to args to connect to modem
	- The computer will wait until there are as many computers connected as players in the game
	- All computers will display the board, only the current player can select a cell
	- Any player can restart or quit the game for everyone
	- Use `-p #` to limit the number of players in the game
	- Use `-p # -m` with a larger number to allow extra spectator screens
- By default, board is on left edge and text options are on right
- Add `-c` to args to center board and text
- All colors are customizable
- Move history
- Single file library
- Synced random seed
- Random board generation can happen at game start or during the game
- Supports a unique hidden board for each player (ex: battleship)
- Add `-u` to args to install updates from git
- `gamelist` for a list of playable games, with mouse or keyboard selection
- `gamelist -m` to wait for any multiplayer game and join
- Multiple example games:
	- Tic Tac Toe
	- Checkers
	- Othello
	- Minesweeper
	- Binario

### Install in ComputerCraft

```
wget run https://raw.githubusercontent.com/stuin/CC-Checkerboard/refs/heads/main/install.lua
```

### Play in terminal

Games can also be played outside of ComputerCraft in the terminal using base lua. `ansi-term.lua` provides alias functions for the libraries and terminal input and output.

By default, terminal buffers mean that any text or mouse input must be followed by an enter key, but the `input-wrapper.py` script manually inserts an enter key to avoid this, allowing direct mouse/keyboard control.

```
python input-wrapper.py games/binario.lua
```

### Programming Design

Initial game setup is done with one object and a lambda function to create the initial state for each cell of the grid. A reset function should also be included if there is any custom data included in the game object.

```
require("cccheckerboard")

local othello = {
	name="Othello",
	version="0.1.0",
	cccVersion="0.1.0",
	players={
		{name='Black', color=colors.gray, placed=2, playColor=colors.black},
		{name='White', color=colors.white, placed=2, playColor=colors.white}
	},
	width=8,
	height=8,
	backColor=colors.green,
	edgeColor=colors.gray,
	gridColor=colors.green,
	titleColor=colors.green
}

function othello.setupFunc(game, x,y)
	if (x==4 and y==4) or (x==5 and y==5) then
		return {'O', nullFunc, colors.white, colors.green}
	elseif (x==4 and y==5) or (x==5 and y==4) then
		return {'O', nullFunc, colors.black, colors.green}
	else
		return {'_', play, colors.lime, colors.green}
	end
end

--Clear player data
function othello.resetFunc(game)
	for i=1,#game.players do
		game.players[i].placed = 2
	end
end

--Start game
startGame(othello)
```

Every cell has at minimum a display char, a function to run when the cell is selected, and foreground and background colors.

The run function can be null, the same for all cells, or can be changed along with the other values.

```
local function play(game, x,y)
	if game.turn == 1 then
		--Check if move is valid before placing
		if spread(game, x,y, colors.black) > 0 then
			game.board[x][y] = {'O', nullFunc, colors.black, colors.green}
			game.players[game.turn].placed = game.players[game.turn].placed + 1
			checkWin(game)
		end
	else
		if spread(game, x,y, colors.white) > 0 then
			game.board[x][y] = {'O', nullFunc, colors.white, colors.green}
			game.players[game.turn].placed = game.players[game.turn].placed + 1
			checkWin(game)
		end
	end
end
```

After the selected cell function returns the board is redrawn and a new cell is selected. This can be the same player or the next player depending on if `nextTurn(game)` has been run.

Some games use one input/function to select a piece and highlight all possible destinations, and then a second input is to actually move the piece.

### Plans/Todo

- Bitmaps for replacing the display characters with simple images
- Full web/desktop app
- Game list UI
- Puzzle game levels/difficulty
- Timer
- Multiplayer move verification
- Terminal multiplayer
- Actual online multiplayer
- AI players?
- Game saving?
- Sound effects?

### Potential games to add

- Sudoku
- Pipe flow puzzle
- Mastermind
- Go
- Stratego
- Matching
- Maze
- Dungeon crawler
