local KabalaAStarPath = class("KabalaAStarPath")
function KabalaAStarPath:ctor()

end

function KabalaAStarPath:initData(srcTiled,desTiled)

    self.srcTiled = srcTiled
    self.desTiled = desTiled

    self.openTable = {}
    self.closeTable = {}

    --以后可能会有横向和纵向移动的消耗，可以在这个修改
    self.perDistanceM,self.perDistanceN = 1,1
end

function KabalaAStarPath:getPath()

    print("getPathgetPathgetPathgetPathgetPathgetPath")
    --[[for k,v in pairs(self.closeTable) do
        print(k,v.x,v.y)
    end
    print("******************************************")
    local path = {}
    local index = 1
    while(true) do
        local cur = self.closeTable[index]
        table.insert(path,cur)
        if index == #self.closeTable then
            break
        end
        print("index",index)
        for i=index + 1,#self.closeTable do
            local around = self:getAroundTileds(cur)
            local inaround = self:isExitInTable(around,self.closeTable[i])
            if inaround then
                index = i
            end
        end
    end]]
    return self.closeTable
end

--得到周围格子
function KabalaAStarPath:getAroundTileds(tiledPos)

    local around = {}
    local aroundTileds = {}
    aroundTileds[1] = ccp(tiledPos.x-1,tiledPos.y)
    aroundTileds[2] = ccp(tiledPos.x,tiledPos.y-1)
    aroundTileds[3] = ccp(tiledPos.x,tiledPos.y+1)
    aroundTileds[4] = ccp(tiledPos.x+1,tiledPos.y)

    for i=1,4 do
        local aroundPos = aroundTileds[i] 
        local Nil = KabalaTreeDataMgr:isNilTiled(aroundPos)
        if not Nil then
            --local isObstacle = KabalaTreeDataMgr:isObstacle(aroundPos)
            --if not isObstacle then
                table.insert(around,aroundPos)
            --end
        end
    end
    return around

end

function KabalaAStarPath:calcValueH(point,desTiled)

    local distanceX = math.abs(desTiled.x - point.x)
    local distanceY = math.abs(desTiled.y - point.y)

    return distanceX + distanceY
end

function KabalaAStarPath:calcValueDis(point,desTiled)

    local distanceX = math.abs(desTiled.x - point.x)
    local distanceY = math.abs(desTiled.y - point.y)

    return distanceX + distanceY
end

function KabalaAStarPath:getMinFTiled(lastTiled)

    local minF = math.huge
    local minTiled
    for k,v in ipairs(self.openTable) do
        if v.valueF < minF then
            minF = v.valueF
            minTiled = v
        end
    end

    return minTiled
end

function KabalaAStarPath:isExitInTable(tiledTable,tiled)

    for i=#tiledTable,1,-1 do
        if tiled.x == tiledTable[i].x and tiled.y == tiledTable[i].y then
            return i
        end
    end
    return nil
end

function KabalaAStarPath:equals(tiled1,tiled2)

    if tiled1.x == tiled2.x and tiled1.y == tiled2.y then
        return true
    end
    return false
end


function KabalaAStarPath:findAStarPath()

    self.openTable = {}
    self.closeTable = {}
    local success = false
    local lastTile
    table.insert(self.openTable,{x = self.srcTiled.x,y = self.srcTiled.y,valueG = 0, valueH = 0, valueF = 0, parent = nil})
    while next(self.openTable) do
        local curTiled = self:getMinFTiled()
        table.insert(self.closeTable,curTiled)
        local index = self:isExitInTable(self.openTable,curTiled)
        table.remove(self.openTable,index)
        local aroundTab = self:getAroundTileds(ccp(curTiled.x,curTiled.y))
        for k,v in ipairs(aroundTab) do
            if self:equals(v,self.desTiled) then
                table.insert(self.closeTable,self.desTiled)           
                return true
            end

            --判断是否在closeTab
            if not self:isExitInTable(self.closeTable,v) then

                local index = self:isExitInTable(self.openTable,v)
                if not index then

                    local valueG = self:calcValueDis(curTiled,self.srcTiled)
                    local valueH = self:calcValueH(v,self.desTiled)
                    local valueF = valueG + valueH
                    local tiledInfo = {x = v.x,y = v.y,valueG = valueG, valueH = valueH, valueF = valueF, parent = curTiled}
                    table.insert(self.openTable,tiledInfo)
                else
                    local tiledInOpenTab = self.openTable[index]
                    local tempG = self:calcValueDis(curTiled, tiledInOpenTab) + curTiled.valueG
                    if tempG <= tiledInOpenTab.valueG then
                        tiledInOpenTab.parent = curTiled
                        tiledInOpenTab.valueG = tempG
                        tiledInOpenTab.valueF = tiledInOpenTab.valueH + tempG
                    end
                end
            end
        end
    end
    return false
end

return KabalaAStarPath