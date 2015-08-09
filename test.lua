-- -------------------------------------------------------------------------------
--  test.lua - 
--  Created by Mehdi Fatemi on 2015-07-22.
-- -------------------------------------------------------------------------------

require 'game'
require 'rl'
require 'utils/envt.lua'

local MAX_MOVE        = 1000   -- maximum number of moves in a game
local NUM_EPISODS     = 50     -- number of plays
local NUM_EXPERIMENTS = 1      -- number of Monte Carlo experiments
-- torch.manualSeed(1)           -- fixing random sequences


--[[
 -- For random Game:
local opt = {
    board_w = 5,
    board_h = 7,
    make_board_method = 'random'
}

local base_game = game.GridWorld(opt)
base_game:set_start(2,3)

--]]

b = [[
OOOHOOOOO
OOOHOOHOO
OOOOOOHOO
OOOOHHHOO
OOHOOOOOH
OOHOOOGOO
OOOOOOOOO]]

board_t = {}
for i = 1, #b do
    if b:sub(i,i)~='\n' then table.insert(board_t, b:sub(i,i)) end
end

local opt = {
    board_w = 9,
    board_h = 7,
    board   = board_t,
    make_board_method = 'user'
}

local base_game = game.GridWorld(opt)
base_game:set_start(3,2)



local results = torch.zeros(NUM_EXPERIMENTS, NUM_EPISODS)

for expt_count = 1, NUM_EXPERIMENTS do
    print('\n\n')
    print(string.rep('*', 18))
    print('NEW EXPERIMENT...\n')
    print(string.rep('*', 18))
    
    -- Reinforcement learning agent
    --[[
     Actions are coded as follows:
     'up'    == 1
     'down'  == 2
     'left'  == 3
     'right' == 4
    --]]
    local opt_rl = {
        stateDim = base_game.board_w * base_game.board_h,
        maxStateSize = 1e3,
        s = {},
        numActions = 4
    }
    local agent = rl.RLM(opt_rl)
    
    local episode_count = 1
    
    while episode_count <= NUM_EPISODS do
        -- playing a new game:
        print('\n\n')
        print(string.rep('+', 10))
        print('New episode...\n')
        g = base_game:clone()   -- restart the game
        g:display()
        
        local move_count = 1
        local state_pre = deepcopy(g.board)
        state_pre[g.current_p] = 'X'
        while move_count <= MAX_MOVE do
            print (string.rep('-', 20))
            print ('Move number: ', move_count)
            print (string.rep('-', 20))
            
            local action = g:num2a(agent:policy(g:s2num(state_pre)))
            
            state_next, reward = g:move(action)
            print ('Action: ', action)
            print ('Reward: ', reward)
            print ('Board updated...')
            g:display()
            
            -- Q-learning;
            -- for SARSA, use agent:SARSA(.....)
            agent:QLearning(g:s2num(state_pre), g:s2num(state_next), g:a2num(action), reward)
            state_pre = deepcopy(state_next)
            
            if reward == 30 then
                print ('Game over... Agent won!!')
                results[{expt_count, episode_count}] = move_count
                break
            else
                move_count = move_count + 1
            end
        end
        
        episode_count = episode_count + 1
        if episode_count > 30 and episode_count < 40 then
            agent.epsilon = .9 * agent.epsilon  -- annealing the exploration
        elseif episode_count == 40 then
            agent.epsilon = 0                   -- turn off the exploration
        end
    end
    -- agent.Q:write()
end


-- Plotting
require 'gnuplot'
t = torch.range(1, NUM_EPISODS)
gnuplot.plot(t, results:mean(1):view(NUM_EPISODS))





--[[
g:set_start(2,3)

g:display()

g:move('up')
g:display()

g:move('up')
g:display()

g:move('down')
g:display()

g:move('right')
g:display()

g:move('right')
g:display()

g:move('left')
g:display()

g:move('left')
g:display()
--]]


