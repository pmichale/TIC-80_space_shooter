-- title:   Space
-- author:  Petr Michalek, pmich@email.cz
-- desc:    Space shooter for TIC-80
-- site:    tbc
-- version: 0.1
-- script:  lua

    -- 0 up
    -- 1 down
    -- 2 left
    -- 3 right
    -- 4 z
    -- 5 x
    -- 6 a
    -- 7 s

GameState = {
    level = 000,
    lastLevel = 000,
    difficulty = "easy",
    character = "bub",
    maxLives = 3,
    lives = 3,
    tries = 0,
    invincibilityDuration = 2000,
    score = 0,
    timeStarted = 0,
    readyToAdvance = 0,
}

function init()
    player = {
        spriteId = 257,
        x = 5,
        y = 72,
        speedX = 0,
        speedY = 0,
        w = 3,
        h = 2,
        wpx = 24,
        hpx = 12,
        accelerationX = 1,
        accelerationY = 1,
        invincibilityCounter = 0,
        lastShot = 0,
        projectileType = {1},
        engine = 256,
        pickup = 0,
    }
    moveCoeficientX = 0.3
    moveCoeficientY = 0.3

    nearStars = {
        x = 0,
        y = 0,
        sx = 0,
        sy = 0,
        sxdef = 0,
        smoothing = 0.01,
        scroll = 300,
    }

    farStars = {
        x = 0,
        y = 17,
        sx = 0,
        sy = 0,
        sxdef = 0,
        smoothing = 0.01,
        scroll = 1,
    }
    farScroll = 0
    nearScroll = 0

    projectile1 = {
        spriteId=287,
        x=0,
        y=0,
        speedx=4,
        speedy=0,
        w=1,
        h=1,
        wpx = 3,
        hpx = 1,
        timing=0,
        destroy=false,
        bind=0
    }
    projectile2 = table.copy(projectile1)
    projectile2.spriteId = 271
    projectile2.speedy = -2
    projectile3 = table.copy(projectile1)
    projectile3.spriteId = 303
    projectile3.speedy = 2
    projectileBlueprint = {projectile1, projectile2, projectile3}
    projectiles = {}

    -- INIT ENEMIES
    enemy1 = {
        spriteId=480,
        defSprite=480,
        x=0,
        y=0,
        speedx=-1,
        speedy=0,
        w=2,
        h=2,
        wpx = 13,
        hpx = 16,
        flip = 0,
        animationTiming = 0,
        alive=true,
        beingDestroyed = "no",
        lastShot = -5000,
        hitPoints = 10,
    }
    enemy2 = table.copy(enemy1)
    enemy2.spriteId = 482
    enemy2.defSprite = 482
    enemy2.wpx = 13
    enemy2.hpx = 14
    enemy3 = table.copy(enemy1)
    enemy3.spriteId = 484
    enemy3.defSprite = 484
    enemy3.wpx = 12
    enemy3.hpx = 15
    enemy4 = table.copy(enemy1)
    enemy4.spriteId = 486
    enemy4.defSprite = 486
    enemy4.wpx = 16
    enemy4.hpx = 16
    enemy5 = table.copy(enemy1)
    enemy5.spriteId = 488
    enemy5.defSprite = 488
    enemy5.wpx = 16
    enemy5.hpx = 13
    enemy6 = table.copy(enemy1)
    enemy6.spriteId = 460
    enemy6.defSprite = 460
    enemy6.w = 4
    enemy6.h = 4
    enemy6.wpx = 32
    enemy6.hpx = 32

    enemyBlueprints = {enemy1,enemy2,enemy3,enemy4,enemy5,enemy6}

    enemies={}

    enemyProjectile1 = {
        spriteId=287,
        x=0,
        y=0,
        speedx=2,
        speedy=0,
        w=1,
        h=1,
        wpx = 3,
        hpx = 3,
        destroy=false,
        flip=false,
    }
    enemyProjectile2 = table.copy(enemyProjectile1)
    enemyProjectile2.spriteId = 123
    enemyProjectileBlueprints = {enemyProjectile1, enemyProjectile2}

    enemyProjectiles={}

    pickup1 = {
        spriteId = 260,
        type = 1,
        x = 0,
        y = 0,
        w = 1,
        h = 1,
        wpx = 8,
        hpx = 8,
    }
    pickup2 = table.copy(pickup1)
    pickup2.type = 2
    pickup2.spriteId = 261
    pickup2.wpx = 7
    pickup2.hpx = 7
    pickupBlueprints = {pickup1, pickup2}
    pickups={}

