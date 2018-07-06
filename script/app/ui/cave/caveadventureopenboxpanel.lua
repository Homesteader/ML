-- 文件：山洞探险开宝箱界面
-- 创建：zzx
-- 日期：2017-12-11

local CaveAdventureOpenBoxPanelUI  	= class("CaveAdventureOpenBoxPanelUI", BaseUI)
local ClassItemCell 				= require('script/app/global/itemcell')

function CaveAdventureOpenBoxPanelUI:ctor(caveData_)
    self.uiIndex                = GAME_UI.UI_CAVE_ADVENTURE_OPEN_BOX_PANEL
    self._caveData              = caveData_
end

function CaveAdventureOpenBoxPanelUI:init()
	local bg_img        = self.root:getChildByName("bg_img")
    local alpha_img     = bg_img:getChildByName("alpha_img")

    self:adaptUI(bg_img, alpha_img)

    local main_img      = alpha_img:getChildByName("main_img")
    
    local close_btn     = main_img:getChildByName("close_btn")

    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CaveAdventureMgr:hideOpenBoxUI()
        end
    end)

    local title_tx      = main_img:getChildByName('title_tx')
    title_tx:setString(GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_3'))

    local infoBg 		= main_img:getChildByName('info_bg')

    local noticeTx 		= infoBg:getChildByName('notice_tx')
    noticeTx:setString(GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_4'))

    local rewardSvBg    = infoBg:getChildByName('rewards_sv_bg')
    local rListView 	= rewardSvBg:getChildByName('rewards_list_view')

    rListView:setScrollBarEnabled(false)

    self._infoBg 		= infoBg
    self._rListView 	= rListView

    local leftBtn 		= infoBg:getChildByName('left_btn')
    local rightBtn 		= infoBg:getChildByName('right_btn')

    leftBtn:addClickEventListener(function ()
    	AudioMgr.PlayAudio(11)
    	self:onChangeSelect(-1)
    end)
    rightBtn:addClickEventListener(function ()
    	AudioMgr.PlayAudio(11)
    	self:onChangeSelect(1)
    end)

    local cancelBtn 	= main_img:getChildByName('cancel_btn')
    local cancelBtnTx 	= cancelBtn:getChildByName('cancel_tx')

    local okBtn 		= main_img:getChildByName('ok_btn')
    local okBtnTx 		= okBtn:getChildByName('ok_tx')

    cancelBtnTx:setString( GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_10') )
    okBtnTx:setString( GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_9') )

    cancelBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CaveAdventureMgr:hideOpenBoxUI()
        end
    end)

    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:doOpenBox()
        end
    end)

    self._leftBtn 		= leftBtn
    self._rightBtn 		= rightBtn

    self._boxOpenConf 	= GameData:getConfData('customcavesuperbox')

    self._typeArr 		= {'violence', 'money', 'key'}
    self._curIndex 		= 1

    self:updateListView()
    self:updateCurPage()
    self:updatePageBtn()
end

function CaveAdventureOpenBoxPanelUI:onShow()
	
end

function CaveAdventureOpenBoxPanelUI:onHide()
	self._typeArr 		= nil
end

function CaveAdventureOpenBoxPanelUI:updateListView()
	local conf  		= GameData:getConfData('customcaveaward')
	local joinLv 		= self._caveData['cave']['level']
	local confData 		= conf[tonumber(joinLv)]

	local dropId 		= confData['superLootID']
	local superAward 	= confData['superAward']

	local allAwardsArr  = {}

	-- 极品
	table.insert(allAwardsArr, superAward[1])

	local dropData      = GameData:getConfData("drop")
    local dropConf      = dropData[tonumber(dropId)]

    -- 必得
    local fixedAwards 	= dropConf['fixed']

    if fixedAwards ~= '0' and #fixedAwards > 0 then
    	table.insert(allAwardsArr, fixedAwards[1])
    end

    -- 可能获得
    for i = 1, 15 do
        if dropConf['award' .. i] ~= '0' and #dropConf['award' .. i] > 0 then
            table.insert(allAwardsArr, dropConf['award' .. i][1])
        end
    end

    local displayAwards 	= DisplayData:getDisplayObjs(allAwardsArr)

    local itemWidth 		= 94 * 0.8
    local horOffset 		= 10
    local leftPos 			= 40
    local awardNum 			= #displayAwards
    local allWidth 			= awardNum * itemWidth + (awardNum - 1) * horOffset + 10

    local horSvContentSize 	= self._rListView:getContentSize()

    if allWidth > horSvContentSize.width then
        self._rListView:setInnerContainerSize(cc.size(allWidth,horSvContentSize.height))
    else
        self._rListView:setInnerContainerSize(horSvContentSize)
    end

    for i, v in pairs(displayAwards) do
		local cell 			= ClassItemCell:create(ITEM_CELL_TYPE.ITEM, v, self._rListView)

        cell.awardBgImg:setScale(0.8)
        cell.awardBgImg:setPosition(cc.p(leftPos + (i-1) * (itemWidth + horOffset), 50))

        -- 极品
        if i == 1 then
        	local cornerIco = ccui.ImageView:create('uires/ui_new/explore/corner.png')

        	cornerIco:setScale(0.8)
        	cornerIco:setPosition(cc.p(55, 55))

        	local txt       = ccui.Text:create(GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_13'), 'font/gamefont.ttf', 20)

	        -- txt:setTextColor(cc.c4b(255, 222, 10, 255))
	        txt:enableOutline(cc.c4b(37, 71, 24, 255), 1)
	        txt:setPosition(cc.p(67, 67))
	        txt:setRotation(45)

	        cornerIco:addChild(txt)
        	cell.awardBgImg:addChild(cornerIco)
        end
	end
end

function CaveAdventureOpenBoxPanelUI:onChangeSelect( addindex_ )
	self._curIndex 		= self._curIndex + addindex_

	self:updateCurPage()
    self:updatePageBtn()
end

function CaveAdventureOpenBoxPanelUI:updateCurPage()
	local key 				= self._typeArr[self._curIndex]
	local conf 				= self._boxOpenConf[key]

	if not conf then
		assert(conf, 'no conf in updateCurPage')
		return
	end

	local openTypeTxBg 		= self._infoBg:getChildByName('open_type_tx_bg')
	local openTypeTx 		= openTypeTxBg:getChildByName('open_type_tx')

	local openCostDescTx 	= self._infoBg:getChildByName('open_cost_desc_tx')
	local openCostResIco 	= self._infoBg:getChildByName('open_cost_ico')
	local openCostNumTx 	= self._infoBg:getChildByName('open_cost_num_tx')

	local rateDescBg 		= self._infoBg:getChildByName('rate_desc_bg')
	local rateDescTx 		= rateDescBg:getChildByName('rate_desc_tx')

	openTypeTx:setString( GlobalApi:getGeneralText( conf['desc'] ) )
	openCostDescTx:setString( GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_5') )
	rateDescTx:setString( GlobalApi:getGeneralText( conf['noticedesc'] ) )

	local itemObj 			= DisplayData:getDisplayObj( conf['cost'][1] )

	openCostNumTx:setString( itemObj:getNum() )
	openCostResIco:loadTexture( itemObj:getIcon() )
end

function CaveAdventureOpenBoxPanelUI:updatePageBtn()
	self._leftBtn:setTouchEnabled( self._curIndex > 1 )
	self._leftBtn:setBright( self._curIndex > 1 )

	self._rightBtn:setTouchEnabled( self._curIndex < #self._typeArr )
	self._rightBtn:setBright( self._curIndex < #self._typeArr )
end

function CaveAdventureOpenBoxPanelUI:doOpenBox()
	local key 				= self._typeArr[self._curIndex]
	local conf 				= self._boxOpenConf[key]

	local itemObj 			= DisplayData:getDisplayObj( conf['cost'][1] )

	if itemObj:getCategory() == 'user' and itemObj:getSubtype() == 'gold' then
		if itemObj:getOwnNum() < itemObj:getNum() then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'), COLOR_TYPE.RED)
        	return
		end
	elseif itemObj:getCategory() == 'user' and itemObj:getSubtype() == 'cash' then
		if itemObj:getOwnNum() < itemObj:getNum() then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_CASH'), COLOR_TYPE.RED)
        	return
		end
	elseif itemObj:getCategory() == 'material' then
		if itemObj:getOwnNum() < itemObj:getNum() then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
        	return
		end
	end

	CaveAdventureMgr:sendGetBoxRewardPost( key, function (data)

		if data['awards'] then
	        GlobalApi:parseAwardData(data['awards'])
	        GlobalApi:showAwardsCommon(data['awards'],nil,nil,true)
	    end
	    if data['super_box_mar'] then
	    	self._caveData['cave']['super_box_mar'] = data['super_box_mar']
	    end
	    if data['put_shard_time'] then
	    	self._caveData['cave']['put_shard_time'] = data['put_shard_time']
	    end

	    for i = 1, 4 do
	    	self._caveData['cave']['shard'][tostring(i)] = 0
	    end

	    if data['super_box_mar'] and data['super_box_mar'] == 1 then
	    	promptmgr:showSystenHint(GlobalApi:getLocalStr_new('STR_CAVE_ADVENTURE_DESC_11'), COLOR_TYPE.RED)
	    end

	    CaveAdventureMgr:hideOpenBoxUI()
	    CaveAdventureMgr:updateMainUI()
	end)
end

return CaveAdventureOpenBoxPanelUI
