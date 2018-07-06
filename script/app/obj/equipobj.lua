local ClassGemObj = require('script/app/obj/gemobj')
local EquipObj = class("EquipObj")

local ANCIENT_ID_START = 900000

local function creatDefaultObj()
	local FAKE_OBJ = {
		id = 0,
		xp = 0,
		gems = {},
		pos = 0,
		grade = 0,
		subattr = {},
		belongName = '',
		otherEquips = {},
	}
	return FAKE_OBJ
end

local GOD_EQUIP_COLOR = {"RED", "RED"}

function EquipObj:ctor(sid,obj,grade)
	local attributeConf = GameData:getConfData("attribute")
	if obj == nil then
		obj = creatDefaultObj()
		obj.id = sid
		obj.grade = grade
	end
	self.sid = sid                          -- 区分不同装备的唯一的id
	self.id = obj.id
	self.belongName = obj.belongName or ''	--装备归属名字(其他玩家)
	self.otherEquips = obj.otherEquips		--其他玩家角色上的所有装备

	local equipConf = GameData:getConfData("equipconf")[tonumber(obj.id)]
	local equipBaseConf = GameData:getConfData("equipbase")[equipConf.type][equipConf.quality]

	self.baseConf = equipBaseConf
	self.equipConf = equipConf

	-- 装备的基础属性，对应attribute表，分别是
	self.allAttr = {}
	self.allAttr_check = {}

	for i=1,#attributeConf do
		self.allAttr[i] = 0
		self.allAttr_check[i] = GlobalApi:fuckAttribute(0)
	end
	-- 	[1] = 0,        -- 攻击
	-- 	[2] = 0,		-- 物防
	-- 	[3] = 0,		-- 法防
	-- 	[4] = 0,		-- 生命
	-- 	[5] = 0,		-- 命中
	-- 	[6] = 0,		-- 闪避
	-- 	[7] = 0,		-- 暴击
	-- 	[8] = 0,		-- 韧性
	-- 	[9] = 0,		-- 移动速度
	-- 	[10] = 0,		-- 攻击速度
	-- 	[11] = 0,		-- 伤害加成
	-- 	[12] = 0,		-- 伤害减免
	-- 	[13] = 0,		-- 暴击伤害
	-- 	[14] = 0,		-- 无视防御几率
	-- 	[15] = 0,		-- 5秒回血
	-- 	[16] = 0,		-- 掉落道具加成
	-- 	[17] = 0,		-- 掉落金币加成
	-- 	[18] = 0,		-- 初始怒气
	-- 	[19] = 0,		-- 怒气回复速度
	-- }
	-- 神器属性
	self.godAttr = {}
	self.swallowCost = 0
	self.nextXp = 0

	-- 这件装备所装备的位置
	self.pos = obj.pos

	-- 品级
	self.grade = obj.grade or 0

	-- 装备主属性
	local mainAttribute = {}
	local mainAttrType = equipBaseConf.attributeType
	mainAttribute.attrType 	= mainAttrType
	mainAttribute.name 		= attributeConf[mainAttrType].name
	mainAttribute.value 	= equipBaseConf['attributeValue' .. self.grade]
	mainAttribute.percent 	= 0 -- 主属性加成百分比

	self.mainAttribute = mainAttribute
	self:updateAllAttr(mainAttrType, mainAttribute.value)
	
	-- 强化等级
	self.strengthenLv = obj.intensify or 0

	--精炼等级
	self.refineExp = obj.refine_exp or 0
	local equipRefineCfg = GameData:getConfData("equiprefine")[equipConf.quality]
	self.maxRefineLv = #equipRefineCfg
	self.refineLv = self:changeRefineExpToLv()
	self.refineSpecialaAttr = attributeConf[equipBaseConf.refineSpecialAttType]
end

function EquipObj:getObjType()
	return 'equip'
end
-- 配表里对应的装备id
function EquipObj:getId()
	return self.id
end

-- 唯一id
function EquipObj:getSId()
	return self.sid
end

