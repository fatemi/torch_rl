-- -------------------------------------------------------------------------------
--  Game.lua -
--  Created by Mehdi Fatemi on 2015-07-19.
-- -------------------------------------------------------------------------------


require 'utils/envt.lua'

if not game then
    game = {}
end


local gw = torch.class('game.GridWorld')


function gw:__init(args)
    if args['make_board_method'] == 'random' then
        self.board_w           = args['board_w']  -- board width
        self.board_h           = args['board_h']  -- board height
        self.board             = {}               -- game board
        self.current_p         = {}               -- current position of the agent
        self.available_actions = {'up', 'down', 'left', 'right'}
        self.make_board_method = args['make_board_method']
        self:make_board()
    elseif args['make_board_method'] == 'user' then
        self.board_w           = args['board_w']  -- board width
        self.board_h           = args['board_h']  -- board height
        self.board             = args['board']    -- game board
        self.current_p         = {}
        self.available_actions = {'up', 'down', 'left', 'right'}
        self.make_board_method = args['make_board_method']
    end
end


function gw:clone()
    return deepcopy(self)
end



function gw:set_start(row, col)
--[[
Setting the current position
--]]
    self.current_p = (row - 1) * self.board_w + col
end



function gw:make_board(p)
--[[
This method initializes the game board in accordance with
the 'method' of random board-game.
p  :  percentage of holes in the board
--]]

    local p = p or .2    -- default probability of holes

    if self.make_board_method == 'random' then
        -- Making holes and ordinary places in accordance with p:
        for i = 1, self.board_h * self.board_w do
            if torch.uniform() > p then
                table.insert(self.board, 'O')
            else
                table.insert(self.board, 'H')
            end
        end
                
        -- Selecting a random place as the Goal
        self.board[torch.random(1, (self.board_h * self.board_w) - 1)] = 'G'
        
        -- Selecting a random initial position
        local pos = {}
        for ind, value in pairs(self.board) do
            if value == 'O' then table.insert( pos, ind ) end
        end
        self.current_p = pos[torch.random(1, #pos)]
    end
end



function gw:s2num(state)
    local t = torch.IntTensor(self.board_w * self.board_h):fill(0)
    for i = 1, self.board_w * self.board_h do
        if state[i] == 'O' then
            t[i] = 1
        elseif state[i] == 'H' then
            t[i] = 2
        elseif state[i] == 'X' then
            t[i] = 3
        elseif state[i] == 'G' then
            t[i] = 4
        end
    end
    return t
end



function gw:num2s(state)
    local t = {}
    for i = 1, self.board_w * self.board_h do
        if state[i] == 1 then
            table.insert(t, 'O')
        elseif state[i] == 2 then
            table.insert(t, 'H')
        elseif state[i] == 3 then
            table.insert(t, 'X')
        elseif state[i] == 4 then
            table.insert(t, 'G')
        end
    end
    return t
end



function gw:num2a(action)
    --[[
     Actions are coded as follows:
     'up'    == 1
     'down'  == 2
     'left'  == 3
     'right' == 4
     --]]
    if action == 1 then
        return 'up'
    elseif action == 2 then
        return 'down'
    elseif action == 3 then
        return 'left'
    elseif action == 4 then
        return 'right'
    else
        print('Action is not recognized.')
        return nil
    end
end



function gw:a2num(action)
    --[[
     Actions are coded as follows:
     'up'    == 1
     'down'  == 2
     'left'  == 3
     'right' == 4
     --]]
    if action == 'up' then
        return 1
    elseif action == 'down' then
        return 2
    elseif action == 'left' then
        return 3
    elseif action == 'right' then
        return 4
    else
        print('Action is not recognized.')
        return nil
    end
end



function gw:display()
--[[
This method displayes the board
--]]
    local s = deepcopy(self.board)
    s[self.current_p] = 'X'
   
    local row = string.rep(' P |', (self.board_w - 1)) .. ' P'
    local h_line = '\n' .. string.rep('-', self.board_w*3 + (self.board_w - 1)) .. '\n'
    output = '\n'.. string.rep(row .. h_line, (self.board_h - 1)) .. row .. '\n'
    local s_count = 1
    for i = 1, #output do
        if output:sub(i,i) == 'P' then
            output = string.gsub(output, 'P', s[s_count], 1)
            s_count = s_count + 1
        end
    end
        
    print(output)
end



function gw:move(action)
--[[
This method performs a move.
--]]
    local reward
    local state
    if action == 'up' then
        reward = self:_move_up()
        state = deepcopy(self.board)
        state[self.current_p] = 'X'
        
    elseif action == 'down' then
        reward = self:_move_down()
        state = deepcopy(self.board)
        state[self.current_p] = 'X'
        
    elseif action == 'left' then
        reward = self:_move_left()
        state = deepcopy(self.board)
        state[self.current_p] = 'X'
        
    elseif action == 'right' then
        reward = self:_move_right()
        state = deepcopy(self.board)
        state[self.current_p] = 'X'
        
    else
        print('Action is not recognized.')
    
    end
    return state, reward
end



function gw:_move_up()
    if self.current_p <= self.board_w then                       -- first row
        return -5.0
        
    elseif self.board[self.current_p - self.board_w] == 'H' then -- falling into a hole
        return -5.0
        
    elseif self.board[self.current_p - self.board_w] == 'G' then -- reaching the Goal!
        self.current_p = self.current_p - self.board_w
        return 30.0
        
    else
        self.current_p = self.current_p - self.board_w           -- just an 'O'
        return -1.0
    end
end



function gw:_move_down()
    if self.current_p > (self.board_h - 1)*self.board_w then     -- last row
        return -5.0
        
    elseif self.board[self.current_p + self.board_w] == 'H' then
        return -5.0
        
    elseif self.board[self.current_p + self.board_w] == 'G' then
        self.current_p = self.current_p + self.board_w
        return 30.0
        
    else
        self.current_p = self.current_p + self.board_w
        return -1.0
    end
end
        


function gw:_move_right()
    if (self.current_p % self.board_w) == 0 then                 -- last col
        return -5.0
        
    elseif self.board[self.current_p + 1] == 'H' then
        return -5.0
        
    elseif self.board[self.current_p + 1] == 'G' then
        self.current_p = self.current_p + 1
        return 30.0
        
    else
        self.current_p = self.current_p + 1
        return -1.0
    end
end



function gw:_move_left()
    if (self.current_p % self.board_w) == 1 then                 -- first col
        return -5.0
        
    elseif self.board[self.current_p - 1] == 'H' then
        return -5.0
        
    elseif self.board[self.current_p - 1] == 'G' then
        self.current_p = self.current_p - 1
        return 30.0
        
    else
        self.current_p = self.current_p - 1
        return -1.0
    end
end

