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
    
    -- used to make sure the level text is only printed briefly
    self.printLevel = true

    -- for confirming explosions
    self.explosion = false
    -- I created the explosion image here for animating purposes
    explosion = love.graphics.newImage('graphics/exp2_0.png')
    animation = self:newAnimation(explosion, 64, 64, 1)
    
    -- for confirming player's laser hits on enemies
    self.laserHitRed = false
    
    -- table for enemy projectiles
    self.enemyProj = {}
    -- whether to spawn green hitmarkers
    self.laserHitGreen = false

    -- prevents damage for a short period after being hit
    self.invuln = false
    
    -- decrement remaining seconds of current level by 1 every second
    Timer.every(1, function() self.levSeconds = self.levSeconds - 1 end)
    -- after 2 seconds, remove the level text from the screen
    Timer.after(2, function() self.printLevel = false end)

    -- stop the title music and play the game music
    gSounds['title-theme']:stop()
    gSounds['game-music']:setLooping(true)
    gSounds['game-music']:play()
    gSounds['game-music']:setVolume(0.5)
end

function PlayState:enter(params)
  -- pass the player's info into play state
    self.player = params.player
    self.player.score = params.score
    self.player.health = params.health
    self.level = params.level
    -- used to keep track of how much score is needed
    -- to earn an extra life
    self.lifeTracker = params.lifeTracker
    self.levSeconds = 40 + (20 * self.level)
end

