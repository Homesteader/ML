local PagePetition = class("PagePetition")
local ClassActivityPetitionHelpUI = require("script/app/ui/activity/page_petition_help")
local ClassActivityPetitionTipsUI = require("script/app/ui/activity/page_petition_tips")
local ClassItemCell = require('script/app/global/itemcell')

function PagePetition:init(msg)
    UserData:getUserObj().activity.petition.day = msg.petition.day
    UserData:getUserObj().activity.petition.got = msg.petition.got
    UserData:getUserObj().activity.petition.reward = msg.petition.reward

    self.rootBG = self.root:getChildByName("root")
    self.cfg = GameData:getConfData("avpetition")
    self.cellsItems = {}
	self.isPetitonStatus = false
	self.isGet=(msg.petition.got > 0) and true or false
	self.recover=msg.petition.recover
	
	self.getItemList={}
	for k,v in pairs(msg.petition.reward) do
		local item = DisplayData:getDisplayObjs(self.cfg[v[1]].award)
		if(item[1] ~= nil) then
			item[1].times=v[2]
			item[1].id=v[1]
			table.insert(self.getItemList, item[1])
		end
	end

	self.itemPanel = self.rootBG:getChildByName("itemPanel")
	self.topPanel = self.rootBG:getChildByName("topPanel")

    self.topPanel:getChildByName('desc1'):setString(GlobalApi:getLocalStr('ACTIVITY_PETITION_DES1'))
    self.topPanel:getChildByName('tx_0_0'):setString(GlobalApi:getLocalStr('ACTIVITY_PETITION_DES2'))

	self.buttomPanel = self.rootBG:getChildByName("buttomPanel")

    self.buttomPanel:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_PETITION_DES3'))
	--mask panel
	self.maskPanel=self.buttomPanel:getChildByName("maskPanel")
	
	self:updateShowItems()
	
    self.rootBG:getChildByName("image_bg"):setVisible(false)

	--title
	local title=ccui.Helper:seekWidgetByName(self.topPanel,"title_ex")
	title:setString(GlobalApi:getLocalStr('ACTIVITY_PETITION_TITLE'))
	--starNum
	self.starNum=self.topPanel:getChildByName("num")
	--cdTime
	self.cdTime = self.topPanel:getChildByName("cdTime")
	self.desc1 = self.topPanel:getChildByName("desc1")
	
	--npc
	local npc_node = self.rootBG:getChildByName("npc_node")
    local npc = GlobalApi:createSpineByName("ui_kongmingdeng", "spine/ui_kongmingdeng/ui_kongmingdeng", 1)
	npc:setAnimation(0, "idle", true)
    npc_node:addChild(npc)

    local posY = npc:getPositionY()

    npc:setPositionY(posY + 23)

    self.npc_node = npc_node
    self.npc = npc

    --
    local limitDes = self.rootBG:getChildByName("limit_des")
    limitDes:setString(GlobalApi:getLocalStr('GET_BTN_AWARD_DES'))

    local pass24 = false
    local currProgress = MapData:getFightedCityId()
    if currProgress == nil or currProgress and currProgress < 24 then -- 未达到24关
        pass24 = false
        limitDes:setVisible(true)
    else
        pass24 = true
        limitDes:setVisible(false)
    end

	--getBtn
	local getBtn=self.buttomPanel:getChildByName("getBtn")
	local getTips=self.buttomPanel:getChildByName("getTips")
	getTips:setString(GlobalApi:getLocalStr('ACTIVITY_PETITION_GETTIPS'))
	
	if (self.isGet==true) then
		getTips:setVisible(true)
		getBtn:setVisible(false)
		getBtn:setTouchEnabled(false)
	else
		getTips:setVisible(false)
		getBtn:setVisible(true)
		getBtn:setTouchEnabled(true)
	end
	
	getBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
                -- 玩家若未通关到24关，则点击按钮提示：请先通关24.荥阳再来领奖吧
                if pass24 == false then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('GET_BTN_AWARD_TIPS'), COLOR_TYPE.RED)
                    return
                end

				--get awards
				MessageMgr:sendPost('reward_petition','activity',json.encode({}),
					function(response)
						if(response.code ~= 0) then
							return
						end

						local awards = response.data.awards
						if awards then
							GlobalApi:parseAwardData(awards)
                            GlobalApi:showAwardsCommon(awards,nil,nil,true)
						end

						self.isGet=true
						self.getItemList={}
						self:updateItemList()
						getTips:setVisible(true)
						getBtn:setVisible(false)
						getBtn:setTouchEnabled(false)

                        UserData:getUserObj().activity.petition.got = 1
                        UserData:getUserObj().activity.petition.reward = {}

						self:updateMark()
                        self:updateRefreshStar()

                        -- 如果是最后1天，领取结束后，那切换到"签到"标签页就可以了
                        if ActivityMgr:judgeActivityIsPetiton() == true then
                            ActivityMgr:removePepetion()
                        end

					end)
			end
		end)
	
	--helpBtn
	local helpBtn=self.buttomPanel:getChildByName("helpBtn")
	helpBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				HelpMgr:showHelpUI(26)
			end
		end)
	
	local viewPanel = ccui.Helper:seekWidgetByName(self.buttomPanel,"viewPanel")
	self.cells={}
	local innerWidth=0
	for i=1,10 do
		local cell=ccui.ImageView:create('uires/ui/common/frame_default2.png')
		innerWidth=i*91
		cell:setPosition(cc.p(innerWidth-47, 50))
		cell:setLocalZOrder(10-i)
		cell:setScale(0.84)
		viewPanel:addChild(cell)
		self.cells[i]=cell
	end
	
	self:updateStar(msg.petition.fan)
	self:updateRecover(msg.petition.recover)
    -- 延迟的天数不能许愿
    if ActivityMgr:judgeActivityIsPetiton() == false then      
        self.cdTime:setVisible(true)
        self:updateCdTime(msg.cd)
    end
	self:updateItemList()
	self:updateMark()
	
    self:updateRefreshStar()

	ActivityMgr:ShowPetitionTime()
    -- 延迟的天数不能许愿
    if ActivityMgr:judgeActivityIsPetiton() == true then
        self.starNum:setVisible(false)
        self.topPanel:getChildByName("desc1"):setVisible(false)
        self.rootBG:getChildByName("Image_29"):setVisible(false)
        self.cdTime:setVisible(false)
        self.topPanel:getChildByName("tx_0_0"):setVisible(false)
        self.rootBG:getChildByName("Image_29_0"):setVisible(false)
    end
