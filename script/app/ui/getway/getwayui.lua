local GetWayUI = class("GetWayUI", BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

function GetWayUI:ctor(obj,showgetway,num,posobj,lv,ismerge)
	self.uiIndex = GAME_UI.UI_GETWAY
	self.listview = nil
    self.obj = obj
    self.posobj = posobj
    self.neednum = num
    self.showgetway = showgetway
    self.lv = lv
    self.roleCellTable = {}
    self.ismerge = ismerge
    self.extranum = 0
end

function GetWayUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            GetWayMgr:hideGetwayUI()
        end
    end)
	local bgimg1 = bgimg:getChildByName('bg_img1')
    self:adaptUI(bgimg, bgimg1)
    self.bgimg2 = bgimg1:getChildByName('bg_img6')
	local closebtn = self.bgimg2:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)        
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:hideGetwayUI()
        end
    end)
    if not self.showgetway then
        closebtn:setVisible(false)
    end
    for i=1,8 do
        local pl = self.bgimg2:getChildByName('head_'..i..'_pl')
        pl:setVisible(false)
    end

    local clickTx = self.bgimg2:getChildByName("click_tx")
    clickTx:setString(GlobalApi:getLocalStr_new("COMMON_STR_CONTINUE"))
    clickTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))

    self:initHead()
    self:initBottom()
end

function GetWayUI:initHead()
    local typestr = self.obj:getObjType()
    print("typestr" ,typestr)
    if typestr =='material' then
        self.parent = self.bgimg2:getChildByName('head_5_pl')
        self:initMaterial()
    elseif typestr == 'card' then
        self.parent = self.bgimg2:getChildByName('head_2_pl')
        self:initRole()
    elseif typestr == 'equip' then
        self.parent = self.bgimg2:getChildByName('head_3_pl')
        self:initEquip()
    elseif typestr == 'fragment' then
        self.parent = self.bgimg2:getChildByName('head_4_pl')
        self:initFragment()
    elseif typestr == 'gem' then
        self.parent = self.bgimg2:getChildByName('head_5_pl')
        self:initGem()
    elseif typestr == 'dress' then
        self.parent = self.bgimg2:getChildByName('head_6_pl')
        self:initDress()
    elseif typestr == 'user' then
        self.parent = self.bgimg2:getChildByName('head_1_pl')
        self:initUse()
    elseif typestr == 'dragon' then
        self.parent = self.bgimg2:getChildByName('head_1_pl')
        self:initDragon()
    elseif typestr == 'headframe' then
        self.parent = self.bgimg2:getChildByName('head_1_pl')
        self:initMaterial()
    elseif typestr == "limitmat" then
        self.parent = self.bgimg2:getChildByName('head_7_pl')
        self:initLimitMat()
    elseif typestr == "skyweapon" or typestr == "skywing" then
        self.parent = self.bgimg2:getChildByName('head_8_pl')
        self:initPeopleKing()
    elseif typestr == "group" then
        local getWayType = self.obj:getShowGetWayType() or 0
        if getWayType == 0 then
            self.parent = self.bgimg2:getChildByName('head_1_pl')
        end
        self:initGroup(getWayType)
    end
    self.parent:setVisible(true)
end

function GetWayUI:initFragment()
    local cardobj = RoleData:getRoleInfoById(self.obj:getId())
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, cardobj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    local getwarytx = self.parent:getChildByName('getway_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infobtn = self.parent:getChildByName('info_btn')
    local infobtntx = infobtn:getChildByName('func_tx')
    infobtntx:setString(GlobalApi:getLocalStr('INFO'))
    infobtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if ChartMgr.uiClass["chartInfoUI"] then
                GetWayMgr:hideGetwayUI()
            else
                ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.CHIP_MERGET, self.obj)
            end           
        end
    end)
    
    getwarytx:setString(GlobalApi:getLocalStr('STR_GETWAY2'))
    local richText = xx.RichText:create()
    local hasnum = 0
    if self.showgetway then
        hasnum =self.obj:getNum()
    else
        hasnum =self.obj:getOwnNum()
    end
    local neednum = self.obj:getMergeNum()
    local tx1 = hasnum
    local tx2 = '/' .. neednum ..')'
    local tx3 = '('
    richText:setContentSize(cc.size(130, 40))
    local re1 = xx.RichTextLabel:create(tx1,23, COLOR_TYPE.RED)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(tx2,23, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create(tx3,23, COLOR_TYPE.WHITE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re3)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(numtx:getPositionX(),numtx:getPositionY()))
    self.parent:addChild(richText,9527)
    richText:setVisible(true)
