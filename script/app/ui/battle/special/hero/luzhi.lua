local BaseClass = require("script/app/ui/battle/special/hero/base")

local LuZhi = class("LuZhi", BaseClass)

-- 所有敌方武将承受伤害增加
function LuZhi:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(enemy) do
			v.heroInfo.defPercent = v.heroInfo.defPercent + self.value1[1]
		end
	end
end

-- 一定范围内的敌军持续掉血
function LuZhi:effectBeforeFight()
	if self.skill2 then
		self.owner:createBuff(self.value2[1], self.owner)
	end
end

return LuZhi