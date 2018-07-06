local itemCell = {}
local ClassRoleObj = require('script/app/obj/roleobj')

function itemCell:setGodLight(awardBgImg,godType)
    godType = godType or 0
    local size = awardBgImg:getContentSize()
    local effect = awardBgImg:getChildByName('god_light')
    if godType == 3 then
        if not effect then
            effect = GlobalApi:createLittleLossyAniByName('god_light')
            effect:setPosition(cc.p(size.width/2,size.height/2))
            effect:getAnimation():playWithIndex(0, -1, 1)
            effect:setName('god_light')
            effect:setScale(1.25)
            awardBgImg:addChild(effect)
        end
        effect:setVisible(true)
    else
        if effect then
            effect:setVisible(false)
        end
    end
    local selectAni = awardBgImg:getChildByName('godequip_blink')
    if godType > 0 then
        if not selectAni then
            selectAni = GlobalApi:createLittleLossyAniByName("godequip_blink")
            selectAni:getAnimation():playWithIndex(0, -1, 1)
            selectAni:setName('godequip_blink')
            selectAni:setVisible(true)
            selectAni:setPosition(cc.p(size.width/2,size.height/2))
            awardBgImg:addChild(selectAni)
            local function movementFun(armature, movementType, movementID)
                local posX,posY = math.random(14,80),math.random(14,80)
                if movementType == 2 then
                    selectAni:setPosition(cc.p(posX,posY))
                end
            end
            selectAni:getAnimation():setMovementEventCallFunc(movementFun)
        else
            selectAni:setVisible(true)
        end
    else
        if effect then
            effect:setVisible(false)
        end
        if selectAni then
            selectAni:setVisible(false)
        end
    end
end

function itemCell:setHeroPromote(root,hid,promote)
    local obj = ClassRoleObj.new(hid,0)
    obj:setPromoted(promote)
    if obj then
        local size = root:getContentSize()
        local goldframeImg = root:getChildByName('ui_jinjiangtouxiang')
        if not goldframeImg then
            goldframeImg = GlobalApi:createLittleLossyAniByName('ui_jinjiangtouxiang')
            goldframeImg:setPosition(cc.p(size.width/2,size.height/2))
            goldframeImg:getAnimation():playWithIndex(0, -1, 1)
            goldframeImg:setName('ui_jinjiangtouxiang')
            goldframeImg:setVisible(false)
            root:addChild(goldframeImg)
        end
        local promotestarImgs = {}
        for i=1,3 do
            local promotestarImg = ccui.ImageView:create('uires/ui/common/icon_star3.png')
            promotestarImg:setName('promotestar_img_'..i)
            promotestarImg:setVisible(false)
            promotestarImg:setScale(0.8)
            promotestarImg:setLocalZOrder(1)
            root:addChild(promotestarImg)
            promotestarImgs[i] = promotestarImg
        end

        if obj:getObjType() == 'card' and obj:getPosId() > 0 and obj:isJunZhu() == false then
            local promote = obj:getPromoted()
            local lv = 0
            local protype = 0 

            if promote and #promote > 1 then
                protype = promote[1]
                lv = promote[2]
            end
            local promotedconf =obj:getPromotedConf()
            protype = obj:checkPromoteType(protype)
            if protype > 0 then
                local starnum = promotedconf[protype][obj:getProfessionType()*100 +lv]['heroStars']
                if starnum > 0 then
                    for i=1,starnum do
                        promotestarImgs[i]:setVisible(true)
                    end
                else
                    for i=1,3 do
                        promotestarImgs[i]:setVisible(false)
                    end
                end
                if starnum == 1 then
                    promotestarImgs[1]:setPosition(cc.p(size.width/2,5))
                elseif starnum == 2 then
                    promotestarImgs[1]:setPosition(cc.p(size.width/2-15,5))
                    promotestarImgs[2]:setPosition(cc.p(size.width/2+15,5))
                elseif starnum == 3 then
                    promotestarImgs[1]:setPosition(cc.p(size.width/2-25,5))
                    promotestarImgs[2]:setPosition(cc.p(size.width/2,5))
                    promotestarImgs[3]:setPosition(cc.p(size.width/2+25,5))
                end
                if obj:getQuality() == 7 then
                    goldframeImg:setVisible(true)
                end
            end
        end
        root:loadTexture(obj:getBgImg())
    end
