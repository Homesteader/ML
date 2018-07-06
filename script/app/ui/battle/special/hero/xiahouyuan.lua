local BaseClass = require("script/app/ui/battle/special/hero/base")

local XiaHouYuan = class("XiaHouYuan", BaseClass)

-- 攻击射程增加，暴击率提升
function XiaHouYuan:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		owner.heroInfo.attackRange = owner.heroInfo.attackRange + self.value1[1]
		owner.heroInfo.crit = owner.heroInfo.crit + self.value1[2]*100
	end
end

-- 暴击时，加个buff
function XiaHouYuan:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill2 and hpNum < 0 and flag == 3 then
		self.owner:createBuff(self.value2[1], self.owner)
	end
	return hpNum
end

return XiaHouYuan