end

-- COMMON FUNCTIONS
function interpolate(from,to,step)
    return (1-step)*from + to*step
end --interpolate
function table.copy(t)
    local u = { }
    for k, v in pairs(t) do u[k] = v end
    return setmetatable(u, getmetatable(t))
end --table.copy
function sign(n)
    if n > 0 then
      return 1
    elseif n < 0 then
      return -1
    else
      return 0
    end
end --sign
function randomBetween(min, max)
    return min + math.random() * (max - min)
end --randomBetween
function collisionObject(obj1,obj2)
    local obj1l = obj1.x
    local obj1r = obj1.x + (obj1.wpx)
    local obj1u = obj1.y 
    local obj1d = obj1.y + (obj1.hpx)
    
    local obj2l = obj2.x
    local obj2r = obj2.x + (obj2.wpx)
    local obj2u = obj2.y 
    local obj2d = obj2.y + (obj2.hpx)

    if (obj1r > obj2l) and
    (obj1l < obj2r) and
    (obj1u < obj2d) and
    (obj1d > obj2u) then
        return true
    else
        return false
    end

end --collisionObject

--FUNCTIONS
function shootPlayer(types)
    if btn(6) and time() - player.lastShot > 100 then
        for i = 1, #types do
            local type = types[i]
            local newProjectile = table.copy(projectileBlueprint[type])
            newProjectile.x = player.x + player.w * 8 - 4
            newProjectile.y = player.y + 6
            if types[i] == 2 then newProjectile.y=player.y + 4 end
            table.insert(projectiles, newProjectile)
        end
        player.lastShot = time()
    end
end --shootPlayer
function harmPlayer()
    if not player.invincibility then
        -- player damage
        GameState.lives = GameState.lives - 1
        player.invincibilityCounter = time()
        player.invincibility = true
        player.x = player.startx
        player.y = player.starty
        if GameState.lives == 0 then
            GameState.tries = GameState.tries+1
        end
    end
end --harmPlayer
function spawnEnemy(x,y,type)
    newEnemy = table.copy(enemyBlueprints[type])
    newEnemy.x = x
    newEnemy.y = y
    table.insert(enemies, newEnemy)
end --spawnEnemy
function dropPickup(x,y,type)
    newPickup = table.copy(pickupBlueprints[type])
    newPickup.x = x
    newPickup.y = y
    table.insert(pickups, newPickup)
end --dropPickup


--UPDATE
function updatePlayer()
    player.speedX=player.speedX*moveCoeficientX
    player.speedY=player.speedY*moveCoeficientY
    
    --INPUT
    -- left
    if btn(2) then
        player.speedX = player.speedX-player.accelerationX
    end
    -- right
    if btn(3) then
        player.speedX = player.speedX+player.accelerationX
    end
    -- up
    if btn(0) then
        player.speedY = player.speedY-player.accelerationY
    end
    -- down
    if btn(1) then
        player.speedY = player.speedY+player.accelerationY
    end


    --[[
    -- fall/jump COLLISION
    if player.speedY>0 then
        if collisionMap(player,"down",0) then
            player.speedY=0
            player.y=math.floor((player.y + player.h) / 8) * 8
        end
    elseif player.speedY<0 then
        player.airborne=true
        if collisionMap(player,"up",1) then
            player.speedY=0
        end
    end
    -- left/rigth COLLISION
    if player.speedX<0 then
        if collisionMap(player,"left",1) then
            player.speedX=0
        end
    elseif player.speedX>0 then
        if collisionMap(player,"right",1) then
            player.speedX=0
        end
    end]]

    -- MOVEMENT CHANGE
    player.x = player.x+player.speedX
    player.y = player.y+player.speedY

    -- player invincibility
    if (time() - player.invincibilityCounter) > GameState.invincibilityDuration and player.invincibility then
        player.invincibility = false
    end

    -- player pickups
    if player.pickup == 2 then player.projectileType = {1, 2, 3} end
