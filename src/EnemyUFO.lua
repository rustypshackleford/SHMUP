--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]

EnemyUFO = Class{}

function EnemyUFO:init(num)
    -- get width and height at 25% scale due to sprite size
    self.width = gTextures['enemy-ufo']:getWidth() / 4
    self.height = gTextures['enemy-ufo']:getHeight() / 4
    
    -- random starting position along the top
    self.x = math.random(0, VIRTUAL_WIDTH - self.width)
    -- spawns outside the screen bounds
    self.y = -50
    
    self.ID = num
    
    -- # of points to give
    self.points = 400
    -- how many hits it takes to destroy
    self.health = 2
    
    -- rate of travel
    self.xTraj = math.random(2)
    self.yTraj = math.random(2)
    self.straight = math.random(2)
    
    -- makes sure the ship is always traveling in 
    -- toward the center and never out toward the edge
    if self.straight == 2 then
        if self.x < VIRTUAL_WIDTH / 2 then
            self.xDir = 2
        else
            self.xDir = 1
        end
    else    -- or traveling straight
        self.xDir = 0
    end
    
    self.shooting = false
    
    -- the interval for shooting is every 1.25 seconds, in 3 shot bursts spaced 0.1 second apart
    Timer.every(1.25, function() self.shooting = not self.shooting end)
    Timer.after(0.1, function() Timer.every(1.25, function() self.shooting = not self.shooting end) end)
    Timer.after(0.2, function() Timer.every(1.25, function() self.shooting = not self.shooting end) end)
end

function EnemyUFO:update(dt)
    -- update x either to the left or right,
    -- or don't update x at all
    if self.xDir == 2 then
        self.x = self.x + self.xTraj
        -- only update y downward
        self.y = self.y + self.yTraj
    elseif self.xDir == 1 then
        self.x = self.x - self.xTraj
        -- only update y downward
        self.y = self.y + self.yTraj
    else
        -- only update y downward
        self.y = self.y + self.yTraj
    end 
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