end

function PagePetition:updateStar(num)
    UserData:getUserObj().activity.petition.fan = num
	self.curStarNum=num
	self.starNum:setString(num.."/"..tonumber(GlobalApi:getGlobalValue('petitionMaxFan')))
end

function PagePetition:updateRefreshStar()
    if self.isGet == false then
        --return
    end

    local allCount = 0

    local hasPetitionCount = 0
    for k,v in pairs(self.cfg) do
		for m,n in pairs(self.getItemList) do					
			if tonumber(v.id)==tonumber(n.id) then
				hasPetitionCount = hasPetitionCount + 1
			end
		end        
    end
    allCount = hasPetitionCount + self.curStarNum

    if allCount >= tonumber(GlobalApi:getGlobalValue('petitionMaxFan')) then
        self.cdTime:setVisible(false)
        self.topPanel:getChildByName("desc1"):setVisible(false)
    else
        self.cdTime:setVisible(true)
        self.topPanel:getChildByName("desc1"):setVisible(true)
    end
end


function PagePetition:updateRecover(val)
	self.recover=val
	if self.recover >= tonumber(GlobalApi:getGlobalValue('petitionMaxFan')) then
		self.cdTime:setVisible(false)
		self.desc1:setVisible(false)
	end
end

function PagePetition:updateCdTime(time)
	self.cdTime:removeAllChildren()
	local label = cc.Label:createWithTTF('', "font/gamefont.ttf", 21)
    label:setPosition(cc.p(0,0))
	label:setLocalZOrder(10)
    self.cdTime:addChild(label)
	Utils:createCDLabel(label,time,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,nil,nil,nil,25,function()
		if self.recover < tonumber(GlobalApi:getGlobalValue('petitionMaxFan')) then
			self:updateRecover(self.recover+1)
			self:updateStar(self.curStarNum+1)
			self:updateCdTime(tonumber(GlobalApi:getGlobalValue('petitionFanCD')))
            self:updateMark()
            self:updateRefreshStar()
		end
	end)
