
local HookDispatchUI = class("HookDispatchUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function HookDispatchUI:ctor(taskId,taskIndex)

	self.uiIndex = GAME_UI.UI_HOOK_DISPATCH_UI
    self.taskId = taskId
end


function HookDispatchUI:init()

	local bgimg = self.root:getChildByName("bg_img")
	local bg = bgimg:getChildByName("bg_img1")
	self:adaptUI(bgimg, bg)

	local close_btn = bg:getChildByName("close_btn")
	close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideHookDispatchUI()
        end
    end)

	local titleTx = bg:getChildByName("title_tx")
	titleTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX26"))
	
	local cloneCell = bg:getChildByName("cellbg")
	cloneCell:setVisible(false)
	local svbg = bg:getChildByName("sv_bg")
	local roleSv = svbg:getChildByName("role_sv")
	roleSv:setScrollBarEnabled(false)

	local otherRole = {}
	local roleMap = RoleData:getRoleMap()
    for i=1,#roleMap do
    	local roleObj  = RoleData:getRoleByPos(i)
    	if roleObj and not roleObj:isJunZhu() and roleObj:getId() > 0 then
    		otherRole[#otherRole+1] = roleObj
    	end
    end

    local count = #otherRole
    local cellSize
    for i=1,count do
    	local cell = roleSv:getChildByTag(i + 100)
        local cellBg
        if not cell then
            cellBg = cloneCell:clone()
            cellBg:removeFromParent(false)
            cell = ccui.Widget:create()
            cellBg:setVisible(true)
            cell:addChild(cellBg)
            roleSv:addChild(cell,1,i+100)
        else
            cellBg = cell:getChildByName('cell_bg')
        end
        cell:setVisible(true)
        cellSize = cellBg:getContentSize()
        local roleIcon = cellBg:getChildByName("icon")
        local roleCell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, otherRole[i], roleIcon)
	    roleCell.awardBgImg:setTouchEnabled(false)
	    roleCell.awardBgImg:setPosition(cc.p(47,47))

        local text_bg = cellBg:getChildByName("text_bg")
        local nameTx = text_bg:getChildByName("text")
        
        nameTx:setString(otherRole[i]:getName())
        nameTx:setColor(otherRole[i]:getNameColor())
        nameTx:enableOutline(otherRole[i]:getNameOutlineColor(), 2)

        local num_tx = cellBg:getChildByName("num_tx")
        num_tx:setString(string.format(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX28"),otherRole[i]:getFragmentNum()))
        
        local send_btn = cellBg:getChildByName("send_btn")
        local btnTx = send_btn:getChildByName("text")
        if otherRole[i]:getDispatchFlag() then
            btnTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX35"))
            btnTx:setColor(COLOR_TYPE.GRAY1)
            btnTx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
            btnTx:enableShadow(COLOR_BTN_SHADOW.DISABLE_BTN,cc.size(0, -1), 0)
            ShaderMgr:setGrayForWidget(send_btn)
            send_btn:setTouchEnabled(false)
        else
            btnTx:setString(GlobalApi:getLocalStr_new("HOOK_MIAN_INFOTX27"))
            btnTx:enableShadow(COLOR_BTN_SHADOW.YELLOW_BTN,cc.size(0, -1), 0)
            btnTx:setColor(COLOR_TYPE.YELLOW_BTN)
            btnTx:enableOutline(COLOROUTLINE_TYPE.YELLOW_BTN, 2)
            ShaderMgr:restoreWidgetDefaultShader(send_btn)
            send_btn:setTouchEnabled(true)
        end
        
        send_btn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
                local args = {
                    task_id = self.taskId,
                    hid = otherRole[i]:getId( )
                }
	            MessageMgr:sendPost('send_hero','auto_fight',json.encode(args),function (response)
                    local code = response.code
                    local data = response.data
                    if code == 0 then

                        MainSceneMgr:updateHookMainUI(HOOKMAIN_TYPE.PATROL,data.task)
                        MainSceneMgr:hideHookDispatchUI()
                    end
                end)
	        end
	    end)
    end

    local size = roleSv:getContentSize()
    if count > 0 then
        if  count*cellSize.height > size.height then
        	local yNum = math.floor((count-1)/2+1)
            roleSv:setInnerContainerSize(cc.size(size.width,cellSize.height*yNum+(yNum-1)*3))
        else
            roleSv:setInnerContainerSize(size)
        end

        local size2 = roleSv:getInnerContainerSize()  
        local function getPos(i)
        	
            local posX = 2
	        if i%2 == 0 then
	        	posX = cellSize.width+5
	        end
	        local yId = math.floor((i-1)/2+1)
	        local posY = yId*cellSize.height+(yId-1)*3
            return cc.p(posX,size2.height-posY)       
        end

        for i=1,count do
            local cell = roleSv:getChildByTag(i + 100)
            if cell then
                cell:setPosition(getPos(i))
            end
        end
    end
end

return HookDispatchUI