end --updatePlayer
function updateProjectiles()
    for i, projectile in ipairs(projectiles) do
        if (time()-player.lastShot)>800 then
            projectile.destroy=true
        end
        --[[
        --check collision left
        if projectile.speedx<0 then
            if collisionMap(projectile,"left",1) then
                projectile.speedx=0
                projectile.destroy=true
            end
        --check collision right
        elseif projectile.speedx>0 then
            if collisionMap(projectile,"right",1) then
                projectile.speedx=0
                projectile.destroy=true
            end
        end
        ]]
        --check collision enemy
        
        for i, enemy in ipairs(enemies) do
            if collisionObject(projectile,enemy) then
                projectile.destroy=true
                enemies[i].hitPoints = enemies[i].hitPoints - 1
                if enemies[i].hitPoints <= 0 then 
                    enemies[i].alive = false
                end
                --enemy.spriteId = enemy.spriteId + 32
                break
            end
        end
        --update position
        projectile.x = projectile.x+projectile.speedx
        projectile.y = projectile.y+projectile.speedy
        --destroy projectiles
        if projectile.destroy then
            table.remove(projectiles, i)  -- Remove the projectile at index 'i'
            break  -- Exit the loop after removing the projectile
        end
    end
end --updateProjectiles
function updateEnemyProjectiles()
end --updateEnemyProjectiles
function updateEnemies()
    for i, enemy in ipairs(enemies) do
        -- check map collisions
        --[[
        if enemy.speedy>0 then
            if collisionMap(enemy,"down",0) then
                enemy.speedy=0
                enemy.y=math.floor((enemy.y + enemy.h) / 8) * 8
            end
        elseif enemy.speedy<0 then
            if collisionMap(enemy,"up",1) then
                enemy.speedy=0
            end
        end
        -- left/rigth COLLISION
        if enemy.speedx<0 then
            if collisionMap(enemy,"left",1) then
                enemy.speedx=-enemy.speedx
            end
        elseif enemy.speedx>0 then
            if collisionMap(enemy,"right",1) then
                enemy.speedx=-enemy.speedx
            end
        end ]]

        --damage player
        if collisionObject(player,enemy) and not enemy.bound then
            harmPlayer()
        end

        --kill enemy
        if not enemy.alive then
            if enemy.beingDestroyed == "no" then
                enemy.beingDestroyed = "yes"
            end

            if enemy.beingDestroyed == "done" then
                dropPickup(enemy.x,enemy.y,2)
                table.remove(enemies, i)
            elseif enemy.beingDestroyed == "yes" then
                animateDeadEnemies(i)
            end
        end

        enemy.x = enemy.x+enemy.speedx
        enemy.y = enemy.y+enemy.speedy
        if enemy.y < -127 then enemy.y = -126 end -- update to remove them off screen
        if enemy.y > 112 then enemy.y = 112 end -- update to remove them off screen

    end
end --updateEnemies
function updatePickups()
    for i, pickup in ipairs(pickups) do
        if collisionObject(player, pickup) then
            player.pickup = pickup.type
            table.remove(pickups, i)
        end
    end
end --updatePickups


--ANIMATE
function animatePlayer()

    if player.speedY < -0.1 then
        player.spriteId = 321
    elseif player.speedY > 0.1 then
        player.spriteId = 289
    else 
        --default
        player.spriteId = 257
        player.engine = 256
        nearStars.scroll = 300
    end

    if player.speedX > 0.1 then
        --fast
        player.engine = 272
        nearStars.scroll = 400
    elseif player.speedX < -0.1 then
        --motor off
        player.engine = 288
        nearStars.scroll = 200
    end

    
end --animatePlayer
function animateNearStars()
    --240x136
    local newCam=math.ceil(interpolate(nearStars.sx,nearStars.sx+nearStars.scroll,nearStars.smoothing))
    local worldMove=newCam/8
    nearStars.sx = newCam
    nearScroll = worldMove
