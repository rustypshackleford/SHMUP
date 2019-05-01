--
-- libraries
--

Class = require 'lib/class'
Event = require 'lib/knife.event'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

require 'src/StateMachine'
require 'src/Util'
require 'src/constants'
require 'src/Player'
require 'src/PlayerProjectile'
require 'src/BigAsteroid'
require 'src/SmallAsteroid'
require 'src/EnemyShip'
require 'src/EnemyUFO'

require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/PlayState'
require 'src/states/GameOverState'

gTextures = {
    ['background'] = love.graphics.newImage('graphics/Background/starBackground.png'),
    ['speed-line'] = love.graphics.newImage('graphics/Background/speedLine.png'),
    ['title-bg'] = love.graphics.newImage('graphics/Background/backgroundColor.png'),
    ['enemy-ship'] = love.graphics.newImage('graphics/enemyShip.png'),
    ['enemy-ufo'] = love.graphics.newImage('graphics/enemyUFO.png'),
    ['laser-green'] = love.graphics.newImage('graphics/laserGreen.png'),
    ['green-hit'] = love.graphics.newImage('graphics/laserGreenShot.png'),
    ['laser-red'] = love.graphics.newImage('graphics/laserRed.png'),
    ['red-hit'] = love.graphics.newImage('graphics/laserRedShot.png'),
    ['life'] = love.graphics.newImage('graphics/life.png'),
    ['meteor-big'] = love.graphics.newImage('graphics/meteorBig.png'),
    ['meteor-small'] = love.graphics.newImage('graphics/meteorSmall.png'),
    ['player'] = love.graphics.newImage('graphics/player.png'),
    ['player-dmg'] = love.graphics.newImage('graphics/playerDamaged.png'),
    ['player-left'] = love.graphics.newImage('graphics/playerLeft.png'),
    ['player-right'] = love.graphics.newImage('graphics/playerRight.png'),
    ['shield'] = love.graphics.newImage('graphics/shield.png'),
}

gFonts = {
    ['f-thin'] = love.graphics.newFont('fonts/future_thin.ttf', 16),
    ['future'] = love.graphics.newFont('fonts/future.ttf', 32)
}

gSounds = {
    ['title-theme'] = love.audio.newSource('sounds/Space-Heroes.wav'),
    ['game-music'] = love.audio.newSource('sounds/Without-Fear.wav'),
    ['game-over'] = love.audio.newSource('sounds/Defeated (Game Over Tune).wav'),
    ['laser1'] = love.audio.newSource('sounds/sfx_laser1.wav'),
    ['laser2'] = love.audio.newSource('sounds/sfx_laser2.wav'),
    ['lose-game'] = love.audio.newSource('sounds/sfx_lose.wav'),
    ['shld-down'] = love.audio.newSource('sounds/sfx_shieldDown.wav'),
    ['shld-up'] = love.audio.newSource('sounds/sfx_shieldUp.wav'),
    ['score'] = love.audio.newSource('sounds/sfx_twoTone.wav'),
    ['zap'] = love.audio.newSource('sounds/sfx_zap.wav'),
    ['boom1'] = love.audio.newSource('sounds/booms/boom1.wav'),
    ['boom2'] = love.audio.newSource('sounds/booms/boom2.wav'),
    ['boom3'] = love.audio.newSource('sounds/booms/boom3.wav'),
    ['boom4'] = love.audio.newSource('sounds/booms/boom4.wav'),
    ['boom5'] = love.audio.newSource('sounds/booms/boom5.wav'),
    ['boom6'] = love.audio.newSource('sounds/booms/boom6.wav'),
    ['boom7'] = love.audio.newSource('sounds/booms/boom7.wav'),
    ['boom8'] = love.audio.newSource('sounds/booms/boom8.wav'),
    ['boom9'] = love.audio.newSource('sounds/booms/boom9.wav')    
}