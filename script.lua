local function Notify()
    -- 1. Lấy dữ liệu người chơi
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    local uPlayerController = GameplayData.GetPlayerController()
    if not uPlayerController then return end

    -- 2. Lấy thư viện Blueprint và Chat Component
    local s2, STExtraBlueprintFunctionLibrary = pcall(import, "STExtraBlueprintFunctionLibrary")
    if s2 and STExtraBlueprintFunctionLibrary then
        local chatComp = STExtraBlueprintFunctionLibrary.GetChatComponentFromController(uPlayerController)
        if chatComp and chatComp.AddMsgInClient then
            chatComp:AddMsgInClient("<ChatQuickMsg>Lexusmod: Loadmod thành công!</>")
        end
    end

    -- 3. HIỂN THỊ POPUP RA GIỮA MÀN HÌNH (Dùng đúng hàm từ file InGameTipsTools)
    local s3, IngameTipsTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
    if s3 and IngameTipsTools and IngameTipsTools.BattleNormalTips then
        -- Truyền: (Nội dung chữ, ID hiệu ứng animation (thường là 1), Thời gian hiển thị (giây))
        IngameTipsTools.BattleNormalTips("Lexusmod: Đã tiêm Script từ Cloud thành công!", 2, 3)
    end
end

-- Bọc pcall để chống crash tuyệt đối
local stat, err = pcall(Notify)
if not stat then
    print("Lexusmod Error: " .. tostring(err))
end

-- ==============================================
-- BẠN VIẾT TIẾP LOGIC HACK/MOD CỦA BẠN TỪ ĐÂY
-- ==============================================
