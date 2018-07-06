local GemObj = class("GemObj")

function GemObj:ctor(id, num)
	self.id = id
	self.num = num
    logger("id",self.id)
	local gemConf = GameData:getConfData("gem")[tonumber(self.id)]
	self.baseConf = gemConf

	local attributeConf = GameData:getConfData("attribute")
	self.attrName = attributeConf[gemConf.type].name
end

function GemObj:getObjType()
	return 'gem'
end

function GemObj:getId()
	return self.id
end

function GemObj:getShopId()
    return self.id
end

-- 名称
function GemObj:getName()
	return self.baseConf.name
end

-- 颜色
function GemObj:getNameColor()
	return COLOR_QUALITY[self.baseConf.quality]
end

-- 描边颜色
function GemObj:getNameOutlineColor()
	return COLOROUTLINE_QUALITY[self.baseConf.quality]
end
-- 图标
function GemObj:getIcon()
	return "uires/icon/gem/" .. self.baseConf.icon
end

function GemObj:getBgImg()
	return COLOR_FRAME[self.baseConf.quality]
end

-- 边框
function GemObj:getFrame()
	return 'uires/ui/common/bg1_alpha.png'
end

function GemObj:judgeHasDrop()
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

-- 等级
function GemObj:getLevel()
	return self.baseConf.level
end

-- 类型
function GemObj:getType()
	return self.baseConf.type
end

-- 品质
function GemObj:getQuality()
	return self.baseConf.quality
end

-- 属性名称
function GemObj:getAttrName()
	return self.attrName
end

-- 属性ID
function GemObj:getAttrId()
	return self.baseConf.type
end

-- 属性值
function GemObj:getValue()
	return self.baseConf.value
end

-- 数量
function GemObj:getNum()
	return self.num
end

function GemObj:addNum(num)
	self.num = self.num + num
end

-- 描述
function GemObj:getDesc()
	return self.baseConf.desc
end

-- 是否可出售
function GemObj:getSellable()
	return 1
end

-- 出售价格
function GemObj:getSell()
	return self.baseConf['sell']
end

-- 消耗宝石品质
function GemObj:getCostQuality()
    return self.baseConf.costQuality
end

-- 获取消耗
function GemObj:getCosts()
    return self.baseConf.cost[1]
end

-- 红色碎片特效
function GemObj:setLightEffect(awardBgImg,scale)
    local isNotLight = false
    if self.baseConf.quality ~= 6 or scale == 0 then
        isNotLight = true
    end

    if isNotLight then
        local effect = awardBgImg:getChildByName('chip_light')
        if effect then
            effect:setVisible(false)
        end
        return
    end
    local effect = awardBgImg:getChildByName('chip_light')
    local size = awardBgImg:getContentSize()
    if not effect then
        effect = GlobalApi:createLittleLossyAniByName("chip_light")
        effect:getAnimation():playWithIndex(0, -1, 1)
        effect:setName('chip_light')
        effect:setVisible(true)
        effect:setPosition(cc.p(size.width/2,size.height/2))
        effect:setScale(scale or 1)
        awardBgImg:addChild(effect)
    else
        effect:setVisible(true)
    end
end

-- 是否可升级
function GemObj:getScalable()
    if tonumber(self.baseConf.costQuality) == 0 then
        local cost = DisplayData:getDisplayObj(self.baseConf.cost[1]):getNum()
        local gold = UserData:getUserObj()['gold']
        return gold >= cost
    elseif self.baseConf.getGem == 0 then
        return false
    else
        local gemConf = GameData:getConfData("gem")
        local costQuality = tonumber(self.baseConf.costQuality)
        local cost = DisplayData:getDisplayObj(self.baseConf.cost[1]):getNum()
        local gold = UserData:getUserObj()['gold']
        if gold < cost then
            return false
        end
        local tab = {}
        for i,v in pairs(gemConf) do
            if v.type == self.baseConf.type and costQuality == v.quality then
                local gem = BagData:getGemById(v.id)
                local num = 0
                if gem then
                    num = gem:getNum()
                end
                if num > 0 then
                    return true
                end
            end
        end
    end
    return false
end

-- 获得升级所需的宝石列表
-- 从高级宝石开始消耗
function GemObj:getUpgradeConsumeList(isBag, num)
    if num == nil then
        num = 1
    end

    local canUpgrade = false    -- 是否能升级
    local consumeList = {}
    
    local gemConf = GameData:getConfData("gem")
    local curLevel = self:getLevel()
    local nextLevel = curLevel + 1
    local nextLevelGemId = self:getId() + 1

    local nextGemConf = gemConf[nextLevelGemId]
    local needNum = GEMUPGRADENEEDNUM * num
    local factor = GEMUPGRADENEEDNUM
     
    -- isBag 是否是背包里的宝石点出来的
    local addOne = 1
    if isBag then
        addOne = 0
    end

    if nextGemConf then
        for i = curLevel,1,-1 do
            local hasNum, existGemObj = BagData:getGemNumByTypeAndLevel(self:getType(), i)

            if i == curLevel and addOne > 0 then
                needNum = needNum - addOne
            end

            if hasNum >= needNum then
                -- 满足
                local consumeObj = {}
                consumeObj.level = i
                consumeObj.num = needNum
                consumeObj.gemObj = existGemObj

                table.insert(consumeList, consumeObj)
                canUpgrade = true
                break
            else
                if hasNum > 0 then
                    local consumeObj = {}
                    consumeObj.level = i
                    consumeObj.num = hasNum
                    consumeObj.gemObj = existGemObj

                    table.insert(consumeList, consumeObj)
                end        

                -- 刷新需要的数量，以及倍数
                needNum = (needNum - hasNum) * factor
            end
        end
    end

    return canUpgrade, consumeList
end

-- 获取基础提升幸运值
function GemObj:getBasePromoteLucky()
    return self.baseConf.basePromoteLucky
end

-- 获取失败提升能量值
function GemObj:getPromoteLucky()
    return self.baseConf.promoteLucky
end

-- 获取提升能量值
function GemObj:getLevelUpLucky()
    return self.baseConf.levelUpLucky
end

function GemObj:eatAll(gemId,equipObj)
    local gemObj = BagData:getGemObjById(gemId)
    local gemObj1 = BagData:getGemObjById(gemId - 1)
    local needLuck = gemObj:getLevelUpLucky()
    local luck = UserData:getUserObj():getLuck()
    local num = 0
    local maxNum = self:getNum()
    if self.id == gemId and not equipObj then
        maxNum = maxNum - 1
    end
    if maxNum < 0 then
        maxNum = 0
    end
    local newLuck = 0
    local isUp = false
    if luck >= needLuck then
        num = 1
        newLuck = luck - needLuck + self:getPromoteLucky()
        isUp = true
    else
        local maxLuck = luck + maxNum * self:getPromoteLucky()
        if maxLuck >= needLuck then
            num = math.ceil((needLuck - luck)/self:getPromoteLucky())
            newLuck = num * self:getPromoteLucky() + luck - needLuck
            isUp = true
        else
            newLuck = maxLuck
            num = maxNum
            isUp = false
        end
    end
    local costs = DisplayData:getDisplayObj(gemObj:getCosts())
    local costGoldNum = costs:getNum() * num
    local gold = UserData:getUserObj():getGold()
    local goldNotEnough = false
    if gold < costGoldNum then
        num = math.floor(gold/costs:getNum())
        costGoldNum = num * costs:getNum()
        newLuck = luck + num * self:getPromoteLucky()
        isUp = false
        goldNotEnough = true
    end
    return isUp,num,newLuck,costGoldNum,goldNotEnough
end

return GemObj
