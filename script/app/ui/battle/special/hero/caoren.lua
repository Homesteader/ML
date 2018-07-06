local BaseClass = require("script/app/ui/battle/special/hero/base")

local CaoRen = class("CaoRen", BaseClass)

-- 生命值越低防御力越高
-- 单次伤害超过自身生命某一百分比时，小技能冷却
function CaoRen:effectWhenGetHurt(hpNum, flag, atker)
	if self.skill1 and hpNum < 0 then
		local addDef = -hpNum/self.owner.maxHp*self.value1[1]/100
		self.owner.phyDef = self.owner.phyDef + self.owner.basePhyDef*addDef
		self.owner.magDef = self.owner.magDef + self.owner.baseMagDef*addDef
	end
	if self.skill2 and -hpNum/self.maxHp >= self.value2[1]/100 then
		self.owner.baseSkill.usedTimes = self.owner.autoSkillTimes
	end
	return hpNum
end

return CaoRen