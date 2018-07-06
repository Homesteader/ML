-- 文件：圣物觉醒界面
-- 创建：zzx
-- 日期：2017-12-18

local PeopleKingAwakeWeaponUI 		= class("PeopleKingAwakeWeaponUI", BaseUI)
local ClassItemCell 				= require('script/app/global/itemcell')

local STYPE 						= {'atk','hp','def','mdef'}

local TITLE_DESC = {
    [1] = GlobalApi:getLocalStr('PEOPLE_KING_TITLE_DESC_1'),
    [2] = GlobalApi:getLocalStr('PEOPLE_KING_TITLE_DESC_2'),
}
local BUTTON_RES = {
    [1] = 'uires/ui/peopleking/button_1.png',
    [2] = 'uires/ui/peopleking/button_2.png', 
}
local M_IDS = {
    [1] = tonumber(GlobalApi:getGlobalValue('skyGasCostId')),
    [2] = tonumber(GlobalApi:getGlobalValue('skyBloodCostId')),
}

function PeopleKingAwakeWeaponUI:ctor(page)
    self.uiIndex 		= GAME_UI.UI_PEOLPLE_KING_AWAKE_WEAPON
    self.page 			= page or 1
    self.conf 			= {
        [1] = GameData:getConfData('skygasawaken'),
        [2] = GameData:getConfData('skybloodawaken'),
    }
    self.leftPage 		= 1
    self.rightPage 		= 1
    self.effectCount 	= 0
    self.data 			= UserData:getUserObj():getPeopleKing()
end

function PeopleKingAwakeWeaponUI:init()
    local winSize 		= cc.Director:getInstance():getWinSize()
    local bgImg 		= self.root:getChildByName("bg_img")
    local bgImg2 		= bgImg:getChildByName("bg_img2")
    local contentBg 	= bgImg2:getChildByName('content_bg')
    local infoBg 		= contentBg:getChildByName('info_bg')

    self:adaptUI(bgImg, bgImg2)

    local closeBtn 		= bgImg2:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            PeopleKingMgr:hidePeopleKingAwakeWeaponUI()
        end
    end)

    self.pageBtns       		= {}

    for i = 1, 2 do
        local pageBtn           = bgImg2:getChildByName("page_"..i.."_btn")
        local infoTx            = pageBtn:getChildByName("info_tx")

        self.pageBtns[i]        = {}
        self.pageBtns[i].btn    = pageBtn
        self.pageBtns[i].tx     = infoTx

        infoTx:setString( GlobalApi:getLocalStr_new("STR_PEOPLEKING_DESC_" .. (9+i)) )
        pageBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:chooseWin(i)
            end
        end)
    end

    self.bgImg3 = infoBg

    self:setOldData()
    self:createRichTextDesc()
    self:chooseWin(self.page)
end

function PeopleKingAwakeWeaponUI:createRichTextDesc()
    local leftNode 		= self.bgImg3:getChildByName("left_bg")
    local rightNode 	= self.bgImg3:getChildByName("right_bg")

    local nodes 		= {leftNode,rightNode}
    -- local page = {self.leftPage,self.rightPage}

    for i,v in ipairs(M_IDS) do
        local material 		= BagData:getMaterialById(v)
        local iconNode 		= nodes[i]:getChildByName('icon_node')
        local nameTx 		= nodes[i]:getChildByName('name_tx')
        local awardBgImg 	= iconNode:getChildByName('award_bg_img')
        if not awardBgImg then
            local tab 		= ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
            awardBgImg 		= tab.awardBgImg
            iconNode:addChild(awardBgImg)
        end
        local lvTx 			= awardBgImg:getChildByName('lv_tx')
        ClassItemCell:updateItem(awardBgImg,material,2)
        lvTx:setVisible(false)

        nameTx:setString(material:getName())
        nameTx:setColor(material:getNameColor())
    end
end


function PeopleKingAwakeWeaponUI:getAttr(conf,level,ntype)
    local allAttr 		= {0,0,0,0}
    local attr 			= {0,0,0,0}

    local useNum 		= self:getUseCount(ntype)
    for i,v in ipairs(conf) do
        for j=1,4 do
            if i == level then
                attr[j] = v[STYPE[j]]
                allAttr[j] =  v[STYPE[j]]*useNum
            end
        end
    end
    return {attr,allAttr}
end

