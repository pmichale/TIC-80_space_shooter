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
    invincibilityDuration = 2000,
    score = 0,
    timeStarted = 0,
    readyToAdvance = 0,
}

function init(level)
    --GAMESTATE
    if level == 92 then
        GameState.score = 0
    end
    GameState.timeStarted = time()
    GameState.level = level

    player = {
        spriteId = 257,
        x = 5,
        y = 72,
        startx = 5,
        starty = 72,
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
        lastMine = 0,
        projectileType = {1},
        engine = 256,
        pickup = 0,
        pickupTime = 0,
        pickupTimeOut = 15000,
        shield = false,
        shieldTime = 0,
        shieldTimeOut = 15000,
        mines = 10,
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
        wpx = 4,
        hpx = 3,
        timing=0,
        timeOut = 2000,
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
        type = 1,
        spriteId=480,
        defSprite=480,
        x=0,
        y=0,
        --speedx=-1,
        speedx=0,
        speedy=0,
        w=2,
        h=2,
        wpx = 13,
        hpx = 16,
        flip = 0,
        canShoot = true,
        hasMines = false,
        guidedMines = false,
        shotOffsetX = 2,
        shotOffsetY = -6,
        animationTiming = 0,
        alive=true,
        beingDestroyed = "no",
        lastShot = 0,
        shotTimeout = 500,
        hitPoints = 10,
        followPlayer = true,
        score = 500,
    }
    enemy2 = table.copy(enemy1)
    enemy2.type = 2
    enemy2.spriteId = 482
    enemy2.defSprite = 482
    enemy2.wpx = 13
    enemy2.hpx = 14
    enemy2.speedx = -2
    enemy2.hitPoints = 5
    enemy2.canShoot = false
    enemy2.score = 300
    enemy3 = table.copy(enemy1)
    enemy3.type = 3
    enemy3.spriteId = 484
    enemy3.defSprite = 484
    enemy3.wpx = 12
    enemy3.hpx = 15
    enemy3.speedx = 0
    enemy3.hitPoints = 5
    enemy4 = table.copy(enemy1)
    enemy4.type = 4
    enemy4.spriteId = 486
    enemy4.defSprite = 486
    enemy4.wpx = 16
    enemy4.hpx = 16
    enemy4.shotTimeout = 300
    enemy4.shotOffsetX = -4
    enemy4.shotOffsetY = -13
    enemy4.score = 1000
    enemy5 = table.copy(enemy1)
    enemy5.type = 5
    enemy5.spriteId = 488
    enemy5.defSprite = 488
    enemy5.wpx = 16
    enemy5.hpx = 13
    enemy5.canShoot = false
    enemy5.hasMines = true
    enemy5.score = 800
    enemy6 = table.copy(enemy1)
    enemy6.type = 6
    enemy6.spriteId = 460
    enemy6.defSprite = 460
    enemy6.w = 4
    enemy6.h = 4
    enemy6.wpx = 32
    enemy6.hpx = 32
    enemy5.canShoot = false
    enemy6.followPlayer = false
    enemy6.hasMines = true
    enemy6.guidedMines = true
    enemy6.score = 4000

    enemyBlueprints = {enemy1,enemy2,enemy3,enemy4,enemy5,enemy6}

    enemies={}

    enemyProjectile = {
        spriteId=270,
        x=0,
        y=0,
        speedx=-2.5,
        speedy=0,
        w=1,
        h=1,
        wpx = 5,
        hpx = 3,
        timing = 0,
        timeOut = 3000,
        destroy=false,
        flip=false,
    }

    enemyProjectiles={}

    enemyMine = {
        defSprite=507,
        spriteId=507,
        x=0,
        y=0,
        speedx=0,
        speedy=0,
        w=1,
        h=1,
        wpx = 8,
        hpx = 8,
        timeDeployed = 0,
        timeOut = 17000,
        flip = false,
        guided = false,
        beingDeployed = "yes",
        animationTiming = 0,
    }

    enemyMines = {}

    playerMine = table.copy(enemyMine)
    playerMine.speedx = 1
    playerMine.defSprite = 506
    playerMine.spriteId = 506
    playerMines = {}

    pickup1 = {
        spriteId = 260,
        type = 1,
        x = 0,
        y = 0,
        w = 1,
        h = 1,
        wpx = 8,
        hpx = 8,
        timeDropped = 0,
        timeOut = 6000,
    }
    pickup2 = table.copy(pickup1)
    pickup2.type = 2
    pickup2.spriteId = 261
    pickup2.wpx = 7
    pickup2.hpx = 7
    pickup3 = table.copy(pickup1)
    pickup3.type = 3
    pickup3.spriteId = 262
    pickupBlueprints = {pickup1, pickup2, pickup3}
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
    if btn(7) and time() - player.lastShot > 100 then
        for i = 1, #types do
            local type = types[i]
            local newProjectile = table.copy(projectileBlueprint[type])
            newProjectile.x = player.x + player.w * 8 - 4
            newProjectile.y = player.y + 5
            newProjectile.timing = time()
            if types[i] == 2 then newProjectile.y=player.y + 4 end
            table.insert(projectiles, newProjectile)
        end
        player.lastShot = time()
    end
