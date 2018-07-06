local ClassBattleUI = require("script/app/ui/battle/battleui/battleui")
local BattleTowerUI = class("BattleTowerUI", ClassBattleUI)

function BattleTowerUI:calculateStar()
	self.starNum = 3
end

return BattleTowerUI