-- -------------------------------------------------------------------------------
--  InitEnvt.lua -
--  Created by Mehdi Fatemi on 2015-07-21.
-- -------------------------------------------------------------------------------

-- rl = {}
-- game = {}

require 'torch'
require 'nn'
require 'nngraph'
-- require 'nnutils'
require 'image'
-- require 'TransitionTable'
-- require 'Rectifier'







--- Utility functions


function deepcopy(o, seen)
    seen = seen or {}
    if o == nil then return nil end
    if seen[o] then return seen[o] end
    
    
    local no = {}
    seen[o] = no
    setmetatable(no, deepcopy(getmetatable(o), seen))
    
    for k, v in next, o, nil do
        k = (type(k) == 'table') and deepcopy(k, seen) or k
        v = (type(v) == 'table') and deepcopy(v, seen) or v
        no[k] = v
    end
    return no
end


function table.maxtt(t)
--[[
 This funcitons returns a table of keys of "t" with max value.
 If "t" is empty, it returns an empty table.
 
--]]
    local max
    for _, u in pairs(t) do   -- just to get an element from t and init max
        max = u
        for _, v in pairs(t) do
            if v > max then max = v end
        end
        break
    end
    local indeces = {}
    for i, v in pairs(t) do
        if v == max then table.insert(indeces, i) end
    end
    return indeces
end



