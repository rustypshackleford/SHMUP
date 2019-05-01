--[[
    GD50
    SHMUP (Final Project)

    Author: Russell Saia
    parsons978@gmail.com
]]

PlayState = Class{__includes = BaseState}

function PlayState:init() 
    -- these two values are used to scroll the background
    self.backgroundY = 0
    self.backgroundScrollSpd = 50
    
    -- asteroids table and a spawner for them
    self.asteroids = {}
    self.spawner1 = 0
    
    -- ships table and a spawner for them
    self.ships = {}
    self.spawner2 = 0
    
    -- for confirming collisions
    self.collision = false
    
    -- these four are for positioning explosions
    -- and laser hit sprites
    self.explX = 0
    self.explY = 0
    self.hitX = 0
    self.hitY = 0
    
    -- for confirming explosions
    self.explosion = false
    -- I created the explosion image here for animating purposes
    explosion = love.graphics.newImage('graphics/exp2_0.png')
    animation = self:newAnimation(explosion, 64, 64, 1)
    
    -- for confirming player's laser hits on enemies
    self.laserHitRed = false
    
    -- stop the title music and play the game music
    gSounds['title-theme']:stop()
    gSounds['game-music']:setLooping(true)
    gSounds['game-music']:play()
    gSounds['game-music']:setVolume(0.5)
end

function PlayState:enter(params)
  -- pass the player's info into play state
    self.player = params.player
end

