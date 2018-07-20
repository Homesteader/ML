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

    --按钮组
    self.Panel_func_btn = TFDirector:getChildByPath(self.Panel_root, "Panel_func_btn")
    self.Button_res_exchange = TFDirector:getChildByPath(self.Panel_func_btn, "Button_res_exchange")
    self.Button_cleantask = TFDirector:getChildByPath(self.Panel_func_btn, "Button_cleantask")
    self.Button_playhelp = TFDirector:getChildByPath(self.Panel_func_btn, "Button_playhelp")

    --罗盘
    self.Panel_luopan_touch= TFDirector:getChildByPath(self.Panel_root, "Image_luopan_bg")
    self.Image_luopan= TFDirector:getChildByPath(self.Panel_luopan_touch, "Image_luopan_bg")
    self.Panel_luopanItem = TFDirector:getChildByPath(self.Panel_prefab, "Panel_luopanItem")

    --质点
    self.Panel_pointItem = TFDirector:getChildByPath(self.Panel_prefab, "Panel_pointItem")
    self:updateScrollBtn()
    self:refreshView()
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

function KabalaTreeMainView:updateScrollBtn()
    
    --max:12 360/30
    self.btnInfo = {}
    for i=1,8 do
        local angle = 15 + (i-1)*30
        local x = 200*math.cos(math.pi*angle/180)
        local y = 200*math.sin(math.pi*angle/180)
        local btn = self.Panel_luopanItem:clone()
        btn:setPosition(ccp(x,y))
        self.Image_luopan:addChild(btn)
        self.btnInfo[i] = btn
    end
end

function KabalaTreeMainView:touchBegin(touch,touchPos)    
    self.touchBeginPos = touchPos
end


function KabalaTreeMainView:touchMoved(touch,touchPos)
    
    self.touchEndPos = touchPos
    local deltaxtemp = self.touchBeginPos.x - self.touchEndPos.x
    local deltax = self.touchBeginPos.x - self.touchEndPos.x
    local deltay = self.touchBeginPos.y - self.touchEndPos.y
    local delta =  math.abs(deltax)
    local angle = delta/360+1
    if deltaxtemp > 0  then
        angle = -math.abs(angle)
    end
    local newAngle =  self.Image_luopan:getRotation()+angle
    if newAngle < 0 then
        return
    end
    if newAngle > (#self.btnInfo-3)*30 then
        return
    end
    for i=1,8 do
        self.btnInfo[i]:setRotation(self.btnInfo[i]:getRotation()-angle)
    end
    self.Image_luopan:setRotation(self.Image_luopan:getRotation()+angle)
end

function KabalaTreeMainView:registerEvents()

    --[[self:setBackBtnCallback(function ()
        AlertManager:close()
        local view = AlertManager:getLayer(-1)
        if view and view.__cname == "FubenChapterView" then
            print("is FubenChapterView")
        else
            Utils:openView("fuben.FubenChapterView")
        end
    end)]]
    self.Panel_luopan_touch:setTouchEnabled(true)
    self.Panel_luopan_touch:addMEListener(TFWIDGET_TOUCHBEGAN, handler(self.touchBegin,self));
    self.Panel_luopan_touch:addMEListener(TFWIDGET_TOUCHMOVED, handler(self.touchMoved,self));

    --资源兑换
    self.Button_res_exchange:onClick(function ()
        Utils:showTips("资源兑换")
    end)

    --净化任务
    self.Button_cleantask:onClick(function ()
        Utils:showTips("净化任务")
    end)

    --玩法说明
    self.Button_playhelp:onClick(function ()
        local layer = require("lua.logic.common.HelpView"):new("玩法说明", "谁玩谁知道")
        AlertManager:addLayer(layer)
        AlertManager:show()
    end)
end


return KabalaTreeMainView