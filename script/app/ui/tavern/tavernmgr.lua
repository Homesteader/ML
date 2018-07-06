local ClassTavernMainUI = require("script/app/ui/tavern/tavernmainui")
local ClassTavernNormalRecruitUI = require("script/app/ui/tavern/tavernnormalrecruitui")
local ClassTavernHighRecruitUI = require("script/app/ui/tavern/tavernhighrecruitui")
local ClassTavernAnimateUI = require('script/app/ui/tavern/tavernanimateui')

cc.exports.TavernMgr = {
	uiClass = {
		tavernMainUI = nil,
        tavernNormalRecruitUI = nil,
        tavernHighRecruitUI = nil,
        tavernAnimateUI = nil,
	},
}

cc.exports.RecruitType = {
    normal = 1,
    high = 2,
}

setmetatable(TavernMgr.uiClass, {__mode = "v"})

function TavernMgr:showTavernMain()
    if self.uiClass["tavernMainUI"] == nil then
        MessageMgr:sendPost('get','tavern',json.encode({}),function(jsonObj)
            if jsonObj.code == 0 then
                local heroId = jsonObj.data.hid
                local typeId = jsonObj.data.id
        		self.uiClass["tavernMainUI"] = ClassTavernMainUI.new(heroId,typeId)
        		self.uiClass["tavernMainUI"]:showUI()
            end
        end)
	end
end

function TavernMgr:recuiteAgin(recuiteType,recuiteCount,love)

    if recuiteType == RecruitType.normal then
        if self.uiClass["tavernNormalRecruitUI"] then
            if recuiteCount == 1 then
                self.uiClass["tavernNormalRecruitUI"]:sendRecruitOneMsg()
            elseif recuiteCount == 10 then
                self.uiClass["tavernNormalRecruitUI"]:sendRecruitTenMsg()
            end
        end
    elseif recuiteType == RecruitType.high then
        if self.uiClass["tavernHighRecruitUI"] then
            if love then
                self.uiClass["tavernHighRecruitUI"]:sendRecruitFriendshipMsg()
            else
                if recuiteCount == 1 then
                    self.uiClass["tavernHighRecruitUI"]:sendRecruitOneMsg()
                elseif recuiteCount == 10 then
                    self.uiClass["tavernHighRecruitUI"]:sendRecruitTenMsg()
                end
            end
        end
    end
end

function  TavernMgr:updateTavernMain(recruitType)

    if self.uiClass["tavernMainUI"] then
        self.uiClass["tavernMainUI"]:update(recruitType)
    end

end

function TavernMgr:hideTavernMain()
    if self.uiClass["tavernMainUI"] then
		self.uiClass["tavernMainUI"]:hideUI()
		self.uiClass["tavernMainUI"] = nil
	end
end

function TavernMgr:showTavernNormalRecruitUI()
    if self.uiClass["tavernNormalRecruitUI"] == nil then
        self.uiClass["tavernNormalRecruitUI"] = ClassTavernNormalRecruitUI.new()
        self.uiClass["tavernNormalRecruitUI"]:showUI()
    end
end

function TavernMgr:hideNormalRecruitUI()
    if self.uiClass["tavernNormalRecruitUI"] then
        self.uiClass["tavernNormalRecruitUI"]:hideUI()
        self.uiClass["tavernNormalRecruitUI"] = nil
    end
end

function TavernMgr:showTavernHighRecruitUI()
    if self.uiClass["tavernHighRecruitUI"] == nil then
        self.uiClass["tavernHighRecruitUI"] = ClassTavernHighRecruitUI.new()
        self.uiClass["tavernHighRecruitUI"]:showUI()
    end
end

function TavernMgr:hideHighRecruitUI()
    if self.uiClass["tavernHighRecruitUI"] then
        self.uiClass["tavernHighRecruitUI"]:hideUI()
        self.uiClass["tavernHighRecruitUI"] = nil
    end
end

function TavernMgr:showTavernAnimate(awards, func, recruitCount, recuitetype, love)
    if self.uiClass["tavernAnimateUI"] == nil then
        self.uiClass["tavernAnimateUI"] = ClassTavernAnimateUI.new(awards, func, recruitCount,recuitetype,love)
        self.uiClass["tavernAnimateUI"]:showUI()
    end
end

function TavernMgr:hideTavernAnimate()
    if self.uiClass["tavernAnimateUI"] then
        self.uiClass["tavernAnimateUI"]:hideUI()
        self.uiClass["tavernAnimateUI"] = nil
        SpineCache:del_s('qianglingpai')
    end
end

function TavernMgr:showTavernMainFromFight()
    if self.uiClass["tavernMainUI"] == nil then
        self:showTavernMain()
    end
end
