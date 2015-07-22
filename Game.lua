-- -------------------------------------------------------------------------------
--  Game.lua -
--  Created by Mehdi Fatemi on 2015-07-19.
-- -------------------------------------------------------------------------------


--[[
if not dqn then
    require 'initenv'
end
--]]

game = {}

local gw = torch.class('game.GridWorld')


function gw:__init(args)
    self.state_dim  = args.state_dim -- State dimensionality.









require 'torch'
local class = torch.class(Game)

-- define Game class

function Game:__init(kwarg)
    self.board_w   = kwarg['board_w']   -- board width
    self.board_h   = kwarg['board_h']   -- board height
    self.board     = {}                 -- game board
    self.current_p = {}                 -- current position of the agent
    self.available_actions = {'up', 'down', 'left', 'right'}
    self.make_board_method = kwarg['make_board_method']
    --self.make_board()
end

function Game:run()
    print(self.board_w)
end