end --animateNearStars
function animateFarStars()
    --240x136 
    local newCam=math.ceil(interpolate(farStars.sx,farStars.sx+farStars.scroll,farStars.smoothing))
    local worldMove=newCam/8
    farStars.sx = newCam
    farScroll = worldMove
end --animateFarStars
function animateDeadEnemies(i)
    if (time()/1000)-enemies[i].animationTiming>0.05 then
        enemies[i].animationTiming=(time()/1000)
        enemies[i].spriteId=enemies[i].spriteId-32
        if enemies[i].spriteId<=(enemies[i].defSprite-128) then
            enemies[i].spriteId = (enemies[i].defSprite-128)
            enemies[i].beingDestroyed = "done"
        end
    end
end --animateDeadEnemies

--DRAW
function drawPlayer()
    --ship
    spr(player.spriteId,player.x,player.y,0,1,player.flip,player.rotate,player.w,player.h)
    --flame
    spr(player.engine,player.x-2,player.y+3,0,1,player.flip,player.rotate,1,1)
end --drawPlayer
function drawEnemies()
    for i, enemy in ipairs(enemies) do
        spr(enemy.spriteId, enemy.x, enemy.y, 0, 1, enemy.flip, 0, enemy.w, enemy.h)
    end
end --drawEnemies
function drawFarStars()
    local cmr = (farStars.sx%8)-8
    map(farScroll,farStars.y,33,20,-cmr,0,0)
end --drawFarStars
function drawNearStars()
    local cmr = (nearStars.sx%8)-8
    map(nearScroll,nearStars.y,33,20,-cmr,0,0)
end --drawNearStars
function drawProjectiles()
    for i, projectile in ipairs(projectiles) do
        spr(projectile.spriteId,projectile.x,projectile.y,0,1,0,0,projectile.w,projectile.h)
    end
end --drawProjectiles
function drawShield()
    if player.pickup == 1 then
        local x = player.x
        local y = player.y
        local w = player.wpx
        local h = player.hpx
        --shield
        --top
        line((x),(y-2),(x+w+2),(y-2),10)
        line((x),(y-3),(x+w+2),(y-3),12)
        line((x),(y-4),(x+w+2),(y-4),10)
        --bottom
        line((x),(y+h+1),(x+w+2),(y+h+1),10)
        line((x),(y+h+2),(x+w+2),(y+h+2),12)
        line((x),(y+h+3),(x+w+2),(y+h+3),10)
        --front
        line((x+w+1),(y-2),(x+w+1),(y+h+1),10)
        line((x+w+2),(y-3),(x+w+2),(y+h+2),12)
        line((x+w+3),(y-4),(x+w+3),(y+h+3),10)
    end
end --drawShield
function drawPickups()
    for i, pickup in ipairs(pickups) do
        spr(pickup.spriteId,pickup.x,pickup.y,0,1,0,0,pickup.w,pickup.h)
    end
end --drawPickups

function printPlayer()
    print("x: "..player.x,0,0,7)
    print("y: "..player.y,0,10,7)
    print("xs: "..player.speedX,0,20,7)
    print("ys: "..player.speedY,0,30,7)
end

function printStars()
    print("nearScroll: "..nearScroll,0,0,7)
    print("farScroll: "..farScroll,0,10,7)
    print("nearStars.sx: "..nearStars.sx,0,20,7)
    print("farStars.sx: "..farStars.sx,0,30,7)
end


function update()
    shootPlayer(player.projectileType)
    updatePlayer()
    updateProjectiles()
    updateEnemyProjectiles()
    updateEnemies()
    updatePickups()
end

function animate()
    animateFarStars()
    animateNearStars()
    animatePlayer()
end
function draw()
    drawFarStars()
    drawNearStars()
    drawEnemies()
    drawPlayer()
    drawProjectiles()
    drawShield()
    drawPickups()
end

init()
spawnEnemy(235,72,1)
function TIC()
    cls()
    update()
    animate()
    draw()
end

