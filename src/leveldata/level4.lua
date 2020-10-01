function Game:update(dt, x, y)
    self.mouseX = x
    self.mouseY = y

    local next = next
    -- Level progression
    leveltimer = leveltimer + dt

    -- If win_condition is satisfied do one more story prompt and then the level is cleared
    if self.win_condition and not self.story_condition then
        victory()
    elseif self.story_condition and leveltimer > 1 then
        self.story_condition = false
        prompt_story()
    elseif self.storyphase == 'Boss Phase 2' and next(self.enemies) == nil and next(self.boss) == nil then
        self.win_condition = true
        self.story_condition = true
    elseif self.storyphase == 'Crescendo' then
        self.elapsed = self.elapsed + dt
        self.enemy_interval = self.enemy_interval - 13
        self.storyphase = 'Boss Phase 1'
    elseif self.storyphase == 'Boss Phase 2' then
        self.elapsed = self.elapsed + dt
        if self.elapsed > self.enemy_interval and next(self.boss) ~= nil then
            for i = 1, 4 do
                local num = love.math.random(5)
                table.insert(self.enemies, Enemy(num))
            end
            self.elapsed = self.elapsed - self.enemy_interval
        end
    -- Enemy spawning throughout the level
    elseif leveltimer <= 60 or self.storyphase == 'Boss Phase 1' then
        if leveltimer >= 140 then
            self.story_condition = true
            self.storyphase = 'Boss Phase 2'
            local num = 34
            local boss = Enemy(num)
            boss.y = -100
            boss.dy = math.floor(boss.dy / 2)
            table.insert(self.boss, boss)
            self.enemy_interval = 5
            self.elapsed = 0
        elseif leveltimer >= 110 then
            self.enemy_interval = 15
        elseif leveltimer >= 100 then
            self.enemy_interval = 10
        elseif leveltimer >= 90 then
            self.enemy_interval = 9
        elseif leveltimer >= 80 then
            self.enemy_interval = 8
        elseif leveltimer >= 70 then
            self.enemy_interval = 5
        elseif leveltimer >= 60 then
            self.enemy_interval = 3
        end
        self.elapsed = self.elapsed + dt
        if self.elapsed >= self.enemy_interval and self.storyphase ~= 'Boss Phase 2' then
            local num = love.math.random(11,15)
            table.insert(self.enemies, Enemy(num))
            self.elapsed = self.elapsed - self.enemy_interval
        elseif self.elapsed > 1 and self.elapsed < 2 then
            local num = love.math.random(5)
            table.insert(self.enemies, Enemy(num))
            num = love.math.random(5)
            table.insert(self.enemies, Enemy(num))
            num = love.math.random(5)
            table.insert(self.enemies, Enemy(num))
            self.elapsed = self.elapsed + 1
        end
    elseif self.storyphase == 'Default' then
        self.storyphase = 'Crescendo'
        self.story_condition = true
    end
    

    -- Fill up charge meter
    if self.charging then self.chargetime = self.chargetime + dt end
    
    -- Update bullet and check for collision
    local num_bullets = #self.bullets
    local j = 1
    while j <= num_bullets do
        local bullet = self.bullets[j]
        bullet:update(dt)
        if bullet:outofbounds() then
            self:remove_bullet(j, num_bullets)
            num_bullets = num_bullets - 1
        else
            for i, boss in ipairs(self.boss) do
                if boss:collides(bullet.x, bullet.y) and boss.state == "Default" then
                    if bullet.type == 'Bullet' then
                        if bullet.cannon_index == 1 then
                            boss:initsearch(1)
                        elseif boss.sorted == 2 then
                            boss:initsearch(2)
                        end
                    else
                        boss:initsort(2)
                    end
                    bullet = self:remove_bullet(j, num_bullets)
                    num_bullets = num_bullets - 1
                    j = j - 1
                    break
                end
            end
            if bullet then
                for i, enemy in ipairs(self.enemies) do
                    if enemy:collides(bullet.x, bullet.y) and enemy.state == "Default" then                   
                        if bullet.type == 'Bullet' then
                            if bullet.cannon_index == 1 then
                                enemy:initsearch(1)
                            elseif enemy.sorted == 2 then
                                enemy:initsearch(2)
                            end
                        else
                            enemy:initsort(2)
                        end
                        bullet = self:remove_bullet(j, num_bullets)
                        num_bullets = num_bullets - 1
                        j = j - 1
                        break
                    end
                end
            end
            j = j + 1
        end
    end

    -- Update freezetimer
    if self.frozen then
        self.freezetimer = self.freezetimer - dt
        if self.freezetimer <= 0 then
            self.freeze_ready = true
            self.frozen = false
        elseif self.freezetimer <= 10 and not self.unfrozen then
            self:unfreeze()
        end
    end

    -- Update bombtimer
    if not self.bomb_ready then
        self.bombtimer = self.bombtimer - dt
        if self.bombtimer <= 0 then
            self.bomb_ready = true
        end
    end

    -- Update enemy movement and interactions
    local num_enemies = #self.enemies
    j = 1
    while j <= num_enemies do
        enemy = self.enemies[j]
        if enemy.bars == 0 then
            self.enemies[j] = self.enemies[num_enemies]
            self.enemies[num_enemies] = nil
            num_enemies = num_enemies - 1
        elseif enemy.bounds.y2 >= 670 then
            self.storyphase = 'Game Over'
            break
        else
            enemy:update(dt)
            j = j + 1
        end
    end
    -- Check and update boss
    for i,boss in ipairs(self.boss) do
        if boss.bars == 0 then
            table.remove(self.boss, i)
        elseif boss.bounds.y2 >= 670 then
            self.storyphase = 'Game Over'
            break
        else
            boss:update(dt)
        end
    end

    if self.storyphase == 'Game Over' then
        game_over()
    end
end