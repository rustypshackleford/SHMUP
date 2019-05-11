--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]
 
EnemyProjectile = Class{}

function EnemyProjectile:init(enemy)
    -- grab player info
    self.enemy = enemy
    
    -- get width and height scaled to 25% due to sprite size
    self.width = gTextures['laser-green']:getWidth() / 4
    self.height = gTextures['laser-green']:getHeight() / 4
    
    -- set x and y based on enemy info,
    -- but shift them slightly to be centered
    -- and in front of the ship
    self.x = self.enemy.x + 11.5
    self.y = self.enemy.y + self.enemy.height
    
    -- rate of travel
    self.dy = 5
end

function EnemyProjectile:update(dt)
    -- if on-screen, move the projectile down
    if self.y < VIRTUAL_HEIGHT then
        self.y = self.y + self.dy
    end
end

function EnemyProjectile:collisions(target)
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

function EnemyProjectile:render()
    -- as long as projectile is on screen, render it at 25% size
    if self.y < VIRTUAL_HEIGHT then
        love.graphics.draw(gTextures['laser-green'], self.x, self.y, 0, 0.25, 0.25)
    end
end