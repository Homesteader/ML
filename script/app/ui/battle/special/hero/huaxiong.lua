local BaseClass = require("script/app/ui/battle/special/hero/base")

local HuaXiong = class("HuaXiong", BaseClass)

-- 对远程部队额外造成伤害
function HuaXiong:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill1 and hpNum < 0 and target.attackType == 2 then
		return math.floor(hpNum*(1+self.value1[1]/100))
	else
		return hpNum
	end
end

function HuaXiong:effectWhenDie(killer)
	if self.skill2 and not killer.isPlayerSkill then
		self.owner:createBuff(self.value2[1], killer)
	end
end

return HuaXiong