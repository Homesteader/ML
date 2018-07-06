local BaseClass = require("script/app/ui/battle/special/hero/base")
local BattleHelper = require("script/app/ui/battle/battlehelper")

local CaoCao = class("CaoCao", BaseClass)

function CaoCao:init()
	self.hurtNum = 0
end

-- 每失去一定生命时小技能立马冷却
function CaoCao:effectWhenGetHurt(hpNum, flag, atker)
	if self.skill1 and hpNum < 0 then
		self.hurtNum = self.hurtNum - hpNum
		if self.hurtNum/self.owner.maxHp >= self.value1[1]/100 then
			self.hurtNum = 0
			if self.triggerSkill then
				self.triggerSkill:useSkill()
				self.triggerSkill:effect()
			end
		end
	end
	return hpNum
end

function CaoCao:effectBeforeFight()
	if self.skill1 then
		local skillGroupInfo = GameData:getConfData("skillgroup")[self.owner.skillGroupId]
		if skillGroupInfo then
			self.triggerSkill = self.owner:createSkill(skillGroupInfo.autoSkill1 + self.owner.skillLevel - 1, BattleHelper.ENUM.SKILL_TYPE.SPECIAL)
		end
	end
	if self.skill2 then
		self.owner:changeSkillForever(self.value2[1])
	end
end

return CaoCao