--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]
 
PlayerProjectile = Class{}

function PlayerProjectile:init(player)
    -- grab player info
    self.player = player

    -- set x and y based on player info,
    -- but shift them slightly to be centered
    -- and in front of the ship
    self.x = self.player.x + 11.5
    self.y = self.player.y - 10
    
    -- get width and height scaled to 25% due to sprite size
    self.width = gTextures['laser-red']:getWidth() / 4
    self.height = gTextures['laser-red']:getHeight() / 4
    
    -- rate of travel
    self.dy = 10
end

function PlayerProjectile:update(dt)
    -- if on-screen, move the projectile up
    if self.y > 0 then
        self.y = self.y - self.dy
    end
end

function PlayerProjectile:collisions(target)
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

function PlayerProjectile:render()
    -- as long as projectile is on screen, render it at 25% size
    if self.y > 0 then
        love.graphics.draw(gTextures['laser-red'], self.x, self.y, 0, 0.25, 0.25)
    end
end