function PeopleKingAwakeWeaponUI:getLevel()
    local levels = {self.data.weapon_level,self.data.wing_level}
    return levels[self.page]
end

function PeopleKingAwakeWeaponUI:getUseCount(ntype)
    local counts = {
        [1] = {self.data.weapon_gas,self.data.weapon_blood},
        [2] = {self.data.wing_gas,self.data.wing_blood}
    }
    return counts[self.page][ntype]
end

function PeopleKingAwakeWeaponUI:setOldData(currAttr,fightforce)
    if currAttr then
        self.currAttr = currAttr
    else
        local attr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
        self.currAttr = {}
        for i = 1, 4 do
            self.currAttr[i] = attr[i] or 0
        end
    end
    self.oldfightforce = fightforce or RoleData:getFightForce()
end

function PeopleKingAwakeWeaponUI:popupTips()
    local newAttr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
    for i = 1, 4 do
        newAttr[i] = newAttr[i] or 0
    end
    RoleData:setAllFightForceDirty()
    local newfightforce = RoleData:getFightForce()
    GlobalApi:popupTips(self.currAttr, newAttr, self.oldfightforce, newfightforce)
    self:setOldData(newAttr,newfightforce)
end

function PeopleKingAwakeWeaponUI:lvUp(ntype,callback)

    -- 人皇圣武觉醒 mod: 'hero' act: 'awaken_sky_weapon' args:utype  1:精气石 2: 精血石
    -- 人皇圣翼觉醒 mod: 'hero' act: 'awaken_sky_wing' args:utype  1:精气石 2: 精血石
    -- local currAttr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
    -- for i = 1, 4 do
    --     currAttr[i] = currAttr[i] or 0
    -- end
    -- local oldfightforce = RoleData:getFightForce()
    self.effectCount = self.effectCount + 1
    local act = {
        [1] = 'awaken_sky_weapon',
        [2] = 'awaken_sky_wing',
    }
    local args = {
        utype = ntype
    }
    MessageMgr:sendPost(act[self.page],'hero',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            if self.page == 1 then
                if ntype == 1 then
                    self.data.weapon_gas = self.data.weapon_gas + 1
                else
                    self.data.weapon_blood = self.data.weapon_blood + 1
                end
            else
                if ntype == 1 then
                    self.data.wing_gas = self.data.wing_gas + 1
                else
                    self.data.wing_blood = self.data.wing_blood + 1
                end
            end
            -- local newAttr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
            -- for i = 1, 4 do
            --     newAttr[i] = newAttr[i] or 0
            -- end
            -- local newfightforce = RoleData:getFightForce()
            -- GlobalApi:popupTips(currAttr, newAttr, oldfightforce, newfightforce)
                    
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            if callback then
                callback()
            end
        else
            self.effectCount = self.effectCount - 1
            if self.effectCount <= 0 then
                self:popupTips()
            end
        end
    end)
end

function PeopleKingAwakeWeaponUI:updatePanel()
	local bgImg 		= self.root:getChildByName("bg_img")
    local bgImg2 		= bgImg:getChildByName("bg_img2")
    local titleTx 		= bgImg2:getChildByName("title_tx")

    titleTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_TITLE_AWAKE_"..self.page))

    self:updateLeft()
    self:updateRight()
end

function PeopleKingAwakeWeaponUI:playAction(node,callback)
    local particle = cc.ParticleSystemQuad:create("particle/bullet_guojia_2_p1.plist")
    particle:setPosition(cc.p(70, 350))
    -- particle:setScale(0.5)
    node:addChild(particle)

    local bezier = {
        cc.p(92,280),
        cc.p(50,150),
        cc.p(177,126)
    }
    local time = 0.5
    local bezierTo = cc.BezierTo:create(time, bezier)
    particle:runAction(cc.Sequence:create(bezierTo,cc.CallFunc:create(function()
        particle:removeFromParent()
        if callback then
            callback()
        end
    end)))
end

