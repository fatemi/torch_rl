-- -------------------------------------------------------------------------------
--  Game.lua -
--  Created by Mehdi Fatemi on 2015-07-19.
-- -------------------------------------------------------------------------------


--[[
if not game then
    require 'InitEnvt'
end
--]]

require 'InitEnvt'
game = {}

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
    self.current_p = (row - 1) * self.board_w + col - 1
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
    if action == 'up' then
        local reward = self:_move_up()
        local state = deepcopy(self.board)
        state[self.current_p] = 'X'
        
    elseif action == 'down' then
        local reward = self:_move_down()
        local state = deepcopy(self.board)
        state[self.current_p] = 'X'
        
    elseif action == 'left' then
        local reward = self:_move_left()
        local state = deepcopy(self.board)
        state[self.current_p] = 'X'
        
    elseif action == 'right' then
        local reward = self:_move_right()
        local state = deepcopy(self.board)
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
        
    elseif self.board[self.current_p - self.board_w] == 'G' then -- reaching the Goal!!!
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
        
    elseif self.board[self.current_p + self.board_w] == 'H' then -- falling into a hole
        return -5.0
        
    elseif self.board[self.current_p + self.board_w] == 'G' then -- reaching the Goal!!!
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
        
    elseif self.board[self.current_p + 1] == 'H' then            -- falling into a hole
        return -5.0
        
    elseif self.board[self.current_p + 1] == 'G' then            -- reaching the Goal!!!
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
        
    elseif self.board[self.current_p - 1] == 'H' then            -- falling into a hole
        return -5.0
        
    elseif self.board[self.current_p - 1] == 'G' then            -- reaching the Goal!!!
        self.current_p = self.current_p - 1
        return 30.0
        
    else
        self.current_p = self.current_p - 1
        return -1.0
    end
end

