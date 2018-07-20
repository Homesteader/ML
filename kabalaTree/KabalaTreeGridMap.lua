local KabalaTreeGridMap = class("KabalaTreeGridMap")
function KabalaTreeGridMap:ctor()
	
end

function KabalaTreeGridMap:generateMap(mapId,playerPos,scale)

    self.playerPos = playerPos

	local tileMapRes = KabalaTreeDataMgr:getTileMapRes(mapId)
    if not tileMapRes then
        return
    end

    self.tileMap = TMXTiledMap:create(tileMapRes)    
    if not self.tileMap then
        return
    end
    scale = scale or 1
    self.tileMap:setAnchorPoint(me.p(0.5,0.5))
    KabalaTreeDataMgr:initTileMapData(self.tileMap)
    KabalaTreeDataMgr:setMapScale(scale)
    KabalaTreeDataMgr:setGridMapLimit()

    self:initTiled()
    return self.tileMap
end

--隐藏出生点之外的格子(打开的服务器会告知)
function KabalaTreeGridMap:initTiled()

    local layer = self.tileMap:getLayer("ground")
    local tileXCount,tileYCount = KabalaTreeDataMgr:getTileXYCount()
    for i=0,tileXCount-1 do
        for j=0,tileYCount-1 do
            local tileSprite = layer:getTileAt(ccp(i,j))
            if tileSprite then
                local gid = layer:getTileGIDAt(ccp(i,j))                
                local opacity = self:isInAroundTab(i,j)
                tileSprite:setOpacity(opacity)
                if opacity == 0 then
                    local posY = tileSprite:getPositionY()
                    tileSprite:setPositionY(posY-80)
                end
            end
        end
    end
end

function KabalaTreeGridMap:isInAroundTab(m,n)

    if self.playerPos.x == m and self.playerPos.y == n then
        return 255
    end

    local aroundtiled = KabalaTreeDataMgr:getAroundTileds(self.playerPos)
    for k,v in ipairs(aroundtiled) do        
        if v.x == m and v.y == n then
            return 255
        end
    end

    return 0
end

return KabalaTreeGridMap