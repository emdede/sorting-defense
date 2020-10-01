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
    elseif self.story_condition and leveltimer > 1 then
        self.story_condition = false
        prompt_story()

    -- Enemy spawning throughout the level
    elseif leveltimer <= 40 then
        self.elapsed = self.elapsed + dt
        if self.elapsed > self.enemy_interval then
            local num = 1
            table.insert(self.enemies, Enemy(num))
            self.elapsed = self.elapsed - self.enemy_interval
        end
    elseif self.storyphase == 'Default' and next(self.enemies) == nil then
        self.storyphase = 'Story'
        self.story_condition = true
        local num = 5
        table.insert(self.enemies, Enemy(num))
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
            for i, enemy in ipairs(self.enemies) do
                if enemy:collides(bullet.x, bullet.y) and enemy.state == "Default" then
                    if self.storyphase == 'Default' then
                        enemy:initsearch(1)
                    elseif self.story_prompts > 0 then
                        self.story_condition = true
                        self.story_prompts = self.story_prompts - 1
                        if self.story_prompts == 0 then
                            ls_cannon_unlocked = true
                        end
                    elseif self.story_prompts == 0 then
                        enemy:initsearch(1)
                    end
                    bullet = self:remove_bullet(j, num_bullets)
                    num_bullets = num_bullets - 1
                    j = j - 1
                    break
                end
            end
            j = j + 1
        end
    end

    -- Update enemy movement and interactions
    local num_enemies = #self.enemies
    j = 1
    while j <= num_enemies do
        enemy = self.enemies[j]
        if next(enemy.values) == nil then
            self.enemies[j] = self.enemies[num_enemies]
            self.enemies[num_enemies] = nil
            num_enemies = num_enemies - 1
            if leveltimer > 43 then
                self.story_condition = true
                self.win_condition = true
            end
        elseif enemy.bounds.y2 >= 670 then
            self.storyphase = 'Game Over'
            break
        else
            enemy:update(dt)
            j = j + 1
        end
    end

    if self.storyphase == 'Game Over' then game_over() end
end