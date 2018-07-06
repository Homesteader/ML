local BaseClass = require("script/app/ui/battle/special/hero/base")

local LvBu = class("LvBu", BaseClass)

-- 击杀单位会提升攻击力
function LvBu:effectWhenKillTarget(target)
	if self.skill1 then
		if target.soldierType == 1 then
			self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value1[1]/100
		else
			self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value1[2]/100
		end
	end
end

-- 每有一个武将死亡时，提升攻击力
function LvBu:effectBeforeFight()
	if self.skill2 then
		self.owner.battlefield:addHandleWhenSoldierDie(self.owner, function (guid, soldierType)
			if soldierType == 1 and guid == self.owner.guid then
				self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value2[1]/100
			end
		end)
	end
end

function LvBu:effectWhenDie(killer)
	if self.skill2 then
		self.owner.battlefield:removeHandleWhenSoldierDie(self.owner)
	end
end

return LvBu