end

function PagePetition:updateItemList()
    if not self.cells then
        return
    end
	for i=1,10 do
		if  self.cells[i] ~= nil then
			self.cells[i]:removeAllChildren()
			if self.getItemList[i] ~= nil then
				local tab=self:CreateItem(self.getItemList[i], self.cells[i])
				local size=self.cells[i]:getContentSize()
				tab.awardBgImg:setPosition(cc.p(size.width/2, size.height/2))
				
				local times=tonumber(self.getItemList[i].times)
				if times>1 then
					local pic=ccui.ImageView:create("uires/ui/activity/petition_cri"..times..".png")
					pic:setPosition(cc.p(47,80))
					pic:setScale(0.6)
					self.cells[i]:addChild(pic,10)
				end
			end
		end
	end
end

function PagePetition:CreateItem(item,parent)
	if item==nil then
		return nil
	end
	local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, item, parent)
	tab.awardBgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			GetWayMgr:showGetwayUI(item,false)
		end
	end)
    local dd = tab.awardBgImg:getContentSize()
	return tab
end


function PagePetition:CreatePetitionItem()
    local tab = {}
    tab.node = cc.CSLoader:createNode("csb/petition_effect.csb")

    tab.action = cc.CSLoader:createTimeline("csb/petition_effect.csb")

    tab.root = tab.node:getChildByName('root')
    tab.kongmingdeng = tab.root:getChildByName('kongmingdeng')
    tab.icon = tab.root:getChildByName('icon')

	return tab
end



