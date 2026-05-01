-- 1. GỌI THƯ VIỆN LÊN ĐẦU FILE
local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
Notify("Đã tải file từ clodu!")
-- 2. TẠO BẢNG CHỨA HÀM MOD
local Lexus = {}

local function Notify(msg)
    pcall(function()
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. msg, 2, 4)
        end
    end)
end

-- ==========================================
-- HÀM CẤU HÌNH SÚNG
-- ==========================================
function Lexus:ApplyWeaponConfig()
    local LocalPlayer = self:GetPlayerCharacterSafety()
    if not slua.isValid(LocalPlayer) then return false end
    
    local WeaponManager = LocalPlayer.WeaponManagerComponent
    if not slua.isValid(WeaponManager) then return false end
    
    local Slot = WeaponManager:GetCurrentUsingPropSlot()
    local SlotValue = tonumber(Slot:GetValue()) or 0
    
    if SlotValue >= 1 and SlotValue <= 3 then
        local CurrentWeapon = WeaponManager.CurrentWeaponReplicated
        
        if slua.isValid(CurrentWeapon) then
            local ShootEntity = CurrentWeapon.ShootWeaponEntityComp
            local ShootEffect = CurrentWeapon.ShootWeaponEffectComp
            
            if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
                -- Kiểm tra xem súng này đã được mod chưa để tránh gán lại liên tục
                if ShootEntity.VehicleDamageScale ~= 573.0 then
                    ShootEntity.VehicleDamageScale = 573.0
                    ShootEntity.BurstShootInterval = 0.0
                    ShootEntity.ShootIntervalShowNumber = 990
                    ShootEntity.ShootInterval = 0.05
                    ShootEntity.ExtraShootInterval = 0.05
                    ShootEntity.bRecordHitDetail = false
                    
                    ShootEntity.AccessoriesVRecoilFactor = 0.13
                    ShootEntity.AccessoriesHRecoilFactor = 0.13
                    ShootEntity.RecoilKickADS = 0.11
                    
                    ShootEntity.GameDeviationFactor = 0.0
                    ShootEntity.GameDeviationAccuracy = 0.0
                    ShootEntity.MaxDamageRate = 0
                    
                    ShootEffect.CameraShakeInnerRadius = 0.0
                    ShootEffect.CameraShakeOuterRadius = 0.0
                    ShootEffect.CameraShakFalloff = 0.000001
                    
                    Notify("Cấu hình súng đã kích hoạt!")
                end
                return true
            end
        end
    end
    return false
end

-- ==========================================
-- HỆ THỐNG AUTO-SCAN (Quét liên tục an toàn)
-- ==========================================
if not _G.Lexus_Scanner_Running then
    _G.Lexus_Scanner_Running = true
    Notify("Hệ thống Auto-Scan đang chạy!")
end

-- LƯU Ý: Phải lưu hàm Tick của class CCharacterBase (Class cha)
local Old_ReceiveTick = CCharacterBase.ReceiveTick

-- Ghi đè hàm Tick
function Lexus:ReceiveTick(DeltaSeconds)
    -- 1. Luôn gọi lại hàm gốc để game hoạt động bình thường
    if Old_ReceiveTick then
        Old_ReceiveTick(self, DeltaSeconds)
    end
    
    -- 2. Tạo một bộ đếm thời gian (ScanTimer)
    self.LexusScanTimer = (self.LexusScanTimer or 0) + DeltaSeconds
    
    -- 3. Chỉ thực thi việc check súng mỗi 1.0 giây (tránh lag FPS)
    if self.LexusScanTimer >= 1.0 then
        self.LexusScanTimer = 0 -- Reset bộ đếm
        
        -- Chạy hàm cấu hình súng
        pcall(function() 
            self:ApplyWeaponConfig() 
        end)
    end
end

-- ==========================================
-- TẠO CLASS VÀ TRẢ VỀ CHO ENGINE GAME
-- ==========================================
local CLexus = class(CCharacterBase, nil, Lexus)

return require("combine_class").DeclareFeature(CLexus, {
  {
    SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature"
  },
  {
    CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature"
  },
  {
    SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature"
  },
  {
    TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature"
  },
  {
    LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature"
  },
  {
    FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature"
  },
  {
    CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature"
  },
  {
    BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature"
  },
  {
    CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature"
  }
}, "Lexus")
