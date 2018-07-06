local PartObj = class("PartObj")
local ClassGemObj = require('script/app/obj/gemobj')
local function creatDefaultObj()
	local FAKE_OBJ = {
		id = 0,
		level = 0,
		exp = 0,
		awake_level = 0,
		max_awake = 0,
		gems = {},
	}
	return FAKE_OBJ
end

function PartObj:ctor(partId, obj)
	
	self.partId = partId
    self.awake_level = obj.awake_level
    self.max_awake = obj.max_awake
    self.gems = {}
    --初始化宝石
    for k,gem_id in pairs(obj.gems) do
    	if gem_id ~= 0 then
	    	local gemsIndex = tonumber(k)
	    	self.gems[gemsIndex] = ClassGemObj.new(gem_id, 1)
	    end
    end 
end

function PartObj:getObjType()
	return 'part'
end

function PartObj:getBgImg()
	return DEFAULT
end

function PartObj:getIcon()
	return DEFAULTEQUIPPART[self.partId]
end

function PartObj:getGemSlotBgIcon()
	return "uires/ui_new/common/gem_small_bg.png"
end

function PartObj:getGemSlotIcon(gemType)
	return GEM_SLOT_ICON[gemType]
end

function PartObj:getPartId()
	return self.partId
end

function PartObj:getAwakeLv()
	return self.awake_level
end

function PartObj:setAwakeLv(awakeLv)
	self.awake_level = awakeLv or self.awake_level 
end

--极限觉醒(返回的是bool)
function PartObj:getMaxAwakeLv()
	return self.max_awake 
end

--设置极限觉醒标志
function PartObj:setMaxAwakeLv(max_awake)
	self.max_awake = max_awake or false
end

function PartObj:getGems()
	return self.gems
end

--镶嵌宝石
function PartObj:putOnGem(slot_index, gem_id)
	
	if gem_id == 0 then
		self.gems[slot_index] = nil
	else
        if self.gems[slot_index]  then
            self:removeGem(slot_index)
        end
        self.gems[slot_index]= ClassGemObj.new(gem_id, 1)
    end
end

--拆除宝石
function PartObj:removeGem(slot_index)

	if not self.gems[slot_index] then
		return
	end

	self.gems[slot_index] = nil
end

--拆除所有宝石
function PartObj:removeAllGems()
    for i = 1, PART_GEMS_COUNT do
       self:removeGem(i)
    end 
end

--已经镶嵌的宝石总数
function PartObj:equipedGemsCount()

	local total = 0
	for i = 1, PART_GEMS_COUNT do
       if self.gems[i] then
       	total = total + 1
       end
    end
    return total
end

-- 根据部位觉醒等级，获取开启的宝石格子数
function PartObj:getGemSlotCount()
    local openCount = 0
    for i = 1, PART_GEMS_COUNT do
    	local needOpenLv = tonumber(GlobalApi:getGlobalValue("partEmbedLimit"..i))
        if self.awake_level >= needOpenLv then
            openCount = openCount + 1
        end
    end
    return openCount
end

-- 计算部位镶嵌等级
function PartObj:getPartEmbedLevel()

    local embedConf = GameData:getConfData("partembed")
    local embedLevel = 0
    for i = #embedConf, 1, -1 do
        local needNum = embedConf[i].needGemNum
        local needLevel = embedConf[i].needGemLevel

        local hasNum = 0
        for j = 1, PART_GEMS_COUNT do
            if self.gems[j]  then
            	local gemLv = self.gems[j]:getLevel()
                if gemLv >= needLevel then
                    hasNum = hasNum + 1
                end
            end
        end

        if hasNum >= needNum then
            embedLevel = i
            break
        end
    end

    return embedLevel
end

return PartObj