end

function itemCell:create(itemType, obj, parent, createStar)
    itemType = itemType or ITEM_CELL_TYPE.ITEM
    local awardBgImg = ccui.ImageView:create('uires/ui_new/common/frame_base.png')
    awardBgImg:ignoreContentAdaptWithSize(true)
    awardBgImg:setName("award_bg_img")
    local size = awardBgImg:getContentSize()
    awardBgImg:setTouchEnabled(true)

    local awardImg = ccui.ImageView:create()
    awardImg:ignoreContentAdaptWithSize(true)
    awardImg:setPosition(cc.p(size.width/2,size.height/2))
    awardImg:setName('award_img')

    --碎片遮罩
    local fragmentMaskImg = ccui.ImageView:create('uires/ui_new/common/fragment.png')
    fragmentMaskImg:ignoreContentAdaptWithSize(true)
    fragmentMaskImg:setPosition(cc.p(size.width/2,size.height/2))
    fragmentMaskImg:setName('fragment_mask')
    fragmentMaskImg:setVisible(false)

    local lvTx = ccui.Text:create()
    lvTx:setFontName("font/gamefont.ttf")
    lvTx:setFontSize(20)
    lvTx:setPosition(cc.p(88,15))
    lvTx:setTextColor(COLOR_TYPE.WHITE)
    lvTx:enableOutline(COLOR_TYPE.BLACK, 1)
    lvTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    lvTx:setAnchorPoint(cc.p(1,0.5))
    lvTx:setName('lv_tx')

    local nameTx = ccui.Text:create()
    nameTx:setFontName("font/gamefont.ttf")
    nameTx:setFontSize(24)
    nameTx:setPosition(cc.p(size.width/2,-20))
    nameTx:setTextColor(COLOR_TYPE.WHITE)
    nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setAnchorPoint(cc.p(0.5,0.5))
    nameTx:setName('name_tx')

    local upImg = ccui.ImageView:create('uires/ui/common/new_img.png')
    upImg:setPosition(cc.p(21,72))
    upImg:setName('up_img')
    upImg:setVisible(false)

    local addImg = ccui.ImageView:create('uires/ui/common/add_04.png')
    addImg:setPosition(cc.p(size.width/2,size.height/2))
    addImg:setName('add_img')
    addImg:setVisible(false)

    local chipImg = ccui.ImageView:create('uires/ui/common/bg1_alpha.png')
    chipImg:setPosition(cc.p(size.width/2,size.height/2))
    chipImg:setName('chip_img')
    chipImg:setScaleX(-1)
    chipImg:setVisible(false)
 
    --[[local gemLvTx = cc.LabelBMFont:create()
    gemLvTx:setFntFile('uires/ui_new/number/font_lv.fnt')]]

    local gemLvTx = ccui.Text:create()
    gemLvTx:setFontName("font/gamefont.ttf")
    gemLvTx:setFontSize(20)
    gemLvTx:setTextColor(COLOR_TYPE.WHITE)
    gemLvTx:setAnchorPoint(cc.p(0,0.5))
    gemLvTx:setPosition(cc.p(10,76))
    gemLvTx:setName("gemlv_tx")
    gemLvTx:setVisible(false)

    local limitTx = ccui.Text:create()
    limitTx:setFontName("font/gamefont.ttf")
    limitTx:setFontSize(20)
    limitTx:setPosition(cc.p(10,76))
    limitTx:setTextColor(COLOR_TYPE.WHITE)
    limitTx:enableOutline(COLOR_TYPE.RED, 1)
    limitTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    limitTx:setAnchorPoint(cc.p(0,0.5))
    limitTx:setName('limit_tx')
    limitTx:setVisible(false)

    local doubleImg = ccui.ImageView:create('uires/ui/common/shuangbei.png')
    doubleImg:setPosition(cc.p(75,75))
    doubleImg:setName('double_img')
    doubleImg:setVisible(false)

    --人皇外观时间
    local surfacetimeImg = ccui.ImageView:create('uires/ui/common/num_bg.png')
    surfacetimeImg:setPosition(cc.p(size.width-12,size.height-12))
    surfacetimeImg:setName('surfacetime_Img')
    surfacetimeImg:setVisible(false)
    surfacetimeImg:setContentSize(cc.size(44,22))
    surfacetimeImg:setScale9Enabled(true)
    surfacetimeImg:setCapInsets(cc.rect(20, 10, 4, 2))
    surfacetimeImg:setAnchorPoint(cc.p(0.5,0.5))
    surfacetimeImg:setVisible(false)

    local timeTx = ccui.Text:create()
    timeTx:setFontName("font/gamefont.ttf")
    timeTx:setFontSize(16)
    timeTx:setPosition(cc.p(22,11))
    timeTx:setTextColor(COLOR_TYPE.WHITE)
    timeTx:enableOutline(COLOR_TYPE.BLACK, 1)
    timeTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    timeTx:setAnchorPoint(cc.p(0.5,0.5))
    timeTx:setName('timeTx')
    surfacetimeImg:addChild(timeTx)

    -- 觉醒等级
    local starImg = ccui.ImageView:create('uires/ui_new/common/star_title.png')
    local size1 = starImg:getContentSize()
    starImg:setAnchorPoint(cc.p(1,1))
    starImg:setPosition(cc.p(size.width - 4,size.height - 4))
    starImg:setName('star_img')
    local starLv = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    starLv:setAnchorPoint(cc.p(1, 0.5))
    starLv:setPosition(cc.p(3, size1.height/2 - 2))
    starLv:enableOutline(COLOR_TYPE.BLACK, 1)
    starLv:setName('star_lv')
    starImg:addChild(starLv)
    starImg:setVisible(false)

    -- 宝石镶嵌
    local gemArr = {}
    for i = 1, PART_GEMS_COUNT do
        local gemImg = ccui.ImageView:create('uires/ui_new/common/gem_small_bg.png')
        local size1 = gemImg:getContentSize()
        gemImg:setAnchorPoint(cc.p(0,0))
        gemImg:setPosition(cc.p(6 + size1.width * (i - 1), -20))
        gemImg:setVisible(false)
        gemImg:setName("gem"..i)
        awardBgImg:addChild(gemImg)
        gemArr[i] = gemImg
        gemImg:setVisible(false)
    end

    -- 镶嵌大师百分比
    local embedPercent = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
    embedPercent:setPosition(cc.p(size.width/2, -12))
    embedPercent:setAnchorPoint(cc.p(0.5, 0.5))
    embedPercent:setTextColor(COLOR_TYPE.YELLOW)
    embedPercent:enableOutline(COLOR_TYPE.BLACK, 1)
    embedPercent:setName('embed_percent_tx')
    embedPercent:setVisible(false)
    
    --左上角图标
    local cornerImg = ccui.ImageView:create(COLOR_CORNER[1])
    cornerImg:setPosition(cc.p(-2, size.height+2))
    cornerImg:setAnchorPoint(cc.p(0, 1))
    cornerImg:setName('corner_img')
   
    --左上角文本
    local conerimgSize = cornerImg:getContentSize()
    local cornerTx = ccui.Text:create()
    cornerTx:setFontName("font/gamefont.ttf")
    cornerTx:setFontSize(18)
    cornerTx:setPosition(cc.p(conerimgSize.width*0.4, conerimgSize.height/2))
    cornerTx:setAnchorPoint(cc.p(0.5, 0.5))
    cornerTx:setTextColor(COLOR_TYPE.WHITE1)
    cornerTx:enableOutline(COLOROUTLINE_TYPE.OFFWHITE1, 1)
    cornerTx:setName('corner_tx')
    cornerImg:addChild(cornerTx)
    cornerImg:setVisible(false)

    --右上角图标
    local topRightImg = ccui.ImageView:create(COLOR_CORNER[1])
    topRightImg:setPosition(cc.p(size.width+5, size.height+4))
    topRightImg:setAnchorPoint(cc.p(1, 1))
    topRightImg:setName('top_right_img')
    topRightImg:setVisible(false)

     --右下角图标
    local cornerImgR = ccui.ImageView:create("uires/ui_new/common/conerR_red.png")
    cornerImgR:setPosition(cc.p(size.width-6, 6))
    cornerImgR:setAnchorPoint(cc.p(1, 0))
    cornerImgR:setName('cornerR_img')
    cornerImgR:setVisible(false)
    
    --右下角图标文字
    local cornerImgRSize = cornerImgR:getContentSize()
    local cornerRTx = ccui.Text:create()
    cornerRTx:setFontName("font/gamefont.ttf")
    cornerRTx:setFontSize(18)
    cornerRTx:setPosition(cc.p(cornerImgRSize.width/2, cornerImgRSize.height/2))
    cornerRTx:setAnchorPoint(cc.p(0.5, 0.5))
    cornerRTx:setTextColor(COLOR_TYPE.WHITE1)
    cornerRTx:enableOutline(COLOROUTLINE_TYPE.OFFWHITE1, 1)
    cornerRTx:setName('cornerR_tx')
    cornerImgR:addChild(cornerRTx)

    --必掉图标
    local cornerFallImg = ccui.ImageView:create("uires/ui_new/common/corner.png")
    cornerFallImg:setPosition(cc.p(size.width/2, size.height/2))
    cornerFallImg:setName('corner_fall')
    cornerFallImg:setVisible(false)

    --必掉文字
    local cornerFallTx = ccui.Text:create()
    cornerFallTx:setFontName("font/gamefont.ttf")
    cornerFallTx:setFontSize(20)
    cornerFallTx:setPosition(cc.p(69, 64))
    cornerFallTx:setAnchorPoint(cc.p(0.5, 0.5))
    cornerFallTx:setRotation(45)
    cornerFallTx:setTextColor(cc.c4f(255, 255, 255, 255))
    cornerFallTx:enableOutline(cc.c4f(15, 87, 27, 255), 2)
    cornerFallTx:setName('corner_fall_tx')
    cornerFallImg:addChild(cornerFallTx)

    awardBgImg:addChild(awardImg)
    awardBgImg:addChild(fragmentMaskImg)
    awardBgImg:addChild(lvTx)
    awardBgImg:addChild(addImg)
    awardBgImg:addChild(chipImg)
    awardBgImg:addChild(upImg)
    awardBgImg:addChild(nameTx)
    awardBgImg:addChild(limitTx)
    awardBgImg:addChild(doubleImg)
    awardBgImg:addChild(surfacetimeImg)
    awardBgImg:addChild(starImg)
    awardBgImg:addChild(embedPercent)
    awardBgImg:addChild(cornerImg)
    awardBgImg:addChild(cornerImgR)
    awardBgImg:addChild(gemLvTx)
    awardBgImg:addChild(topRightImg)
    awardBgImg:addChild(cornerFallImg)
    
    local tab = {
        awardBgImg = awardBgImg,
        awardImg = awardImg,
        fragmentMaskImg = fragmentMaskImg,
        lvTx = lvTx, 
        upImg = upImg, 
        addImg = addImg,
        chipImg = chipImg,
        nameTx = nameTx,
        limitTx = limitTx,
        doubleImg = doubleImg,
        surfacetimeImg = surfacetimeImg,
        starImg = starImg,
        embedPercent = embedPercent,
        gemArr = gemArr,
        cornerImg = cornerImg,
        cornerTx = cornerTx,
        cornerImgR = cornerImgR,
        cornerRTx = cornerRTx,
        gemLvTx = gemLvTx,
        cornerFallImg = cornerFallImg,
        cornerFallTx = cornerFallTx,
        topRightImg = topRightImg,
    }

    if createStar then
        local rhombImgs = {}
        for i=1,4 do
            local rhombImg = ccui.ImageView:create('uires/ui/common/rhomb_1.png')
            rhombImg:setName('rhomb_img_'..i)
            rhombImg:setVisible(false)
            rhombImg:setLocalZOrder(1)
            awardBgImg:addChild(rhombImg)
            rhombImgs[i] = rhombImg
        end
        tab.rhombImgs = rhombImgs
    end

    awardImg:setScale(1)
    if itemType == ITEM_CELL_TYPE.ITEM then
        if obj then

            if obj.getShowtype and (obj:getShowtype() == 'fargementEquip' or obj:getShowtype() == 'fargementOthers') then
                fragmentMaskImg:setVisible(true)
            end

            if obj:getObjType() == 'fragment' then
                chipImg:setVisible(true)
                chipImg:loadTexture(obj:getChip())
            elseif obj:getObjType() == 'material' and obj.getResCategory and obj:getResCategory() == "equip" then
                chipImg:setVisible(true)
                chipImg:loadTexture(obj:getChip())
            elseif obj:getObjType() == "limitmat" then
                chipImg:setVisible(true)
                chipImg:loadTexture(obj:getChip())
                limitTx:setVisible(true)
                limitTx:setString(GlobalApi:getLocalStr('LIMIT_DESC'))
            elseif obj:getObjType() == "part" then
                starImg:setVisible(true)
            elseif obj:getObjType() == 'equip' then
                if obj.getRefineLv and obj.getStrengthenLv then
                    local refineLv = obj:getRefineLv()
                    local strengthenLv = obj:getStrengthenLv()
                    cornerImg:setVisible(strengthenLv~=0)
                    cornerImgR:setVisible(refineLv~=0)
                    cornerImg:loadTexture(obj:getCornerImg())
                    cornerTx:setString(obj:getCornerTx())
                    cornerRTx:setString(obj:getCornerRTx())
                    topRightImg:setVisible(true)
                    topRightImg:loadTexture(obj:getGradeSamllIcon())
                else
                    cornerImg:setVisible(false)
                    cornerImgR:setVisible(false)
                end
                awardImg:setScale(0.9)
            elseif obj:getObjType() == 'skywing' or obj:getObjType() == 'skyweapon' then
                local timeType = obj:getTimeType()
                local time = obj:getTime()
                local timeTx = surfacetimeImg:getChildByName("timeTx")
                if tonumber(timeType) == 1 then
                    timeTx:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_17"),time))
                else
                    timeTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_18"))
                end
                surfacetimeImg:setVisible(true)            
            elseif obj:getObjType() == 'gem' then
                local lv = obj:getLevel()
                gemLvTx:setVisible(true)
                gemLvTx:setString("LV"..lv)
                if obj:getNum() > 0  then
                    lvTx:setVisible(true)
                    lvTx:setString('x'..obj:getNum())
                end
                gemLvTx:setScale(1.2)
            else
                if obj:getNum() > 0  then
                    lvTx:setString('x'..obj:getNum())
                end
            end
            awardBgImg:loadTexture(obj:getBgImg())
            awardImg:loadTexture(obj:getIcon())
            awardBgImg:setTouchEnabled(true)
            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(obj,false)
                end
            end)
            parent:addChild(awardBgImg)
        end
    elseif itemType == ITEM_CELL_TYPE.HERO then
        local goldframeImg = awardBgImg:getChildByName('ui_jinjiangtouxiang')
        if not goldframeImg then
            goldframeImg = GlobalApi:createLittleLossyAniByName('ui_jinjiangtouxiang')
            goldframeImg:setPosition(cc.p(size.width/2,size.height/2))
            goldframeImg:getAnimation():playWithIndex(0, -1, 1)
            goldframeImg:setName('ui_jinjiangtouxiang')
            goldframeImg:setVisible(false)
            awardBgImg:addChild(goldframeImg)
            tab.goldframeImg = goldframeImg
        end

        local promotestarImgs = {}
        for i=1,3 do
            local promotestarImg = ccui.ImageView:create('uires/ui/common/icon_star3.png')
            promotestarImg:setName('promotestar_img_'..i)
            promotestarImg:setVisible(false)
            promotestarImg:setScale(0.8)
            promotestarImg:setLocalZOrder(1)
            awardBgImg:addChild(promotestarImg)
            promotestarImgs[i] = promotestarImg
        end
        tab.promotestarImgs = promotestarImgs
        if obj then
            if obj:getObjType() == 'card' and obj:getPosId() > 0 and obj:isJunZhu() == false then
                local promote = obj:getPromoted()
                local lv = 0
                local protype = 0 

                if promote and #promote > 1 then
                    protype = promote[1]
                    lv = promote[2]
                end
                local promotedconf =obj:getPromotedConf()
                protype = obj:checkPromoteType(protype)
                if protype > 0 then
                    local starnum = promotedconf[protype][obj:getProfessionType()*100 +lv]['heroStars']
                    if starnum > 0 then
                        for i=1,starnum do
                            promotestarImgs[i]:setVisible(true)
                        end
                    else
                        for i=1,3 do
                            promotestarImgs[i]:setVisible(false)
                        end
                    end
                    if starnum == 1 then
                        promotestarImgs[1]:setPosition(cc.p(size.width/2,5))
                    elseif starnum == 2 then
                        promotestarImgs[1]:setPosition(cc.p(size.width/2-15,5))
                        promotestarImgs[2]:setPosition(cc.p(size.width/2+15,5))
                    elseif starnum == 3 then
                        promotestarImgs[1]:setPosition(cc.p(size.width/2-25,5))
                        promotestarImgs[2]:setPosition(cc.p(size.width/2,5))
                        promotestarImgs[3]:setPosition(cc.p(size.width/2+25,5))
                    end
                    if obj:getQuality() == 7 then
                        goldframeImg:setVisible(true)
                    end
                end
            end
            awardBgImg:loadTexture(obj:getBgImg())
            awardImg:loadTexture(obj:getIcon())
            awardBgImg:setTouchEnabled(true)
            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(obj,false)
                end
            end)
            parent:addChild(awardBgImg)
        end
    elseif itemType == ITEM_CELL_TYPE.HEADPIC then
        local headframeImg = ccui.ImageView:create('uires/ui/common/bg1_alpha.png')
        headframeImg:setPosition(cc.p(size.width/2,size.height/2))
        headframeImg:setName('headframeImg')
        headframeImg:setVisible(true)
        awardBgImg:addChild(headframeImg)
        tab.headframeImg = headframeImg
        tab.lvTx:setLocalZOrder(1)
    elseif itemType == ITEM_CELL_TYPE.SKILL then
    else
    end
    return tab