function PeopleKingAwakeWeaponUI:updateLeft()
    local ntype 		= 1
    local conf 			= self.conf[ntype][self.page]
    local level 		= self:getLevel()
    local material 		= BagData:getMaterialById(M_IDS[ntype])
    local leftNode 		= self.bgImg3:getChildByName("left_bg")

    local useTx 		= leftNode:getChildByName("use_tx")
    local desc1Tx 		= leftNode:getChildByName('desc_1_tx')

    local totalAttrAdd  = leftNode:getChildByName('total_attr_add_bg')
    local totalTitleTx 	= totalAttrAdd:getChildByName('title_tx')
    local attrAdd 		= leftNode:getChildByName('attr_add_bg')
    local oneTitleTx 	= attrAdd:getChildByName('title_tx')

    local haveDescNumTx = leftNode:getChildByName('have_num_desc_tx')
    local haveNumTx 	= leftNode:getChildByName('have_num_tx')

    local useBtn 		= leftNode:getChildByName('use_btn')
    local useBtnTx 		= useBtn:getChildByName('tx')

    local num 			= material:getNum()
    local useNum 		= self:getUseCount(ntype)
    local maxNum 		= conf[level].num
    local needLevel 	= 0

    for i,v in ipairs(conf) do
        if v.num > 0 then
            needLevel = i
            break
        end
    end

    useTx:setString( GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_14') .. useNum..'/'..maxNum)

    desc1Tx:setString( TITLE_DESC[self.page] .. GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_18') )
  
    haveDescNumTx:setString( GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_15') )
    haveNumTx:setString(num)

    if num > 0 then
        -- haveNumTx:setColor(COLOR_TYPE.GREEN)
        useBtnTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_21"))
    else
        -- haveNumTx:setColor(COLOR_TYPE.RED)
        useBtnTx:setString(GlobalApi:getLocalStr("GET_TEXT"))
    end

    totalTitleTx:setString( GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_16') )
    oneTitleTx:setString( string.format(GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_17'), material:getName()) )
   		
    local attrConf 		= GameData:getConfData("attribute") 
    local attrTab 		= self:getAttr(conf,level,ntype)
    local showAttr 		= {}

    showAttr[1] 		= attrTab[1][1] or 0
    showAttr[2] 		= attrTab[1][4] or 0
    showAttr[3] 		= attrTab[1][2] or 0
    showAttr[4] 		= attrTab[1][3] or 0

    for i = 1, 4 do
        local attrName 	= attrAdd:getChildByName("attr_name_" .. i)
        local attrNum 	= attrAdd:getChildByName("attr_num_" .. i)

        attrName:setString(attrConf[i].name)
        attrNum:setString(' +'.. showAttr[i]) 
    end

    local showAttr 		= {}

    showAttr[1] 		= attrTab[2][1] or 0
    showAttr[2] 		= attrTab[2][4] or 0
    showAttr[3] 		= attrTab[2][2] or 0
    showAttr[4] 		= attrTab[2][3] or 0

    for i = 1, 4 do
        local attrName 	= totalAttrAdd:getChildByName("attr_name_" .. i)
        local attrNum 	= totalAttrAdd:getChildByName("attr_num_" .. i)

        attrName:setString(attrConf[i].name)
        attrNum:setString(' +'.. showAttr[i]) 
    end

    useBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if num > 0 then
                if level < needLevel then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("PEOPLE_KING_DESC_8"),TITLE_DESC[self.page],needLevel), COLOR_TYPE.RED)
                    return
                end
                if useNum >= maxNum then
                    if level >= #conf then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('PEOPLE_KING_DESC_11'), COLOR_TYPE.RED)
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('PEOPLE_KING_DESC_10'), COLOR_TYPE.RED)
                    end
                else
                    self:lvUp(ntype,function()
                        self:playAction(leftNode,function()
                            self.effectCount = self.effectCount - 1
                            if self.effectCount <= 0 then
                                self:popupTips()
                            end
                            self:updateLeft()
                        end)
                    end)
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
                GetWayMgr:showGetwayUI(material,true)
            end
        end
    end)
end

function PeopleKingAwakeWeaponUI:updateRight()
    local ntype 		= 2
    local conf 			= self.conf[ntype][self.page]
    local level 		= self:getLevel()
    local material 		= BagData:getMaterialById(M_IDS[ntype])
    local leftNode 		= self.bgImg3:getChildByName("right_bg")

    local useTx 		= leftNode:getChildByName("use_tx")
    local desc1Tx 		= leftNode:getChildByName('desc_1_tx')

    local totalAttrAdd  = leftNode:getChildByName('total_attr_add_bg')
    local totalTitleTx 	= totalAttrAdd:getChildByName('title_tx')
    local attrAdd 		= leftNode:getChildByName('attr_add_bg')
    local oneTitleTx 	= attrAdd:getChildByName('title_tx')

    local haveDescNumTx = leftNode:getChildByName('have_num_desc_tx')
    local haveNumTx 	= leftNode:getChildByName('have_num_tx')

    local useBtn 		= leftNode:getChildByName('use_btn')
    local useBtnTx 		= useBtn:getChildByName('tx')

    local num 			= material:getNum()
    local useNum 		= self:getUseCount(ntype)
    local maxNum 		= conf[level].num
    local needLevel 	= 0

    for i,v in ipairs(conf) do
        if v.num > 0 then
            needLevel = i
            break
        end
    end

    useTx:setString( GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_14') .. useNum..'/'..maxNum)

    desc1Tx:setString( TITLE_DESC[self.page] .. GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_19') )
  
    haveDescNumTx:setString( GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_15') )
    haveNumTx:setString(num)

    if num > 0 then
        -- haveNumTx:setColor(COLOR_TYPE.GREEN)
        useBtnTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_21"))
    else
        -- haveNumTx:setColor(COLOR_TYPE.RED)
        useBtnTx:setString(GlobalApi:getLocalStr("GET_TEXT"))
    end

    totalTitleTx:setString( GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_16') )
    oneTitleTx:setString( string.format(GlobalApi:getLocalStr_new('STR_PEOPLEKING_DESC_17'), material:getName()) )
    
    local attrConf 		= GameData:getConfData("attribute") 
    local attrTab 		= self:getAttr(conf,level,ntype)
    local showAttr 		= {}

    showAttr[1] 		= attrTab[1][1] or 0
    showAttr[2] 		= attrTab[1][4] or 0
    showAttr[3] 		= attrTab[1][2] or 0
    showAttr[4] 		= attrTab[1][3] or 0

    for i = 1, 4 do
        local attrName 	= attrAdd:getChildByName("attr_name_" .. i)
        local attrNum 	= attrAdd:getChildByName("attr_num_" .. i)

        attrName:setString(attrConf[i].name)
        attrNum:setString(' +'.. showAttr[i] .. '%') 
    end

    local showAttr 		= {}

    showAttr[1] 		= attrTab[2][1] or 0
    showAttr[2] 		= attrTab[2][4] or 0
    showAttr[3] 		= attrTab[2][2] or 0
    showAttr[4] 		= attrTab[2][3] or 0

    for i = 1, 4 do
        local attrName 	= totalAttrAdd:getChildByName("attr_name_" .. i)
        local attrNum 	= totalAttrAdd:getChildByName("attr_num_" .. i)

        attrName:setString(attrConf[i].name)
        attrNum:setString(' +'.. showAttr[i] .. '%') 
    end

    useBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if num > 0 then
                if level < needLevel then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("PEOPLE_KING_DESC_8"),TITLE_DESC[self.page],needLevel), COLOR_TYPE.RED)
                    return
                end
                if useNum >= maxNum then
                    if level >= #conf then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('PEOPLE_KING_DESC_11'), COLOR_TYPE.RED)
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('PEOPLE_KING_DESC_10'), COLOR_TYPE.RED)
                    end
                else
                    self:lvUp(ntype,function()
                        self:playAction(leftNode,function()
                            self.effectCount = self.effectCount - 1
                            if self.effectCount <= 0 then
                                self:popupTips()
                            end
                            self:updateRight()
                        end)
                    end)
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
                GetWayMgr:showGetwayUI(material,true)
            end
        end
    end)
end

function PeopleKingAwakeWeaponUI:chooseWin(page)
    self.page = page

    for i = 1,2 do
        if i == self.page then
            self.pageBtns[i].btn:loadTextureNormal('uires/ui_new/common/select_tab_nor.png')
            self.pageBtns[i].btn:setTouchEnabled(false)
            self.pageBtns[i].btn:setScale(1)

            GlobalApi:setTabBtnTxt( self.pageBtns[i].tx, true )
        else
            self.pageBtns[i].btn:loadTextureNormal('uires/ui_new/common/select_tab_push.png')
            self.pageBtns[i].btn:setTouchEnabled(true)
            self.pageBtns[i].btn:setScale(0.9)
            
            GlobalApi:setTabBtnTxt( self.pageBtns[i].tx, false )
        end
    end

    self:updatePanel()
end

return PeopleKingAwakeWeaponUI