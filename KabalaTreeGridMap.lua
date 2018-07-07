local KabalaTreeGridMap = class("KabalaTreeGridMap")
function KabalaTreeGridMap:ctor()
	print("ctor ctor ctor")
end


function KabalaTreeGridMap:generateMap(mapId)

	self.horizontalCnt,self.verticalCnt = KabalaTreeDataMgr:getGirdMapSize(mapId)
	self.gridH,self.gridW = KabalaTreeDataMgr:getGirdSize()
	KabalaTreeDataMgr:init()
	self.drawNode = TFDrawNode:create()
	self:paintGridMap()
	return self.drawNode
end

function KabalaTreeGridMap:getPolygonPos(centerPoint)

    local points = {}
    points[1] = ccp(centerPoint.x - self.gridW/2,centerPoint.y)			--左
    points[2] = ccp(centerPoint.x,centerPoint.y + self.gridH/2)			--上
    points[3] = ccp(centerPoint.x + self.gridW/2,centerPoint.y)			--右
    points[4] = ccp(centerPoint.x,centerPoint.y - self.gridH/2)			--下

    return points
end

function KabalaTreeGridMap:getFirstGirdPos()
    local posX = -self.gridW/2 - (self.horizontalCnt/2-1)*self.gridW
    local posY = 0
    return ccp(posX,posY)
end

function KabalaTreeGridMap:paintGridByCenterPos(gridId,centerPoint,gridPosij)

    local points = self:getPolygonPos(centerPoint)
    for i = 1,#points do
        local srcPoint = points[i]
        local desPoint = i == #points and points[1] or points[i+1]
        self.drawNode:drawLine(srcPoint,desPoint,me.c4f(0,0,0,0.1))
    end

    local dataInfo = {}
    dataInfo.gridId = gridId
    dataInfo.centerPoint = centerPoint
    dataInfo.borderPoints = points
    dataInfo.gridPosij = gridPosij
    KabalaTreeDataMgr:setGridData(gridId,dataInfo)
end

function KabalaTreeGridMap:paintGridMap()

    local gridId = 0
    local firstGirdPos = self:getFirstGirdPos()
    for i = 1,self.horizontalCnt do
        for j = 1,self.verticalCnt do

            local startPosX,startPosY
            if i==1 and j == 1 then
                startPosX,startPosY = firstGirdPos.x,firstGirdPos.y
            else
                startPosX = firstGirdPos.x + (j - 1)*self.gridW/2
                startPosY = firstGirdPos.y - (j - 1)*self.gridH/2
            end
            local posX = startPosX + (i - 1)*self.gridW/2
            local posY = startPosY + (i - 1)*self.gridH/2
            gridId = gridId + 1

            self:paintGridByCenterPos(gridId,ccp(posX,posY),ccp(i,j))

            if (i == 1 and j == 1) or  (i == 1 and j == self.verticalCnt) or
               (i == self.horizontalCnt and j == 1) or  (i == i == self.horizontalCnt and j == self.verticalCnt)	then
               KabalaTreeDataMgr:setGridMapBorderPoints(ccp(posX,posY))
            end
        end
    end

end
return KabalaTreeGridMap