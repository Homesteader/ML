
local HookDetailUI = class("HookDetailUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function HookDetailUI:ctor(mosterLv)

	self.uiIndex = GAME_UI.UI_HOOK_DETAIL_UI
	self.monsterLv = mosterLv

end


function HookDetailUI:init()

	local bgImg = self.root:getChildByName("bg_img")
    local neiPl = bgImg:getChildByName('nei_pl')
    self:adaptUI(bgImg,neiPl)
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.neiBgImg = neiPl:getChildByName('nei_bg_img')
    local descTx = neiPl:getChildByName('desc_tx')
    local size = self.neiBgImg:getContentSize()
    local size1 = neiPl:getContentSize()
    
    descTx:setPosition(cc.p(size1.width/2,descTx:getPositionY()))
    descTx:setString(GlobalApi:getLocalStr_new('COMMON_STR_CONTINUE'))
    descTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
    

    local effect = GlobalApi:createLittleLossyAniByName("ui_bossjieshaojiemiantexiao")  
    effect:setScale(1.5)
    effect:setPosition(cc.p(winSize.width/2,winSize.height/2))
    effect:getAnimation():play('Animation1', -1, -1)
    bgImg:addChild(effect)

    neiPl:setScaleX(1)
    neiPl:setScaleY(0.05)
    neiPl:setVisible(false)
    local act1=cc.Sequence:create(cc.DelayTime:create(0.3), cc.Show:create(), cc.ScaleBy:create(0.5,1,20))
    local act2 = cc.DelayTime:create(0.1)
    local act3 = cc.CallFunc:create(function()
        descTx:setVisible(true)
    end)
    local act4 = cc.CallFunc:create(function()
        bgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                MainSceneMgr:hideHookDetailUI()
            end
        end)
    end)
    neiPl:runAction(cc.Sequence:create(act1,act2,act3,act4))
    self:update()
end

function HookDetailUI:update()
	
	local nameTx = self.neiBgImg:getChildByName("name_tx")
	nameTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX20"))

	local exploreMonster = GameData:getConfData("exploremonster")
	local lastMonsterCfg = exploreMonster[self.monsterLv-1]
	local exploreMonsterCfg = exploreMonster[self.monsterLv]
	local soldierCfg,modelConf = GlobalApi:getSoldierConf(exploreMonsterCfg.soldierId)
	local monsterimg = self.neiBgImg:getChildByName("role_img")
	monsterimg:loadTexture('uires/icon/soldier/'..modelConf.bodyIcon)

	local lvTx = self.neiBgImg:getChildByName("lv_tx")
	lvTx:setString("Lv."..self.monsterLv)
	
	local explorebaseCfg = GameData:getConfData("explorebase")
	local existTime = explorebaseCfg['ExistTime'].value
	local restTime = explorebaseCfg['RestTime'].value
	local minKillCount = explorebaseCfg['OnceKillMin'].value
	local maxKillCount = explorebaseCfg['OnceKillMax'].value

	local intervaTime = existTime+ restTime/(minKillCount+maxKillCount)*2
	local exp = math.floor(3600/intervaTime * exploreMonsterCfg.singleExp)
	local earn_tx = self.neiBgImg:getChildByName("earn_tx")
	earn_tx:setString(string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX3"),exp))

	--有增长
	local lastExp = math.floor(3600/intervaTime * lastMonsterCfg.singleExp)
	if exp > lastExp then
		earn_tx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
	end

	--显示奖励
	for i=1,6 do 		
		local itembg = self.neiBgImg:getChildByName("item_bg"..i)
		local item = itembg:getChildByName("item")
		local lockImg = itembg:getChildByName("lock")
		local displayobj = DisplayData:getDisplayObj(exploreMonsterCfg["award"..i][1])
		if displayobj then
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,displayobj,item)  
			local openLv = explorebaseCfg["LootLevel"..i].value
			lockImg:setVisible(self.monsterLv<openLv)
			local str = self.monsterLv>=openLv and "+"..exploreMonsterCfg["improve"..i].."%" or "Lv."..openLv
			tab.lvTx:setString(str)
			itembg:setVisible(true)
			tab.awardBgImg:setPosition(cc.p(47,47))

			if exploreMonsterCfg["improve"..i] > lastMonsterCfg["improve"..i] and self.monsterLv>=openLv then
				tab.lvTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
			end
		else
			itembg:setVisible(false)
		end
	end
end

return HookDetailUI