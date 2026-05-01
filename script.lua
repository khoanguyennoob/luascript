-- Hệ thống Notify
local function Notify(msg)
    pcall(function()
        local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
        if IngameTipsTools and IngameTipsTools.BattleNormalTips then
            IngameTipsTools.BattleNormalTips("Lexusmod: " .. tostring(msg), 2, 4)
        end
    end)
end

Notify("Hệ thống Mod đang khởi động...")

-- Hàm Mod súng
local function ApplyWeaponMod(PlayerRef)
    -- Nếu PlayerRef đã là Character, việc gọi GetPlayerCharacterSafety có thể báo lỗi.
    -- Tùy thuộc vào cấu trúc game của bạn, hãy cẩn thận ở dòng này.
    local LocalPlayer = PlayerRef
    if PlayerRef.GetPlayerCharacterSafety then
        LocalPlayer = PlayerRef:GetPlayerCharacterSafety()
    end

    if not slua.isValid(LocalPlayer) then return end
    
    local WeaponManager = LocalPlayer.WeaponManagerComponent
    if not slua.isValid(WeaponManager) then return end
    
    local Slot = WeaponManager:GetCurrentUsingPropSlot()
    local SlotValue = tonumber(Slot:GetValue()) or 0
    
    -- Kiểm tra lại xem game dùng index từ 0 hay 1 (thường slot súng là 0, 1, 2)
    if SlotValue >= 1 and SlotValue <= 3 then
        local CurrentWeapon = WeaponManager.CurrentWeaponReplicated
        if slua.isValid(CurrentWeapon) then
            local ShootEntity = CurrentWeapon.ShootWeaponEntityComp
            local ShootEffect = CurrentWeapon.ShootWeaponEffectComp
            
            if slua.isValid(ShootEntity) and slua.isValid(ShootEffect) then
                -- In ra log để xem giá trị gốc là bao nhiêu
                -- Nếu nó crash ở những dòng gán này, tức là bạn cần hàm Setter
                ShootEntity.VehicleDamageScale = 573.0
                ShootEntity.BurstShootInterval = 0.0
                ShootEntity.ShootInterval = 0.05
                ShootEntity.AccessoriesVRecoilFactor = 0.13
                ShootEntity.AccessoriesHRecoilFactor = 0.13
                ShootEntity.GameDeviationFactor = 0.0
                ShootEffect.CameraShakeInnerRadius = 0.0
                
                Notify("Cấu hình súng đã kích hoạt!")
            end
        end
    end
end

-- Tách biến Timer ra khỏi `self` để tránh làm crash Lua Metatable của Character
local LexusScanTimer = 0

_G.LexusCloudTick = function(self, DeltaSeconds)
    if not DeltaSeconds then return end -- Chống lỗi nil
    
    LexusScanTimer = LexusScanTimer + DeltaSeconds
    if LexusScanTimer >= 1.0 then
        LexusScanTimer = 0
        
        -- Dùng pcall nhưng bắt lỗi (err) để biết chính xác nó chết ở đâu
        local status, err = pcall(ApplyWeaponMod, self)
        if not status then
            -- Bắn thông báo lỗi lên màn hình để dễ Debug
            Notify("Lỗi Mod: " .. tostring(err))
        end
    end
end
