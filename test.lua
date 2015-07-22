-- -------------------------------------------------------------------------------
--  test.lua - 
--  Created by Mehdi Fatemi on 2015-07-22.
-- -------------------------------------------------------------------------------

require 'Game'


opt = {
    board_w = 5,
    board_h = 7,
    make_board_method = 'random'
}

g = game.GridWorld(opt)

g:set_start(2,3)

g:display()

g:move('up')
g:display()

g:move('up')
g:display()

g:move('up')
g:display()

g:move('up')
g:display()

g:move('up')
g:display()

g:move('down')
g:display()

g:move('down')
g:display()

g:move('down')
g:display()

g:move('down')
g:display()

g:move('down')
g:display()

g:move('right')
g:display()

g:move('right')
g:display()

g:move('right')
g:display()
g:move('right')
g:display()
g:move('right')
g:display()

g:move('left')
g:display()

g:move('left')
g:display()

g:move('left')
g:display()

g:move('left')
g:display()

g:move('left')
g:display()

g:move('left')
g:display()

g:move('left')
g:display()