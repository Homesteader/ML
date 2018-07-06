local BaseClass = require("script/app/ui/battle/special/hero/base")

local YuanShao = class("YuanShao", BaseClass)

-- 所有群雄武将属性增加
function YuanShao:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.camp == 4 then
				v.heroInfo.atk = v.heroInfo.atk + v.heroInfo.baseAtk*self.value1[1]/100
				v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value1[1]/100
				v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value1[1]/100
				v.heroInfo.hp = v.heroInfo.hp + v.heroInfo.baseHp*self.value1[1]/100
				v.heroInfo.hit = v.heroInfo.hit + v.heroInfo.baseHit*self.value1[1]/100
				v.heroInfo.dodge = v.heroInfo.dodge + v.heroInfo.baseDodge*self.value1[1]/100
				v.heroInfo.crit = v.heroInfo.crit + v.heroInfo.baseCrit*self.value1[1]/100
				v.heroInfo.resi = v.heroInfo.resi + v.heroInfo.baseResi*self.value1[1]/100
			end
		end
	end
end

-- 生命值高于攻击者，则受到伤害减少
function YuanShao:effectWhenGetHurt(hpNum, flag, atker)
	if self.skill2 and hpNum < 0 and self.owner.hp > atker.hp then
		hpNum = math.floor(hpNum*(1+self.value2[1]/100))
	end
	return hpNum
end

return YuanShao