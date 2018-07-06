local GemSelectUI = class("GemSelectUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local function sortFn(a, b)
    local l1 = a:getLevel()
    local l2 = b:getLevel()
    local id1 = a:getId()
    local id2 = b:getId()
    if level1 == level2 then
        if l1 == l2 then
            return id1 < id2
        else
            return l1 > l2
        end
    else
        return level1 > level2
    end

end
function GemSelectUI:ctor(slotIndex, rolePosId, partObj, callback)
    self.uiIndex = GAME_UI.UI_GEMSELECT
    self.callback = callback
    self.slotIndex = slotIndex
    self.partObj = partObj
    self.rolePosId = rolePosId
end

function GemSelectUI:init()

    local bg_img = self.root:getChildByName("bg_img")
    local bg = bg_img:getChildByName("bg")
    self:adaptUI(bg_img, bg)

    local titleTx = bg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr_new('GEM_SELECT_TITLE'))

    local closeBtn = bg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    
    local nogemimg = bg:getChildByName('null_bg')
    local noText = nogemimg:getChildByName('text')
    noText:setString(GlobalApi:getLocalStr_new("GEM_SELECT_INFO1"))
    local infoTx = bg:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr_new("GEM_SELECT_INFO2"))

    local gemSv = bg:getChildByName("gem_sv")
    gemSv:setScrollBarEnabled(false)

    local allGems = BagData:getAllGems()
    local partGems = self.partObj:getGems()
    local partId = self.partObj:getPartId()
    local showedGemNum = 0
    local currGemNum = 0
    local innerHeight = 0
    local showedGemArr = {}

    local partBaseConf = GameData:getConfData("partbase")
    local gemType = partBaseConf[partId].embedGemType

    for k, v in pairs(allGems) do
        if k == gemType then
            for k2, v2 in pairs(v) do
                table.insert(showedGemArr, v2)
                showedGemNum = showedGemNum + 1
            end
        end
    end
    nogemimg:setVisible(showedGemNum==0)
    infoTx:setVisible(showedGemNum~=0)

    table.sort( showedGemArr, sortFn )
    local cellItem = {}
    for i=1,#showedGemArr do 

        local itemBg = gemSv:getChildByTag(i+100)
        if not cell then
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
            gemSv:addChild(tab.awardBgImg,1,i+100)
            cellItem[i] = tab
            tab.awardBgImg:setScale(0.8)
            tab.awardBgImg:setAnchorPoint(cc.p(0,0))
            tab.awardBgImg:setSwallowTouches(false)
        end

        ClassItemCell:updateItem(cellItem[i],showedGemArr[i],1)

        cellItem[i].awardBgImg:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local args = {
                    pos = self.rolePosId,
                    part_pos = partId,
                    gem_pos = self.slotIndex,
                    gem_id = showedGemArr[i]:getId()
                }
                MessageMgr:sendPost("embed_gem", "parttrain", json.encode(args), function (jsonObj)
                    print(json.encode(jsonObj))
                    local code = jsonObj.code
                    if code == 0 then
                        
                        self.partObj:putOnGem(self.slotIndex, showedGemArr[i]:getId())
                        if self.callback then
                            self.callback()
                        end

                        local costs = jsonObj.data.costs
                        GlobalApi:parseAwardData(costs)

                        self:hideUI()
                    end
                end)
            end
        end)
    end

    local size1 = cc.size(75.2,75.2)
    local count = #showedGemArr
    local size = gemSv:getContentSize()
    local vertiIndex = 0
    local space = 10
    if count > 0 then
        local verticalCnt = math.ceil(#showedGemArr/4)
        if verticalCnt * size1.height > size.height then
            gemSv:setInnerContainerSize(cc.size(size.width,verticalCnt * size1.height+(verticalCnt-1)*space+10))
        else
            gemSv:setInnerContainerSize(size)
        end
    
        local function getPos(i)
            local size2 = gemSv:getInnerContainerSize()  
            if i%4 == 1 then
                vertiIndex = vertiIndex + 1
            end
            local horiIndex = (i-1)%4+1
            local posY = 10 + (size1.height+space)*(vertiIndex) 
            return cc.p((size1.width+5)*(horiIndex-1)+10,size2.height-posY)          
        end
        for i=1,count do
            local cell = gemSv:getChildByTag(i + 100)
            if cell then
                cell:setPosition(getPos(i))
            end
        end
    end
end

return GemSelectUI