end

function itemCell:updateHero(tabOrRoot, obj, updateType)
    local promotestarImgs
    local goldframeImg
    local awardBgImg
    local awardImg
    local lvTx
    if updateType == 1 then
        promotestarImgs = tabOrRoot.promotestarImgs
        goldframeImg = tabOrRoot.goldframeImg
        awardBgImg = tabOrRoot.awardBgImg
        awardImg = tabOrRoot.awardImg
    else
        promotestarImgs = {}
        for i=1,3 do
            promotestarImgs[i] = tabOrRoot:getChildByName('promotestar_img_' .. i)
        end
        goldframeImg = tabOrRoot:getChildByName("gold_frame_img")
        awardBgImg = tabOrRoot
        awardImg = tabOrRoot:getChildByName("award_img")
    end
    if obj:getObjType() == 'card' and obj:getPosId() > 0 and obj:isJunZhu() == false then
        local promote = obj:getPromoted()
        local lv = 0
        local protype = 0 

        if promote and #promote > 1 then
            protype = promote[1]
            lv = promote[2]
        end
        local promotedconf =obj:getPromotedConf()
        protype = obj:checkPromoteType(protype)
        if protype > 0 then
            local starnum = promotedconf[protype][obj:getProfessionType()*100+lv]['heroStars']
            if starnum > 0 then
                for i=1,starnum do
                    promotestarImgs[i]:setVisible(true)
                end
            else
                for i=1,3 do
                    promotestarImgs[i]:setVisible(false)
                end
            end
            local size = awardBgImg:getContentSize()
            if starnum == 1 then
                promotestarImgs[1]:setPosition(cc.p(size.width/2,5))
            elseif starnum == 2 then
                promotestarImgs[1]:setPosition(cc.p(size.width/2-15,5))
                promotestarImgs[2]:setPosition(cc.p(size.width/2+15,5))
            elseif starnum == 3 then
                promotestarImgs[1]:setPosition(cc.p(size.width/2-25,5))
                promotestarImgs[2]:setPosition(cc.p(size.width/2,5))
                promotestarImgs[3]:setPosition(cc.p(size.width/2+25,5))
            end
            if obj:getQuality() == 7 then
                goldframeImg:setVisible(true)
            end
        end
    else
        for i=1,3 do
            promotestarImgs[i]:setVisible(false)
        end
        goldframeImg:setVisible(false)
    end
    awardBgImg:loadTexture(obj:getBgImg())
    awardImg:loadTexture(obj:getIcon())
