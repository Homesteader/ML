local MapObj = class("MapObj")

function MapObj:ctor(conf)
	self.conf = conf
	self.data = {}
end

-- 设置数据
function MapObj:setCityData(data)
	for k,v in pairs(data) do
		self.data[tonumber(k)] = v
	end 
end

--获取关卡ID
function MapObj:getId()
	return self.conf.id
end

-- 名称
function MapObj:getName()
	return self.conf.name
end

-- 类型名字
function MapObj:getTypeName()
	local nameTab = {"CUSTOMS_MAP_BTNTX1","CUSTOMS_MAP_BTNTX2","CUSTOMS_MAP_BTNTX3"}
	local custiomsType = self:getCustomsType()
	local str = GlobalApi:getLocalStr_new(nameTab[custiomsType])
	return str
end

-- 关卡类型
function MapObj:setCustomsType(type)
	self.customsType = type
end

function MapObj:getCustomsType()
	return self.customsType or MapType.normal
end

-- 是否是主关卡
function MapObj:isMainCustoms()
	return self.conf.isMain == 1
end

-- 得到功能开启ID
function MapObj:getOpenModuleId()
	local customsType = self:getCustomsType()
	if customsType ~= MapType.normal then
		return '0'
	else
		return self.conf.moduleOpenId
	end
end

-- 怪物
function MapObj:getFormation()

	local customsType = self:getCustomsType()
	return self.conf["formation"][customsType]
end

-- 每日可挑战次数
function MapObj:getDayLimits()
	local customsType = self:getCustomsType()
	return self.conf['limit'][customsType] or 0
end

-- 获得次数
function MapObj:getTimes()
	self:checkData()
	local customsType = self:getCustomsType()
	return self.data[customsType].time
end

-- 更改次数
function MapObj:addTimes(maptype,num)
	self:checkData()
	self.data[maptype].time = self.data[maptype].time + num
end

-- 设置次数
function MapObj:setTimes(maptype,times)
	self:checkData()
	self.data[maptype].time = times
end

-- 设置通过
function MapObj:setPass(maptype)
	self:checkData()
	self.data[maptype].star = 3
end

--是否完成首通
function MapObj:getBfirst()
	self:checkData()
	local customsType = self:getCustomsType()
	local isFirst = self.data[customsType].star == 3
	return isFirst
end

-- 得到重置消耗
function MapObj:getResetCost()
	
	local restedNum = self:getResetedNums()
	local nextNum = restedNum+1
	local buyCfg = GameData:getConfData("buy")
	if nextNum > #buyCfg then
		nextNum = #buyCfg
	end
	local customsType = self:getCustomsType()
	local resetIndexStr = {"normalRest","eliteReset","hardReset"}
	local costYB = buyCfg[nextNum][resetIndexStr[customsType]] or 0
	return costYB

end

-- 得到可重置次数
function MapObj:getTotalResetNums()
	
	local customsType = self:getCustomsType()
	local vipLv = UserData:getUserObj():getVip()
	local vipCfg = GameData:getConfData("vip")[tostring(vipLv)]
	local resetIndexStr = {"normalRest","eliteReset","hardReset"}
	local resetNum = vipCfg[resetIndexStr[customsType]] or 0
	return resetNum
end

-- 得到已重置次数
function MapObj:getResetedNums()
	self:checkData()
	local customsType = self:getCustomsType()
	local resetNums = self.data[customsType].reset_num or 0
	return resetNums
end

-- 设置已重置次数
function MapObj:setResetedNums(nums)
	self:checkData()
	local customsType = self:getCustomsType()
	self.data[customsType].reset_num = nums
end

-- 城市资源
function MapObj:getBtnResource()

	if self.conf.isMain == 1 then
		return 'uires/ui_new/mainscene/customs_'..self.conf.isMain..'_'..MapMgr.maptype
	elseif self.conf.isMain == 0 then
		return 'uires/ui_new/mainscene/customs_'..self.conf.isMain
	end
end

--得到坐标点
function MapObj:getBtnPos()
	return cc.p(self.conf.posX,self.conf.posY)
end

--消耗粮草
function MapObj:getFood()

	local globalKey = ''
	if MapMgr.maptype == MapType.normal then
		globalKey = 'customNormalCost'
	elseif MapMgr.maptype == MapType.elite then
		globalKey = 'customEliteCost'
	elseif MapMgr.maptype == MapType.hard then
		globalKey = 'customHardCost'
	end
	local award = GlobalApi:toAwards(GlobalApi:getGlobalValue_new(globalKey))
	return award
end

-- 开启等级
function MapObj:getLevel()
	if MapMgr.maptype == MapType.normal then
		return self.conf['level']
	else
		return 0
	end
end

-- 首通奖励
function MapObj:getFirstAward()
	return self.conf['first'..MapMgr.maptype]
end

function MapObj:getDropAward(dropId)

	local awards = {}
	if dropId == 0 then
		return awards
	end

	local dropConf = GameData:getConfData("drop")[dropId]
	for i=1,#dropConf.fixed do
		table.insert(awards, dropConf.fixed[i])
	end

	for i=1,15 do
		local drop = dropConf["award"..i] or 0
		if drop ~= 0 then
			table.insert(awards, drop[1])
		end
	end

	return awards
end

-- 掉落奖励
function MapObj:getDrop()
	local customsType = self:getCustomsType()
	local dropId = self.conf['drop'][customsType]
	return self:getDropAward(dropId)
end

function MapObj:checkData()
	if not self.data then
		self.data = {}
		self.data[MapType.normal] = {star = 0,time = 0,reset_num = 0}
		self.data[MapType.elite] = {star = 0,time = 0,reset_num = 0}
		self.data[MapType.hard] = {star = 0,time = 0,reset_num = 0}
	end
end

--首通
function MapObj:setBfirst(b)
	self.bFirst = b
end
return MapObj