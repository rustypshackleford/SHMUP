--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]

GameOverState = Class{__includes = BaseState}

function GameOverState:init()
    -- stop game music and play game over tune
    gSounds['game-music']:stop()
    gSounds['game-over']:play()
end

function GameOverState:enter(params)
    -- get the score from the player
    self.score = params.score
end

function GameOverState:update(dt)
    -- quit
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    
    -- restart
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('start')
    end
end

function GameOverState:render()
    -- draw simple BG
    love.graphics.draw(gTextures['title-bg'], 0, 0, 0, 
        VIRTUAL_WIDTH / gTextures['title-bg']:getWidth(),
        VIRTUAL_HEIGHT / gTextures['title-bg']:getHeight())

    -- text
    love.graphics.setFont(gFonts['future'])
    love.graphics.setColor(34, 34, 34, 255)
    love.graphics.printf('GAME OVER', 2, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(175, 53, 42, 255)
    love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')

    -- displays the score
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['f-thin'])
    love.graphics.printf('Your score: ' .. tostring(self.score), 0, VIRTUAL_HEIGHT / 2 + 32, VIRTUAL_WIDTH, 'center')
    
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['f-thin'])
    love.graphics.printf('Press enter', 0, VIRTUAL_HEIGHT / 2 + 64, VIRTUAL_WIDTH, 'center')
end