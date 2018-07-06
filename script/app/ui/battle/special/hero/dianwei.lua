local BaseClass = require("script/app/ui/battle/special/hero/base")

local DianWei = class("DianWei", BaseClass)

-- 1.自身生命值越低伤害越高
-- 2.对生命值低于一半的武将多造成伤害
function DianWei:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill1 and hpNum < 0 then
		local coefficient = (1 - self.owner.hp/self.owner.maxHp)*self.value1[1]/100
		if coefficient < 0 then
			coefficient = 0
		end
		hpNum = math.floor(hpNum*(1 + coefficient))
	end
	if self.skill2 and hpNum < 0 and target.hp/target.maxHp < self.value2[1]/100 then
		hpNum = math.floor(hpNum*(1 + self.value2[2]/100))
	end
	return hpNum
end

return DianWei