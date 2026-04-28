local function Notify()
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    local uPlayerController = GameplayData.GetPlayerController()
    if not uPlayerController then return end
    local s2, STExtraBlueprintFunctionLibrary = pcall(import, "STExtraBlueprintFunctionLibrary")
    if not s2 or not STExtraBlueprintFunctionLibrary then return end
    local chatComp = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
    local s3, InGameUITools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameUITools")

    if chatComp and chatComp.AddMsgInClient then
        chatComp:AddMsgInClient("<ChatQuickMsg>Lexusmod: Chào</>")
        InGameUITools.ShowSystemTip("Lexusmod: Thông báo từ Cloud!")
        if s3 and InGameUITools and InGameUITools.ShowSystemTip then
            InGameUITools.ShowSystemTip("Lexusmod: Thông báo từ Cloud!")
        end
    else
        if s3 and InGameUITools and InGameUITools.ShowSystemTip then
            InGameUITools.ShowSystemTip("Lexusmod: Khởi chạy thành công (ChatComponent bị kẹt)")
        end
    end
end

local stat, err = pcall(Notify)
if not stat then
    local s, UI = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameUITools")
    if s and UI then UI.ShowSystemTip("Lexusmod Lỗi: " .. tostring(err)) end
end
