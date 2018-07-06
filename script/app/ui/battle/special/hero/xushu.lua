local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local XuShu = class("XuShu", BaseClass)

-- 本方所有部队对魏国武将额外造成伤害
function XuShu:effectBeforeFight()
	if self.skill1 then
		BattleHelper:addCampCorrection(self.owner.guid, 1, self.value1[1]/100)
	end
end

function XuShu:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill2 and hpNum < 0 then
		self.owner:createBuff(self.value2[1], target)
	end
	return hpNum
end


return XuShu