--===============================================================
-- 好友搜索添加界面
--===============================================================
local FriendsInfoPanelUI = class("FriendsInfoPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local defaultNor = 'uires/ui_new/common/select_tab_push.png'
local defaultSel = 'uires/ui_new/common/select_tab_nor.png'
local defaultColor = cc.c4b(207, 186, 141, 255)
local selectColor = cc.c4b(255, 247, 228, 255)

function FriendsInfoPanelUI:ctor(page)
    self.uiIndex = GAME_UI.UI_FRIENDS_FIND_PANEL
    self.page = page or 2
    self.applydata = FriendsMgr:getFriendData().applied
end

function FriendsInfoPanelUI:onShow()
    self:update()
end

function FriendsInfoPanelUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local alphabg = bgimg1:getChildByName('bg_img1')
    local bgimg2 = alphabg:getChildByName('bg_img_1')
    local closebtn = alphabg:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:hideFriendsInfo()
        end
    end)
    self:adaptUI(bgimg1, alphabg)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_4'))
    self.friendbtnarr = {}
    for i=1,3 do
        local arr = {}
        arr.btn = alphabg:getChildByName('friend_'..i..'_btn')
        arr.btntx = arr.btn:getChildByName('btn_tx')
        arr.btntx:setString(GlobalApi:getLocalStr_new('FRIENDS_BTN_'..i))
        arr.btnimg = arr.btn:getChildByName('new_img')
        arr.btnimg:setVisible(false)
        self.friendbtnarr[i] = arr
        self.friendbtnarr[i].btn:addTouchEventListener(function (sender, eventType)
            if eventType ==ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.page and self.page == i then
                    return
                end

                if i == 1 then
                    -- 关闭界面
                    FriendsMgr:hideFriendsInfo()
                else
                    self.page = i
                    self:swapList()
                    for j=1,3 do
                        self.friendbtnarr[j].btn:loadTextureNormal(defaultNor)
                        self.friendbtnarr[j].btntx:setColor(defaultColor)
                    end
                    self.friendbtnarr[i].btn:loadTextureNormal(defaultSel)
                    self.friendbtnarr[i].btntx:setColor(selectColor)
                end    
            end
        end)
    end

    --推荐好友界面
    local friendsbg = bgimg2:getChildByName('friends_bg')
    self.addfriendspl = friendsbg:getChildByName('add_friend_pl')

    -- 刷新按钮
    local refreshBtn = self.addfriendspl:getChildByName('refresh_btn')
    local refreshBtnTx = refreshBtn:getChildByName('func_tx')
    refreshBtnTx:setString(GlobalApi:getLocalStr_new('FRIENDS_DESC_4'))
    refreshBtn:addTouchEventListener(function( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:refreshRecommandList()
        end
    end)

    -- 一键申请按钮
    local applyAllBtn = self.addfriendspl:getChildByName('apply_all_btn')
    local applyAllBtnTx = applyAllBtn:getChildByName('func_tx')
    applyAllBtnTx:setString(GlobalApi:getLocalStr_new('FRIENDS_DESC_2'))
    applyAllBtn:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:applyAll()
        end
    end)

    local findbtn = self.addfriendspl:getChildByName('find_btn')
    findbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local tx = self.nameTx:getString()
            if tx == "" then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_42'), COLOR_TYPE.RED)
                return
            end

            if tx == UserData:getUserObj():getName() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_43'), COLOR_TYPE.RED)
                return
            end

            local obj = {
                name = self.nameTx:getString()
                }
            MessageMgr:sendPost('applyByName','friend',json.encode(obj),function (response)    
                local code = response.code
                local data = response.data
                if code == 0 then
                    if response.data.status == 5 then
                        self.frienddata = FriendsMgr:getFriendData().friends
                        table.insert(self.frienddata,data.basedata)

                        -- 找到这个名字的uid
                        for k,v in pairs(self.applydata) do
                            if tonumber(v.uid) == tonumber(data.basedata.uid) then
                                self.applydata[k] = nil
                                break
                            end
                        end
                        FriendsMgr:setDirty(true)
                    end
                    FriendsMgr:MsgPop(response.data.status)
                    self:update()
                end
            end)
        end
    end)

    -- 推荐列表
    local slotPl = self.addfriendspl:getChildByName('slot_pl')
    self.recommandList = {}
    for i = 1, 8 do
        local slot = slotPl:getChildByName('slot_' .. i)
        self.recommandList[i] = slot;
    end

    -- 自己的头像
    self.myNode = self.addfriendspl:getChildByName('self_node')

    --local btntx = findbtn:getChildByName('btntext')
    --btntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_6'))

    --local addposttx = self.addfriendspl:getChildByName('post_desc')
    --addposttx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_5')..':')

    --申请列表界面
    self.applylistpl = friendsbg:getChildByName('applylist_pl')

    self.addsv = self.applylistpl:getChildByName('add_sv')
    self.addsv:setScrollBarEnabled(false)
    self:createEditbox(self.addfriendspl)

    -- 一键删除
    local deleteallbtn = self.applylistpl:getChildByName('delete_all_btn')
    deleteallbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local judge = false
            for k,v in pairs(self.applydata) do
                if v then
                    judge = true
                    break
                end
            end
            if judge == false then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_36'), COLOR_TYPE.RED)
                return
            end
            MessageMgr:sendPost('remove_apply','friend',"{}",function (response)    
                local code = response.code
                local data = response.data
                if code == 0 then
                    FriendsMgr:setDirty(true)
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_47'), COLOR_TYPE.RED)
                    for k,v in pairs(self.applydata) do
                        self.applydata[k] = nil
                    end
                    self:update()
                end 
            end)
        end
    end)
    local delbtntx = deleteallbtn:getChildByName('btntext')
    delbtntx:setString(GlobalApi:getLocalStr_new('FRIENDS_DESC_5'))
    self.applyposttx = self.applylistpl:getChildByName('post_desc')

    -- 一键同意
    local agreeAllBtn = self.applylistpl:getChildByName('agree_all_btn')
    local agreeAllBtnTx = agreeAllBtn:getChildByName('btntext')
    agreeAllBtnTx:setString(GlobalApi:getLocalStr_new('FRIENDS_DESC_6'))
    agreeAllBtn:addTouchEventListener(function ( sender, eventType )
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:handleAllApply()
        end
    end)

    self:update()

    local titlePl = self.applylistpl:getChildByName('title_pl')
    local ListTitleInfo = titlePl:getChildByName('title_1')
    local title1Tx = ListTitleInfo:getChildByName('title_tx')
    title1Tx:setString(GlobalApi:getLocalStr_new('STR_PLAYER_INFO'))
    ListTitleInfo:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- 按时间排序
            release_print('sort by time')
            self:updateApplylist(1)
        end
    end)

    local ListTitleForce = titlePl:getChildByName('title_2')
    local title2Tx = ListTitleForce:getChildByName('title_tx')
    title2Tx:setString(GlobalApi:getLocalStr_new('COMMON_STR_FIGHT'))
    ListTitleForce:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- 按战斗力排序
            release_print('sort by force')
            self:updateApplylist(2)
        end
    end)

