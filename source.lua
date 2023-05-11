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
        accelerationX = 1,
        accelerationY = 1,
        invincibilityCounter = 0,
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

    projectile = {
        spriteId=352,
        x=0,
        y=0,
        speedx=4,
        w=1,
        h=1,
        wpx=8,
        hpx=8,
        timing=0,
        destroy=false,
        bind=0
    }
    projectiles = {}
    lastShot = 0

    -- INIT ENEMIES
    enemy = {
        spriteId=352,
        defSprite=352,
        x=0,
        y=0,
        speedx=1,
        speedy=0,
        w=2,
        h=2,
        wpx=16,
        hpx=16,
        flip = 0,
        alive=true,
    }
    enemy2 = table.copy(enemy)
    enemy2.spriteId = 354
    enemy2.defSprite = 354
    enemy3 = table.copy(enemy)
    enemy3.spriteId = 356
    enemy3.defSprite = 356
    enemy4 = table.copy(enemy)
    enemy4.spriteId = 358
    enemy4.defSprite = 358
    enemy5 = table.copy(enemy)
    enemy5.spriteId = 360
    enemy5.defSprite = 360
    enemy5.lastShot = -5000
    enemy.seenPlayer = 0

    enemies={}

    enemyProjectile = {
        spriteId=271,
        x=0,
        y=0,
        speedx=2,
        w=1,
        h=1,
        wpx=8,
        hpx=8,
        destroy=false,
        flip=false
    }

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

--FUNCTIONS
function shootPlayer()
    if btn(6) and time()-lastShot > 50 then
        local newProjectile = table.copy(projectile)
        newProjectile.x = player.x+player.w*8-4
        newProjectile.y = player.y+6
        table.insert(projectiles, newProjectile)
        lastShot = time()
    end
end --shootProjectile

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
        if (time()-lastShot)>800 then
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
        --check collision enemy
        
        for i, enemy in ipairs(enemies) do
            if collisionObject(projectile,enemy) and not enemy.bound then
                projectile.destroy=true
                projectile.bind = i
                enemy.spriteId = enemy.spriteId + 32
                enemy.bound = true
                break
            end
        end]]
        --update position
        projectile.x = projectile.x+projectile.speedx
        --destroy projectiles
        if projectile.destroy then
            projectile=nil
            table.remove(projectiles)
        end
    end
end
function updateEnemyProjectiles()
end
function updateEnemies()
end
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
    shootPlayer()
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
    drawPlayer()
    drawProjectiles()
end

init()
function TIC()
    cls()
    update()
    animate()
    draw()
end