end

function GetWayUI:initDress()
    local infobtn = self.parent:getChildByName("info_btn")
    local infotx = infobtn:getChildByName('func_tx')
    infotx:setString(GlobalApi:getLocalStr('EQUIP'))
    local getwaytx = self.parent:getChildByName('desc_3')
    local limittx =self.parent:getChildByName('limit_tx')
    if self.showgetway  then
        infobtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType ==  ccui.TouchEventType.ended then
                local hasnum = self.obj:getNum()
                if hasnum >= self.neednum then
                    local args = {
                        pos = self.posobj:getPosId(),
                        slot = self.obj:getId()%10
                    }
                    MessageMgr:sendPost("dress_wear", "hero", json.encode(args), function (jsonObj)
                        print(json.encode(jsonObj))
                        local code = jsonObj.code
                        if code == 0 then
                            local awards = jsonObj.data.awards
                            GlobalApi:parseAwardData(awards)
                            local costs = jsonObj.data.costs
                            if costs then
                                GlobalApi:parseAwardData(costs)
                            end
                            self.posobj:setSoldierdress(self.obj:getId()%10)
                            self.posobj:setFightForceDirty(true)
                            RoleMgr:updateRoleMainUI()
                            GetWayMgr:hideGetwayUI()
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('EQUIP_SUCC'), COLOR_TYPE.GREEN)
                        end
                    end)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
                end
            end
        end)
        infobtn:setVisible(true)


        getwaytx:setString('')
        local numtx = self.parent:getChildByName('desc_3')

        local richText = xx.RichText:create()
        local hasnum = 0
        if self.showgetway then
            hasnum =self.obj:getNum()
        else
            hasnum = self.obj:getOwnNum()
        end

        local tx1 = hasnum
        local tx2 = '/' .. self.neednum ..')'
        local tx3 = '('
        local tx4 = GlobalApi:getLocalStr('STR_GETWAY2')..':'
        richText:ignoreContentAdaptWithSize(false)
        richText:setContentSize(cc.size(250, 40))
        local re1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.WHITE)
        re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
        re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re3 = xx.RichTextLabel:create(tx3,21, COLOR_TYPE.WHITE)
        re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re4 = xx.RichTextLabel:create(tx4,21, COLOR_TYPE.ORANGE)
        re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

        local infotx = infobtn:getChildByName('func_tx')
        if hasnum >= self.neednum then
            --re1:setColor(COLOR_TYPE.WHITE)
            infobtn:setBright(true)
            infobtn:setEnabled(true)
            infotx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
        else
            re1:setColor(COLOR_TYPE.RED)
            infobtn:setBright(false)
            infobtn:setEnabled(false)
            infotx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        end
        
        richText:addElement(re4)
        richText:addElement(re3)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:setAnchorPoint(cc.p(0,1))
        richText:setAlignment('left')
        richText:setPosition(cc.p(0,0))
        numtx:addChild(richText,9527)
        richText:setVisible(true)
        if self.ismerge then
            infobtn:setVisible(false)
            re1:setString(hasnum)
            re2:setString('')
            re3:setString('')
        else
            if self.posobj and tonumber(self.posobj:getLevel()) < tonumber(self.lv) then
                limittx:setString(string.format(GlobalApi:getLocalStr('STR_NEEDLV'),self.lv))
                infobtn:setVisible(false)
            else
                limittx:setString('')
                infobtn:setVisible(true)
            end
        end
        richText:format(true)
    else
        infobtn:setVisible(false)
        getwaytx:setString('')
        limittx:setString('')
        local infotx = self.parent:getChildByName('desc_3')
        infotx:ignoreContentAdaptWithSize(false)
        infotx:setTextAreaSize(cc.size(250,80))
        infotx:setString(self.obj:getDesc())
        local richText = xx.RichText:create()
        local neednum = self.neednum
        local tx1 = GlobalApi:getLocalStr('STR_HAD')
        local tx2 = self.obj:getOwnNum()
        local tx3 = GlobalApi:getLocalStr('GE')

        richText:setContentSize(cc.size(200, 40))
        local re1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.ORANGE)
        re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
        re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re3 = xx.RichTextLabel:create(tx3,21, COLOR_TYPE.ORANGE)
        re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:setAnchorPoint(cc.p(1,0.5))
        richText:setAlignment('right')
        richText:setPosition(cc.p(400,87))
        self.parent:addChild(richText,9527)
        richText:setVisible(true)
    end
    local nametx = self.parent:getChildByName('name_tx')
    nametx:setString(self.obj:getName())

    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)
