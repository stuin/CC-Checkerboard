--Copied from https://github.com/jpnickolas/takuzu-generator/blob/master/generator.cpp
--Manually converted to lua

local DEFAULT_SIZE = 8
BLANK = '_'
ZERO = '0'
ONE = '1'

--Prints out the board
function print_board(board)
  for i=1,#board do
    term.setCursorPos(1,i)
    for j=1,#board[i] do
      term.write(board[i][j])
    end
  end
  term.setCursorPos(1,#board+1)
end

--Returns true if the board is a valid board, and false otherwise
function valid_board(board)
  local zero,one = 0,0
  local size = #board

  --checks the rows for too many 1's or 0's
  for i=1,size do
    for j=1,size do
      if board[i][j] == ONE then
        one = one + 1
      elseif board[i][j] == ZERO then
        zero = zero + 1
      end
    end
    if one > size/2 or zero > size/2 then
      return false
    end

    one = 0
    zero = 0
  end

  --checks the columns for too many 1's or 0's
  for i=1,size do
    for j=1,size do
      if board[j][i] == ONE then
        one = one + 1
      elseif board[j][i] == ZERO then
        zero = zero + 1
      end
    end
    if one > size/2 or zero > size/2 then
      return false
    end

    one = 0
    zero = 0
  end

  --checks the rows for any values of more than 2 in succession
  local consecutive = false
  for i=1,size do
    for j=2,size do
      if board[i][j]==board[i][j-1] and board[i][j] ~= BLANK then
        if consecutive then
          return false
        else
          consecutive = true
        end
      else
        consecutive = false
      end
    end
  end

  --checks the columns for any values of more than 2 in succession
  consecutive = false
  for i=1,size do
    for j=2,size do
      if board[j][i]==board[j-1][i] and board[j][i] ~= BLANK then
        if consecutive then
          return false
        else
          consecutive = true
        end
      else
        consecutive = false
      end
    end
  end

  --checks the rows for duplicates
  for i=1,size do
    for j=i+1,size do
      local same = true
      for k=1,size do
        if board[i][k] ~= board[j][k] or board[j][k]==BLANK then
          same = false
          break
        end
      end
      if same then
        return false
      end
    end
  end

  --checks the columns for duplicates
  for i=1,size do
    for j=i+1,size do
      local same = true
      for k=1,size do
        if board[k][i] ~= board[k][j] or board[k][j]==BLANK then
          same = false
          break
        end
      end
      if same then
        return false
      end
    end
  end

  return true
end

--counts the blank spaces in a board
function count_blanks(board)
  local blanks = 0

  for i=1,#board do
    for j=1,#board[i] do
      if board[i][j] == BLANK then
        blanks = blanks + 1
      end
    end
  end

  return blanks
end

--chooses a random blank space from the board, and sends back the (x, y)
function get_random_blank(board)

  --counts the blanks and chooses a random one
  local blanks = count_blanks(board)
  local blank = math.random(1, blanks)-1

  --finds that random blank spot, and sends it back
  for i=1,#board do
    for j=1,#board[i] do
      if board[i][j] == BLANK then
        if blank > 0 then
          blank = blank - 1
        else
          return i,j
        end
      end
    end
  end
end

--Recursively counts the number of solutions of the board.
--This caps at 2 for the sake of efficiency, but can be altered easily to get
--the total number of solutions.
function count_solutions(board)
  --checks if the board is even valid
  if not valid_board(board) then
    return 0
  end

  --finds a blank spot
  for i=1,#board do
    for j=1,#board[i] do
      if board[i][j]==BLANK then

        --tests zero in that blank spot
        board[i][j]=ZERO
        local solutions = count_solutions(board)

        --if there are too many solutions, don't even bother getting the rest
        if solutions>1 then
          board[i][j]=BLANK
          return solutions
        else
          --tests one in that blank spot
          board[i][j]=ONE
          solutions = solutions + count_solutions(board)

          --resets the board before returning the number of solutions
          board[i][j]=BLANK
          return solutions
        end
      end
    end
  end

  --if there are no more blank spots, then this must be a solution
  return 1
end

--recursively finds the first solution to a puzzle, and returns it
function get_solution(board)
  if not valid_board(board) then
    return nil
  end

  --finds the first blank in the board
  for i=1,#board do
    for j=1,#board[i] do
      if board[i][j]==BLANK then

        --tries filling the blank with a zero
        board[i][j]=ZERO

        --gets the first solution with a zero
        solution = get_solution(board)

        --if the solution is empty, tries again with a one
        if solution == nil then
          board[i][j]=ONE
          solution = get_solution(board)

          if solution == nil then
            board[i][j]=BLANK
          end
        end

        --resets the board before returning the solution
        board[i][j] = BLANK
        return solution
      end
    end
  end

  --Convert board to deep copy
  board1 = {}
  for i=1,#board do
    board1[i] = {}
    for j=1,#board[i] do
      board1[i][j] = board[i][j]
    end
  end

  return board1
end

--makes the game a bit easier by giving the user some free spaces
function ease_board(board, extra_spots)

  --gets the solution to the puzzle
  solution = get_solution(board)

  --gets random blank spots, and fills them in
  for i=1,extra_spots do
    local x,y = get_random_blank(board)

    board[x][y] = solution[x][y]
  end

  return board
end

--recursively generates the takuzu puzzle based on the size of the initial
--board sent. If the board is filled, it will attempt to create a puzzle from
--it.
function generate_puzzle(board)

  --counts the possible solutions in the board
  local solutions = count_solutions(board)

  --if there is only one solution, return that board with a few spaces filled
  if solutions == 1 then
    return ease_board(board, count_blanks(board)/8)
  elseif solutions > 1 then
    --will try up to 10 times to create a working puzzle
    for i=1,10 do

      --gets a random blank spot, and fills it with a random zero or one
      local x,y = get_random_blank(board)
      if math.random(1,2) == 1 then
        board[x][y] = ZERO
      else
        board[x][y] = ONE
      end

      --generates a new puzzle with that configuration
      generated_puzzle = generate_puzzle(board)

      --if the new puzzle is successful, it is returned. Otherwise, reattempt
      if generated_puzzle == nil then
        board[x][y]=BLANK
      else
        return generated_puzzle
      end
    end
  end

  --will eventually give up, although this is highly unlikely.
  return nil
end

function main()

  local size = DEFAULT_SIZE

  --checks if a command line argument was sent
  if #arg > 0 then
    --gets the size from the argument
    size = string.byte(arg[1])

    --makes sure the argument is valid.
    if size<2 then
      size = DEFAULT_SIZE
    end

    --makes sure the argument is even
    if size%2 == 1 then
      size = size - 1
    end
  end

  --randomizes the timer
  math.randomseed(os.epoch())

  local board = nil
  local tries = 10

  --keeps trying to generate puzzles until it creates a successful one.
  --this normally doesn't need to loop, but it's still an edge case to test for
  while board == nil and tries > 0 do
    --creates the board of the correct size
    board = {}
    for i=1,size do
      board[i] = {}
      for j=1,size do
        board[i][j] = BLANK
      end
    end

    board = generate_puzzle(board)
    tries = tries - 1
  end

  --prints out the board
  if board ~= nil then
    term.clear()
    print_board(board)
  end
  term.write(10-tries)
end


if run_main == nil then
  main()
end