end

function FriendsInfoPanelUI:createEditbox(parent)
    --self.createpl = bgimg3:getChildByName('create_pl')
    local nameidboxbg = parent:getChildByName('idbox_bg')
    local nameidboxtx = nameidboxbg:getChildByName('idbox_tx')
    nameidboxbg:setLocalZOrder(1)
    nameidboxtx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_7'))

    local maxLen = 20--self.legionglobalconf['legionNameMax'].value
    self.nameeditbox = cc.EditBox:create(cc.size(400, 50), 'uires/ui_new/friend/input.png')
    self.nameeditbox:setPlaceholderFontColor(cc.c4b(0,0,0,255))
    self.nameeditbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.nameeditbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.nameeditbox:setPlaceHolder('')
    self.nameeditbox:setPosition(199, 52)
    self.nameeditbox:setFontSize(25)
    self.nameeditbox:setText('')
    self.nameeditbox:setFontColor(cc.c4b(0,0,0,255))
    self.nameeditbox:setMaxLength(maxLen)
    -- self.nameeditbox:setOpacity(0)
    parent:addChild(self.nameeditbox)

    self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    self.nameTx:setPosition(cc.p(199, 52))
    self.nameTx:setColor(COLOR_TYPE.WHITE)
    self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.nameTx:setAnchorPoint(cc.p(0.5,0.5))
    self.nameTx:setName('name_tx')
    parent:addChild(self.nameTx)

    local oldStr = ''
    self.nameeditbox:registerScriptEditBoxHandler(function(event,pSender)
        if event == "began" then
            self.nameeditbox:setText(self.nameTx:getString())
            oldStr = self.nameTx:getString()
            self.nameTx:setString('')
            nameidboxtx:setString('')
        elseif event == "ended" then
            local str = self.nameeditbox:getText()
            local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,maxLen*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
            local isOk,str1 = GlobalApi:checkSensitiveWords(str)
            if not isOk then
                -- promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER'), MESSAGE_BOX_TYPE.MB_OK)
                self.nameTx:setString(str1 or oldStr or '')
            else
                self.nameTx:setString(str)
            end
            self.nameeditbox:setText('')
            if self.nameTx:getString() == '' then
                nameidboxtx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_7'))
            else
                nameidboxtx:setString('')
            end
        end
    end)
