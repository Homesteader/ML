local ClassEquipSelectCell = require("script/app/ui/equip/equipselectcell")

local EquipSelectUI = class("EquipSelectUI", BaseUI)
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")

local function sortByQuality(arr)
    table.sort(arr, function (a, b)
        local value1 = a:getAllBaseAttr()
        local value2 = b:getAllBaseAttr()
        if value1 == value2 then
            local q1 = a:getQuality()
            local q2 = b:getQuality()
            if q1 == q2 then
                local id1 = a:getId()
                local id2 = b:getId()
                return id1 > id2
            else
                return q1 > q2
            end
        else
            return value1 > value2
        end
    end)
end

-- selectEquipArr: 已经选择了的装备
-- equipType: 1-6 对应6个部位，0表示选择全部的装备
function EquipSelectUI:ctor(roleobj,selectEquipArr,equipType)
    self.uiIndex = GAME_UI.UI_EQUIPSELECT
    self.selectEquipArr = selectEquipArr
    self.equipType = equipType
    self.roleobj = roleobj
end

function EquipSelectUI:init()

    local equipSelectBgImg = self.root:getChildByName("equip_select_bg_img")
    local equipSelectImg = equipSelectBgImg:getChildByName("equip_select_img")
    self.panel = equipSelectImg
    self:adaptUI(equipSelectBgImg, equipSelectImg)
    local bgimg1 = equipSelectImg:getChildByName('bg_img1')

    local titletx = bgimg1:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr_new('ROLE_EQUIP_SELECT_TITLE1'))

    local closeBtn = bgimg1:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)


    local equipedBg = bgimg1:getChildByName("mine_bg")

    local svBg = bgimg1:getChildByName("sv_bg")
    local listview = svBg:getChildByName("equip_sv")  -- 其实是scrollview，这里难得改名字了
    listview:setScrollBarEnabled(false)
    self.listview = listview
    local svSize = listview:getContentSize()
    self.posY = self.listview:getPositionY()

    self.svSize = svSize -- 最原始的大小

    self.noequipimg = bgimg1:getChildByName('noequipimg')
    local noTx = self.noequipimg:getChildByName("text")
    noTx:setString(GlobalApi:getLocalStr_new("ROLE_EQUIP_SELECT_INFO1"))

    self.equips = {}
    local equipNum = 0
    local equipMap = BagData:getEquipMapByType(self.equipType)
    for k, v in pairs(equipMap) do
        local belongObj = v:getbelongObj()
        if not belongObj then
            table.insert(self.equips, v)
            equipNum = equipNum + 1
        end
    end

    local equipIndex = next(self.selectEquipArr)
    if equipIndex then -- 已经装备了一件装备
        local function callCloseFunc ()
            self:hideUI()
        end
        local equipObj = self.selectEquipArr[equipIndex]
        local equipedCell = ClassEquipSelectCell.new(self.roleobj,0,svSize.width, equipObj, false,false,callCloseFunc)
        local panel = equipedCell:getPanel()
        local size = equipedBg:getContentSize()
        panel:setPosition(cc.p(size.width/2,size.height/2))
        equipedBg:addChild(panel)
    end

    local offsetH = 0
    self.listview:setContentSize(cc.size(svSize.width,svSize.height - offsetH))
    self.listview:setPositionY(self.posY)

    self.viewSize = self.listview:getContentSize() -- 可视区域的大小
    sortByQuality(self.equips)
    if equipNum > 0 then
        self:initListView()
        self.noequipimg:setVisible(false)
    else
        self.noequipimg:setVisible(true)
    end

end

function EquipSelectUI:initListView()

    self.cellSpace = 4
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.equips
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace
    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    ScrollViewGeneral.new(self.listview,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback)

end


function EquipSelectUI:initItemData(index)
    if self.equips[index] then
        local equips = self.equips
        local equipObj = equips[index]

        local w = self.viewSize.width-10
        local h = 110
        
        self.allHeight = h + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w

        table.insert(self.cellsData,tempCellData)
    end
end

function EquipSelectUI:addItem(tempCellData,widgetItem)
    if self.equips[tempCellData.index] then
        local equips = self.equips
        local index = tempCellData.index

        local function callCloseFunc ()
            self:hideUI()
        end
        local cell = ClassEquipSelectCell.new(self.roleobj,index,self.viewSize.width, equips[index], selectedFlag,true,callCloseFunc)

        local w = tempCellData.w
        local h = tempCellData.h

        widgetItem:addChild(cell:getPanel())
        cell:getPanel():setPosition(cc.p(w*0.5+5,h*0.5))
    end
end

return EquipSelectUI