-- 名称
function EquipObj:getName()
	return self.equipConf.name
end

-- 名称颜色
function EquipObj:getNameColor()
	return COLOR_QUALITY[self.equipConf.quality]
end

-- 描边颜色
function EquipObj:getNameOutlineColor()
	return COLOROUTLINE_QUALITY[self.equipConf.quality]
end

-- 背包显示
function EquipObj:getBagTab()
	return self.equipConf.type
end

function EquipObj:getBagType()
	return self.conf['bagType'] or 'equip'
end

function EquipObj:judgeHasDrop()
    local judge = false
    local useEffect = self.baseConf.useEffect
    if useEffect then
        local tab = string.split(useEffect,'.')
        if tab and tab[1] == 'drop' then
	        local tab2 = string.split(tab[2],':')
            local dropId = tab2[1]
            if tonumber(dropId) == 5006 or tonumber(dropId) == 5007 or tonumber(dropId) == 5008 or tonumber(dropId) == 5009 or tonumber(dropId) == 5010 then
                judge = false
            else
                judge = true
            end
        end
    end
    return judge
end

-- 类型:1-6 对应6个装备位
function EquipObj:getType()
	return self.equipConf.type
end

function EquipObj:getColorType()
	return self.baseConf.color
end

function EquipObj:getBgImg()
	return COLOR_FRAME_TYPE[self.equipConf.quality]
end

function EquipObj:getCornerImg()
	return COLOR_CORNER[self.equipConf.quality]
end

function EquipObj:getCornerTx()
	return self.strengthenLv
end

function EquipObj:getGrade()
	return self.grade
end

function EquipObj:getGradeIcon()
	return 'uires/icon/equipgrade/equip_grade_' .. self.grade .. '.png' 
end

function EquipObj:getGradeSamllIcon()
	return 'uires/icon/equipgrade/equip_grade_small_' .. self.grade .. '.png' 
end

function EquipObj:getCornerRTx()
	local tip = GlobalApi:getLocalStr_new("COMMON_JIE")
	return self.refineLv .. tip
end

-- 图标
function EquipObj:getIcon()
	return "uires/icon/equip/" .. self.equipConf.icon
end

-- 边框
function EquipObj:getFrame()
	return 'uires/ui/common/bg1_alpha.png'
end

-- 等级
function EquipObj:getLevel()
	return 1
end

-- 战斗力
function EquipObj:getFightForce()
	local attconf =GameData:getConfData('attribute')
	local  fightforce = 0
	local att = clone(self.allAttr)
	for i=1,#attconf do
		fightforce = fightforce + math.floor(att[i]*attconf[i].factor)
	end
	return fightforce
end

function EquipObj:getFightForcePre(attarr)
	local arr = clone(attarr)
	local attconf =GameData:getConfData('attribute')
	local  fightforce = 0
	for i=1,#attconf do
		fightforce = fightforce + math.floor(arr[i]*attconf[i].factor)
	end
	return fightforce
end

-- 主属性
function EquipObj:getMainAttribute()
	return self.mainAttribute
end

-- 副属性
function EquipObj:getSubAttribute()
	return self.subAttr
end

-- 副属性数量
function EquipObj:getSubAttrNum()
	return self.subAttrNum
end

-- 更新副属性
function EquipObj:updateSubAttr(subattr)
	for k, v in pairs(subattr) do
		local index = tonumber(k)
		self:updateAllAttr(index, v - self.subAttr[index].value)
		self.subAttr[index].value = v
	end
end

-- 品质
function EquipObj:getQuality()
	return self.baseConf.quality
end

-- 洗练花费金币
function EquipObj:getRefineCost(i)
	if i >= 4 then
		return 0
	else
		return self.baseConf['refineCost'..i]
	end
end

-- 描述
function EquipObj:getDesc()
	return self.baseConf.desc
end

-- 出售价格
function EquipObj:getSellPrice()
	return self.baseConf.sellPrice
end

-- 宝石
function EquipObj:getGems()
	return null
end

-- 可装备的宝石数量
function EquipObj:getMaxGem()
	return null
