--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    gSounds['title-theme']:stop()
    gSounds['game-music']:setLooping(true)
    gSounds['game-music']:play()

end

function PlayState:enter(params)
  
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    love.graphics.draw(gTextures['background'], 0, 0, 0, 
        VIRTUAL_WIDTH / gTextures['background']:getWidth(),
        VIRTUAL_HEIGHT / gTextures['background']:getHeight())
end