end

function FriendsInfoPanelUI:swapList()
    self:updateCell()
end

function FriendsInfoPanelUI:updateCell()
    self.addsv:removeAllChildren()
    for j=1,3 do
        self.friendbtnarr[j].btn:loadTextureNormal(defaultNor)
        self.friendbtnarr[j].btntx:setColor(defaultColor)
    end
    self.friendbtnarr[self.page].btn:loadTextureNormal(defaultSel)
    self.friendbtnarr[self.page].btntx:setColor(selectColor)

    if #FriendsMgr:getFriendData().applied > 0 then
        self.friendbtnarr[3].btnimg:setVisible(true)
    else
        self.friendbtnarr[3].btnimg:setVisible(false)
    end
    --添加好友界面
    if self.page == 2 then
        self.addfriendspl:setVisible(true)
        self.applylistpl:setVisible(false)
        self:updateAddFriend()
    --申请列表界面
    elseif self.page == 3 then
        self.addfriendspl:setVisible(false)
        self.applylistpl:setVisible(true)
        self:updateApplylist()
    end
end

function FriendsInfoPanelUI:update()
    self:swapList()
end

-- 刷新推荐列表
function FriendsInfoPanelUI:refreshRecommandList()
    MessageMgr:sendPost("recommend", "friend", "{}", function (jsonObj)
        --print(json.encode(jsonObj))
        if jsonObj.code == 0 then
            self.recommenddataArr = {}
            FriendsMgr:setRecommendData(jsonObj.data)
            self.recommenddata = FriendsMgr:getRecommendData().recommend
            for k,v in pairs(self.recommenddata) do
                if v ~= nil then
                    table.insert(self.recommenddataArr,v) 
                end
            end
            self:updateAddFriendCell()
        end
    end)
end

function FriendsInfoPanelUI:updateAddFriend()
    self.recommenddata = FriendsMgr:getRecommendData().recommend
    self.recommenddataArr =  {}
    for k,v in pairs(self.recommenddata) do
        if v ~= nil then
            table.insert(self.recommenddataArr,v) 
        end
    end
    if #self.recommenddataArr == 0 then
        self:refreshRecommandList()
    else
        self:updateAddFriendCell()
    end
end

function FriendsInfoPanelUI:updateAddFriendCell()
    for i=1,#self.recommenddataArr do
        if i <= 8 then
            self:addFriendsCell(i, self.recommenddataArr[i])
        end
    end

    -- 刷新自己的信息
    local roleObj = RoleData:getRoleByPos(1)
    local selfData = {}
    selfData.uid = UserData:getUserObj():getUid()
    selfData.quality = roleObj:getQuality()
    selfData.headpic = UserData:getUserObj():getHeadpic()
    selfData.level = UserData:getUserObj():getLv()
    selfData.headframe = UserData:getUserObj():getHeadFrameId()
    self:initRecommandHeadNode(self.myNode, selfData)

    local nameBg = self.myNode:getChildByName('name_bg')
    local nameTx = nameBg:getChildByName('name_tx')
    nameTx:setString(UserData:getUserObj():getName())
end

