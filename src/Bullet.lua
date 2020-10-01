Bullet = Class{}

function Bullet:init(angle, weaponw, type, cannon)
    self.x = 610 - weaponw * math.cos(angle)
    self.y = 540 - weaponw * math.sin(angle)
    self.dx = - math.cos(angle) * 800
    self.dy = - math.sin(angle) * 800
    self.type = type
    self.cannon_index = cannon
    -- Types 'Bullet' and  'Beam'
    if self.type == 'Beam' then
        self.xorig = 610 - weaponw * math.cos(angle)
        self.yorig = 540 - weaponw * math.sin(angle)
        self.dx = self.dx * 2
        self.dy = self.dy * 2
    end
end

function Bullet:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Bullet:render()
    if self.type == 'Beam' then
        love.graphics.setLineWidth(8)
        love.graphics.setColor(0.2,0.4,0.8,0.5)
        love.graphics.line(self.xorig, self.yorig, self.x, self.y)
        love.graphics.setLineWidth(4)
        love.graphics.setColor(0.7,0.3,0.2,1)
        love.graphics.line(self.xorig, self.yorig, self.x, self.y)
        love.graphics.setLineWidth(1)
    else
        love.graphics.setColor(0.7,0.4,0.1,1)
        love.graphics.circle("fill", self.x, self.y, 6)
    end
end

function Bullet:outofbounds()
    if self.x < -5 or self.x > 1285 or self.y < -5 or self.y > 785 then
        return true
    else
        return false
    end
end