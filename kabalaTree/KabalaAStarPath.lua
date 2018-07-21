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

    local reversePath = {}       
    reversePath[1] = self.closeTable[#self.closeTable]
    local index = 1
    local p = self.closeTable[#self.closeTable].parent
    for i=#self.closeTable-1,1,-1 do
        if p.x == self.closeTable[i].x and p.y == self.closeTable[i].y then
            index = index + 1
            p = self.closeTable[i].parent
            reversePath[index] = self.closeTable[i]
        end
    end

    self.path = {}
    for i = 1, #reversePath do
        local key = #reversePath
        self.path[i] = table.remove(reversePath)
    end

    return self.path
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
    local minTiled,index
    for k,v in ipairs(self.openTable) do
        if v.valueF < minF then
            minF = v.valueF
            minTiled = v
            index = k
        end
    end

    return minTiled,k
end

function KabalaAStarPath:isExitInTable(tiledTable,tiled)

    for i=1,#tiledTable do
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
    table.insert(self.openTable,{x = self.srcTiled.x,y = self.srcTiled.y,valueG = 0, valueH = 0, valueF = 0, parent = nil})

    while next(self.openTable) do

        local curTiled = self:getMinFTiled()
        table.insert(self.closeTable,curTiled)
        local index = self:isExitInTable(self.openTable,curTiled)
        table.remove(self.openTable,index)

        local aroundTab = self:getAroundTileds(ccp(curTiled.x,curTiled.y))
        for k,v in ipairs(aroundTab) do
            if self:equals(v,self.desTiled) then
                table.insert(self.closeTable,{x = self.desTiled.x,y = self.desTiled.y, parent = curTiled})           
                return true
            end

            --判断是否在closeTab
            if not self:isExitInTable(self.closeTable,v) then

                local valueG = curTiled.valueG + self:calcValueDis(curTiled, v)
                local valueH = self:calcValueDis(v,self.desTiled)
                local valueF = valueG + valueH

                local index = self:isExitInTable(self.openTable,v)
                if not index then
                    local tiledInfo = {x = v.x,y = v.y,valueG = valueG, valueH = valueH, valueF = valueF, parent = curTiled}
                    table.insert(self.openTable,tiledInfo)
                else
                    local tiledInOpenTab = self.openTable[index]                    
                    if valueG < tiledInOpenTab.valueG then
                        tiledInOpenTab.parent = curTiled
                        tiledInOpenTab.valueG = valueG                        
                    end
                end
            end
        end
    end
    return false
end

return KabalaAStarPath