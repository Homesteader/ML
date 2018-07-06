local BaseClass = require("script/app/ui/battle/special/hero/base")

local XiaHouDun = class("XiaHouDun", BaseClass)

-- 攻击速度降低，攻击力提高
function XiaHouDun:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		owner.heroInfo.attackSpeed = owner.heroInfo.attackSpeed + owner.heroInfo.baseAttackSpeed*self.value1[1]/100
		owner.heroInfo.atk = owner.heroInfo.atk + owner.heroInfo.baseAtk*self.value1[2]/100
	end
end

--暴击伤害提升
function XiaHouDun:effectBeforeFight()
	if self.skill2 then
		self.owner.critCoefficient = self.value2[1]/100
	end
end

return XiaHouDun