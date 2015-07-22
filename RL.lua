-- -------------------------------------------------------------------------------
--  RL.lua - 
--  Created by Mehdi Fatemi on 2015-07-19.
-- -------------------------------------------------------------------------------

local class = require 'class'

-- define RL class
local RL = class('A')

function RL:__init(kwarg)
    self.board_w   = kwarg['board_w']   # board width
    self.board_h   = kwarg['board_h']   # board height
    self.board     = {}                 # game board
    self.current_p = {}                 # current position of the agent
    self.available_actions = {'up', 'down', 'left', 'right'}
    self.make_board_method = kwarg['make_board_method']
    --self.make_board()
end

function RL:run()
    print(self.stuff)
    endreturn RL