end

function GetWayUI:initGem()
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.awardBgImg:setScale(0.9)
    cell.lvTx:setVisible(false)

    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infotx = self.parent:getChildByName('info_tx')
    local attrtx = self.parent:getChildByName('attr_tx')
    local part_tx = self.parent:getChildByName('part_tx')
    
    infotx:ignoreContentAdaptWithSize(false)
    infotx:setTextAreaSize(cc.size(294,80))
    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(self.obj:getDesc())

    local gemId = self.obj:getId()
    local gemcfg = GameData:getConfData("gem")[gemId]
    local attributeCfg = GameData:getConfData("attribute")[gemcfg.attType]

    local attrName = attributeCfg.name
    local attrValue = gemcfg.value
    attrtx:setString(attrName.."+"..attrValue)

    local partName = ''
    for i=1,#gemcfg.partId do
        local partId = gemcfg.partId[i]
        local str = GlobalApi:getLocalStr_new("EQUIP_TYPE_"..partId)
        if i ~= #gemcfg.partId then
            partName = partName .. str .. "、"
        else
            partName = partName .. str
        end

    end
    local patrStr = GlobalApi:getLocalStr_new("COMMON_STR_PARTDESC")
    part_tx:setString(patrStr..partName)
end

function GetWayUI:initMaterial()
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.awardBgImg:setScale(0.9)
    cell.lvTx:setVisible(false)
    
    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('own_tx')
    local infotx = self.parent:getChildByName('info_tx')
    infotx:ignoreContentAdaptWithSize(false)
    infotx:setTextAreaSize(cc.size(294,80))
    
    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(self.obj:getDesc())
    numtx:setString(GlobalApi:getLocalStr_new("COMMON_STR_OWN")..self.obj:getOwnNum())
end

function GetWayUI:initLimitMat()
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)
    cell.awardBgImg:setScale(0.9)
    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infotx = self.parent:getChildByName('info_tx')
    local timetx = self.parent:getChildByName('time_tx')

    infotx:ignoreContentAdaptWithSize(false)
    infotx:setTextAreaSize(cc.size(294,80))
    timetx:setString('')
    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(self.obj:getDesc())
    infotx:setFontSize(22)
    self.obj:setLightEffect(cell.awardBgImg)

    local itemId = tonumber(GlobalApi:getGlobalValue('heroQualityCostItem'))
    if self.obj:getId() == itemId then
        infotx:setFontSize(17)
    elseif self.obj:getId() == 200064 then
        infotx:setFontSize(19)
    end
    
    local time = 0--GlobalData:getServerTime()
    if tonumber(self.obj:getTimeType()) == 1 then
        time = self.obj:getTime()
        local str1 = string.sub(time,1,-7)
        local str2 = string.sub(time,5,-5)
        local str3 = string.sub(time,7,-3)
        local str4 = string.sub(time,9)
        local str =  str1..GlobalApi:getLocalStr('YEAR')..str2..GlobalApi:getLocalStr('MONTH')..str3..GlobalApi:getLocalStr('DAY_DESC_1')
        local strtemp = GlobalApi:getLocalStr('LIMIT_TIME_DESC')..str..str4..GlobalApi:getLocalStr('HOUR')
        timetx:setString(strtemp)
    elseif tonumber(self.obj:getTimeType()) == 2 then
        time = self.obj:getTime()
        timetx:setString( GlobalApi:getLocalStr('LIMIT_DESC')..'：'..time..GlobalApi:getLocalStr('DAY'))
    end
    
end

function GetWayUI:initDragon()
    local attconf = GameData:getConfData('attribute')
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infotx = self.parent:getChildByName('info_tx')
    infotx:ignoreContentAdaptWithSize(false)
    infotx:setTextAreaSize(cc.size(250,80))
    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(GlobalApi:getLocalStr("TRARIN_DRAGON_GET_ATTR") .. self.obj:getAttNum() .. "%" .. attconf[self.obj:getAttType()].name)
    infotx:setFontSize(22)
end

function GetWayUI:initUse()
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.awardBgImg:setScale(0.9)
    cell.lvTx:setVisible(false)

    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infotx = self.parent:getChildByName('info_tx')
    infotx:ignoreContentAdaptWithSize(false)
    infotx:setTextAreaSize(cc.size(230,80))
    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(self.obj:getDesc())
end

