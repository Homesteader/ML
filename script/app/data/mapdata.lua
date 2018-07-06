local ClassMapObj  =require('script/app/obj/mapobj')

cc.exports.MapData = {
	maxProgress = nil,
	currProgress = nil,
	data = {},
    fightedCustoms = {0,0,0},                                --普通,精英,恶魔分别打倒了多少关
}

function MapData:removeAllData()
    self.maxProgress = nil
    self.currProgress = nil
    self.data = {}
end

function MapData:createAllCity()
	local conf = GameData:getConfData("custom")
	for i=1,#conf do
		local mapObj = ClassMapObj.new(conf[i])
		self.data[i] = mapObj
	end
end

function MapData:initWithData(mapData)
    self:createAllCity()
    self.maxProgress = mapData.max_progress
    self.currProgress = mapData.progress
    if mapData.max_progress == mapData.progress then
       self.currProgress = mapData.progress
    else
        self.currProgress = mapData.progress + 1
    end
    for k, v in pairs(mapData.city) do
        if self.data[tonumber(k)] then
            self.data[tonumber(k)]:setCityData(v)
            for i = 1,MapType.hard do
                if v[tostring(i)].star ~= 0 then
                    local maxfighted = self.fightedCustoms[i]
                    if not maxfighted then
                        self.fightedCustoms[i] = tonumber(k)
                    else
                        if maxfighted < tonumber(k) then
                            self.fightedCustoms[i] = tonumber(k)
                        end
                    end
                end
            end
        end
    end

end

--得到各个种类地图应该打的关卡
function MapData:getCurProgress(mapType)

    mapType = mapType or MapType.normal
    local fighted = self:getFightedCustomsByType(mapType)
    local showAttackCutoms = fighted + 1
    if showAttackCutoms >= self.maxProgress then
        showAttackCutoms = self.maxProgress
    end
    return showAttackCutoms
end

--得到各个种类地图已到关卡
function MapData:getFightedCustomsByType(mapType)

    if not self.fightedCustoms[mapType] then
        return 0
    end
    return self.fightedCustoms[mapType]
end

--设置地图已通过的最大关卡
function MapData:setMaxFightedCustoms(mapType,customsId)

    local fightedMax = self.fightedCustoms[mapType]
    if not fightedMax then
        self.fightedCustoms[mapType] = customsId
    end
    if fightedMax < customsId then
        fightedMax = customsId
    end
    self.fightedCustoms[mapType] = fightedMax
end

function MapData:setCurrProgress(currProgress)
    self.currProgress = currProgress
end

--------------------------废弃接口--------------------
function MapData:getMaxStar()
    return 0
end
