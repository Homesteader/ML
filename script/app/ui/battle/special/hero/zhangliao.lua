local BaseClass = require("script/app/ui/battle/special/hero/base")

local ZhangLiao = class("ZhangLiao", BaseClass)

-- 每次暴击会使对方降低怒气
function ZhangLiao:effectWhenHurtTarget(hpNum, flag, target)
	if self.skill1 and hpNum < 0 and flag == 3 then
		target:addMpPercentage(self.value1[1]/100)
	end
	return hpNum
end

-- 击杀者怒气清空，全场武将怒气下降
function ZhangLiao:effectWhenDie(killer)
	if self.skill2 then
		local enemyArr = self.owner.battlefield.armyArr[3-self.owner.guid]
		for k, v in ipairs(enemyArr) do
			if not v:isDead() and not v.heroObj:isDead() then
				if v.heroObj == killer then
					v.heroObj:clearMp()
				else
					v.heroObj:addMpPercentage(self.value2[1]/100)
				end
			end
		end
	end
end

return ZhangLiao