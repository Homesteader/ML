local hookhero = require("script/app/ui/hook/hookhero")
local hookboss = require("script/app/ui/hook/hookboss")
cc.exports.hookheromgr = {
	time = 0,
	countime = 0,
	hero = {},
	hookMap = {},
	plistLoaded = {},
	jsonLoaded = {},
	boss = {},
	bossIndex = 0,
}
local function getTime(t)
	local m = string.format("%02d", math.floor(t%3600/60))
	local s = string.format("%02d", math.floor(t%3600%60%60))
	return m..':'..s
end

local PIC_EXTENSION = ".png"
local targetPlatform = CCApplication:getInstance():getTargetPlatform()
if targetPlatform == kTargetAndroid then
    PIC_EXTENSION = ".pkm"
elseif targetPlatform == kTargetIphone or targetPlatform == kTargetIpad then
    PIC_EXTENSION = ".pvr.ccz"
end

function hookheromgr:init(mapbg)

	local explorepathCfg = GameData:getConfData("explorepath")
	self.hookMap = {}
	for k,v in pairs(explorepathCfg) do
		if v.isMonster == 1 then
			local index = #self.hookMap+1
			self.hookMap[index] = {id = index,empty = true}
			local pos = {}
			pos.x = v.pos[1]
			pos.y = v.pos[2]
			self.hookMap[index].pos = pos
		end
	end

	local size = cc.Director:getInstance():getWinSize()
	self.mapbg = mapbg
    self:create()
    self.mapbg:scheduleUpdateWithPriorityLua(function (dt)
		self:update(dt)
	end, 0)

    --创建boss
    local i = 0
    local hookBoss = UserData:getUserObj():getHookBoss()
    for k,v in pairs(hookBoss) do
    	i = i + 1
    	self.boss[i] = hookboss.new(self.mapbg,k,v)
    end
end

function hookheromgr:create()

	--得到上次位置
	self.hero = {}
	local roleMap = RoleData:getRoleMap()
    for i=1,#roleMap do
    	local roleObj  = RoleData:getRoleByPos(i)
    	if roleObj and roleObj:getId() > 0 then
    		local heroid = roleObj:getId()
    		local heroname = roleObj:getName()
    		self.hero[i] = hookhero.new(heroid,i,self.mapbg,heroname)
    		self.hero[i]:born()
    	end
    end
end

--更换上阵武将时候调用
function hookheromgr:updateHero()

	local roleMap = RoleData:getRoleMap()
	for i=1,#roleMap do
    	local roleObj  = RoleData:getRoleByPos(i)
    	if roleObj and roleObj:getId() > 0 then
    		local heroid = roleObj:getId()
    		local heroname = roleObj:getName()
    		if self.hero[i] then
    			self.hero[i]:updateRole(heroid,i,heroname)
    		else
    			self.hero[i] = hookhero.new(heroid,i,self.mapbg,heroname)
    			self.hero[i]:born()
    		end
    	end
    end
end

function hookheromgr:update(dt)
	self.countime = self.countime + dt
	if self.countime > 1 then
		self.time = self.time + 1
		self.countime = 0

		for k,v in pairs(self.hero) do
			v:update()
		end
	end
end

function hookheromgr:updateHookBoss()
	local hookBoss = UserData:getUserObj():getHookBoss()
	local i = 0
    for k,v in pairs(hookBoss) do
    	i = i + 1
    	if self.boss[i] then
    		self.boss[i]:updateBoss(k,v)
    	else
    		self.boss[i] = hookboss.new(self.mapbg,k,v)
    	end
    end
end

function hookheromgr:ProcessHookBoss(msg)
	
	local hookBoss = UserData:getUserObj():getHookBoss()
	local i = 0
    for k,v in pairs(hookBoss) do
    	i = i + 1
    end
    local maxSysCont = GameData:getConfData("explorebase")['bossSysAmountLmint'].value
    if i >= maxSysCont then
    	return
    end
	UserData:getUserObj():updateHookBoss(msg.boss_birth)
	self:updateHookBoss()
end

function hookheromgr:createAniByName(name, plistRes, changeEquipObj)
	local jsonRes = "animation/" .. name .. "/" .. name
	plistRes = plistRes or jsonRes
	self:loadAnimationRes(plistRes, jsonRes)
	local ani = self:createArmature(name, changeEquipObj)
	return ani
end

function hookheromgr:loadAnimationRes(plistRes, jsonRes)
	self:loadPlist(plistRes)
	self:loadJson(jsonRes)
end

function hookheromgr:loadPlist(plistRes)
	if self.plistLoaded[plistRes] == nil then
		self.plistLoaded[plistRes] = true
		cc.SpriteFrameCache:getInstance():addSpriteFrames(plistRes .. ".plist")
	end
end

function hookheromgr:loadJson(jsonRes)
	if self.jsonLoaded[jsonRes] == nil then
		self.jsonLoaded[jsonRes] = true
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(jsonRes .. ".json")
	end
end

function hookheromgr:createArmature(name, changeEquipObj)
	local armature = ccs.Armature:create(name)
	GlobalApi:changeModelEquip(armature, name, changeEquipObj, 1)
    if targetPlatform == kTargetAndroid then
        ShaderMgr:setShaderForArmature(armature, "default_etc")
    end
    return armature
end

function hookheromgr:clearArmature()
	self.plistLoaded = {}
    if self.jsonLoaded then
	    for k, v in pairs(self.jsonLoaded) do
		    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(k .. ".json")
	    end
    end
	self.jsonLoaded = {}
end

function hookheromgr:createObjPool()
	local pools = {
		dataPools = {}
	}
	-- 弹出一个对象
	function pools:pop(key_)
		local dataPool = pools.dataPools[key_]
		if dataPool == nil then
		-- 无数据
			return nil
		end
		local obj = nil
		if dataPool.num > 0 then
			obj = table.remove(dataPool.data)
			dataPool.num = dataPool.num - 1
		end
		return obj
	end

	-- 弹出一个对象
	function pools:push(key_, obj_)
		local dataPool = pools.dataPools[key_]
		if dataPool==nil then
		-- 还没该类型受击特效的池，创建一个空池
			dataPool = {
				data = {},
				num = 0
			}
			--logger("datapools" ,pools.dataPools)
			--logger("key_" ,key_)
			pools.dataPools[key_] = dataPool
		end
		-- 放入数据对象到尾部
		table.insert(dataPool.data, obj_)
		dataPool.num = dataPool.num + 1
	end

	return pools
end

return hookheromgr



