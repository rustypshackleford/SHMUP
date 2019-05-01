--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]

StartState = Class{__includes = BaseState}

function StartState:init()
    -- stop game over sound and play title music
    gSounds['game-over']:stop()
    gSounds['title-theme']:setLooping(true)
    gSounds['title-theme']:play()
    gSounds['title-theme']:setVolume(0.5)
end

function StartState:enter(params)

end

function StartState:update(dt)
    -- quit
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- transition to playing
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play', {
          player = Player() -- send a new player into the play state
          })
    end
end

function StartState:render()
    -- basic bg
    love.graphics.draw(gTextures['title-bg'], 0, 0, 0, 
        VIRTUAL_WIDTH / gTextures['title-bg']:getWidth(),
        VIRTUAL_HEIGHT / gTextures['title-bg']:getHeight())

    -- text
    love.graphics.setFont(gFonts['future'])
    love.graphics.setColor(34, 34, 34, 255)
    love.graphics.printf('SHMUP', 2, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(175, 53, 42, 255)
    love.graphics.printf('SHMUP', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['f-thin'])
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT / 2 + 64, VIRTUAL_WIDTH, 'center')
end