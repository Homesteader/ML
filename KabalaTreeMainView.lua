local KabalaTreeMainView = class("KabalaTreeMainView", BaseLayer)

function KabalaTreeMainView:ctor()
	self.super.ctor(self)
	self:initData()
	self:init("lua.uiconfig.kabalaTree.kabalaTreeMainView")
end

function KabalaTreeMainView:initData()
	self.pointItem_ = {}
end


function KabalaTreeMainView:initUI(ui)
	self.super.initUI(self,ui)
	self.ui = ui
	self:showTopBar()

	self.Panel_root = TFDirector:getChildByPath(ui, "Panel_root")
    self.Panel_prefab = TFDirector:getChildByPath(ui, "Panel_prefab"):hide()

    self.Panel_site = {}
    local ScrollView_point = TFDirector:getChildByPath(self.Panel_root, "ScrollView_point")
    local Image_diban = TFDirector:getChildByPath(ScrollView_point, "Image_diban")
    for i=1, 10 do
    	self.Panel_site[i] = TFDirector:getChildByPath(Image_diban, "Panel_site_"..i)
    	self.Panel_site[i]:setBackGroundColorType(0)
    end

    --滚动按钮组
    self.ScrollView_ScrollBtnPL = TFDirector:getChildByPath(ui, "ScrollView_ScrollBtnPL")
    local item = TFDirector:getChildByPath(self.Panel_prefab, "Button_ScrollBtnPrefab")
    local params  = {
        upItem = item,
        downItem = item,
        selItem = item,
        offsetX = 55,
        size = self.ScrollView_ScrollBtnPL:Size(),
        cellCount = 8,
        isFlippingX = true,
    }
    local ScrollMenu_chapter = ScrollMenu:create(params)
    self.ScrollView_ScrollBtnPL:getParent():addChild(ScrollMenu_chapter, 1)
    ScrollMenu_chapter:setContentPosition(self.ScrollView_ScrollBtnPL:getPosition())

    self.Panel_pointItem = TFDirector:getChildByPath(self.Panel_prefab, "Panel_pointItem")

    self:refreshView()
end


function KabalaTreeMainView:updateScrollBtn()
end

function KabalaTreeMainView:onScrollMenuSelect()
end

function KabalaTreeMainView:refreshView()

	for k, v in pairs(self.Panel_site) do
        local Panel_pointItem = self:addPointItem(k)
        self:updatePointItem(k)
        Panel_pointItem:Pos(0, 0):AddTo(v)
    end

end

function KabalaTreeMainView:addPointItem(pointId)
    local Panel_pointItem = self.Panel_pointItem:clone()
    local item = {}
    item.root = Panel_pointItem
    item.Image_di = TFDirector:getChildByPath(item.root, "Image_di")
    item.Image_select = TFDirector:getChildByPath(item.root, "Image_select")
    item.Image_frameLight = TFDirector:getChildByPath(item.root, "Image_frameLight")
    item.Image_frameGray = TFDirector:getChildByPath(item.root, "Image_frameGray")
    item.Image_icon = TFDirector:getChildByPath(item.root, "Image_icon")
    item.Image_enName = TFDirector:getChildByPath(item.root, "Image_enName")
    item.Label_name = TFDirector:getChildByPath(item.root, "Label_name")
    item.Label_nameGray = TFDirector:getChildByPath(item.root, "Label_nameGray")
    item.Label_receive = TFDirector:getChildByPath(item.root, "Label_receive")
    item.LoadingBar_countDown = TFDirector:getChildByPath(item.root, "LoadingBar_countDown")
    item.Spine_redTip = TFDirector:getChildByPath(item.root, "Spine_redTip")
    self.pointItem_[pointId] = item
    return Panel_pointItem
end

function KabalaTreeMainView:updatePointItem(pointId)

    local item = self.pointItem_[pointId]
    item.root:onClick(function()
        Utils:openView("kabalaTree.kabalaTreeExploreView",pointId)
    end)
end

function KabalaTreeMainView:registerEvents()

	self:setBackBtnCallback(function ()
		AlertManager:close()
		local view = AlertManager:getLayer(-1)
		if view and view.__cname == "FubenChapterView" then
			print("is FubenChapterView")
		else
        	Utils:openView("fuben.FubenChapterView")
        end
	end)

end

return KabalaTreeMainView