function GetWayUI:initRole()
    local cardobj = RoleData:getRoleInfoById(self.obj:getId())
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, cardobj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local chipnumtx = self.parent:getChildByName('chip_num_tx')
    nametx:setString(cardobj:getName())
    nametx:setColor(cardobj:getNameColor())

    local richText = xx.RichText:create()
    local cardobj1 =BagData:getCardById(self.obj:getId())
    local hasnum = 0
    if cardobj1 ~= nil then
        if self.showgetway then
            hasnum = cardobj1:getOwnNum()
        else
            hasnum = self.obj:getNum()
        end
    else

    end
    local tx1 = GlobalApi:getLocalStr('STR_HAD')
    local tx2 = hasnum
    local tx3 = GlobalApi:getLocalStr('STR_ZHANG')
    richText:setContentSize(cc.size(130, 40))
    local re1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create(tx3,21, COLOR_TYPE.ORANGE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(numtx:getPositionX(),numtx:getPositionY()-6))
    self.parent:addChild(richText,9527)
    richText:setVisible(true)

    local richTextchip = xx.RichText:create()
    local hasnum = 0
    if cardobj:getId() <= 10000 then
        local fragmentobj1 = BagData:getFragmentById(cardobj:getId())
        if fragmentobj1 ~= nil then
            if self.showgetway then
                hasnum =fragmentobj1:getNum()
            else
                hasnum = fragmentobj1:getOwnNum()
            end
        end
        local neednum = GameData:getConfData("item")[tonumber(cardobj:getId())]['mergeNum']
        --local neednum = fragmentobj1:getMergeNum()
        local tx1 = hasnum
        local tx2 = '/' .. neednum ..')'
        local tx3 = '('
        --local tx4 = '碎片数量：'
        richTextchip:setContentSize(cc.size(260, 40))
        local rechip1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.RED)
        rechip1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local rechip2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
        rechip2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local rechip3 = xx.RichTextLabel:create(tx3,21, COLOR_TYPE.WHITE)
        rechip3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local rechip4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_MERGE_DES2'),21, COLOR_TYPE.WHITE)
        rechip4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

        if hasnum >= neednum then
            rechip1:setColor(COLOR_TYPE.WHITE)
        else
            rechip1:setColor(COLOR_TYPE.RED)
        end
        richTextchip:addElement(rechip4)
        richTextchip:addElement(rechip3)
        richTextchip:addElement(rechip1)
        richTextchip:addElement(rechip2)
        richTextchip:setAnchorPoint(cc.p(0,0.5))
        richTextchip:setPosition(cc.p(chipnumtx:getPositionX(),chipnumtx:getPositionY()-5))
        self.parent:addChild(richTextchip,9527)
        richTextchip:setVisible(true)
    end
end

