local BaseClass = require("script/app/ui/battle/special/hero/base")

local ZhuGeLiang = class("ZhuGeLiang", BaseClass)

-- 对被控制的目标额外造成伤害
function ZhuGeLiang:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill1 and hpNum < 0 then
		if target.limitMove > 0 or target.limitAtt > 0 or target.limitAtt > 0 then
			hpNum = math.floor(hpNum*(1+self.value1[1]/100))
		end
	end
	return hpNum
end

-- 切换目标时，伤害提高
function ZhuGeLiang:effectWhenLockTarget(target)
	if self.skill2 then
		self.owner:createBuff(self.value2[1], self.owner)
	end
end

return ZhuGeLiang