end --shootPlayer
function shootMinePlayer()
    if btn(6) and time() - player.lastMine > 2000 and player.mines > 0 then
        local newMine = table.copy(playerMine)
        newMine.x = player.x + player.w * 8 + 2
        newMine.y = player.y + 2
        table.insert(playerMines, newMine)
        player.lastMine = time()
        player.mines = player.mines - 1
    end
end --shootMinePlayer
function harmPlayer()
    if not player.invincibility and not player.shield then
        -- player damage
        GameState.lives = GameState.lives - 1
        player.invincibilityCounter = time()
        player.invincibility = true
        player.x = player.startx
        player.y = player.starty
        if GameState.lives == 0 then
            init(92)
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
    newPickup.timeDropped = time()
    table.insert(pickups, newPickup)
end --dropPickup
function shootEnemy(enemy)
    if enemy.canShoot and time() - enemy.lastShot > enemy.shotTimeout then
        local newEnemyProjectile = table.copy(enemyProjectile)
        newEnemyProjectile.x = enemy.x - enemy.shotOffsetX
        newEnemyProjectile.y = enemy.y - enemy.shotOffsetY
        newEnemyProjectile.timing = time()
        table.insert(enemyProjectiles, newEnemyProjectile)
        enemy.lastShot = time()
    end
end --shootEnemy
function shootMineEnemy(enemy)
    if enemy.hasMines and time() - enemy.lastShot > enemy.shotTimeout then
        local newMine = table.copy(enemyMine)
        newMine.x = enemy.x + enemy.w * 8 + 2
        newMine.y = enemy.y + 2
        if enemy.guidedMines then newMine.guided = true end
        table.insert(enemyMines, newMine)
        enemy.lastShot = time()
    end
end --shootMineEnemy
function addScore(enemy)
    GameState.score = GameState.score + enemy.score
end --addScore

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
    -- shield
    if player.pickup == 1 then
        player.shield = true
        player.shieldTime = time()
        player.pickup = 0
    end
    if time()-player.shieldTime > player.shieldTimeOut then player.shield = false end
    -- tripleshot
    if player.pickup == 2 then
        player.projectileType = {1, 2, 3}
    else
        player.projectileType = {1}
    end
    if time()-player.pickupTime > player.pickupTimeOut then player.pickup = 0 end
    -- mines
    if player.pickup == 3 then
        player.mines = 5
        player.pickup = 0
    end
end --updatePlayer
function updateProjectiles()
    local projectilesToRemove = {}
    for i, projectile in ipairs(projectiles) do
        if (time()-projectile.timing)>projectile.timeOut then
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
                break
            end
        end
        --update position
        projectile.x = projectile.x+projectile.speedx
        projectile.y = projectile.y+projectile.speedy
        --destroy projectiles
        if projectile.destroy then
            table.insert(projectilesToRemove, i)
        end
    end
    for i = #projectilesToRemove, 1, -1 do
        table.remove(projectiles, projectilesToRemove[i])
    end