function GetWayUI:initEquip()

    local iconBgNode = self.parent:getChildByName('icon_bg_node')

    local equipObj = self.obj
    if self.obj.getObj then
        equipObj = self.obj:getObj()
    end

    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, equipObj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    --name
    local nametx = self.parent:getChildByName('name_tx')
    local attrtx = self.parent:getChildByName('attr_tx')
    nametx:setString(equipObj:getName())
    nametx:setColor(equipObj:getNameColor())
    nametx:enableOutline(equipObj:getNameOutlineColor(), 2)

    local equipCfg = GameData:getConfData('equipconf')
    local equipConf = equipCfg[self.obj:getId()]
    local equipQuality = equipConf.quality
    local equipType = equipConf.type
    local suitId = equipConf.suitId
    local equipbaseCnf =GameData:getConfData('equipbase')[equipType][equipQuality]

     --品级
    local equipGrade = equipObj:getGrade() or 0
    local equipGradeIcon = self.parent:getChildByName('equip_grade')
    equipGradeIcon:loadTexture(equipObj:getGradeIcon())

    local attributeConf = GameData:getConfData("attribute")

    --主属性
    local mainAttr = equipObj:getMainAttribute()
    local attrName = mainAttr.name
    attrtx:setString('')
    local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0, 0.5))
    local rt1 = xx.RichTextLabel:create(mainAttr.name, 18, COLOR_TYPE.YELLOW1)
    rt1:setStroke(COLOROUTLINE_TYPE.YELLOW1, 2)
    rt1:clearShadow()
    local rt2 = xx.RichTextLabel:create("+"..mainAttr.value, 18, COLOR_TYPE.WHITE1)
    rt2:setStroke(COLOROUTLINE_TYPE.OFFWHITE1, 2)
    rt2:clearShadow()
    rt:addElement(rt1)
    rt:addElement(rt2)
    rt:setAlignment("left")
    rt:setPosition(cc.p(0,0))
    rt:setContentSize(cc.size(150, 30))
    rt:format(true)
    attrtx:addChild(rt)

    --最高精炼等级
    local refineLv,refineMaxLv = equipObj:getRefineLv()
    local refineLvtx = self.parent:getChildByName('refine_lv')
    local str = string.format(GlobalApi:getLocalStr_new("GETWAY_MAIN_INFO1"),refineMaxLv)
    refineLvtx:setString(str)
    
    --强化成长
    local strengthNum = equipObj:getStrengthGrowth()
    local streng_tx = self.parent:getChildByName('streng_tx') 
    local str = GlobalApi:getLocalStr_new("GETWAY_MAIN_INFO2")..attrName.."+"..strengthNum
    streng_tx:setString(str)

    --精炼成长
    local refine_tx = self.parent:getChildByName('refine_tx') 
    local refineGrowth = equipObj:getRefineGrowth()
    local refineSpecialAttr = equipObj:getRefineSpecialAttr()
    local refineSpecialAdd = equipObj:getRefineSpecialGrowth()
    local attrdesc = refineSpecialAttr.desc == '0' and '' or refineSpecialAttr.desc
    local str = GlobalApi:getLocalStr_new("GETWAY_MAIN_INFO3")..attrName.."+"..refineGrowth
    str = str .. " "..refineSpecialAttr.name .. "+"..refineSpecialAdd..attrdesc
    refine_tx:setString(str)

    --归属
    local belongName = equipObj:getbelongName()
    local belong_icon = self.parent:getChildByName('belong_icon')
    local belongNameTx = self.parent:getChildByName('belong_name')
    belong_icon:setVisible(belongName~='')
    belongNameTx:setString(belongName)

    --套装
    local suit = equipObj:getSuitId()
    local suitCfg = GameData:getConfData("equipsuit")[suitId]
    local suit_tx = self.parent:getChildByName('suit_tx')
    local equips = equipObj:getOtherEquips()
    local suitCont = 0 
    for i=1,6 do
        local equipId = suitCfg["equip"..i]
        local quality = equipCfg[equipId].quality
        local equipIcon = equipCfg[equipId].icon
        local suitFrame = self.parent:getChildByName('suit_frame'..i)
        suitFrame:loadTexture(COLOR_FRAME_TYPE[quality])
        local equipImg = suitFrame:getChildByName("equip")
        equipImg:loadTexture("uires/icon/equip/" .. equipIcon)
        local isSuit = false
        for k,v in pairs(equips) do
            if v.id == equipId then
                isSuit = true
                break
            end
        end

        if isSuit then
            ShaderMgr:restoreWidgetDefaultShader(suitFrame)
            ShaderMgr:restoreWidgetDefaultShader(equipImg)
            suitCont = suitCont + 1
        else
            ShaderMgr:setGrayForWidget(suitFrame)
            ShaderMgr:setGrayForWidget(equipImg)
        end        
    end
    suit_tx:setString(suitCfg.name.."("..suitCont.."/6)")

    --套装效果
    for i=1,3 do
        local effectTx = self.parent:getChildByName('suit_effect_tx'..i)
        local needSuitCnt = i*2
        local suitStr = string.format(GlobalApi:getLocalStr_new("GETWAY_MAIN_INFO4"),needSuitCnt)
        local suitattr = suitCfg['attribute'..needSuitCnt]
        local attrStr = ''
        local attrCont = #suitattr
        for attrIndex = 1,attrCont do
            local attr = suitattr[attrIndex]
            local attrId,attrValue = GlobalApi:getAttrTypeAndValue(attr)
            local attrDesc = attributeConf[attrId].desc == '0' and '' or attributeConf[attrId].desc
            local attrName = attributeConf[attrId].name
            local attrValueStr = "+"..attrValue..attrDesc
            attrStr = attrStr .. attrName..attrValueStr.." "
        end
        effectTx:setString(suitStr..attrStr)

        if suitCont >= needSuitCnt then
            effectTx:setTextColor(cc.c4b(19, 138, 12, 255))
        else
            effectTx:setTextColor(cc.c4b(84, 90, 103, 255))
        end
    end

    --描述
    local infotx = self.parent:getChildByName('info_tx')
    infotx:setString(self.obj:getDesc())
end

