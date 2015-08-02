-- -------------------------------------------------------------------------------
--  test.lua - 
--  Created by Mehdi Fatemi on 2015-07-22.
-- -------------------------------------------------------------------------------


require 'rl'

q = rl.Q({stateDim = 5, maxStateSize = 100})

q:add_new(torch.IntTensor{1,2,4,7,3}, 2, 567)

print(q:get_item(torch.IntTensor{1,2,4,7,3}, 2))   -- return 567


t ={}
t[1] = 5
t[5] = 6
t[12] = 345
t[7] = 345
t[-34] = 345
t[-3] = 13
require 'utilities'
print(table.maxtt(t))
