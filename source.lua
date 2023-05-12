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
        spriteId = 256,
        x = 5,
        y = 72,
        speedX = 0,
        speedY = 0,
        w = 4,
        h = 2,
        wpx = 25,
        hpx = 12,
        accelerationX = 1,
        accelerationY = 1,
        invincibilityCounter = 0,
        lastShot = 0,
        projectileType = 1,
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
        spriteId=352,
        x=0,
        y=0,
        speedx=4,
        w=1,
        h=1,
        wpx = 3,
        hpx = 1,
        timing=0,
        destroy=false,
        bind=0
    }
    projectile2 = table.copy(projectile1)
    projectile2.spriteId = 123
    projectileBlueprint = {projectile1, projectile2}
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
        wpx = 8,
        hpx = 8,
        flip = 0,
        alive=true,
        lastShot = -5000,
    }
    enemy2 = table.copy(enemy1)
    enemy2.spriteId = 354
    enemy2.defSprite = 354
    enemy3 = table.copy(enemy1)
    enemy3.spriteId = 356
    enemy3.defSprite = 356
    enemy4 = table.copy(enemy1)
    enemy4.spriteId = 358
    enemy4.defSprite = 358
    enemy5 = table.copy(enemy1)
    enemy5.spriteId = 360
    enemy5.defSprite = 360

    enemyBlueprints = {enemy1,enemy2,enemy3,enemy4,enemy5}

    enemies={}

    enemyProjectile1 = {
        spriteId=271,
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
function shootPlayer(type)
    if btn(6) and time()-player.lastShot > 50 then
        local newProjectile = table.copy(projectileBlueprint[type])
        newProjectile.x = player.x+player.w*8-4
        newProjectile.y = player.y+6
        table.insert(projectiles, newProjectile)
        player.lastShot = time()
    end
end --shootProjectile
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
function removeDeadEnemies()
    local i = 1
    while i <= #enemies do
      if enemies[i] == nil then
        table.remove(enemies, i)
      else
        i = i + 1
      end
    end
end --removeDeadEnemies

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
                enemies[i] = nil
                trace("collided")
                --enemy.spriteId = enemy.spriteId + 32
                break
            end
        end
        --update position
        projectile.x = projectile.x+projectile.speedx
        --destroy projectiles
        if projectile.destroy then
            projectile=nil
            table.remove(projectiles, projectile)
        end
    end
end
function updateEnemyProjectiles()
end
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

        enemy.x = enemy.x+enemy.speedx
        enemy.y = enemy.y+enemy.speedy
        if enemy.y < -127 then enemy.y = -126 end -- update to remove them off screen
        if enemy.y > 112 then enemy.y = 112 end -- update to remove them off screen

        --remove dead enemies
        removeDeadEnemies()
    end
end --updateEnemies
function animateNearStars()
    --240x136
    local newCam=math.ceil(interpolate(nearStars.sx,nearStars.sx+nearStars.scroll,nearStars.smoothing))
    local worldMove=newCam/8
    nearStars.sx = newCam
    nearScroll = worldMove
end
function animateFarStars()
    --240x136 
    local newCam=math.ceil(interpolate(farStars.sx,farStars.sx+farStars.scroll,farStars.smoothing))
    local worldMove=newCam/8
    farStars.sx = newCam
    farScroll = worldMove
end

--ANIMATE
function animatePlayer()

    if player.speedY < -0.1 then
        player.spriteId = 320
    elseif player.speedY > 0.1 then
        player.spriteId = 288
    else 
        --default
        player.spriteId = 256
        nearStars.scroll = 300
    end

    if player.speedX > 0.1 then
        --fast
        player.spriteId = player.spriteId + 4
        nearStars.scroll = 400
    elseif player.speedX < -0.1 then
        --motor off
        player.spriteId = player.spriteId + 8
        nearStars.scroll = 200
    end

    
end

--DRAW
function drawPlayer()
    spr(player.spriteId,player.x,player.y,0,1,player.flip,player.rotate,player.w,player.h)
end
function drawEnemies()
    for i, enemy in ipairs(enemies) do
        spr(enemy.spriteId, enemy.x, enemy.y, 0, 1, enemy.flip, 0, enemy.w, enemy.h)
    end
end --drawEnemies
function drawFarStars()
    local cmr = (farStars.sx%8)-8
    map(farScroll,farStars.y,33,20,-cmr,0,0)
end
function drawNearStars()
    local cmr = (nearStars.sx%8)-8
    map(nearScroll,nearStars.y,33,20,-cmr,0,0)
end
function drawProjectiles()
    for i, projectile in ipairs(projectiles) do
        spr(projectile.spriteId,projectile.x,projectile.y,0,1,0,0,projectile.w,projectile.h)
    end
end

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
end

init()
spawnEnemy(235,72,1)
function TIC()
    cls()
    update()
    animate()
    draw()
end

