-- -------------------------------------------------------------------------------
--  RL.lua - 
--  Created by Mehdi Fatemi on 2015-07-19.
-- -------------------------------------------------------------------------------

require 'utilities'

if not rl then
    rl = {}
end

local rlm = torch.class('rl.RLM')


function rlm:__init(args)
    self.numStates    = args.numStates or 0  -- current # of states
    self.maxStateSize = args.maxStateSize    -- max # of states
    self.stateDim     = args.stateDim        -- # of vars in the state
    self.numActions   = args.numActions      -- # of actions
    
    -- set of states:
    self.S = args.s or torch.IntTensor(self.maxStateSize, self.stateDim):fill(0)
    -- set of actions:
    self.A = args.a or torch.range(1,self.numActions):type('torch.IntTensor')
    -- table of action-values (should be rl.Q() object)
    self.Q = args.Q or
        rl.Q({maxStateSize = self.maxStateSize, stateDim = self.stateDim})
    -- transition table (should be rl.TransTable() object)
    self.TransTable = args.TransTable or
        rl.TransTable({maxStateSize = self.maxStateSize, stateDim = self.stateDim})
    
    self.discount = args.discount or 0.9
    self.l_rate   = args.l_rate or 0.5
    -- policy strategy (e-greedy or softmax)
    self.strategy = args.strategy or 'e-greedy'
    if self.strategy == 'e-greedy' then
        self.epsilon = args.epsilon or 0.1
    end
end


function rlm:QLearning(s, s_next, a, R)
    --[[
    This method implements q-learning
    s      = current state
    s_next = next state
    a      = selected action
    R      = immedate reward
    --]]
    local available_Q = {}  -- size is not known in advanced
    for _, action in ipairs(self.A:totable()) do
        table.insert(available_Q, self.Q:get_value(s_next, action))
    end
    local maxQ = torch.Tensor(available_Q):max()
    local delta = R + self.discount * maxQ - self.Q:get_value(s,a)
    local v = self.Q:get_value(s,a) + self.l_rate*delta
    self.Q:add_new(s, a, v)               -- updating Q
end


function rlm:SARSA(s, s_next, a, R)
    --[[
    This method implements SARSA
    s      = current state
    s_next = next state
    a      = selected action
    R      = immedate reward
    --]]
    local a_next = self:policy(s_next)    -- next best action
    local delta = R + self.discount * self.Q:get_value(s_next, a_next) - self.Q:get_value(s,a)
    local v = self.Q:get_value(s,a) + self.l_rate*delta
    self.Q:add_new(s, a, v)               -- updating Q
end


function rlm:policy(state)
    --[[
    This method implements policy according to strategies of either:

    * epsilon-greedy (if class-property 'strategy' == 'epsilon'), or

    * softmax (if class-property 'strategy == 'softmax').
               
    It returns the selected action for the input state based on the
    specified strategy.
    --]]

    if self.strategy == 'epsilon' then
        --[[
        Implementation of the epsilon-greedy policy.
        --]]
        -- chekcing for epsilon-greedy
        if torch.uniform() < self.epsilon then  -- exploration
            return self.A[ torch.random(1, self.A:size()[1]) ]
        else                                    -- making a greedy action
            -- table of values for "all" the available actions at the given state
            local current_Q = {}
            for _, action in ipairs(self.A:totable()) do
                current_Q[action] = self.Q:get_value(state, action)
            end
           
            if table.getn(current_Q) == 0 then
                -- "state" has not been visited yet,
                -- no policy exists, a random action will be returned
                return self.A[ torch.random(1, self.A:size()[1]) ]
            else
                -- returning the action (or actions) with max value
                local best_actions = table.maxtt(current_Q)
                if table.getn(best_actions) == 1 then
                    return best_actions[1]
                else
                    return best_actions[ torch.random(1, #best_actions) ]
                end
            end
        end
       
    --[[
    elseif self.strategy == 'softmax' then
        --[[
        Implementation of the logistic softmax policy.
        This method returns an action with the following probability:
        
        exp[ Q(s,a) ]
        p(a|s) = -------------------------   For all available a' at input "state"
        sum_a' { exp[ Q(s,a') ] }
        --]
        from scipy import stats
        import numpy as np
        current_Q = [self.Q[(s,a)] for s, a in self.Q if s == state and (a in self.A)]
        if len(current_Q) == 0:         # this state has not been visited yet.
            # no policy exists, a random action will be returned
            return random.choice(self.A)
        else
            actions   = [a for s, a in self.Q if s == state and (a in self.A)]
            sum_exp_Q = np.sum( np.exp(current_Q) )
            Prob      = [np.exp(Q_)/sum_exp_Q for Q_ in current_Q]
            softmax   = stats.rv_discrete(name='softmax', values=(actions, Prob))
            return softmax.rvs()
        end
    else
        raise NameError('Game strategy not recognized. Must be "epsilon" or "softmax".')
    --]]
    end
end












--[[
 Class rl.Q
 
 --]]


local qf = torch.class('rl.Q')


function qf:__init(args)
    self.gpu          = args.gpu or false
    self.stateDim     = args.stateDim
    self.maxStateSize = args.maxStateSize or 1024
    self.numQ         = 0
    
    self.s     = args.s or torch.IntTensor(self.maxStateSize, self.stateDim):fill(0)
    self.a     = args.a or torch.IntTensor(self.maxStateSize):fill(0)
    self.value = args.value or torch.FloatTensor(self.maxStateSize):fill(0)
end


function qf:add_new(s, a, value)
    if not self:get_value(s, a) then
        self.numQ               = self.numQ + 1
        self.s[{self.numQ, {}}] = s
        self.a[self.numQ]       = a
        self.value[self.numQ]   = value
    end
end


function qf:get_value(s, a)
    for i = 1, self.numQ do
        if self.s[i]:eq(s):all() and self.a[i] == a then
            return self.value[i]
        end
    end
    return nil
end


--[[
Class rl.TransTable 

--]]


local trans = torch.class('rl.TransTable')


function trans:__init(args)
    self.gpu          = args.gpu or false
    self.stateDim     = args.stateDim
    self.maxStateSize = args.maxStateSize or 1024
    self.numTrans = 0
    
    self.s_current = args.s_current or torch.IntTensor(self.maxStateSize, self.stateDim):fill(0)
    self.s_next    = args.s_next or torch.IntTensor(self.maxStateSize, self.stateDim):fill(0)
    self.a         = args.a or torch.IntTensor(self.maxStateSize):fill(0)
    self.reward    = args.reward or torch.FloatTensor(self.maxStateSize):fill(0)
end


function trans:add_new(s, a, r, s2)
    if not self:get_item(s, a, s2) then
        self.numTrans = self.numTrans + 1
        self.s_current[{self.numTrans, {}}] = s
        self.a[self.numTrans]               = a
        self.reward[self.numTrans]          = reward
        self.s_next[{self.numTrans, {}}]    = s2
    end
end


function trans:get_item(s, a, s2)
    for i = 1, self.numTrans do
        if self.s_current[i]:eq(s):all() and self.s_next[i]:eq(s2):all() and self.a[i] == a then
            return self.reward[i]
        end
    end
    return nil
end









