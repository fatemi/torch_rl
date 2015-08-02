-- -------------------------------------------------------------------------------
--  qf.lua - 
--  Created by Mehdi Fatemi on 2015-07-27.
-- -------------------------------------------------------------------------------

if not rl then
    rl = {}
end


local qf = torch.class('rl.q')


function qf:__init(args)
    self.gpu          = args.gpu or false
    self.stateDim     = args.stateDim
    self.maxStateSize = args.maxStateSize or 1024
    
    self.s     = args.s or torch.IntTensor(self.maxStateSize, self.stateDim):fill(0)
    self.a     = args.a or torch.IntTensor(self.maxStateSize):fill(0)
    self.value = args.value or torch.FloatTensor(self.maxStateSize):fill(0)
end



local trans = torch.class('rl.transTable')


function trans:__init(args)
    self.gpu          = args.gpu or false
    self.stateDim     = args.stateDim
    self.maxStateSize = args.maxStateSize or 1024
    
    self.current_s = args.current_s or torch.IntTensor(self.maxStateSize, self.stateDim):fill(0)
    self.next_s    = args.next_s or torch.IntTensor(self.maxStateSize, self.stateDim):fill(0)
    self.a         = args.a or torch.IntTensor(self.maxStateSize):fill(0)
    self.reward = args.reward or torch.FloatTensor(self.maxStateSize):fill(0)
end