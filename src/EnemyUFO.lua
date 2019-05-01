--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]

EnemyUFO = Class{}

function EnemyUFO:init()
    -- random starting position along the top
    self.x = math.random(0, VIRTUAL_WIDTH)
    -- spawns outside the screen bounds
    self.y = -50
    
    -- # of points to give
    self.points = 400
    -- how many hits it takes to destroy
    self.health = 4
    
    -- rate of travel
    self.xTraj = math.random(3)
    self.yTraj = math.random(3)
    
    -- makes sure the ship is always traveling in 
    -- toward the center and never out toward the edge
    if self.x < VIRTUAL_WIDTH / 2 then
        self.xDir = 2
    else
        self.xDir = 1
    end
    
    -- get width and height at 25% scale due to sprite size
    self.width = gTextures['enemy-ufo']:getWidth() / 4
    self.height = gTextures['enemy-ufo']:getHeight() / 4
end

function EnemyUFO:update()
    -- update x either left or right
    if self.xDir == 2 then
        self.x = self.x + self.xTraj
    else
        self.x = self.x - self.xTraj
    end
    
    -- always update y downward
    self.y = self.y + self.yTraj
end

function EnemyUFO:collisions(target)
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

function EnemyUFO:render()
    -- draw the ship at 25% scale due to size of sprites
    love.graphics.draw(gTextures['enemy-ufo'], self.x, self.y, 0, 0.25, 0.25)
end