local BaseClass = require("script/app/ui/battle/special/hero/base")

local ZhuGong = class("ZhuGong", BaseClass)

-- 怒气值越多伤害值越高
function ZhuGong:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill1 and hpNum < 0 then
		hpNum = math.floor(hpNum*(1 + self.owner.mp/self.owner.maxMp*self.value1[1]/100))
	end
	return hpNum
end

-- 切换目标时，增加怒气
function ZhuGong:effectWhenLockTarget(target)
	if self.skill2 then
		self.owner:addMpPercentage(self.value2[1]/100)
	end
end

return ZhuGong