function PlayState:update(dt)
    -- quit the game
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- if levSeconds is 0 we've beaten the level
    if self.levSeconds == 0 then
        -- remove all currently spawned objects
        self.asteroids = {}
        self.ships = {}
        self.enemyProj = {}
        -- if player's score is above 10k times lifeTracker,
        -- we increase lifeTracker so player does not get a free life
        if self.player.score > (10000 * self.lifeTracker) then
            self.lifeTracker = self.lifeTracker + 1
        end
        -- and re-load the play state with current info
        gStateMachine:change('play', {
            player = self.player, -- send a new player into the play state
            score = self.player.score,
            health = 4, -- only exception, heal the player to full health every time
            level = self.level + 1,
            lifeTracker = self.lifeTracker
        })
    end

    -- added this feature after making my video, the player can gain back a life
    -- when they hit some multiple of 10000 points, if they are missing at least one life
    if self.player.score >= (10000 * self.lifeTracker) and self.player.lives < 3 then
        self.player.lives = self.player.lives + 1
        self.lifeTracker = self.lifeTracker + 1
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
    
    -- every 10-11/level second, spawn an asteroid
    if self.spawner1 > math.random(10, 11) / self.level then
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
    if self.spawner2 > math.random(10.5, 12.5) / self.level then
        if shipPicker == 1 then
            table.insert(self.ships, EnemyShip(shipPicker))
        else
            table.insert(self.ships, EnemyUFO(shipPicker))
        end
        --reset spawner2
        self.spawner2 = 0
    end
    
    -- in the asteroids table, do...
    for k, asteroid in pairs(self.asteroids) do
        -- if the asteroid has gone off the screen, remove it
        if asteroid.y > VIRTUAL_HEIGHT or asteroid.x > VIRTUAL_WIDTH or asteroid.x + asteroid.width < 0 then
            table.remove(self.asteroids, k)
        end
        
        -- if the player collides with an asteroid (and hasn't already, to keep multiple collisions from happening)
        if asteroid:collisions(self.player) or self.player:collides(asteroid) and self.collision == false then
            -- update the player's health and lives accordingly
            if self.collision == false and self.invuln == false then
                if self.player.health == 4 then
                    self.player.health = 3
                    -- briefly set collision to true, which
                    -- causes the ship to blink, to give a
                    -- visual that the player has collided with something
                    self.collision = true
                    -- self.invuln prevents damage briefly so that
                    -- damage doesn't stack or overlap incorrectly
                    self.invuln = true
                    -- play a sound
                    gSounds['shld-down']:play()
                    -- timers reset each boolean after a short delay 
                    Timer.after(0.1, function() self.collision = false end)
                    Timer.after(1, function() self.invuln = false end)
                elseif self.player.health == 3 then
                    self.player.health = 2
                    self.collision = true 
                    self.invuln = true 
                    gSounds['shld-down']:play()
                    Timer.after(0.1, function() self.collision = false end)
                    Timer.after(1, function() self.invuln = false end)
                elseif self.player.health == 2 then
                    self.player.health = 1
                    self.collision = true 
                    self.invuln = true 
                    gSounds['shld-down']:play()
                    Timer.after(0.1, function() self.collision = false end)
                    Timer.after(1, function() self.invuln = false end)
                else -- at 1 health, blow the thing up and decrement lives
                    if self.player.lives == 3 then
                        self.player.lives = 2
                        self:explode()
                        self.player.health = 4
                    elseif self.player.lives == 2 then
                        self.player.lives = 1
                        self:explode()
                        self.player.health = 4
                    else
                        self.player.lives = 0
                        self:explode()
                        self.player.health = 0
                    end
                end
            end
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
    
    -- this stuff is mostly the same as the asteroids logic, but with ships
    for k, ship in pairs(self.ships) do
        if ship.y > VIRTUAL_HEIGHT or ship.x + ship.width < 0 or ship.x > VIRTUAL_WIDTH then
            table.remove(self.ships, k)
        end

        if ship:collisions(self.player) or self.player:collides(ship) and self.collision == false then
            if self.collision == false and self.invuln == false then
                if self.player.health == 4 then
                    self.player.health = 3
                    self.collision = true 
                    self.invuln = true
                    gSounds['shld-down']:play() 
                    Timer.after(0.1, function() self.collision = false end)
                    Timer.after(1, function() self.invuln = false end)
                elseif self.player.health == 3 then
                    self.player.health = 2
                    self.collision = true 
                    self.invuln = true 
                    gSounds['shld-down']:play()
                    Timer.after(0.1, function() self.collision = false end)
                    Timer.after(1, function() self.invuln = false end)
                elseif self.player.health == 2 then
                    self.player.health = 1
                    self.collision = true 
                    self.invuln = true 
                    gSounds['shld-down']:play()
                    Timer.after(0.1, function() self.collision = false end)
                    Timer.after(1, function() self.invuln = false end)
                else
                    if self.player.lives == 3 then
                        self.player.lives = 2
                        self:explode()
                        self.player.health = 4
                    elseif self.player.lives == 2 then
                        self.player.lives = 1
                        self:explode()
                        self.player.health = 4
                    else
                        self.player.lives = 0
                        self:explode()
                        self.player.health = 0
                    end
                end
            end
        end
        
        -- difference: they shoot lasers
        if ship.ID == 1 then -- if we have a regular ship
            -- and its shooting boolean is true (see EnemyShip.lua)
            if ship.shooting == true then
                -- create a green projectile in the enemyProj table,
                -- play a sound and set shooting to false for now
                table.insert(self.enemyProj, EnemyProjectile(ship))
                cloneLaser = gSounds['laser2']:clone()
                cloneLaser:play()
                -- important to set ship.shooting to false here
                -- to prevent excess lasers from being fired
                ship.shooting = false
            end
        else -- else we have a UFO
            -- and the shooting code is pretty much the same (see EnemyUFO.lua)
            if  ship.shooting == true then
                table.insert(self.enemyProj, EnemyProjectile(ship))
                cloneLaser = gSounds['laser2']:clone()
                cloneLaser:play()
                ship.shooting = false
            end
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
        ship:update(dt)
    end
    
    -- make sure to update all lasers continually
    for k, proj in pairs(self.enemyProj) do
        if proj.y <= VIRTUAL_HEIGHT then
            proj:update()
        end
    end
    
    -- if a laser goes beyond the screen, remove it from the table
    for k, proj in pairs(self.enemyProj) do
        if proj.y >= VIRTUAL_HEIGHT then
            table.remove(self.enemyProj, k)
        end
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
    
    -- collision detection for player and enemy shots
    for k, proj in pairs(self.enemyProj) do -- go through enemyProj table
        -- if there is a collision then
        if self.player:collides(proj) or proj:collisions(self.player) then
            -- similar to above, but don't flash the ship
            -- because you can't see the green laser hit marker
            -- if the ship does get flashed
            if self.invuln == false then
                if self.player.health == 4 then
                    self.player.health = 3
                    self.laserHitGreen = true 
                    self.invuln = true
                    gSounds['shld-down']:play() 
                    Timer.after(1, function() self.invuln = false end)
                elseif self.player.health == 3 then
                    self.player.health = 2
                    self.laserHitGreen = true  
                    self.invuln = true
                    gSounds['shld-down']:play()  
                    Timer.after(1, function() self.invuln = false end)
                elseif self.player.health == 2 then
                    self.player.health = 1
                    self.laserHitGreen = true  
                    self.invuln = true 
                    gSounds['shld-down']:play() 
                    Timer.after(1, function() self.invuln = false end)
                else
                    if self.player.lives == 3 then
                        self.player.lives = 2
                        self:explode()
                        self.player.health = 4
                    elseif self.player.lives == 2 then
                        self.player.lives = 1
                        self:explode()
                        self.player.health = 4
                    else
                        self.player.lives = 0
                        self:explode()
                        self.player.health = 0
                    end
                end
            end
        end
    end
    
    -- update the player sprite every frame unless the player is dead
    if self.collision == false then
        self.player:update(dt)
    end
end

function PlayState:explode()
    self.collision = true -- set collision to true
    self.explosion = true -- set explosion to true
    self.player.collision = true -- set player collision to true, to stop movement while dead
    self.invlun = true -- set invuln to true so player won't take damage while dead
    gSounds['boom' .. tostring(math.random(9))]:play() -- play 1 of 9 random BOOM sounds
    Timer.after(2, function() self.collision = false end)
    Timer.after(3, function() self.invuln = false end) -- after 2 seconds, put collision back to false
    self.explX = self.player.x -- get player's x for explosion
    self.explY = self.player.y -- and player's y
    self.player.x = VIRTUAL_WIDTH / 2 - 25 -- reset player's position
    self.player.y = VIRTUAL_HEIGHT - 50 -- back to where you start
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

    -- for loop that prevents lasers from going through the player
    -- when contact is made between them and a laser projectile
    for k, proj in pairs(self.enemyProj) do
        -- if we've scored a hit, then
        if self.laserHitGreen == true then
            -- go through projectiles and start removing them
            for k, projectile in pairs(self.enemyProj) do
                table.remove(self.enemyProj, k)
                -- only render a projectile if it's above the location of the hit
                if projectile.y < self.player.y then
                    projectile:render()
                end
            end
        -- otherwise render projectiles normally
        elseif proj.y < VIRTUAL_HEIGHT then
            proj:render()
        end
    end
    
    -- render laser blast objects
    if self.laserHitRed == true then
        love.graphics.draw(gTextures['red-hit'], self.hitX, self.hitY, 0, 0.25, 0.25)
        -- make them disappear after 1/16th of a second
        Timer.after(0.0625, function() self.laserHitRed = false end)
    end
    
    -- render laser blast objects
    if self.laserHitGreen == true then
        love.graphics.draw(gTextures['green-hit'], self.player.x + 11.5, self.player.y - 5, 0, 0.25, 0.25)
        -- make them disappear after 1/16th of a second
        Timer.after(0.0625, function() self.laserHitGreen = false end)
    end
    
    -- render the enemyProj shots if on-screen
    for k, proj in pairs(self.enemyProj) do
        if proj.y < VIRTUAL_HEIGHT then
            proj:render()
        end
    end
    
    -- print the score in the top right corner, with space for score to grow
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['f-thin'])
    love.graphics.printf('Score: ' .. tostring(self.player.score), 0, 0, VIRTUAL_WIDTH - 25, 'right')

    -- print the time left in the level in the top center(ish) of the screen
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(gFonts['f-thin'])
    love.graphics.printf('Time left: ' .. tostring(self.levSeconds), 0, 0, VIRTUAL_WIDTH / 2 + 110, 'center')

    -- print the current level for 2 sec at start of level
    if self.printLevel == true then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setFont(gFonts['future'])
        love.graphics.printf('Level: ' .. tostring(self.level), 0, VIRTUAL_HEIGHT / 2 - 25, VIRTUAL_WIDTH / 2 + 175, 'center') 
    end
    
    -- render the player's lives in the top left
    for i = 1, self.player.lives do
      love.graphics.draw(gTextures['life'],
          (i - 1) * 20, 2, 0, 0.5, 0.5)
    end

    -- render the player's health below the lives
    if self.player.health > 0 then
        love.graphics.draw(gTextures['health'], gFrames['health'][self.player.health], 5, 20, 0, 0.5, 0.5)
    end
end