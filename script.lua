-- File trên GitHub: script.lua
_G.LexusNotify = function(msg)
    pcall(function()
        local s3, IngameTipsTools = pcall(require, "GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if s3 and IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 3)
        end
    end)
end

_G.LexusEnemyCache = _G.LexusEnemyCache or {}
_G.LexusLastScan = _G.LexusLastScan or 0

-- HÀM LOGIC CHÍNH
local function LexusMainLoop()
    local s, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not s or not GameplayData then return end
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then return end
    local uPlayerCharacter = uPlayerController:GetCurPawn()
    if not slua.isValid(uPlayerCharacter) then return end

    local sMark, InGameMarkTools = pcall(require, "GameLua.Mod.BaseMod.Common.InGameMarkTools")
    local UGameplayStatics = import("GameplayStatics")
    local CharacterClass = import("/Script/Engine.Character")

    local currentTime = os.clock()

    -- ==========================================
    -- [LUỒNG CHẬM] 2 Giây/lần: Quét địch & Mod Súng
    -- ==========================================
    if currentTime - _G.LexusLastScan > 2.0 then
        _G.LexusLastScan = currentTime

        -- 1. MOD SÚNG (Giữ nguyên các thông số tối ưu của bạn)
        if uPlayerCharacter.GetCurrentShootWeapon then
            local uWeaponManager = uPlayerCharacter:GetWeaponManager()
            if slua.isValid(uWeaponManager) and uWeaponManager.HideCurrentWeapon ~= true then
                local CurrentWeapon = uPlayerCharacter:GetCurrentShootWeapon()
                if slua.isValid(CurrentWeapon) then
                    local shootComp = CurrentWeapon.ShootWeaponComponent
                    local ShootEntity = CurrentWeapon.ShootWeaponEntity or (slua.isValid(shootComp) and shootComp.ShootWeaponEntityComponent)
                    local ShootEffect = CurrentWeapon.ShootWeaponEffect or (slua.isValid(shootComp) and (shootComp.ShootWeaponEffectComp or shootComp.ShootWeaponEffectComponent))
                    
                    if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
                        if ShootEntity.AccessoriesVRecoilFactor ~= 0.11 then
                            ShootEntity.bRecordHitDetail = false
                            ShootEntity.RecoilKickADS = 0.11
                            ShootEntity.bCachedDefaultConfig = false
                            ShootEntity.AccessoriesVRecoilFactor = 0.11
                            ShootEntity.AccessoriesHRecoilFactor = 0.07
                            ShootEntity.GameDeviationFactor = 0.0
                            ShootEffect.CameraShakeInnerRadius = 0.0
                        end
                    end
                end
            end
        end

        -- 2. QUÉT TÌM ĐỊCH & TẠO CHẤM RADAR MỚI
        -- Xóa sạch chấm cũ để làm mới
        for _, enemy in pairs(_G.LexusEnemyCache) do
            if slua.isValid(enemy) and enemy.ActiveForceMark and sMark and type(InGameMarkTools.HideMapMark) == "function" then
                InGameMarkTools.HideMapMark(enemy.ActiveForceMark)
                enemy.ActiveForceMark = nil
            end
        end
        _G.LexusEnemyCache = {} 
        
        if CharacterClass then
            local outActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
            UGameplayStatics.GetAllActorsOfClass(uPlayerController, CharacterClass, outActors)
            local myKey = uPlayerCharacter.PlayerKey
            
            for i = 0, outActors:Num() - 1 do
                local enemy = outActors:Get(i)
                -- Lọc bản thân và đồng đội
                if slua.isValid(enemy) and enemy.PlayerKey ~= myKey and enemy.TeamID ~= uPlayerCharacter.TeamID then
                    table.insert(_G.LexusEnemyCache, enemy)
                    
                    if sMark and type(InGameMarkTools.ClientAddMapMark) == "function" then
                        local loc = type(enemy.GetHeadLocation) == "function" and enemy:GetHeadLocation(false) or enemy:K2_GetActorLocation()
                        -- Dùng 'i' làm kênh hiển thị để cố gắng lách giới hạn 4 người của hệ thống Mark
                        enemy.ActiveForceMark = InGameMarkTools.ClientAddMapMark(1003, loc, 0, "", i, nil)
                    end
                end
            end
        end
    end

    -- ==========================================
    -- [LUỒNG NHANH] Cập nhật vị trí Radar mượt mà (30 FPS)
    -- ==========================================
    for _, enemy in pairs(_G.LexusEnemyCache) do
        if slua.isValid(enemy) then
            local isAlive = type(enemy.IsAlive) == "function" and enemy:IsAlive() or true
            
            if isAlive then
                -- Liên tục cập nhật tọa độ mới nhất của địch
                if enemy.ActiveForceMark and sMark and type(InGameMarkTools.UpdateMapMarkLocation) == "function" then
                    local headLocation = type(enemy.GetHeadLocation) == "function" and enemy:GetHeadLocation(false) or enemy:K2_GetActorLocation()
                    InGameMarkTools.UpdateMapMarkLocation(enemy.ActiveForceMark, headLocation)
                end
                
            -- Xóa chấm Radar khi địch chết
            elseif not isAlive and enemy.ActiveForceMark then
                if sMark and type(InGameMarkTools.HideMapMark) == "function" then
                    InGameMarkTools.HideMapMark(enemy.ActiveForceMark)
                    enemy.ActiveForceMark = nil
                end
            end
        end
    end
end

-- ==========================================
-- BỘ KHỞI ĐỘNG ĐỘNG CƠ (CHẠY ĐỆ QUY 30 FPS)
-- ==========================================
if _G.LexusLoopRunning == nil then
    _G.LexusLoopRunning = true
    local function StartFastLoop()
        pcall(LexusMainLoop)
        local s, time_ticker = pcall(require, "common.time_ticker")
        if s and time_ticker and time_ticker.AddTimerOnce then
            -- Gọi lại liên tục mỗi 0.03s để chấm Radar không bị khựng
            time_ticker.AddTimerOnce(0.03, StartFastLoop)
        end
    end
    StartFastLoop()
    if _G.LexusNotify then _G.LexusNotify("Hệ thống Mod Súng + Radar Minimap đã sẵn sàng!") end
end
