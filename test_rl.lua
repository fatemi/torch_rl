--[[ ---------------------------------------------------------------------------
--  test_rl.lua -
--  Created by Mehdi Fatemi on 2015-07-19.

Copyright (c) 2015 Mehdi Fatemi.

-- -----------------------------------------------------------------------------
--]]


 -- Test UTILS:
 
 require 'utils/envt.lua'
 t ={}
 t[1] = 5
 t[5] = 6
 t[12] = 345
 t[7] = 345
 t[-34] = 345
 t[-3] = 13
 print(table.maxtt(t))
 

 
 -- Test RL.Q:
 
 require 'rl'

 q = rl.Q({stateDim = 5, maxStateSize = 100})

 q:add_new(torch.IntTensor{1,2,4,7,3}, 2, 567)

 print(q:get_value(torch.IntTensor{1,2,4,7,3}, 2))   -- return 567



