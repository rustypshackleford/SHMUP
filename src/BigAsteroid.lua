--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]

BigAsteroid = Class{}

function BigAsteroid:init()
    -- determines whether to spawn a top or side object
    self.picker1 = math.random(2)
    -- determines whether to spawn a left or right object
    self.picker2 = math.random(2)
    
    -- # of points added
    self.points = 100
    -- amount of shots it takes to blow up
    self.health = 3

    -- if picker1 is 1 then we spawn from the top
    if self.picker1 == 1 then
        self.x = math.random(0, VIRTUAL_WIDTH)
        self.y = -50
    else -- we spawn from a side
        -- left side spawn
        if self.picker2 == 1 then
            self.x = -50
            self.y = math.random(0, VIRTUAL_HEIGHT)
        -- right side spawn
        elseif self.picker2 == 2 then
            self.x = VIRTUAL_WIDTH + 50
            self.y = math.random(0, VIRTUAL_HEIGHT)
        end
    end
    
    -- the speed at which the object will travel
    self.xTraj = math.random(3)
    self.yTraj = math.random(3)
    
    -- whether it goes left or right
    self.xDir = math.random(2)
    -- whether it goes up or down
    self.yDir = math.random(2)
    
    -- get width and height, scaled to 25% because of sprite size
    self.width = gTextures['meteor-big']:getWidth() / 4
    self.height = gTextures['meteor-big']:getHeight() / 4
end

function BigAsteroid:update()
    -- if top-spawning, move x traj either left or right and y traj down
    if self.picker1 == 1 then
        if self.xDir == 1 then
            self.x = self.x + self.xTraj
        else
            self.x = self.x - self.xTraj
        end
    
        self.y = self.y + self.yTraj
    else
        --else, move y traj up or down and x traj   
        if self.yDir == 1 then
            self.y = self.y + self.yTraj
        else
            self.y = self.y - self.yTraj
        end

        -- and move x traj either left or right
        if self.xDir == 1 then
            self.x = self.x + self.xTraj
        else
            self.x = self.x - self.xTraj
        end
    end
end

function BigAsteroid:collisions(target)
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

function BigAsteroid:render()
    -- draw the asteroid at 25% size (idk why I called them meteors in dependencies)
    love.graphics.draw(gTextures['meteor-big'], self.x, self.y, 0, 0.25, 0.25)
end