local BaseClass = require("script/app/ui/battle/special/hero/base")

local ZhangJiao = class("ZhangJiao", BaseClass)

-- 对生命值小于指定百分比的小兵秒杀
function ZhangJiao:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill1 and hpNum < 0 and target.soldierType == 2 and target.hp/target.maxHp < self.value1[1]/100 then
		return -target.hp
	else
		return hpNum
	end
end

-- 召唤物攻击增加
function ZhangJiao:effectWhenSummon(summon)
	if self.skill2 then
		summon.atk = summon.atk + summon.baseAtk*self.value2[1]/100
	end
end

return ZhangJiao