end

-- 是否有可镶嵌的宝石
function EquipObj:getGemUp(index)
	return false
end

-- 可装备的宝石数量
function EquipObj:getEmptyGemNum()
	return false
end

-- 最大可装备的宝石数量
function EquipObj:getMaxGemNum()
	return 0
end

-- 所装备的role位置1-5, 0表示未被装备
function EquipObj:getPos()
	return self.pos
end

-- 神器吞噬消耗
function EquipObj:getSwallowCost()
	return 0
end

-- 神器传承消耗
function EquipObj:getInheritCost()
	return 0
end

-- 神器等级
function EquipObj:getGodLevel()
	return 0
end

-- 拆解消耗
function EquipObj:getDismantlingCost()
	return 0
end

-- 拆解获得
function EquipObj:getDismantlingAward()
	return null
end

-- 当前所有需要的神器xp,要判断是单属性还是双属性
function EquipObj:getAllXp()
    return 0
end

-- 神器当前经验
function EquipObj:getXp()
	return 0
end

-- 神器当前吞噬所需经验
function EquipObj:getNextXp()
	return 0
end

-- 神器属性id
function EquipObj:getGodId()
	return 0
end

-- 神器属性
function EquipObj:getGodAttr()
	return self.godAttr
end

-- 设置神器属性
function EquipObj:setGod(god,godId)
	
end

-- 更新神器属性
function EquipObj:activateGodByPart(partLv)
	
end

function EquipObj:updateGodAttr(level, xp)
	
end

-- 从其他装备继承神器属性
-- otherEquip一定是神器，自己一定是非神器
function EquipObj:inheritGod(otherEquip)
	otherEquip:resetGod()
end

-- 重置神器属性
function EquipObj:resetGod()
	
end

-- 获取装备的所有属性
function EquipObj:getAllAttr()
	for k, v in ipairs(self.allAttr) do
		GlobalApi:checkAttribute(v, self.allAttr_check[k])
	end
	local att = clone(self.allAttr)
	return att
end

-- 脱装备
function EquipObj:takeOff()
	if self.pos > 0 then
		self.pos = 0
		self:activateGodByPart(0)
		BagData:addItem(ITEM_TYPE.EQUIP, self)
	end
end

-- 穿装备
function EquipObj:putOn(rolePos, otherEquip, talent)
	self.pos = rolePos
	if otherEquip then -- 说明是更换装备,需要继承旧装备的部分属性
		self:inheritOtherEquip(otherEquip)
	end

	local partInfo = RoleData:getRoleByPos(self.pos):getPartByIndex(tostring(self:getType()))
	if partInfo then
		local partLv = partInfo.level
		self:activateGodByPart(partLv)
	end
	--BagData:reduceItem(ITEM_TYPE.EQUIP, self)
end

-- 继承其他装备的属性
function EquipObj:inheritOtherEquip(otherEquipObj)
	
end

-- 镶嵌宝石
function EquipObj:addGem(slotIndex, gemObj)
	
end

-- 卸宝石
function EquipObj:removeGem(slotIndex)
	
end

--卸全部宝石
function EquipObj:removeAllGem()
	
end

--一键镶嵌宝石
function EquipObj:fillGem(slotIndex,gemobj)
	
end

--升级宝石
function EquipObj:upgradeGem(slotIndex,gemobj)
	
end

-- 从其他装备上拔下来宝石然后镶嵌上
function EquipObj:addGemFromOtherEquip(slotIndex, otherSlotIndex, otherGems)
	
end
--用作排序
function EquipObj:canEquip(lv)
	local rv = 0
	if lv < self.baseConf.level then
		rv = 1
	end
	return rv
end

-- 是否是远古装备
function EquipObj:isAncient()
	return false
end

function EquipObj:updateAllAttr(attrId, attrValue)
	local currValue = GlobalApi:defuckAttribute(self.allAttr_check[attrId])
	currValue = currValue + attrValue
	self.allAttr_check[attrId] = GlobalApi:fuckAttribute(currValue)
	self.allAttr[attrId] = currValue