end --updateProjectiles
function updateEnemyProjectiles()
    local projectilesToRemove = {}
    for i, projectile in ipairs(enemyProjectiles) do
        if (time()-projectile.timing)>projectile.timeOut then
            projectile.destroy=true
        end
        --check collision player
        if collisionObject(projectile,player) then
            projectile.destroy=true
            harmPlayer()
        end
        --update position
        projectile.x = projectile.x+projectile.speedx
        projectile.y = projectile.y+projectile.speedy
        --destroy projectiles
        if projectile.destroy then
            table.insert(projectilesToRemove, i)
        end
    end
    for i = #projectilesToRemove, 1, -1 do
        table.remove(enemyProjectiles, projectilesToRemove[i])
    end
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

        -- damage player
        if collisionObject(player,enemy) then
            harmPlayer()
        end
        -- evaluate health
        if enemies[i].hitPoints <= 0 then 
            enemies[i].alive = false
        end
        --kill enemy
        if not enemy.alive then
            if enemy.beingDestroyed == "no" then
                enemy.beingDestroyed = "yes"
            end

            if enemy.beingDestroyed == "done" then
                addScore(enemy)
                dropPickup(enemy.x,enemy.y,math.ceil(randomBetween(0,2)))
                table.remove(enemies, i)
            elseif enemy.beingDestroyed == "yes" then
                animateDeadEnemies(i)
            end
        end
        -- shoot
        shootEnemy(enemy)
        shootMineEnemy(enemy)

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
            if pickup.type == 2 then player.pickupTime = time() end
            table.remove(pickups, i)
        end
        if time() - pickup.timeDropped > pickup.timeOut then
            table.remove(pickups, i)
        end
    end
end --updatePickups
function updateEnemyMines()
    for i, mine in ipairs(enemyMines) do
        if time()-mine.timeDeployed > mine.timeOut then
            mine.beingDeployed = "destroying"
        end
        if mine.beingDeployed == "yes" then 
            animateMine(enemyMines, i)
        elseif mine.beingDeployed == "done" then
            -- collisions
            if collisionObject(player, mine) then
                harmPlayer()
                mine.beingDeployed = "destroying"
                break
            end
            -- control guided
            if mine.guided and mine.x > player.x then
                mine.speedx = -2
                if math.abs(mine.y - player.y) > 2 then
                    mine.speedy = -0.7 * sign(mine.y - player.y)
                else
                    mine.speedy = 0
                end
            end
            -- update position
            mine.x = mine.x+mine.speedx
            mine.y = mine.y+mine.speedy
        elseif mine.beingDeployed == "destroying" then
            animateMineExplosion(enemyMines, i)
        elseif mine.beingDeployed == "destroyed" then
            table.remove(enemyMines, i)
        end
    end
end --updateEnemyMines
function updatePlayerMines()
    for i, mine in ipairs(playerMines) do
        if time()-mine.timeDeployed > mine.timeOut and mine.beingDeployed == "done" then
            mine.defSprite=507
            mine.spriteId=411
            mine.beingDeployed = "destroying"
        end
        if mine.beingDeployed == "yes" then 
            animateMine(playerMines, i)
        elseif mine.beingDeployed == "done" then
            for y, enemy in ipairs(enemies) do
                if collisionObject(enemy, mine) then
                    enemy.hitPoints = enemy.hitPoints - 5
                    mine.defSprite=507
                    mine.spriteId=411
                    mine.beingDeployed = "destroying"
                    break
                end
            end
            -- update position
            mine.x = mine.x+mine.speedx
        elseif mine.beingDeployed == "destroying" then
            animateMineExplosion(playerMines, i)
        elseif mine.beingDeployed == "destroyed" then
            table.remove(playerMines, i)
        end
    end
end --updatePlayerMines


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
function animateMine(mines, i)
    if (time()/1000)-mines[i].animationTiming>0.1 then
        mines[i].animationTiming=(time()/1000)
        mines[i].spriteId=mines[i].spriteId-16
        if mines[i].spriteId<=(mines[i].defSprite-96) then
            mines[i].spriteId = (mines[i].defSprite-96)
            mines[i].beingDeployed = "done"
            mines[i].timeDeployed = time()
        end
    end
end --animateMine
function animateMineExplosion(mines, i)
    if (time()/1000)-mines[i].animationTiming>0.1 then
        mines[i].animationTiming=(time()/1000)
        mines[i].spriteId=mines[i].spriteId-16
        if mines[i].spriteId<=(mines[i].defSprite-192) then
            mines[i].spriteId = (mines[i].defSprite-192)
            mines[i].beingDeployed = "destroyed"
        end
    end
end --animateMineExplosion


