
local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local RoleEquipInfoUI = class("RoleEquipInfoUI", ClassRoleBaseUI)
local ClassEquipSelectUI = require("script/app/ui/equip/equipselectui")
function RoleEquipInfoUI:initPanel()

    self.strengthenLv = 0

	self.panel = cc.CSLoader:createNode("csb/roleequipinfopanel.csb")
    self.panel:setName('role_tianming_panel')
    local bgimg = self.panel:getChildByName('bg_img')
    local nor_pl = bgimg:getChildByName('nor_pl')

    self.equipNameTx = nor_pl:getChildByName("cur_title")
    self.equipImg = nor_pl:getChildByName("equip_img")

    --基础信息
    local attrbg = nor_pl:getChildByName("attrbase_bg")
    self.attrName = attrbg:getChildByName("attr_tx_1")
    local numberbg = attrbg:getChildByName("number_bg") 
    self.attrNum = numberbg:getChildByName("attr_num")

    --强化信息
    local strengthenBg = nor_pl:getChildByName("strengthen_bg")
    local sfunNameTx = strengthenBg:getChildByName("fun_name")
    sfunNameTx:setString(GlobalApi:getLocalStr_new("STRENGTHEN_LV_TX"))
    local strengthBtn = strengthenBg:getChildByName("fun_btn") 
    local btnTx = strengthBtn:getChildByName("func_tx")
    btnTx:setString(GlobalApi:getLocalStr_new("STRENGTHEN_BTN_TX"))
    self.sAttrName = strengthenBg:getChildByName("attr_name")
    local snumberbg = strengthenBg:getChildByName("number_bg1")
    self.strengthLv = snumberbg:getChildByName("strengthen_lv")
    local snumberbg2 = strengthenBg:getChildByName("number_bg2")
    self.addNumTx = snumberbg2:getChildByName("add_num")
    strengthBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:showEquipRebuildUI(1,self.roleObj,self.equipPos)
        end
    end)

    --精炼属性
    local refineBg = nor_pl:getChildByName("refine_bg")
    local refunNameTx = refineBg:getChildByName("fun_name")
    refunNameTx:setString(GlobalApi:getLocalStr_new("REFINE_LV_TX"))
    local refineBtn = refineBg:getChildByName("fun_btn") 
    local btnTx = refineBtn:getChildByName("func_tx")
    btnTx:setString(GlobalApi:getLocalStr_new("REFINE_BTN_TX"))
    self.reattrNameTx = refineBg:getChildByName("attr_name")
    local renumberbg = refineBg:getChildByName("number_bg1")
    self.refineLvTx = renumberbg:getChildByName("refine_lv")
    local renumberbg2 = refineBg:getChildByName("number_bg2")
    self.refineAddNumTx = renumberbg2:getChildByName("add_num")
    local renumberbg3 = refineBg:getChildByName("number_bg3")
    self.refineNumTx3 = renumberbg3:getChildByName("add_num")
    self.refinespecialNameTx = refineBg:getChildByName("attr_name1")
    refineBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:showEquipRebuildUI(2,self.roleObj,self.equipPos)
        end
    end)

    local swapbtn = nor_pl:getChildByName("swap_btn")
    swapbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

            local obj = {}
            if self.equipObj then
                obj[self.equipObj:getSId()] = self.equipObj
            end
            local equipSelectUI = ClassEquipSelectUI.new(self.roleObj,obj,self.equipPos)
            equipSelectUI:showUI()
        end
    end)
end

function RoleEquipInfoUI:sendStrengthenMsg()
    
    local sid = self.equipObj:getSId()
    MessageMgr:sendPost("intensify", "equip", json.encode({eid = sid}), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
           self.strengthenLv = self.strengthenLv + 1
           self.equipObj:setStrengthenLv(self.strengthenLv)
           self:update(self.roleObj,self.equipPos)
           RoleMgr:updateRoleMainUI()
        end
    end)
end

function RoleEquipInfoUI:update(roleObj, equipPos)

	self.equipPos = equipPos
	local equipObj = roleObj:getEquipByIndex(equipPos)
	if equipObj == nil then
		return
	end

	self.roleObj = roleObj
    self.equipObj = equipObj
	
    --装备名字显示
    local equipName = self.equipObj:getName()
    self.equipNameTx:setString(equipName)
    local color = self.equipObj:getNameColor()
    self.equipNameTx:setColor(color)

    --装备图标
    local equipIcon = self.equipObj:getIcon()
    self.equipImg:loadTexture(equipIcon)

    --装备基础属性
    local mainAttribute = self.equipObj:getMainAttribute()
    self.attrName:setString(mainAttribute.name)
    self.attrNum:setString(mainAttribute.value)
    
    --强化信息
    self.strengthenLv = self.equipObj:getStrengthenLv()
    local strengthenAdd = self.equipObj:getStrengthGrowth()
    self.sAttrName:setString(mainAttribute.name)
    self.strengthLv:setString(self.strengthenLv)
    self.addNumTx:setString(strengthenAdd)

    --精炼信息
    local refineLv,maxRefineLv = self.equipObj:getRefineLv()
    local refineAdd = self.equipObj:getRefineGrowth()
    self.reattrNameTx:setString(mainAttribute.name)
    self.refineLvTx:setString(refineLv.."/"..maxRefineLv)
    self.refineAddNumTx:setString(refineAdd)
    local refineSpecialAttr = self.equipObj:getRefineSpecialAttr()
    self.refinespecialNameTx:setString(refineSpecialAttr.name)
    local refineSpecialAdd = self.equipObj:getRefineSpecialGrowth()
    local attrdesc = refineSpecialAttr.desc == '0' and '' or refineSpecialAttr.desc
    self.refineNumTx3:setString(refineSpecialAdd..attrdesc)

end

return RoleEquipInfoUI