function GetWayUI:initPeopleKing()

    local modelNode = self.parent:getChildByName('model_node')
    local nameTx = self.parent:getChildByName('name_tx')
    local typeNameTx = self.parent:getChildByName('typename_tx')
    local timeTx = self.parent:getChildByName('time_tx')
    local attrTx = self.parent:getChildByName('attr_tx')

    local customObj = {}
    local typestr = self.obj:getObjType()
    local id = self.obj:getId()
    local typeid,typenameStr = 1,''
    if typestr == "skyweapon" then
        typeid = 1
        customObj.weapon_illusion = id
        typenameStr = GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_1")
    elseif typestr == "skywing" then
        typeid = 2
        customObj.wing_illusion = id
        typenameStr = GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_2")
    end

    typeNameTx:setString(typenameStr)
    local roleObj = RoleData:getMainRole()
    local mainRoleAni = GlobalApi:createLittleLossyAniByName(roleObj:getUrl() .. "_display", nil, roleObj:getChangeEquipState(customObj))
    mainRoleAni:getAnimation():play("idle", -1, 1)
    mainRoleAni:setPosition(cc.p(0, 0))
    modelNode:addChild(mainRoleAni)

    local name = self.obj:getName()
    nameTx:setString(name)

    local timeType = self.obj:getTimeType()
    if timeType == "2" then
        timeTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_9"))
    else
        local time = self.obj:getTime()
        local str = string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_11"),time)
        timeTx:setString(str)
    end

    local skychangeConf = GameData:getConfData("skychange")[typeid]
    local confInfo = skychangeConf[id]
    if confInfo.attribute == 0 then
        attrTx:setString("")
    else
        local str = string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_10"),typenameStr,confInfo.attribute).."%"
        attrTx:setString(str)
    end

end

function GetWayUI:initGroup(getWayType)
    if getWayType == 0 then
        local iconBgNode = self.parent:getChildByName('icon_bg_node')
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
        cell.awardBgImg:setTouchEnabled(false)
        cell.lvTx:setVisible(false)
        cell.awardBgImg:setScale(0.9)

        local nametx = self.parent:getChildByName('name_tx')
        local numtx = self.parent:getChildByName('num_tx')
        local infotx = self.parent:getChildByName('info_tx')
        infotx:ignoreContentAdaptWithSize(false)
        infotx:setTextAreaSize(cc.size(230,80))
        nametx:setString(self.obj:getName())
        nametx:setColor(self.obj:getNameColor())
        infotx:setString(self.obj:getDesc())
    end
end

function GetWayUI:initBottom()

    self.getWayArr = GetWayMgr:getWayArr()
    local bgimg3 = self.bgimg2:getChildByName('bg_img2')
    local bgimg4 = self.bgimg2:getChildByName('bg_img5')
    local bgimg5 = self.bgimg2:getChildByName('bg_img7')
    local bgimg8 = self.bgimg2:getChildByName('bg_img8')
    local bgimg9 = self.bgimg2:getChildByName('bg_img9')
    
    local getwayimg = bgimg3:getChildByName('way_img')
    local getwaytx = getwayimg:getChildByName('way_tx')
    getwaytx:setString(GlobalApi:getLocalStr('STR_GETWAY'))
    -- local conf = GameData:getConfData('getway')[self.getWayArr[1]]
    bgimg4:setVisible(false)
    bgimg5:setVisible(false)
    bgimg8:setVisible(false)
    bgimg3:setVisible(false)
    bgimg9:setVisible(false)

    if self.showgetway and self.getWayArr and GameData:getConfData('getway')[self.getWayArr[1]] then
        bgimg3:setVisible(true)
        self.listview = bgimg3:getChildByName('getway_listview')
        local node = cc.CSLoader:createNode("csb/getwaycell.csb")
        local cellbgimg = node:getChildByName("bg_img")
        self.listview:setItemModel(cellbgimg)
        self.listview:setScrollBarEnabled(false)
        self:initSv()
    else
        local typestr = self.obj:getObjType()
        if typestr == "skyweapon" or typestr == "skywing" then
            bgimg8:setVisible(true)
        elseif typestr == 'limitmat' or typestr == 'gem' or typestr == 'material' then
            bgimg5:setVisible(true)
        elseif typestr == 'equip' then
            bgimg9:setVisible(true)
        else
            bgimg4:setVisible(true)
        end
    end
end

