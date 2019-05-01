--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]

Player = Class{}

function Player:init()
    -- x is placed in the middle
    self.x = VIRTUAL_WIDTH / 2 - 25
    
    -- y is placed a little above the bottom edge of the screen
    self.y = VIRTUAL_HEIGHT - 50

    -- starting dimensions, scaled to 25% due to sprite size
    self.width = gTextures['player']:getWidth() / 4
    self.height = gTextures['player']:getHeight() / 4
    
    -- # of lives and score
    self.lives = 3
    self.score = 0
    
    -- will use timer to space out shots
    self.timer = 0
    -- prevents player from shooting when dead
    self.collision = false
    
    -- table for laser projectiles
    self.playerProj = {}
end

function Player:collides(target) 
   -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true 
end

function Player:update(dt)
    -- update timer
    self.timer = self.timer + dt
    
    -- keyboard input left/right
    if love.keyboard.isDown('left') then
        if self.x > 0 then
            self.x = self.x - (PLAYER_SPEED * dt)
        elseif self.x == 0 then
            self.x = self.x + 2
        end
    elseif love.keyboard.isDown('right') then
        if self.x + self.width < VIRTUAL_WIDTH then
            self.x = self.x + (PLAYER_SPEED * dt)
        elseif self.x + self.width == VIRTUAL_WIDTH then
            self.x = self.x - 2
        end
    end
    
    -- keyboard input up/down
    if love.keyboard.isDown('up') then
        if self.y > 0 then
            self.y = self.y - (PLAYER_SPEED * dt)
        elseif self.y == 0 then
            self.y = self.y + 2
        end
    elseif love.keyboard.isDown('down') then
      if self.y + self.height < VIRTUAL_HEIGHT then
          self.y = self.y + (PLAYER_SPEED * dt)
      elseif self.y + self.height == VIRTUAL_HEIGHT then
          self.y = self.y - 2
      end
    end
    
    -- the pause between death and respawn is 2 seconds,
    -- so if it's become true, set collision back to false after 2 seconds
    if self.collision == true then
        Timer.after(2, function() self.collision = false end)
    end
    
    -- as long as we're not dead, pressing space creates laser projectiles
    -- every 1/8th second and inserts them into the playerProj table
    -- also, a sound plays and timer gets reset
    if love.keyboard.wasPressed('space') or love.keyboard.isDown('space') and self.collision == false then
        if self.timer > 0.125 then
            table.insert(self.playerProj, PlayerProjectile(self))
            cloneLaser = gSounds['laser1']:clone()
            cloneLaser:play()
            self.timer = 0
        end
    end
    
    -- make sure to update all lasers continually
    for k, proj in pairs(self.playerProj) do
        if proj.y > 0 then
            proj:update()
        end
    end
    
    -- if a laser goes beyond the screen, remove it from the table
    for k, proj in pairs(self.playerProj) do
        if proj.y < 0 then
            table.remove(self.playerProj, k)
        end
    end
end

function Player:render()
    -- special sprites for left and right mean
    -- a bit more complicated rendering, but not much
    if love.keyboard.isDown('left') then
        love.graphics.draw(gTextures['player-left'], self.x, self.y, 0, 0.25, 0.25)
    elseif love.keyboard.isDown('right') then
        love.graphics.draw(gTextures['player-right'], self.x, self.y, 0, 0.25, 0.25)
    else
        love.graphics.draw(gTextures['player'], self.x, self.y, 0, 0.25, 0.25)
    end
end