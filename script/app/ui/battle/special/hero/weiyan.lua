local BaseClass = require("script/app/ui/battle/special/hero/base")

local WeiYan = class("WeiYan", BaseClass)

-- 敌方武将死亡则自身回复10%生命值
function WeiYan:effectWhenKillTarget(target)
	if self.skill1 and target.soldierType == 1 then
		local hpNum = math.floor(self.owner.baseHp*self.value1[1]/100)
		self.owner:getEffect(self.owner, hpNum, false, 0, 0, 1, true)
	end
end

-- 如果暴击则回复自身等量生命值
function WeiYan:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill2 and hpNum < 0 and flag == 3 then
		self.owner:getEffect(self.owner, -hpNum, false, 0, 0, 1, true)
	end
	return hpNum
end

return WeiYan