function PagePetition:updateShowItems()
    self.awardBgImgs = {}
    self.awardImgs = {}
    local pass24 = false
    local currProgress = MapData:getFightedCityId()
    if currProgress == nil or currProgress and currProgress < 24 then -- 未达到24关
        pass24 = false
    else
        pass24 = true
    end

    if #self.cellsItems == 0 then
        self.itemPanel:removeAllChildren()
        for k = 1,#self.cfg do
            local item = DisplayData:getDisplayObjs(self.cfg[k].award)
		    if(item[1] ~= nil) then	
			    local cell = self:CreateItem(item[1],self.itemPanel)
                cell.item = item[1]
                self.cellsItems[#self.cellsItems + 1] = cell
            end
        end
    end
    

	for k = 1,#self.cellsItems do
        local v = self.cfg[k]
        local cell = self.cellsItems[k]
		local item = cell.item

		if(item ~= nil) then
			if cell~=nil then
				local xPos = (k-1)%5*110+60
				local yPos = (k<=5) and 160 or 50
				cell.awardBgImg:setPosition(cc.p(xPos, yPos))
                self.awardBgImgs[#self.awardBgImgs + 1] = cell.awardBgImg
                self.awardImgs[#self.awardImgs + 1] = cell.awardImg
				cell.awardBgImg:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.ended then
						AudioMgr.PlayAudio(11)
                        if self.isPetitonStatus == true then
                            if self.npc then
                                self.npc:removeFromParent()

                                local npc = GlobalApi:createSpineByName("ui_kongmingdeng", "spine/ui_kongmingdeng/ui_kongmingdeng", 1)
	                            npc:setAnimation(0, "idle", true)
                                self.npc_node:addChild(npc)                               
                                self.npc = npc
                            end
                            

                            if self.maskPanel:getChildByName('node_tab_node') then
                                self.maskPanel:removeChildByName('node_tab_node')
                            end
                            --[[
                            if self.tabAwardBgImg then
				                self.tabAwardBgImg:setVisible(true)
                                self.tabAwardBgImg = nil
                            else
                                if self.cells[#self.getItemList] then
                                    self.cellsIdx = self.cells[#self.getItemList]
                                    local tab = self:CreateItem(self.getItemList[#self.getItemList], self.cells[#self.getItemList])
		                            local size = self.cells[#self.getItemList]:getContentSize()
		                            tab.awardBgImg:setPosition(cc.p(size.width/2, size.height/2))
		                            tab.awardBgImg:setVisible(true)
                                end
                            end

				            if self.cellsIdx and self.cellsIdx.pic then
					            self.cellsIdx.pic:setVisible(true)     
                                self.cellsIdx = nil   
                            else
                                local times = tonumber(self.getItemList[#self.getItemList].times)
		                        if times > 1 then
			                        local pic = ccui.ImageView:create("uires/ui/activity/petition_cri"..times..".png")
			                        pic:setPosition(cc.p(47,80))
			                        pic:setScale(0.6)
			                        self.cellsIdx:addChild(pic,10)
			                        self.cellsIdx.pic = pic
			                        self.cellsIdx.pic:setVisible(true)
		                        end
				            end
                            --]]

				            self:updateShowItems()

                        end
                        self.isPetitonStatus = false

                        if pass24 == false then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('GET_BTN_AWARD_TIPS2'), COLOR_TYPE.RED)
                            return
                        end

                        if ActivityMgr:judgeActivityIsPetiton() == true then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('GET_BTN_AWARD_TIPS3'), COLOR_TYPE.RED)
                            return
                        end

						local tipsUI = ClassActivityPetitionTipsUI.new(item, self.isGet, function ()
							if self.curStarNum <= 0 then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_PETITION_COUNT_ZERO'), COLOR_TYPE.RED)
								return
							end

                            for j = 1,#self.awardBgImgs do
                                self.awardBgImgs[j]:setTouchEnabled(false)
                            end

							--select one awards
							MessageMgr:sendPost('do_petition','activity',json.encode({id=v.id}),
								function(response)
									if(response.code ~= 0) then
										return
									end
									item.times = response.data.times
									item.id = v.id
									table.insert(self.getItemList, item)

                                    --[[
                                    self.npc:setAnimation(0, "idle1", false)
                                    self.npc:registerSpineEventHandler(function ()
							            self.npc:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
							            self.npc:setAnimation(0, "idle", true)
                                        self.isPetitonStatus = true
                                        for j = 1,#self.awardBgImgs do
                                            if sender ~= self.awardBgImgs[j] then
                                                self.awardBgImgs[j]:setTouchEnabled(true)
                                            end
                                        end
                                        self:FlyToSlot2(#self.getItemList, item)
						            end, sp.EventType.ANIMATION_COMPLETE)
                                    --]]
                                    self.npc:setAnimation(0, "idle1", false)
                                    self.npc:registerSpineEventHandler(function ()
                                        print('========++++++++++++++++99666666')
							            self.npc:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
							            self.npc:setAnimation(0, "idle", true)                                       
                                        self:FlyToSlot2(#self.getItemList, item)
						            end, sp.EventType.ANIMATION_COMPLETE)


									local effect = GlobalApi:createLittleLossyAniByName("ui_qingyuan_01")	
									effect:setPosition(cc.p(47,47))
									effect:getAnimation():play('Animation1', -1, -1)
									cell.awardBgImg:addChild(effect)
									
									self:updateStar(self.curStarNum-1)

                                    self:updateMark()

                                    self:updateRefreshStar()

                                    self.isPetitonStatus = true
                                    for j = 1,#self.awardBgImgs do
                                        if sender ~= self.awardBgImgs[j] then
                                            self.awardBgImgs[j]:setTouchEnabled(true)
                                        end
                                    end


								end)
						end)
						tipsUI:showUI()
					end
				end)
				
				if self.isGet then
					local isGray=false
					for m,n in pairs(self.getItemList) do
						
						if tonumber(v.id)==tonumber(n.id) then
							isGray=true
						end
					end
					
					if isGray==true then
						cell.awardBgImg:setTouchEnabled(false)
						ShaderMgr:setGrayForWidget(cell.awardBgImg)
						ShaderMgr:setGrayForWidget(cell.awardImg)
						if cell.chipImg then
							ShaderMgr:setGrayForWidget(cell.chipImg)
						end
					else
						cell.awardBgImg:setTouchEnabled(true)
						ShaderMgr:restoreWidgetDefaultShader(cell.awardBgImg)
						ShaderMgr:restoreWidgetDefaultShader(cell.awardImg)
						if cell.chipImg then
							ShaderMgr:restoreWidgetDefaultShader(cell.chipImg)
						end
					end
				end
			end
		end
	end

    -- 未通过24关
    if pass24 == false then
        for j = 1,#self.awardBgImgs do
            ShaderMgr:setGrayForWidget(self.awardBgImgs[j])
        end
        for k = 1,#self.awardImgs do
            self.awardImgs[k]:setTouchEnabled(false)
            ShaderMgr:setGrayForWidget(self.awardImgs[k])
        end
    end
    

    -- 延迟的天数不能许愿
    if ActivityMgr:judgeActivityIsPetiton() == true then
        for j = 1,#self.awardBgImgs do
            ShaderMgr:setGrayForWidget(self.awardBgImgs[j])
        end
        for k = 1,#self.awardImgs do
            self.awardImgs[k]:setTouchEnabled(false)
            ShaderMgr:setGrayForWidget(self.awardImgs[k])
        end
    end
    self:updateItemList()
end

function PagePetition:FlyToSlot(idx, item)
	if self.cells[idx] then
		local tab=self:CreateItem(item, self.cells[idx])
		local size=self.cells[idx]:getContentSize()
		tab.awardBgImg:setPosition(cc.p(size.width/2, size.height/2))
		tab.awardBgImg:setVisible(false)
		
		local times=tonumber(item.times)
		if times>1 then
			local pic=ccui.ImageView:create("uires/ui/activity/petition_cri"..times..".png")
			pic:setPosition(cc.p(47,80))
			pic:setScale(0.6)
			self.cells[idx]:addChild(pic,10)
			self.cells[idx].pic=pic
			self.cells[idx].pic:setVisible(false)
		end
		
		local cloud=ccui.Helper:seekWidgetByName(self.maskPanel,"cloud")
		cloud:setVisible(true)
		cloud:setPosition(cc.p(450,260))
		if cloud.effect~=nil then
			cloud:removeChild(cloud.effect)
		end
				
		local criPic=cloud:getChildByName("criPic")
		criPic:setLocalZOrder(5)
		criPic:setVisible(false)
		if times>1 then
			criPic:loadTexture("uires/ui/activity/petition_cri"..times..".png")
			criPic:setVisible(true)
		end
	
		local temp=tab.awardBgImg:clone()
		cloud:addChild(temp,20)		
		local pSize=cloud:getContentSize()
		temp:setPosition(cc.p(pSize.width/2, pSize.height/2-10))
		temp:setVisible(true)
		--cloud:setScale(0)
		cloud:setOpacity(100)
		self.maskPanel:setTouchEnabled(true)
		
		local desPos=self.cells[idx]:convertToWorldSpace(cc.p(size.width/2, size.height/2))
		local offset=self.maskPanel:convertToWorldSpace(cc.p(0,0))
		desPos=cc.p(desPos.x-offset.x, desPos.y-offset.y)
		--local act1=cc.Spawn:create(cc.ScaleTo:create(0.5,1), cc.FadeIn:create(0.2))
		local act1=cc.FadeIn:create(0.4)
		local act2=cc.CallFunc:create(
			function ()
				cloud.effect = GlobalApi:createLittleLossyAniByName("ui_qingyuan_03")	
				cloud.effect:setPosition(cc.p(pSize.width/2, pSize.height/2))
				cloud.effect:setScale(2)
				cloud.effect:getAnimation():play('Animation1', -1, 1)
				cloud:addChild(cloud.effect,1)
			end)
		local act3=cc.DelayTime:create(1)
		local act4=cc.Spawn:create(cc.MoveTo:create(0.4, desPos), cc.FadeOut:create(0.4))
		local act5=cc.CallFunc:create(
			function ()
				temp:removeFromParent()
				tab.awardBgImg:setVisible(true)
				if self.cells[idx].pic then
					self.cells[idx].pic:setVisible(true)
				end
				
				local effect = GlobalApi:createLittleLossyAniByName("ui_qingyuan_02")	
				effect:setPosition(cc.p(size.width/2, size.height/2))
				effect:getAnimation():play('Animation1', -1, 0)
				self.cells[idx]:addChild(effect,20)
				
				if cloud.effect~=nil then
					cloud:removeChild(cloud.effect)
				end
		
				self:updateShowItems()
				
				self.maskPanel:setTouchEnabled(false)
			end
		)
		cloud:runAction(cc.Sequence:create(act1, act2, act3, act4, act5))
	end
end

function PagePetition:FlyToSlot2(idx, item)
	if self.cells[idx] then
        -- 最终显示部分弄好了
        self.cellsIdx = self.cells[idx]

        local tab=self:CreateItem(item, self.cells[idx])
		local size=self.cells[idx]:getContentSize()
		tab.awardBgImg:setPosition(cc.p(size.width/2, size.height/2))
		tab.awardBgImg:setVisible(false)
		self.tabAwardBgImg = tab.awardBgImg

		local times=tonumber(item.times)
		if times>1 then
			local pic=ccui.ImageView:create("uires/ui/activity/petition_cri"..times..".png")
			pic:setPosition(cc.p(47,80))
			pic:setScale(0.6)
			self.cells[idx]:addChild(pic,10)
			self.cells[idx].pic=pic
			self.cells[idx].pic:setVisible(false)
		end


        -- 动画
        local nodeTab = self:CreatePetitionItem() -- 整个图片
        nodeTab.root:setVisible(true)
        nodeTab.root:setPosition(cc.p(450,250))
        nodeTab.node:setName('node_tab_node')
        self.maskPanel:addChild(nodeTab.node)

        -- 播放特效
        nodeTab.node:runAction(nodeTab.action)
        if idx and idx <= 5 then
            nodeTab.action:play("animation1", true)
        else
            nodeTab.action:play("animation0", true)
        end
        

        local temp = tab.awardBgImg:clone()
		nodeTab.icon:addChild(temp,20)		
		local pSize = nodeTab.icon:getContentSize()
		temp:setPosition(cc.p(pSize.width/2, pSize.height/2))
		temp:setVisible(true)
		nodeTab.node:setOpacity(255)
		--self.maskPanel:setTouchEnabled(true)

        local cloud=ccui.Helper:seekWidgetByName(self.maskPanel,"cloud")
		local criPic=cloud:getChildByName("criPic")
        local tempCriPic = criPic:clone()
		tempCriPic:setLocalZOrder(5)
		tempCriPic:setVisible(false)
        tempCriPic:setPosition(cc.p(pSize.width/2, pSize.height/2 + 20))
		tempCriPic:setScale(0.6)
		if times>1 then
			tempCriPic:loadTexture("uires/ui/activity/petition_cri"..times..".png")
			tempCriPic:setVisible(true)
		end
        nodeTab.icon:addChild(tempCriPic,30)		

        -- 运动特效       
        --local pos = self.cells[idx]:convertToWorldSpace(cc.p(size.width/2, size.height/2))
        -- 转化为节点下的本地坐标
        --local despos = self.maskPanel:convertToNodeSpace(cc.p(pos.x,pos.y))

        local desPos=self.cells[idx]:convertToWorldSpace(cc.p(size.width/2, size.height/2))
		local offset=self.maskPanel:convertToWorldSpace(cc.p(0,0))
		desPos=cc.p(desPos.x-offset.x, desPos.y-offset.y + size.height/2)

        --print('aaaaa' .. desPos.x .. 'bbbbb' .. desPos.y)

		local act1=cc.FadeIn:create(0.4)
		local act2=cc.DelayTime:create(0.5)
		local act3=cc.Spawn:create(cc.MoveTo:create(1, desPos), cc.FadeOut:create(1))
		local act4=cc.CallFunc:create(
			function ()
                self.isPetitonStatus = false
				tab.awardBgImg:setVisible(true)
				if self.cells[idx].pic then
					self.cells[idx].pic:setVisible(true)
				end
				
				local effect = GlobalApi:createLittleLossyAniByName("ui_qingyuan_02")	
				effect:setPosition(cc.p(size.width/2, size.height/2))
				effect:getAnimation():play('Animation1', -1, 0)
				self.cells[idx]:addChild(effect,20)
				
                nodeTab.node:removeFromParent()

				self:updateShowItems()
				
				--self.maskPanel:setTouchEnabled(false)
			end
		)
		nodeTab.root:runAction(cc.Sequence:create(act1, act2, act3, act4))
	end
end


function PagePetition:updateMark()
	if UserData:getUserObj():getActivityPetitionShowStatus() then
		ActivityMgr:showMark("petition", true)
	else
		ActivityMgr:showMark("petition", false)
	end
end

return PagePetition