function GetWayUI:initSv()
    local cellnum = #self.getWayArr
    local isaddextion = false
    for i=1,cellnum do
        local count,maxcount,ispass,objarr = GetWayMgr:getwayCountarr(self.getWayArr[i],i)
        self.extranum = self.extranum + #objarr

        if #objarr > 0 then
            isaddextion = true
            self:initMap(i,objarr)           
        else
            self.listview:pushBackDefaultItem()
            local index = 0
            if isaddextion then
                index = i-1 + self.extranum -1
            else
                index = i - 1
            end
            local item = self.listview:getItem(index)
            item:setName('item_'..index)
            item:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:hideGetwayUI()
                    GetWayMgr:goto(self.getWayArr[i],self.neednum)
                end
            end)
            local contentsize = item:getContentSize()
            local getwayconf = GameData:getConfData('getway')[tonumber(self.getWayArr[i])]
            local chapternumtx = item:getChildByName('chapter_num_tx')
            chapternumtx:setString(getwayconf.name)
            local chapternametx = item:getChildByName('chapter_name_tx')
            chapternametx:setString(getwayconf.desc)
            local chapterimg = item:getChildByName('arrow_img')
            chapterimg:ignoreContentAdaptWithSize(true)
            chapterimg:loadTexture('uires/ui/getway/' ..getwayconf.icon)
            local gopl = item:getChildByName('go_pl')
            local infotx = item:getChildByName('info_tx')
            infotx:setString(GlobalApi:getLocalStr('STR_NOTOPEN'))
            local starpl = item:getChildByName('star_pl')
            starpl:setVisible(false)
            if getwayconf.havelimit == "1" then
                local hasnum = count
                local neednum = '/' ..maxcount ..'）'
                local tx = '（' --..
                local richText = xx.RichText:create()
                richText:setContentSize(cc.size(200, 40))
                local re1 = xx.RichTextLabel:create(hasnum,23, COLOR_TYPE.RED)
                if hasnum > 0 then
                    re1:setColor(COLOR_TYPE.WHITE)
                else
                    re1:setColor(COLOR_TYPE.RED)
                end
                re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                local re2 = xx.RichTextLabel:create(neednum,23, COLOR_TYPE.WHITE)
                re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                local re3 = xx.RichTextLabel:create(tx,23, COLOR_TYPE.WHITE)
                re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_COUNT'),23, COLOR_TYPE.ORANGE)
                re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                richText:addElement(re4)
                richText:addElement(re3)
                richText:addElement(re1)
                richText:addElement(re2)
                richText:setAnchorPoint(cc.p(0,0.5))
            
                richText:format(true)
                item:addChild(richText,9527)
                richText:setVisible(true)

                if #objarr < 1 then
                    richText:setPosition(cc.p(103.80,32.55))
                    chapternametx:setString('')-- printall(mapobj)
                end
            end
            print('ispass==='..tostring(ispass))
            if ispass then
                gopl:setVisible(true)
                infotx:setVisible(false)
                item:setTouchEnabled(true)
            else
                infotx:setVisible(true)
                gopl:setVisible(false)
                item:setTouchEnabled(false)
            end
        end
    end
end

