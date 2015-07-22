-- -------------------------------------------------------------------------------
--  InitEnvt.lua -
--  Created by Mehdi Fatemi on 2015-07-21.
-- -------------------------------------------------------------------------------

rl = {}
game = {}

require 'torch'
require 'nn'
require 'nngraph'
require 'nnutils'
require 'image'
require 'game'
-- require 'TransitionTable'
-- require 'Rectifier'







--- Utility function(s)

function table.copy(t)
    if t == nil then return nil end
    local nt = {}
    for k, v in pairs(t) do
        if type(v) == 'table' then
            nt[k] = table.copy(v)
        else
            nt[k] = v
        end
    end
    setmetatable(nt, table.copy(getmetatable(t)))
    return nt
end