function PlayState:update(dt)
    -- quit the game
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
    
    -- update currentTime for animation, then reset it 
    -- if it's greater than its duration
    animation.currentTime = animation.currentTime + dt
    if animation.currentTime >= animation.duration then
        animation.currentTime = animation.currentTime - animation.duration
    end
    
    -- these determine which type of asteroid and ship to spawn
    local astPicker = math.random(2)
    local shipPicker = math.random(2)
    
    -- update the spawners
    self.spawner1 = self.spawner1 + dt
    self.spawner2 = self.spawner2 + dt
    
    -- every .8 to 1 second, spawn an asteroid
    if self.spawner1 > math.random(0.8, 1) then
        -- small if we get 1 here
        if astPicker == 1 then
            table.insert(self.asteroids, SmallAsteroid())
        else -- otherwise a large one
            table.insert(self.asteroids, BigAsteroid())
        end
        -- reset spawner1
        self.spawner1 = 0
    end
    
    -- same logic as above except with ships and slightly longer delays
    if self.spawner2 > math.random(1.5, 2.5) then
        if shipPicker == 1 then
            table.insert(self.ships, EnemyShip())
        else
            table.insert(self.ships, EnemyUFO())
        end
        --reset spawner2
        self.spawner2 = 0
    end
    
    -- in the asteroids table, do...
    for k, asteroid in pairs(self.asteroids) do
        -- if the asteroid has gone off the screen, remove it
        if asteroid.y > VIRTUAL_HEIGHT or asteroid.x > VIRTUAL_WIDTH or asteroid.x < 0 then
            table.remove(self.asteroids, k)
        end
        
        -- if the player collides with an asteroid (and hasn't already, to keep multiple collisions from happening)
        if asteroid:collisions(self.player) or self.player:collides(asteroid) and self.collision == false then
            -- update the player's lives accordingly
            if self.collision == false then
                if self.player.lives == 3 then
                    self.player.lives = 2
                elseif self.player.lives == 2 then
                    self.player.lives = 1
                else
                    self.player.lives = 0
                end
            end
            self.collision = true -- set collision to true
            self.explosion = true -- set explosion to true
            self.player.collision = true -- set player collision to true, to stop movement while dead
            gSounds['boom' .. tostring(math.random(9))]:play() -- play 1 of 9 random BOOM sounds
            Timer.after(2, function() self.collision = false end) -- after 2 seconds, put collision back to false
            self.explX = self.player.x -- get player's x for explosion
            self.explY = self.player.y -- and player's y
            self.player.x = VIRTUAL_WIDTH / 2 - 25 -- reset player's position
            self.player.y = VIRTUAL_HEIGHT - 50 -- back to where you start
        end
        
        -- go through projectiles table
        for k, proj in pairs(self.player.playerProj) do
            -- if a projectile collides with an asteroid
            if asteroid:collisions(proj) or proj:collisions(asteroid) then
                -- reduce its health accordingly
                asteroid.health = asteroid.health - 1
                -- LHR will be used to spawn laser blast objects
                self.laserHitRed = true
                -- get the x,y position of the hit so you can
                -- spawn laser blast objects at the impact point
                self.hitX = proj.x + asteroid.xTraj
                self.hitY = proj.y + asteroid.yTraj
                gSounds['shld-up']:play() -- play a sound on contact
                -- if the asteroid died...
                if asteroid.health == 0 then
                    -- ad to the player's score
                    self.player.score = self.player.score + asteroid.points
                    self.explX = asteroid.x -- get x and y again
                    self.explY = asteroid.y -- for another explosion
                    self.explosion = true -- explosion in effect
                    gSounds['boom' .. tostring(math.random(9))]:play() -- BOOM!
                    -- this for loop finds the asteroid that was just blown up
                    for k, ast in pairs(self.asteroids) do
                        -- and removes it from the asteroid table
                        if ast == asteroid then
                            table.remove(self.asteroids, k)
                        end
                    end
                end
            end
        end
        -- finally, call the asteroid update function
        asteroid:update()
    end
    
    -- this stuff is literally the same as the asteroids logic, but with ships
    for k, ship in pairs(self.ships) do
        if ship.y > VIRTUAL_HEIGHT then
            table.remove(self.ships, k)
        end
        
        if ship:collisions(self.player) or self.player:collides(ship) and self.collision == false then
            if self.collision == false then
                if self.player.lives == 3 then
                    self.player.lives = 2
                elseif self.player.lives == 2 then
                    self.player.lives = 1
                else
                    self.player.lives = 0
                end
            end
            self.collision = true
            self.explosion = true
            self.player.collision = true
            gSounds['boom' .. tostring(math.random(9))]:play()
            Timer.after(2, function() self.collision = false end)
            self.explX = self.player.x - 32
            self.explY = self.player.y - 32
            self.player.x = VIRTUAL_WIDTH / 2 - 25
            self.player.y = VIRTUAL_HEIGHT - 50
        end
        
        for k, proj in pairs(self.player.playerProj) do
            if ship:collisions(proj) or proj:collisions(ship) then
                ship.health = ship.health - 1
                self.laserHitRed = true
                self.hitX = proj.x + ship.xTraj
                self.hitY = proj.y + ship.yTraj
                gSounds['shld-up']:play()
                if ship.health == 0 then
                    self.player.score = self.player.score + ship.points
                    self.explX = ship.x
                    self.explY = ship.y
                    self.explosion = true
                    gSounds['boom' .. tostring(math.random(9))]:play()
                    for k, shp in pairs(self.ships) do
                        if shp == ship then
                            table.remove(self.ships, k)
                        end
                    end
                end
            end
        end
        ship:update()
    end
    
    -- update backgroundY every frame
    self.backgroundY = self.backgroundY + (self.backgroundScrollSpd * dt)
    
    -- if backgroundY exceeds virtual height, reset it
    if self.backgroundY > VIRTUAL_HEIGHT then
        self.backgroundY = self.backgroundY - VIRTUAL_HEIGHT
    end
    
    -- if player lives go below 1, they are out of lives
    -- so, go to game over screen
    if self.player.lives < 1 then
        Timer.after(1, function()
            gStateMachine:change('game-over', {
                score = self.player.score
            })
        end)
    end
    
    -- update the player sprite every frame unless the player is dead
    if self.collision == false then
        self.player:update(dt)
    end
end

-- this function creates the explosion animation that plays when things blow up
function PlayState:newAnimation(image, width, height, duration)
    local animation = {} -- table for animations
    animation.spriteSheet = image; -- get the sprite sheet
    animation.quads = {}; -- a table for quads
    
    -- go through the sprite sheet section by section
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            -- and insert a new quad of the image into the quads table
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
    
    -- set the duration and current time
    animation.duration = duration or 1
    animation.currentTime = 0
    
    -- return the new animation table
    return animation
end

function PlayState:render(dt)
    -- draw two background images, one stacked on top of the other,
    -- in order to make the appearance of a seamless scrolling transition
    love.graphics.draw(gTextures['background'], 0, self.backgroundY, 0, 
        VIRTUAL_WIDTH / gTextures['background']:getWidth(),
        VIRTUAL_HEIGHT / gTextures['background']:getHeight())
      
    love.graphics.draw(gTextures['background'], 0, self.backgroundY - VIRTUAL_HEIGHT, 0, 
      VIRTUAL_WIDTH / gTextures['background']:getWidth(),
      VIRTUAL_HEIGHT / gTextures['background']:getHeight())
    
    -- render the player except when they're dead
    if self.collision == false then
        self.player:render()
    end
    
    -- triggers only when an explosion is queued
    if self.explosion == true then
        -- first get the sprite number for the sprite to be displayed
        local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
        -- then draw the sprite using the spritesheet, the quad table with sprite num, and the expl coords
        love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], self.explX, self.explY)
        -- terminate the animation after 0.5 seconds because it started to repeat otherwise
        Timer.after(0.5, function() self.explosion = false end)
    end
    
    -- render all the asteroids
    for k, asteroid in pairs(self.asteroids) do
        if asteroid.y < VIRTUAL_HEIGHT then
            asteroid:render()
        end
    end
    
    -- render all the ships
    for k, ship in pairs(self.ships) do
        if ship.y < VIRTUAL_HEIGHT then
            ship:render()
        end
    end
    
    -- for loop that prevents lasers from going through enemies
    -- when contact is made between them and a laser projectile
    for k, proj in pairs(self.player.playerProj) do
        -- if we've scored a hit and didn't die, then
        if self.laserHitRed == true and self.collision == false then
            -- go through projectiles and start removing them
            for k, projectile in pairs(self.player.playerProj) do
                table.remove(self.player.playerProj, k)
                -- only render a projectile if it's below the location of the hit
                if projectile.y > self.hitY then
                    projectile:render()
                end
            end
        -- otherwise render projectiles normally
        elseif proj.y > 0 and self.collision == false then
            proj:render()
        end
    end
    
    -- render laser blast objects
    if self.laserHitRed == true then
        love.graphics.draw(gTextures['red-hit'], self.hitX, self.hitY, 0, 0.25, 0.25)
        -- make them disappear after 1/16th of a second
        Timer.after(0.0625, function() self.laserHitRed = false end)
    end
    
    -- print the score in the top right corner, with space for score to grow
    -- note to self: maybe flip score and lives if possible....
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['f-thin'])
    love.graphics.printf('Score: ' .. tostring(self.player.score), 0, 0, VIRTUAL_WIDTH - 25, 'right')
    
    -- render the player's lives in the top left
    for i = 1, self.player.lives do
      love.graphics.draw(gTextures['life'],
          (i - 1) * 20, 2, 0, 0.5, 0.5)
    end
end