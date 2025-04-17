--ANSI Terminal substitute for computercraft libraries

--Terminal 256 colors
colors = {
	white=255,
	orange=214,
	magenta=176,
	lightBlue=111,
	yellow=185,
	lime=112,
	pink=212,
	gray=239,
	lightGray=247,
	cyan=67,
	purple=135,
	blue=26,
	brown=94,
	green=70,
	red=160,
	black=233
}

--Terminal output
term = {
	textColor=colors.white,
	backgroundColor=colors.black,
	size=2
}

function term.getSize()
	return 40,25
end

function term.clear()
	io.write("\x1B[2J")
end

function term.clearLine()
	io.write("\x1B[2K")
end

function term.setCursorPos(x,y)
	io.write("\x1B[",y*term.size,";",x*term.size,"H")
end

function term.setTextColor(color)
	io.write("\x1B[38;5;",color,"m")
	term.textColor = color
end

function term.getTextColor()
	return term.textColor
end

function term.setBackgroundColor(color)
	if color == colors.black then
		io.write("\x1B[48;5;0m")
	else
		io.write("\x1B[48;5;",color,"m")
	end
	term.backgroundColor = color
end

function term.getBackgroundColor()
	return term.backgroundColor
end

function term.write(s)
	io.write("\x1B]66;s=",term.size,";")
	io.write(s)
	io.write("\a")
end

--Terminal input
local buffer = ""
local mouseSupport = true

--Blank background
io.write("\x1B[48;5;0m")

--Clear Screen
io.write("\x1B[2J")

for i=1,#arg do
	if arg[i] == "--ansi-no-mouse" then
		mouseSupport = false
	elseif arg[i] == "--ansi-scale" then
		local s = tonumber(arg[i + 1])
		i = i + 1
		term.size = s
	end
end

function os.pullEvent()
	if mouseSupport then
		os.execute("stty -echo")
		io.write("\x1B[?1003h")
	end

	local escape = 0
	local mouse = false
	local x,y = 0,0

	while true do
		--Read stdin
		while buffer == nil or buffer:len() == 0 do
			buffer = io.read()
		end

		--Check for valid inputs
		for i=1,buffer:len() do
			c = string.byte(buffer, i)

			if c == 27 then
				--Escape
				escape = 5
				mouse = false
			elseif escape > 0 then
				if escape == 4 then
					mouse = c==77
				elseif mouse and escape == 3 then
					mouse = c==35
				elseif mouse and escape == 2 then
					x = c
				elseif mouse and escape == 1 then
					if mouseSupport then
						io.write("\x1B[?1000l")
					end
					buffer = buffer:sub(i+1)
					x,y = x-32,c-32
					x,y = math.floor(x/term.size), math.floor(y/term.size)
					return "mouse_click", 0, x,y
				end
				escape = escape - 1
			elseif c > 47 then
				if mouseSupport then
					io.write("\x1B[?1000l")
				end
				l = buffer:sub(i,i)
				buffer = buffer:sub(i+1)
				return "char", l
			end
		end
		buffer = ""
	end
end


--Other library functions to prevent errors
peripheral = {}
shell = {}


function peripheral.find(name)
	return nil
end

function shell.run(cmd)

end

function term.current()
	return 0
end

function term.redirect(t)

end

function os.epoch()
	return os.time()
end