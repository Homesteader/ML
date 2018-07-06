local BaseClass = require("script/app/ui/battle/special/hero/base")

local DiaoChan = class("DiaoChan", BaseClass)

-- 所有敌方武将防御下降
function DiaoChan:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(enemy) do
			v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value1[1]/100
			v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value1[1]/100
		end
	end
end

-- 封印击杀者所有技能
function DiaoChan:effectWhenDie(killer)
	if self.skill2 and not killer.isPlayerSkill then
		killer:forgetSkill(0)
	end
end

return DiaoChan