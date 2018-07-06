--[[
				   _ooOoo_
				  o8888888o
				  88" . "88
				  (| -_- |)
				  O\  =  /O
			   ____/`---'\____
			 .'  \\|     |//  `.
		    /  \\|||  :  |||//  \
		   /  _||||| -:- |||||-  \
		   |   | \\\  -  /// |   |
		   | \_|  ''\---/''  |   |
		   \  .-\__  `-`  ___/-. /
		 ___`. .'  /--.--\  `. . __
	  ."" '<  `.___\_<|>_/___.'  >'"".
	 | | :  `- \`.;`\ _ /`;.`/ - ` : | |
	 \  \ `-.   \_ __\ /__ _/   .-` /  /
======`-.____`-.___\_____/___.-`____.-'======
				   `=---='
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		 佛祖保佑!       永无BUG!
]]

require "socket"
require "script/config"
require "cocos/init"
require "script/app/game"

cc.exports.printall = function(t)
	if type(t) ~= 'table' then
		logger(t)
	else
		for k,v in pairs(t) do
			if type(v) == 'table' then
				logger(k .. ':')
				printall(v)
			else
				logger(k, v)
			end
		end
	end
end

-- 打印Table表数据函数
cc.exports.PrintT = function (table_, recursive, tab)

	if not table_ then
		return
	end

	-- 缩进
	local indent
	if tab == nil then
		indent = ""
	else
		indent = tab .. "	"
	end

	logger( indent .. "{" )
	for k, v in pairs( table_ ) do

		if type(v) == "table" and recursive == true then
			-- 先打印出table名再递归打印出table
			logger( indent .. "  " .. tostring(k) .. " = " )
			PrintT(v, recursive, indent )
		else
			logger( indent .. "  " .. tostring(k) .. " = " .. tostring(v) .. "," )
		end

	end
	logger( indent .. "}" .. "," )
end

cc.exports.requireOnce = function (file)
	local obj = require(file)
	package.loaded[file] = nil
	return obj
end

local lastErrMsg = ""

function __G__TRACKBACK__(msg)
	local errMsg = msg .. "\n" .. debug.traceback()
	if lastErrMsg ~= errMsg then
		lastErrMsg = errMsg
		local args = {
			msg = errMsg
		}
		SocketMgr:send("error", "user", args)
	end
	local str = ""
	if MessageMgr and CCApplication:getInstance():getTargetPlatform() ~= kTargetWindows then
		str = MessageMgr.fuckServerForceToAddThisMsg
	end
	logger_error("----------------------------------------")
	logger_error("LUA ERROR: " .. errMsg .. "\n")
	logger_error(str .. "\n")
	logger_error("----------------------------------------")
end

local function main()
	if jit then
		jit.off()
	end
	math.randomseed(os.time())
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	--require("script/app/update/update")
	cc.Director:getInstance():setAnimationInterval(1/30)
	--cc.Director:getInstance():setDisplayStats(true)
	cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_AUTO)
	cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION_2D)
	-- cc.Director:getInstance():setDepthTest(true)
	-- cc.Director:getInstance():setAlphaBlending(true)
	cc.Device:setKeepScreenOn(true)
	Game:init()
	Game:start()
end

xpcall(main, __G__TRACKBACK__)