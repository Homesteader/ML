local BaseClass = require("script/app/ui/battle/special/hero/base")

local SiMaYi = class("SiMaYi", BaseClass)

-- 所有敌方武将获取怒气速度降低
function SiMaYi:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(enemy) do
			v.heroInfo.recoverMp = v.heroInfo.recoverMp + self.value1[1]
			if v.heroInfo.recoverMp < -100 then
				v.heroInfo.recoverMp = -100
			end
		end
	end
end

function SiMaYi:effectWhenConsumeMp()
	if self.skill2 then
		return self.owner.maxMp*self.value2[1]/100
	else
		return 0
	end
end

return SiMaYi