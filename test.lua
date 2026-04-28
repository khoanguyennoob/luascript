local ChatComponent = require("GameLua.Mod.BaseMod.Common.ChatComponent")

local function Notify()
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerController = GameplayData.GetPlayerController()
    if uPlayerController and uPlayerController.ChatComponent then
        uPlayerController.ChatComponent:AddMsgInClient("<ChatQuickMsg>Lexusmod: Script từ Cloud đã khởi chạy!</>")
    end
end

Notify()
