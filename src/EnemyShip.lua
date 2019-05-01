--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]

EnemyShip = Class{}

function EnemyShip:init()
    -- random start position along top of screen
    self.x = math.random(0, VIRTUAL_WIDTH)
    -- spawns outside screen bounds
    self.y = -50
    
    -- # of points to give
    self.points = 200
    -- how many shots it takes to blow up
    self.health = 2
    
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
    
    -- get width and height, scaled to 25% due to sprite size
    self.width = gTextures['enemy-ship']:getWidth() / 4
    self.height = gTextures['enemy-ship']:getHeight() / 4
end

function EnemyShip:update()
    -- update x either to the left or right
    if self.xDir == 2 then
        self.x = self.x + self.xTraj
    else
        self.x = self.x - self.xTraj
    end

    -- only update y downward
    self.y = self.y + self.yTraj
end

function EnemyShip:collisions(target)
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

function EnemyShip:render()
    -- draw the ship at 25% scale due to size of sprites
    love.graphics.draw(gTextures['enemy-ship'], self.x, self.y, 0, 0.25, 0.25)
end