end

-- 设置主属性加成百分比
function EquipObj:setMainAttributePercent(percent)
    self.mainAttribute.percent = percent
end

------------new--------------

--获得装备归属
function EquipObj:getbelongObj()
	local roleobj = RoleData:getRoleByPos(self.pos)
	return roleobj
end

function EquipObj:getbelongName()
	return self.belongName
end

function EquipObj:getOtherEquips()
	return self.otherEquips
end

--获取强化等级
function EquipObj:getStrengthenLv()
	return self.strengthenLv
end

function EquipObj:setStrengthenLv(strengthenLv)
	self.strengthenLv = strengthenLv or self.strengthenLv
end

--强化加成
function EquipObj:getStrengthGrowth(strengthenLv)
	strengthenLv = strengthenLv or self.strengthenLv
	return self.baseConf.upgradeGrowth*strengthenLv
end

function EquipObj:changeRefineExpToLv(exp)

	exp = exp or self.refineExp
	local refineLv = 0
	local equipRefineCfg = GameData:getConfData("equiprefine")[self.equipConf.quality]
	local needExp = 0
	for i=1,#equipRefineCfg do
		needExp = needExp + equipRefineCfg[i].refineExp
		if exp >= needExp then
			refineLv = tonumber(equipRefineCfg[i].level)
		else
			break
		end
	end

	return refineLv
end

--获取精炼等级
function EquipObj:getRefineLv()
	return self.refineLv,self.maxRefineLv
end

--设置精炼等级
function EquipObj:setRefineLv(refineLv)
	self.refineLv = refineLv
end

--获取精炼总经验
function EquipObj:getRefineExp()
	return self.refineExp
end

function EquipObj:setRefineExp(refineExp)
	self.refineExp = refineExp
	self.refineLv = self:changeRefineExpToLv()
end

--获取精炼展示经验
function EquipObj:getRefineDisPlayExp()

	local equipRefineCfg = GameData:getConfData("equiprefine")[self.equipConf.quality]
	local nextLv = self.refineLv+1
	if nextLv >= self.maxRefineLv then
		nextLv = self.maxRefineLv
	end
	local beforExp = 0
	for i=1,self.refineLv do
		beforExp = beforExp + equipRefineCfg[i].refineExp
	end
	local curdisplayExp = self.refineExp - beforExp
	logger(nextLv,self.equipConf.quality,type(self.equipConf.quality))
	local curdisplayNeedExp = equipRefineCfg[nextLv].refineExp
    return curdisplayExp,curdisplayNeedExp
end

--获取升级到指定阶所需的经验
function EquipObj:getNeedExpToLv(level)

	local equipRefineCfg = GameData:getConfData("equiprefine")[self.equipConf.quality]
	if level >= #equipRefineCfg then
		level = #equipRefineCfg
	end

	local needExp = 0
	for i=1,level do
		needExp = needExp + equipRefineCfg[i].refineExp
	end

	needExp = needExp - self.refineExp
	if needExp < 0 then
		needExp = 0
	end
	return needExp
end

--精炼加成
function EquipObj:getRefineGrowth(refineLv)
	refineLv = refineLv or self.refineLv
	return self.baseConf.refineGrowth*refineLv
end

--精炼特殊属性
function EquipObj:getRefineSpecialAttr()
	return self.refineSpecialaAttr
end

--精炼特殊加成
function EquipObj:getRefineSpecialGrowth(refineLv)
	refineLv = refineLv or self.refineLv
	return self.baseConf.refineSpecialAttGrowth*refineLv
end

--获取套装ID
function EquipObj:getSuitId()
	return self.equipConf.suitId
end

--装备排序属性
function EquipObj:getAllBaseAttr()

	local mianValue = self.mainAttribute.value
	local strengthenValue = self:getStrengthGrowth()
	local refineValue = self:getRefineGrowth()
	local totalAttrValue = mianValue + strengthenValue + refineValue
	return totalAttrValue
end
return EquipObj
