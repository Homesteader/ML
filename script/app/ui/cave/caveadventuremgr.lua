-- 文件：山洞探险mgr
-- 创建：zzx
-- 日期：2017-12-09

local ClassCaveAdventureMainUI 		= require("script/app/ui/cave/caveadventuremainpanel")
local ClassCaveAdventureOpenBoxUI 	= require("script/app/ui/cave/caveadventureopenboxpanel")

cc.exports.CaveAdventureMgr = {
    uiClass = {
        caveMainUI = nil,
        caveOpenBoxUI = nil
    }
}

setmetatable(CaveAdventureMgr.uiClass, {__mode = "v"})

function CaveAdventureMgr:isExistUI( uiKey_ )
	if self.uiClass[uiKey_] then
		return true
	end
	return false
end

function CaveAdventureMgr:showMainUI()
	self:sendMainPost( function (data)
		if not self.uiClass["caveMainUI"] then
	        self.uiClass["caveMainUI"] = ClassCaveAdventureMainUI.new(data)
	        self.uiClass["caveMainUI"]:showUI()
	    end
	end)
end

function CaveAdventureMgr:updateMainUI()
	if self.uiClass["caveMainUI"] then
        self.uiClass["caveMainUI"]:updateAll()
    end
end

function CaveAdventureMgr:hideMainUI()
    if self.uiClass["caveMainUI"] then
        self.uiClass["caveMainUI"]:hideUI()
        self.uiClass["caveMainUI"] = nil
    end
end

function CaveAdventureMgr:showOpenBoxUI( caveData_ )
	if not self.uiClass["caveOpenBoxUI"] then
        self.uiClass["caveOpenBoxUI"] = ClassCaveAdventureOpenBoxUI.new(caveData_)
        self.uiClass["caveOpenBoxUI"]:showUI()
    end
end

function CaveAdventureMgr:hideOpenBoxUI() 
	if self.uiClass["caveOpenBoxUI"] then
        self.uiClass["caveOpenBoxUI"]:hideUI()
        self.uiClass["caveOpenBoxUI"] = nil
    end
end

function CaveAdventureMgr:sendMainPost( callBack_ )
	MessageMgr:sendPost("get", "cave", json.encode({}), function (jsonObj)

		-- print('================================')
  --       PrintT(jsonObj, true)
  --       print('================================')

       	if jsonObj.code ~= 0 then
			return
		end

	    local data = jsonObj.data

	   	if callBack_ then
	   		callBack_(data)
	   	end
    end)
end

function CaveAdventureMgr:sendReplyDicePost( callBack_ )
	MessageMgr:sendPost("reply_dice", "cave", json.encode({}), function (jsonObj)

		-- print('================================')
  --       PrintT(jsonObj, true)
  --       print('================================')

	    if jsonObj.code ~= 0 then
			return
		end

	    local data = jsonObj.data

	   	if callBack_ then
	   		callBack_(data)
	   	end
    end)
end

function CaveAdventureMgr:sendShakeDicePost( diceNumStr_, callBack_ )
	local args = {}

	args['dice_num'] = diceNumStr_

	MessageMgr:sendPost("shake_dice", "cave", json.encode(args), function (jsonObj)

		-- print('================================')
  --       PrintT(jsonObj, true)
  --       print('================================')

	    if jsonObj.code ~= 0 then
			return
		end

	    local data = jsonObj.data

	   	if callBack_ then
	   		callBack_(data)
	   	end
    end)
end

function CaveAdventureMgr:sendGetBoxRewardPost( key_, callBack_ )
	local args = {}

	args['key'] = key_

	MessageMgr:sendPost("get_awards", "cave", json.encode(args), function (jsonObj)

		-- print('================================')
  --       PrintT(jsonObj, true)
  --       print('================================')

	    if jsonObj.code ~= 0 then
			return
		end

	    local data = jsonObj.data

	   	if callBack_ then
	   		callBack_(data)
	   	end
    end)
end
