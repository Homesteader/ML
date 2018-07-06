local GuideFirstUI = class("GuideFirstUI", BaseUI)

function GuideFirstUI:ctor()
    self.uiIndex = GAME_UI.UI_GUIDEFIRST
end

function GuideFirstUI:init()
    local guidefirstBgImg = self.root:getChildByName("guidefirst_bg_img")
    local guidefirstImg = guidefirstBgImg:getChildByName("guidefirst_img")
    self:adaptUI(guidefirstBgImg, guidefirstImg)
    local shipBtn = guidefirstImg:getChildByName("ship_btn")
    shipBtn:setTouchEnabled(false)
    UIManager:getSidebar():setFrameBtnsVisible(false)
end

function GuideFirstUI:showShip()
    local guidefirstBgImg = self.root:getChildByName("guidefirst_bg_img")
    local guidefirstImg = guidefirstBgImg:getChildByName("guidefirst_img")
    local shipBtn = guidefirstImg:getChildByName("ship_btn")
    shipBtn:setTouchEnabled(true)
    shipBtn:addClickEventListener(function ()
        local obj = {
            request = "guide_guanyu"
        }
        MessageMgr:sendPost("mark_guide", "user", json.encode(obj),function (jsonObj)
            if jsonObj.code == 0 then
                GlobalApi:parseAwardData(jsonObj.data.awards)
                TavernMgr:showTavernAnimate(jsonObj.data.awards, function ()
                    TavernMgr:hideTavernAnimate()
                end, 4)
            end
        end)
    end)
    GuideMgr:finishCurrGuide()
end

function GuideFirstUI:goNextScene()
    UIManager:runLoadingAction(true, function ()
        GuideMgr:finishCurrGuide()
    end)
end

return GuideFirstUI