--DRAW
function drawPlayer()
    if player.invincibility then
        if time() % 40 < 5 then
            --ship
            spr(player.spriteId,player.x,player.y,0,1,player.flip,player.rotate,player.w,player.h)
            --flame
            spr(player.engine,player.x-2,player.y+3,0,1,player.flip,player.rotate,1,1)
        end
    else
        --ship
        spr(player.spriteId,player.x,player.y,0,1,player.flip,player.rotate,player.w,player.h)
        --flame
        spr(player.engine,player.x-2,player.y+3,0,1,player.flip,player.rotate,1,1)
    end
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
    for i, mine in ipairs(playerMines) do
        spr(mine.spriteId,mine.x,mine.y,0,1,0,0,mine.w,mine.h)
    end
    for i, mine in ipairs(enemyMines) do
        spr(mine.spriteId,mine.x,mine.y,0,1,0,0,mine.w,mine.h)
    end
    for i, projectile in ipairs(enemyProjectiles) do
        spr(projectile.spriteId,projectile.x,projectile.y,0,1,0,0,projectile.w,projectile.h)
    end 
end --drawProjectiles
function drawShield()
    if player.shield then
        --shield
        if time()-player.shieldTime > player.shieldTimeOut-4000 then
            if time() % 40 < 5 then
                drawShieldLines()
            end
        else
            drawShieldLines()
        end
    end
end --drawShield
function drawShieldLines()
    local x = player.x
    local y = player.y
    local w = player.wpx
    local h = player.hpx
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
end --drawShieldLines
function drawPickups()
    for i, pickup in ipairs(pickups) do
        if time()-pickup.timeDropped > pickup.timeOut-2000 then
            if time() % 40 < 5 then
                spr(pickup.spriteId,pickup.x,pickup.y,0,1,0,0,pickup.w,pickup.h)
            end
        else
            spr(pickup.spriteId,pickup.x,pickup.y,0,1,0,0,pickup.w,pickup.h)
        end
    end
end --drawPickups
function drawHud()
    if GameState.level > 90 then
        if GameState.level == 92 then
            print('VUT.CZ | Petr Michalek | 2023',60,10,12)
            line(3,20,237,20,6)
            print('Press "X" to start',12,25,6)
        elseif GameState.level == 93 then
            print('Select a difficulty to exit.',50,5,6)
        elseif GameState.level == 94 and (time()-GameState.timeStarted) > 2000 then
            print('Press "X" to continue.',70,110,6)
        end
        if GameState.level==99 then
            rect(30,80,190,40,0)
            print('Press "X" to exit.',75,90,6)
            local scoreX = getScoreCentered()
            print('Score: '..GameState.score,scoreX,15,6,true)
        end
    else
        rect(0,0,240,8,0)
        for i=1,GameState.lives do
            spr(304,30+i*(10),-1,0)
        end
        for i=1,(GameState.maxLives - GameState.lives) do 
            spr(320,(40+(10*GameState.maxLives))-i*(10),-1,0)
        end
        print('Lives: ',8,1,12)
        print("Score: "..GameState.score, 100,1,12,false,1,true)
        --line(0,5,240,5,6)
    end
    
end --drawHud

function getScoreCentered()
    local digits = string.len(tostring(GameState.score))
    local scoreLength = (digits+6)*6
    local scoreX = 120-math.floor(scoreLength/2)
    return scoreX
end --getScoreCentered

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
    shootMinePlayer()
    updatePlayer()
    updateProjectiles()
    updateEnemyProjectiles()
    updateEnemies()
    updatePickups()
    updateEnemyMines()
    updatePlayerMines()
end --update

function animate()
    animateFarStars()
    animateNearStars()
    animatePlayer()
end --animate

function draw()
    drawFarStars()
    drawNearStars()
    drawEnemies()
    drawPlayer()
    drawProjectiles()
    drawShield()
    drawPickups()
    drawHud()
end --draw

init(1)
--spawnEnemy(235,72,5)
spawnEnemy(220,22,1)
spawnEnemy(220,72,3)
spawnEnemy(220,122,4)
stTm = time()
function TIC()
    cls()
    update()
    animate()
    draw()
    if time()-stTm>5000 and time()-stTm<5030 then 
        --spawnEnemy(235,72,5)
    end
    if time()-stTm>17000 and time()-stTm<17030 then 
        --spawnEnemy(235,72,2)
    end
end --TIC