function FriendsInfoPanelUI:updateApplylist(sortType)
    if sortType == nil or sortType == 1 then
        -- 按时间排序
        table.sort(FriendsMgr:getFriendData().applied, function(a, b)
            return a.time < b.time
        end)
    elseif sortType == 2 then
        -- 按战斗力排序
        table.sort(FriendsMgr:getFriendData().applied, function(a, b)
            return a.fight_force > b.fight_force
        end)
    end

    self.applydata = FriendsMgr:getFriendData().applied
    self.applydataArr =  {}
    for k,v in pairs(self.applydata) do
        if v ~= nil then
            table.insert(self.applydataArr,v) 
        end
    end
    self.applyposttx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_8')..':'..#self.applydataArr)
    for i=1,#self.applydataArr do
        self:addApplyCell(i,self.applydataArr[i])
    end
end

function FriendsInfoPanelUI:addFriendsCell(index, arrdata)
    local node = self.recommandList[index]
    local headnode = node:getChildByName('head_node')
    local nameBg = node:getChildByName('name_bg')

    local nameTx = nameBg:getChildByName('name_tx')
    nameTx:setString(arrdata.name)

    self:initRecommandHeadNode(headnode, arrdata)

    -- 头衔称号
    local titleTx = node:getChildByName('title_tx')
    titleTx:setString(self:getTitle(arrdata))

    -- vip
    local vipTx = node:getChildByName('vip_tx')
    vipTx:setString('VIP' .. arrdata.vip)
end

function FriendsInfoPanelUI:getTitle(arrdata)
    local nums = GlobalApi:getFormationNum(arrdata.hids)
    local titleConf = GameData:getConfData('friendtitle')
    for i = 1, #titleConf do
        local conditionType = titleConf[i].type
        if conditionType == 1 then
            -- VIP
            if arrdata.vip >= titleConf[i].args[1] and arrdata.vip <= titleConf[i].args[2] then
                return titleConf[i].str
            end
        elseif conditionType == 2 then
            -- 战力排行榜名次
            if arrdata.fightforcerank >= titleConf[i].args[1] and arrdata.fightforcerank <= titleConf[i].args[2] then
                return titleConf[i].str
            end
        elseif conditionType == 3 then
            -- 等级排行榜名次
            if arrdata.levelrank >= titleConf[i].args[1] and arrdata.levelrank <= titleConf[i].args[2] then
                return titleConf[i].str
            end
        elseif conditionType == 4 then
            -- 弓兵数量
            if nums[2] >= titleConf[i].args[1] and nums[2] <= titleConf[i].args[2] then
                return titleConf[i].str
            end
        elseif conditionType == 5 then
            -- 步兵数量
            if nums[1] >= titleConf[i].args[1] and nums[1] <= titleConf[i].args[2] then
                return titleConf[i].str
            end
        elseif conditionType == 6 then
            -- 骑兵数量
            if nums[3] >= titleConf[i].args[1] and nums[3] <= titleConf[i].args[2] then
                return titleConf[i].str
            end
        elseif conditionType == 7 then
            -- 陌生人
            if arrdata.level > titleConf[i].args[1] then
                return titleConf[i].str
            end
        end
    end

    return ''
end