end

function itemCell:updateItem(tabOrRoot, obj, updateType)
    local chipImg
    local starImg
    local awardBgImg
    local awardImg
    local lvTx
    local limitTx
    local surfacetimeImg
    local cornerImg
    local cornerTx
    local cornerImgR
    local cornerRTx
    local starImg
    local gemArr = {}
    local fragmentMaskImg
    local gemLvTx
    local cornerFallImg
    local cornerFallTx
    local topRightImg
    if updateType == 1 then
        chipImg = tabOrRoot.chipImg
        starImg = tabOrRoot.starImg
        awardBgImg = tabOrRoot.awardBgImg
        awardImg = tabOrRoot.awardImg
        lvTx = tabOrRoot.lvTx
        limitTx = tabOrRoot.limitTx
        surfacetimeImg = tabOrRoot.surfacetimeImg
        cornerImg = tabOrRoot.cornerImg
        cornerTx = tabOrRoot.cornerTx
        cornerImgR = tabOrRoot.cornerImgR
        cornerRTx = tabOrRoot.cornerRTx
        starImg = tabOrRoot.starImg
        gemArr = tabOrRoot.gemArr
        fragmentMaskImg = tabOrRoot.fragmentMaskImg
        gemLvTx = tabOrRoot.gemLvTx
        cornerFallImg = tabOrRoot.cornerFallImg
        cornerFallTx = tabOrRoot.cornerFallTx
        topRightImg = tabOrRoot.topRightImg
    else
        chipImg = tabOrRoot:getChildByName("chip_img")
        starImg = tabOrRoot:getChildByName("star_img")
        awardBgImg = tabOrRoot
        awardImg = tabOrRoot:getChildByName("award_img")
        lvTx = tabOrRoot:getChildByName("lv_tx")
        limitTx = tabOrRoot:getChildByName('limit_tx')
        surfacetimeImg = tabOrRoot:getChildByName('surfacetime_Img')
        cornerImg = tabOrRoot:getChildByName('corner_img')
        cornerTx = cornerImg:getChildByName('corner_tx')
        cornerImgR = tabOrRoot:getChildByName('cornerR_img')
        cornerRTx = cornerImgR:getChildByName('cornerR_tx')
        for i=1,PART_GEMS_COUNT do
            gemArr[i] = tabOrRoot:getChildByName("gem"..i)
        end
        fragmentMaskImg = tabOrRoot:getChildByName("fragment_mask")
        gemLvTx = tabOrRoot:getChildByName("gemlv_tx")
        cornerFallImg = tabOrRoot:getChildByName("corner_fall")
        cornerFallTx = cornerFallImg:getChildByName("corner_fall_tx")
        topRightImg = tabOrRoot:getChildByName('top_right_img')
    end

    --全部false
    fragmentMaskImg:setVisible(false)
    chipImg:setVisible(false)
    limitTx:setVisible(false)
    cornerImg:setVisible(false)
    cornerImgR:setVisible(false)
    topRightImg:setVisible(false)
    starImg:setVisible(false)
    surfacetimeImg:setVisible(false)
    lvTx:setVisible(false)
    awardImg:setScale(1)
    for i=1,PART_GEMS_COUNT do
        gemArr[i]:setVisible(false)
    end
    gemLvTx:setVisible(false)
    cornerFallImg:setVisible(false)
    cornerFallTx:setVisible(false)

    if obj.getShowtype and (obj:getShowtype() == 'fargementEquip' or obj:getShowtype() == 'fargementOthers') then
        fragmentMaskImg:setVisible(true)
    end

    if obj:getObjType() == 'fragment' then
        chipImg:setVisible(true)
        chipImg:loadTexture(obj:getChip())
    elseif obj:getObjType() == 'material' and obj.getResCategory and obj:getResCategory() == "equip" then
        chipImg:setVisible(true)
        chipImg:loadTexture(obj:getChip())
    elseif obj:getObjType() == "limitmat" then
        limitTx:setVisible(true)
        limitTx:setString(GlobalApi:getLocalStr('LIMIT_DESC'))
    elseif obj:getObjType() == 'equip' then
        
        if obj:getCornerTx() == '' or obj:getCornerRTx() == '' then
            cornerImg:setVisible(false)
            cornerImgR:setVisible(false)
        else
            local refineLv = obj:getRefineLv()
            local strengthenLv = obj:getStrengthenLv()
            if refineLv and strengthenLv then
                cornerImg:setVisible(strengthenLv~=0)
                cornerImgR:setVisible(refineLv~=0)
                cornerImg:loadTexture(obj:getCornerImg())
                cornerTx:setString(obj:getCornerTx())
                cornerRTx:setString(obj:getCornerRTx())
            else
                cornerImg:setVisible(false)
                cornerImgR:setVisible(false)
            end

            topRightImg:setVisible(true)
            topRightImg:loadTexture(obj:getGradeSamllIcon())
        end
        awardImg:setScale(0.9)
    elseif obj:getObjType() == 'headframe' then
        lvTx:setVisible(false)
    elseif obj:getObjType() == 'skywing' or obj:getObjType() == 'skyweapon' then
        local timeType = obj:getTimeType()
        local time = obj:getTime()
        local timeTx = surfacetimeImg:getChildByName("timeTx")
        if tonumber(timeType) == 1 then
            timeTx:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_17"),time))
        else
            timeTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_18"))
        end
        surfacetimeImg:setVisible(true)
    elseif obj:getObjType() == 'part' then

        starImg:setVisible(true)
        local starLv = starImg:getChildByName("star_lv")
        starLv:setString(obj:getAwakeLv())
        local openGemSolt = obj:getGemSlotCount()
        local gems = obj:getGems()
        for i=1,PART_GEMS_COUNT do
            if i<=openGemSolt then
                gemArr[i]:setVisible(true)
                if gems[i] then
                    local gemType = gems[i]:getType()
                    gemArr[i]:loadTexture(obj:getGemSlotIcon(gemType))
                else
                    gemArr[i]:loadTexture(obj:getGemSlotBgIcon())
                end
            end
        end
    elseif obj:getObjType() == 'gem' then
        gemLvTx:setVisible(true)
        gemLvTx:setString("LV"..obj:getLevel())
        if obj:getNum() > 0  then
            lvTx:setVisible(true)
            lvTx:setString('x'..obj:getNum())
        end
        gemLvTx:setScale(1.2)
    else    
        if obj:getNum() > 0  then
            lvTx:setVisible(true)
            lvTx:setString('x'..obj:getNum())
        end
    end
    awardBgImg:loadTexture(obj:getBgImg())
    awardImg:loadTexture(obj:getIcon())
end

return itemCell