function GetWayUI:initMap(index,objarr)
    for i=1,#objarr do
        self.listview:pushBackDefaultItem()
        local item = self.listview:getItem(index-1+i-1)
        item:setName('item_'..(index-1+i-1))
        item:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                print('self.getWayArr[index]'..self.getWayArr[index])
                if self.getWayArr[index] == 101 then
                    if objarr[i][2] then
                        GlobalApi:getGotoByModule('expedition',nil,{objarr[i][1]:getId(),1,self.obj,self.neednum})
                    end
                elseif self.getWayArr[index]  == 201 then
                    if objarr[i][2] then
                        GlobalApi:getGotoByModule('expedition',nil,{objarr[i][1]:getId(),2,self.obj,self.neednum})
                    end
                elseif self.getWayArr[index]  == 401 then
                    if objarr[i][2] then
                        GlobalApi:getGotoByModule('combat',nil,{objarr[i][1]:getId(),self.obj})
                    end
                elseif self.getWayArr[index]  == 701 then
                    if objarr[i][2] then
                        GlobalApi:getGotoByModule('lord',nil,{objarr[i][1]:getId()})
                    end
                end
                GetWayMgr:hideGetwayUI()
            end
        end)
        local contentsize = item:getContentSize()
        local getwayconf = GameData:getConfData('getway')[tonumber(self.getWayArr[index])]
        local chapternumtx = item:getChildByName('chapter_num_tx')
        chapternumtx:setString(getwayconf.name)
        local chapternametx = item:getChildByName('chapter_name_tx')
        chapternametx:setString(getwayconf.desc)
        local chapterimg = item:getChildByName('arrow_img')
        chapterimg:ignoreContentAdaptWithSize(true)
        chapterimg:loadTexture('uires/ui/getway/' ..getwayconf.icon)
        local gopl = item:getChildByName('go_pl')
        local infotx = item:getChildByName('info_tx')
        infotx:setString(GlobalApi:getLocalStr('STR_NOTOPEN'))
        local starpl = item:getChildByName('star_pl')
        starpl:setVisible(true)
        local stararr = {}
        for i=1,3 do
            local starbg = starpl:getChildByName('star_bg_'..i)
            stararr[i] = starbg:getChildByName('star_img')
            stararr[i]:setVisible(false)
        end
        local richText
        if getwayconf.havelimit == '1' then
            local hasnum = objarr[i][1]:getDayLimits(objarr[i][4])-objarr[i][1]:getTimes(objarr[i][4])
            local neednum = '/' ..objarr[i][1]:getDayLimits(objarr[i][4]) ..'）'
            local tx = '（' --..
            richText = xx.RichText:create()
            richText:setContentSize(cc.size(200, 40))
            local re1 = xx.RichTextLabel:create(hasnum,23, COLOR_TYPE.RED)
            if hasnum > 0 then
                re1:setColor(COLOR_TYPE.WHITE)
            else
                re1:setColor(COLOR_TYPE.RED)
            end
            re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            local re2 = xx.RichTextLabel:create(neednum,23, COLOR_TYPE.WHITE)
            re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            local re3 = xx.RichTextLabel:create(tx,23, COLOR_TYPE.WHITE)
            re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_COUNT'),23, COLOR_TYPE.ORANGE)
            re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            richText:addElement(re4)
            richText:addElement(re3)
            richText:addElement(re1)
            richText:addElement(re2)
            richText:setAnchorPoint(cc.p(0,0.5))
        
            richText:format(true)
            item:addChild(richText,9527)
            richText:setVisible(true)
            if objarr[i][2] and objarr[i][3] then
                gopl:setVisible(true)
                infotx:setVisible(false)
                item:setTouchEnabled(true)
                starpl:setVisible(true)
            else
                infotx:setVisible(true)
                gopl:setVisible(false)
                item:setTouchEnabled(false)
                starpl:setVisible(false)
            end
        end

        if tonumber(self.getWayArr[index]) == 101 then
            chapternumtx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('NORMAL2') ..']')
            chapternumtx:setTextColor(COLOR_TYPE.WHITE)
            chapternametx:setString('')
            richText:setPosition(cc.p(103.80,32.55))
            starpl:setVisible(false)
            -- for i=1,objarr[i][1]:getStar(objarr[i][4]) do
            --     stararr[i]:setVisible(true)
            -- end
        elseif tonumber(self.getWayArr[index]) == 201 then
            chapternumtx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('ELITE2') ..']')
            chapternumtx:setTextColor(COLOR_TYPE.WHITE)
            chapternametx:setString('')
            richText:setPosition(cc.p(103.80,32.55))
            if objarr[i][2] and objarr[i][3] then
                starpl:setVisible(true)
                for i=1,objarr[i][1]:getStar(objarr[i][4])  do
                    stararr[i]:setVisible(true)
                end
            end
        elseif tonumber(self.getWayArr[index]) == 401 then
            chapternumtx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('COMBAT2') ..']')
            chapternumtx:setTextColor(COLOR_TYPE.WHITE)
            chapternametx:setString('')
            richText:setPosition(cc.p(103.80,32.55))
            starpl:setVisible(false)
            -- for i=1,objarr[i][1]:getStar(objarr[i][4])  do
            --     stararr[i]:setVisible(true)
            -- end
        else
            if  tonumber(self.getWayArr[index]) == 101 then
                chapternametx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('NORMAL2') ..']'..GlobalApi:getLocalStr('STR_DROP'))-- printall(mapobj)
            elseif tonumber(self.getWayArr[index]) == 201 then
                chapternametx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('ELITE2') ..']'..GlobalApi:getLocalStr('STR_DROP'))
            elseif tonumber(self.getWayArr[index]) == 401 then
                chapternametx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('COMBAT2') ..']'..GlobalApi:getLocalStr('STR_DROP'))
            end
            starpl:setVisible(false)
            chapternametx:setTextColor(COLOR_TYPE.ORANGE)
            richText:setPosition(cc.p(200,70))
        end
    end
end

return GetWayUI