function FriendsInfoPanelUI:addApplyCell( index,arrdata )
    local node = cc.CSLoader:createNode("csb/friendsapplylistcell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    local cellbg = ccui.Widget:create()
    cellbg:addChild(bgimg)
    local headnode = bgimg:getChildByName('head_node')
    local okbtn = bgimg:getChildByName('ok_btn')
    okbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:sendHandleApplyMsg(1,arrdata.uid)
        end
    end)
    local btntx = okbtn:getChildByName('btntext')
    btntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_10'))

    local deletebtn = bgimg:getChildByName('cannel_btn')
    deletebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:sendHandleApplyMsg(0,arrdata.uid)
        end
    end)
    local deletebtntx = deletebtn:getChildByName('btntext')
    deletebtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_11'))

    self:initHeadNode(headnode,arrdata)

    local contentsize = bgimg:getContentSize()
    if #self.applydataArr*(contentsize.height+10) > self.addsv:getContentSize().height then
        self.addsv:setInnerContainerSize(cc.size(self.addsv:getContentSize().width,#self.applydataArr*(contentsize.height+5)))
    else
        self.addsv:setInnerContainerSize(self.addsv:getContentSize())
    end

    local posy = self.addsv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height/2
    cellbg:setPosition(cc.p(contentsize.width/2+10,posy))
    self.addsv:addChild(cellbg)
    self.addsv:scrollToTop(0.1,true)
end

function FriendsInfoPanelUI:sendHandleApplyMsg( agree, uid)
    local obj = {
        id = tonumber(uid),
        agree = agree
    }
    MessageMgr:sendPost('handle_apply','friend',json.encode(obj),function (response)    
        local code = response.code
        local data = response.data
        if response.data.status == 11 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_15'), COLOR_TYPE.RED) 
            for k,v in pairs(self.applydata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.applydata[k] = nil
                    break
                end
            end
            FriendsMgr:setDirty(true)
            self:update()
            return
        end
        if response.data.status == 4 then
            FriendsMgr:MsgPop(response.data.status)
            for k,v in pairs(self.applydata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.applydata[k] = nil
                    break
                end
            end
            FriendsMgr:setDirty(true)
            self:update()
            return
        end
        if code == 0 then
            if agree == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_37'), COLOR_TYPE.RED) 
            elseif agree == 1 then
                self.frienddata = FriendsMgr:getFriendData().friends
                table.insert(self.frienddata,data.basedata)
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_38'), COLOR_TYPE.GREEN)  
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_7'), COLOR_TYPE.RED)   
            end
            FriendsMgr:MsgPop(response.data.status)
            for k,v in pairs(self.applydata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.applydata[k] = nil
                    break
                end
            end
            FriendsMgr:setDirty(true)
            self:update()
        else
        end

    end)
end

-- 一键同意所有申请
function FriendsInfoPanelUI:handleAllApply()
    local obj = {
        ids = {},
        agree = 1
    }

    for k,v in pairs(self.applydata) do
        if v ~= nil then
            table.insert(obj.ids, v.uid) 
        end
    end

    MessageMgr:sendPost('agree_all_apply','friend',json.encode(obj),function (response)    
        local code = response.code
        local data = response.data
        if code == 0 then
            self.frienddata = FriendsMgr:getFriendData().friends

            for k,v in pairs(data.basedata) do
                table.insert(self.frienddata, data.basedata[k])
            end

            promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_38'), COLOR_TYPE.GREEN)  

            FriendsMgr:MsgPop(response.data.status)

            -- 清空申请列表
            FriendsMgr:getFriendData().applied = {}
            self.applydata = {}

            FriendsMgr:setDirty(true)
            self:update()
        end
    end)
end

function FriendsInfoPanelUI:applyFriend(uid)
    local obj = {
        id = tonumber(uid)
    }
    MessageMgr:sendPost('apply','friend',json.encode(obj),function (response)    
        local code = response.code
        local data = response.data

        if response.data.status == 5 then
            self.frienddata = FriendsMgr:getFriendData().friends
            table.insert(self.frienddata,data.basedata)

            for k,v in pairs(self.applydata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.applydata[k] = nil
                    break
                end
            end
            FriendsMgr:setDirty(true)
        end
        if code == 0 then
            FriendsMgr:MsgPop(response.data.status)
            for k,v in pairs(self.recommenddata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.recommenddata[k] = nil
                    break
                end
            end
            self:update()
        else
        end      
    end)
end

function FriendsInfoPanelUI:applyAll()
    local args = {
        ids = {}
    }

    for k,v in pairs(self.recommenddata) do
        if v ~= nil then
            table.insert(args.ids, v.uid) 
        end
    end

    MessageMgr:sendPost('apply_all', 'friend', json.encode(args), function (response)    
        local code = response.code
        local data = response.data

        if code == 0 then
            FriendsMgr:MsgPop(response.data.status)
            -- 刷新一遍
            self:refreshRecommandList()
        end      
    end)
end

function FriendsInfoPanelUI:initHeadNode(parent, arrdata)
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    cell.awardBgImg:loadTexture(COLOR_FRAME[arrdata.quality])
    cell.awardBgImg:setScale(0.8)
    cell.lvTx:setString('Lv.'..arrdata.level)
    local obj = RoleData:getHeadPicObj(tonumber(arrdata.headpic))
    cell.awardImg:loadTexture(obj:getIcon())
    cell.awardImg:ignoreContentAdaptWithSize(true)
    cell.headframeImg:loadTexture(GlobalApi:getHeadFrame(arrdata.headframe))
    cell.nameTx:setString('')
    local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0, 0.5))
    local rt1 = xx.RichTextLabel:create(arrdata.name..' ', 24,COLOR_TYPE.WHITE)
    local rt2 = xx.RichTextImage:create("uires/ui/chat/vip_small.png")
    local rt3 = xx.RichTextAtlas:create(arrdata.vip,"uires/ui/number/font_ranking.png", 20, 22, '0')
    rt:addElement(rt1)
    if tonumber(arrdata.vip) > 0 then
        rt:addElement(rt2)
        rt:addElement(rt3)
    end
    rt:setAlignment("left")
    rt:setVerticalAlignment('middle')
    rt:setPosition(cc.p(0, 0))
    rt:setContentSize(cc.size(400, 30))
    cell.nameTx:addChild(rt)
    cell.nameTx:setPosition(cc.p(100,70))

    -- 战斗力
    local rtfightforce = xx.RichText:create()
    rtfightforce:setAnchorPoint(cc.p(0.5, 0.5))
    local rtfightforce1= xx.RichTextImage:create("uires/ui/common/fightbg.png")
    local rtfightforce2 = xx.RichTextAtlas:create(arrdata.fight_force,"uires/ui/number/font_fightforce_3.png", 26, 38, '0')
    rtfightforce:addElement(rtfightforce1)
    rtfightforce:addElement(rtfightforce2)
    rtfightforce:setAlignment("middle")
    rtfightforce:setVerticalAlignment('middle')
    rtfightforce:setPosition(cc.p(410, 0))
    rtfightforce:setContentSize(cc.size(400, 30))
    rtfightforce:setScale(0.8)
    parent:addChild(rtfightforce)

    -- 军团名字
    if arrdata.legion_icon > 0 then
        local flag = ccui.ImageView:create('uires/ui/legion/' .. arrdata.legion_icon .. '_jun.png')
        local legionName = cc.Label:createWithTTF(arrdata.legion_name, "font/gamefont.ttf", 18)

        cell.nameTx:addChild(flag)
        cell.nameTx:addChild(legionName)

        flag:setScale(0.5)
        flag:setAnchorPoint(cc.p(0, 0.5))
        flag:setPosition(cc.p(0, -40))

        legionName:setTextColor(COLOR_TYPE.BROWN)
        legionName:setAnchorPoint(cc.p(0, 0.5))
        legionName:setPosition(cc.p(40, -40))
    else
        local legionName = cc.Label:createWithTTF(GlobalApi:getLocalStr_new('STR_NOT_JOIN_LEGION'), "font/gamefont.ttf", 18)
        cell.nameTx:addChild(legionName)
        legionName:setTextColor(COLOR_TYPE.BROWN)
        legionName:setAnchorPoint(cc.p(0, 0.5))
        legionName:setPosition(cc.p(0, -40))
    end

    parent:addChild(cell.awardBgImg)
end

function FriendsInfoPanelUI:initRecommandHeadNode(parent, arrdata)
    parent:removeChildByName('award_bg_img')

    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    cell.awardBgImg:loadTexture(COLOR_FRAME[arrdata.quality])
    cell.awardBgImg:setScale(0.8)
    --cell.lvTx:setString('Lv.'..arrdata.level)

    local obj = RoleData:getHeadPicObj(tonumber(arrdata.headpic))
    cell.awardImg:loadTexture(obj:getIcon())
    cell.awardImg:ignoreContentAdaptWithSize(true)
    cell.headframeImg:loadTexture(GlobalApi:getHeadFrame(arrdata.headframe))
    cell.nameTx:setString('')

    parent:addChild(cell.awardBgImg)
    cell.awardBgImg:setName('award_bg_img')

    -- 点击事件
    cell.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            release_print('uid = ' .. arrdata.uid)
            BattleMgr:showCheckInfo(arrdata.uid,'world',"country")
        end
    end)
end

return FriendsInfoPanelUI