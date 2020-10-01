function Game:update(dt, x, y)
    self.mouseX = x
    self.mouseY = y

    local next = next
    -- Level progression
    leveltimer = leveltimer + dt

    -- If win_condition is satisfied do one more story prompt and then the level is cleared
    if self.win_condition and not self.story_condition then
        level_clear()
    elseif self.story_condition and leveltimer > 1 then
        self.story_condition = false
        prompt_story()
    elseif self.storyphase == 'Boss' and next(self.boss) == nil and next(self.enemies) == nil and not self.win_condition then
        self.story_condition = true
        self.win_condition = true
    elseif self.storyphase == 'Boss Spawning' then
        local num = 15
        table.insert(self.boss, Enemy(num))
        table.insert(self.boss, Enemy(num))
        self.storyphase = 'Boss'
    -- Enemy spawning throughout the level
    elseif leveltimer <= 20 or self.storyphase == 'Crescendo' or self.storyphase == 'Boss' then
        self.elapsed = self.elapsed + dt
        if self.crescendotimer and self.crescendotimer > 0 then
            self.crescendotimer = self.crescendotimer - dt
            if self.crescendotimer <= 0 then
                self.story_condition = true
                self.storyphase = 'Boss Spawning'
                self.enemy_interval = 5
            end
        end
        if self.elapsed > self.enemy_interval then
            if self.storyphase == 'Boss' and next(self.boss) ~= nil then
                local num = love.math.random(8, 10)
                table.insert(self.enemies, Enemy(num))
            elseif self.storyphase ~= 'Boss' then
                local num = love.math.random(5, 7)
                table.insert(self.enemies, Enemy(num))
            end
            self.elapsed = self.elapsed - self.enemy_interval
        end
    elseif self.storyphase == 'Introduce Bubble Sort' then
        if next(self.enemies) == nil then
            local num = 10
            local tut_array = Enemy(num)
            while tut_array:check_sort() == 2 do
                for i = 1, tut_array.bars do
                    local r = love.math.random(i, tut_array.bars)
                    tut_array.values[i], tut_array.values[r] = tut_array.values[r], tut_array.values[i]
                end
            end
            prompt_reminder('Commander, please use the new Cannon so we can test its efficiency. Select the BS CANNON by pressing \'2\' on your keyboard and fire it by charging the beam with your RIGHT MOUSE BUTTON.')
        elseif self.enemies[1].sorted == 2 then
            self.story_condition = true
            self.storyphase = 'Crescendo'
            self.crescendotimer = 15
        end
    elseif self.storyphase == 'Default' and next(self.enemies) == nil then
        self.storyphase = 'Introduce Bubble Sort'
        bs_cannon_unlocked = true
        self.bullets = {}
        self:switchCannon(2)
        self.story_condition = true
        local num = 10
        local tut_array = Enemy(num)
        while tut_array:check_sort() == 2 do
            for i = 1, tut_array.bars do
                local r = love.math.random(i, tut_array.bars)
                tut_array.values[i], tut_array.values[r] = tut_array.values[r], tut_array.values[i]
            end
        end
        table.insert(self.enemies, tut_array)
    end
    

    -- Fill up charge meter
    if self.charging then
        self.chargetime = self.chargetime + dt
    end
    
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
                        elseif boss.sorted == 2 and (self.storyphase == 'Boss' or self.storyphase == 'Crescendo') then
                            boss:initsearch(2)
                        end
                    else
                        boss:initsort(bullet.cannon_index)
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
                                if self.storyphase == 'Introduce Bubble Sort' then
                                    prompt_reminder('Commander, please use the new Cannon so we can test its efficiency. Select the BS CANNON by pressing \'2\' on your keyboard and fire it by charging the beam with your RIGHT MOUSE BUTTON.')
                                else
                                    enemy:initsearch(1)
                                end
                            elseif enemy.sorted == 2 then
                                enemy:initsearch(bullet.cannon_index)
                            end
                        else
                            enemy:initsort(bullet.cannon_index)
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

    -- Update bombtimer
    if not self.bomb_ready then
        self.bombtimer = self.bombtimer - dt
        if self.bombtimer <= 0 then
            self.bombtimer = 0
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