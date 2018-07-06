local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local MaChao = class("MaChao", BaseClass)

-- 对远程部队伤害增加
function MaChao:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill1 and hpNum < 0 and target.attackType == 2 then
		return math.floor(hpNum*(1+self.value1[2]/100))
	else
		return hpNum
	end
end

-- 受到远程部队伤害降低
function MaChao:effectWhenGetHurt(hpNum, flag, target)
	if self.skill1 and hpNum < 0 and target.attackType == 2 then
		return math.floor(hpNum*(1+self.value1[1]/100))
	else
		return hpNum
	end
end

--攻击有几率晕眩敌人
function MaChao:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill2 and hpNum < 0 and BattleHelper:random(0, 100) < self.value2[1] then
		self.owner:createBuff(self.value2[2], target)
	end
	return hpNum
end

return MaChao