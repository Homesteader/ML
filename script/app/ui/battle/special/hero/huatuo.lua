local BaseClass = require("script/app/ui/battle/special/hero/base")

local HuaTuo = class("HuaTuo", BaseClass)

-- 所有本方武将受到的伤害下降
function HuaTuo:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			v.heroInfo.defPercent = v.heroInfo.defPercent + self.value1[1]
		end
	end
end

-- 本方生命值比例最低的武将满血
function HuaTuo:effectWhenDie(killer)
	if self.skill2 then
		local armyArr = self.owner.battlefield.armyArr[self.owner.guid]
		local heroObj
		local minRatio = 100
		for k, v in ipairs(armyArr) do
			if not v:isDead() and not v.heroObj:isDead() then
				local ratio = v.heroObj.hp/v.heroObj.maxHp
				if ratio < minRatio then
					minRatio = ratio
					heroObj = v.heroObj
				end
			end
		end
		if heroObj then
			local needHp = heroObj.maxHp - heroObj.hp
			heroObj:getEffect(self.owner, needHp, false, 0, 0, 1, true)
		end
	end
end

return HuaTuo