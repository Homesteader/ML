local KabalaTreeExploreView = class("KabalaTreeExploreView", BaseLayer)
local KabalaTreeGridMap = import(".KabalaTreeGridMap")
local KabalaTreeNpc = import(".KabalaTreeNpc")
function KabalaTreeExploreView:ctor(pointId)
	self.super.ctor(self)

	self:initData(pointId)
	self:init("lua.uiconfig.kabalaTree.kabalaTreeExploreView")
end

function KabalaTreeExploreView:initData(pointId)
	
    self.pointId = pointId
     
end


function KabalaTreeExploreView:initUI(ui)
	self.super.initUI(self,ui)
	self.ui = ui
	self:showTopBar()

    --设置标题
    self.TextArea_title = TFDirector:getChildByPath(self.topLayer, 'TextArea_title')
    self.TextArea_title:setText("点击了ID："..self.pointId)

	self.Panel_root = TFDirector:getChildByPath(ui, "Panel_root")
    self.Panel_prefab = TFDirector:getChildByPath(ui,"Panel_prefab")
    
    self.Panel_treeExploreMap = TFDirector:getChildByPath(self.Panel_root, 'Panel_treeExploreMap')
    self.Label_gridName = TFDirector:getChildByPath(self.Panel_prefab, 'Label_gridName')

    self:generateMap()
    self:createNpc()
    
end

--创建格子地图
function KabalaTreeExploreView:generateMap()
    
    self.KabalaTreeGridMap = KabalaTreeGridMap:new()
    self.mapNode = self.KabalaTreeGridMap:generateMap(self.pointId)
    local layerId = KabalaTreeDataMgr:getMapParamLayerId(EC_KabalaTreeMapParamType.PARAMTYPE_GRID)
    self.Panel_treeExploreMap:addChild(self.mapNode,layerId)

    local gridDatas = KabalaTreeDataMgr:getGridData()
    for k,v in ipairs(gridDatas) do
        local text = self.Label_gridName:clone()
        text:setText(k)
        text:setPosition(v.centerPoint)
        self.Panel_treeExploreMap:addChild(text)
    end
end

--创建npc
function KabalaTreeExploreView:createNpc()

    self.KabalaTreeNpc = KabalaTreeNpc:new()
    self.NpcNode = self.KabalaTreeNpc:createNpc()
    local layerId = KabalaTreeDataMgr:getMapParamLayerId(EC_KabalaTreeMapParamType.PARAMTYPE_NPC)
    self.Panel_treeExploreMap:addChild(self.NpcNode,layerId)
    local position = KabalaTreeDataMgr:getNpcPosition()
    self.KabalaTreeNpc:setPosition(position)
end


function KabalaTreeExploreView:registerEvents()

	self:setBackBtnCallback(function ()
		AlertManager:close()
        local view = AlertManager:getLayer(-1)
        if view and view.__cname == "kabalaTreeMainView" then
            print("is kabalaTreeMainView")
        else
            Utils:openView("kabalaTree.kabalaTreeMainView")
        end
	end)

    self.Panel_treeExploreMap:addMEListener(TFWIDGET_TOUCHBEGAN, handler(self.clickPL, self));
end

function KabalaTreeExploreView:clickPL(touch,clickPos)
   
   clickPos = me.p(self.Panel_treeExploreMap:convertToNodeSpaceAR(clickPos))
   local gridId = KabalaTreeDataMgr:pointToGridId(clickPos)
   local npcGridId = KabalaTreeDataMgr:getNpcGridId()
   if gridId and  gridId ~= npcGridId then
        print("gridId",gridId)
        local result = KabalaTreeDataMgr:findPath(npcGridId,gridId)
        if not result then
            Utils:showTips("不能到达终点")
            return
        end
        self.KabalaTreeNpc:startSearch(gridId)
   end
end

return KabalaTreeExploreView