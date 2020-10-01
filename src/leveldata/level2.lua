function Game:update(dt, x, y)
    self.mouseX = x
    self.mouseY = y

    -- Speed up comparisons
    local next = next
    -- Level progression
    leveltimer = leveltimer + dt

    -- If win_condition is satisfied do one more story prompt and then the level is cleared
    if self.win_condition and not self.story_condition then
        level_clear()
    elseif self.storyphase == 'Spawn Boss' and not self.story_condition then
        local num = 15
        table.insert(self.boss, Enemy(num))
        self.storyphase = 'Boss'
        self.enemy_interval = 2
        self.elapsed = 0
    elseif self.storyphase == 'Boss' and next(self.boss) == nil and next(self.enemies) == nil and not self.win_condition then
        self.story_condition = true
        self.win_condition = true
    elseif self.story_condition and leveltimer > 1 then
        self.story_condition = false
        prompt_story()

    -- Enemy spawning throughout the level
    elseif leveltimer <= 60 or next(self.boss) ~= nil then
        self.elapsed = self.elapsed + dt
        if self.elapsed > self.enemy_interval then
            if next(self.boss) ~= nil then
                local num = love.math.random(2,4)
                table.insert(self.enemies, Enemy(num))
                table.insert(self.enemies, Enemy(num))
            elseif self.storyphase ~= 'Boss' then
                local num = love.math.random(3, 6)
                table.insert(self.enemies, Enemy(num))
                self.enemy_interval = math.max(0.1, self.enemy_interval - 0.198)
            end
            self.elapsed = self.elapsed - self.enemy_interval
        end
    -- Introduce Bomb ability
    elseif self.storyphase == 'Default' then
        self.storyphase = 'Introduce Bomb'
        self.story_condition = true
        self.bomb_ready = true
        bomb_unlocked = true
    -- Cleared all enemies -> boss appears
    elseif self.storyphase == 'Introduce Bomb' and next(self.enemies) == nil then
        self.story_condition = true
        self.storyphase = 'Spawn Boss'
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
            for i, enemy in ipairs(self.boss) do
                if enemy:collides(bullet.x, bullet.y) and enemy.state == "Default" then
                    enemy:initsearch(1)
                    bullet = self:remove_bullet(j, num_bullets)
                    num_bullets = num_bullets - 1
                    j = j - 1
                    break
                end
            end
            if bullet then
                for i, enemy in ipairs(self.enemies) do
                    if enemy:collides(bullet.x, bullet.y) and enemy.state == "Default" then
                        enemy:initsearch(1)
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
    if bomb_unlocked and not self.bomb_ready then
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