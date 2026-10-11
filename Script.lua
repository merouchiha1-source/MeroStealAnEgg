-- ====================================================
-- سكربت سرقة البيض الاحترافي | Steal An Egg
-- المطور: مـــيـــرو اوتـــــــــشيها (Mero Uchiha)
-- ====================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- حالة المميزات التشغيلية
local ScriptConfig = {
    SilentSleep = false,     -- 1. نوم الحيوان 😴
    ValueInspector = false,  -- 2. بيع الأرباح 💰
    RareEggTracker = false,  -- 3. وقت البيضة النادرة 🥚✨
    ShadowShield = false     -- 4. عدم التأثير بضرب الناس 🛡️⚔️
}

-- دالة ألوان الحالة (أخضر مفعل / أحمر مطفي)
local function GetStatusColor(state)
    if state then
        return Color3.fromRGB(0, 255, 128) -- أخضر ساطع (مفعل 🔥)
    else
        return Color3.fromRGB(255, 60, 60)  -- أحمر (متوقف ❌)
    end
end

-- ====================================================
-- 1. نوم الحيوان 😴 (تشغيل فعلي لتجميد حركة الحيوانات عند السرقة)
local function ToggleSilentSleep(state)
    ScriptConfig.SilentSleep = state
    if state then
        task.spawn(function()
            while ScriptConfig.SilentSleep do
                task.wait(0.5) -- فحص دوري خفيف جداً بدون لاق
                pcall(function()
                    local animalsFolder = Workspace:FindFirstChild("Animals") or Workspace:FindFirstChild("NPCs")
                    if animalsFolder then
                        for _, animal in pairs(animalsFolder:GetChildren()) do
                            local hum = animal:FindFirstChildOfClass("Humanoid")
                            local rootPart = animal:FindFirstChild("HumanoidRootPart")
                            -- إذا كان اللاعب قريب من الحيوان أو بشكل عام يتم تجميد سرعته
                            if hum and rootPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local distance = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                if distance < 20 then -- نطاق التفعيل القريب
                                    hum.WalkSpeed = 0
                                    hum.JumpPower = 0
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end

-- ====================================================
-- 2. بيع الأرباح 💰 (قراءة حقيقية لسعر البيضة والأرباح لكل ثانية بدون لاق)
local function ToggleValueInspector(state)
    ScriptConfig.ValueInspector = state
    if state then
        task.spawn(function()
            while ScriptConfig.ValueInspector do
                task.wait(1)
                pcall(function()
                    local eggsFolder = Workspace:FindFirstChild("Eggs")
                    if eggsFolder then
                        for _, egg in pairs(eggsFolder:GetChildren()) do
                            -- البحث عن قيمة السعر أو الربح داخل البيضة وتحديثها برمجياً
                            local val = egg:FindFirstChild("ValuePerSecond") or egg:FindFirstChild("CPS")
                            if val and not egg:FindFirstChild("MeroValueTag") then
                                -- هنا يتم إرفاق تاغ برمجياً يظهر السعر فوق البيضة مباشرة بدون ضغط على السيرفر
                                local bill = Instance.New("BillboardGui", egg)
                                bill.Name = "MeroValueTag"
                                bill.Size = UDim2.new(0, 100, 0, 50)
                                bill.AlwaysOnTop = true
                                local text = Instance.New("TextLabel", bill)
                                text.Size = UDim2.new(1, 0, 1, 0)
                                text.BackgroundTransparency = 1
                                text.TextColor3 = Color3.fromRGB(255, 215, 0)
                                text.TextScaled = true
                                text.Text = "💰 " .. tostring(val.Value) .. "/s"
                            end
                        end
                    end
                end)
            end
        end)
    else
        -- تنظيف التاغات عند الإيقاف
        pcall(function()
            for _, egg in pairs(Workspace.Eggs:GetChildren()) do
                local tag = egg:FindFirstChild("MeroValueTag")
                if tag then tag:Destroy() end
            end
        end)
    end
end

-- ====================================================
-- 3. وقت البيضة النادرة 🥚✨ (رادار حقيقي يتسق مع ظهور البيض النادر)
local function ToggleRareEggTracker(state)
    ScriptConfig.RareEggTracker = state
    if state then
        pcall(function()
            local eggsFolder = Workspace:FindFirstChild("Eggs")
            if eggsFolder then
                -- مراقبة فورية لأي بيضة جديدة تظهر في الخريطة
                ScriptConfig.EggConnection = eggsFolder.ChildAdded:Connect(function(newEgg)
                    task.wait(0.5)
                    local isRare = newEgg:GetAttribute("IsRare") or newEgg:FindFirstChild("Rare")
                    if isRare then
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "🥚✨ بيضة نادرة ظهرت!",
                            Text = "تم رصد بيضة نادرة، توجه إليها فوراً يا ميرو!",
                            Duration = 6
                        })
                    end
                end)
            end
        end)
    else
        if ScriptConfig.EggConnection then
            ScriptConfig.EggConnection:Disconnect()
        end
    end
end

-- ====================================================
-- 4. عدم التأثير بضرب الناس 🛡️⚔️ (حماية حقيقية ضد ضرر العصا واللاعبين)
local function ToggleShadowShield(state)
    ScriptConfig.ShadowShield = state
    if state then
        task.spawn(function()
            while ScriptConfig.ShadowShield do
                task.wait(0.2)
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            -- منع نقص الدم الناتج عن ضربات اللاعبين الآخرين (Anti-Damage)
                            hum.HealthChanged:Connect(function(health)
                                if ScriptConfig.ShadowShield and health < hum.MaxHealth then
                                    hum.Health = hum.MaxHealth -- إعادة تعبئة الدم فوراً إذا حاول أحد يضربك
                                end
                            end)
                        end
                    end
                end)
            end
        end)
    end
end

-- ====================================================
-- طريقة الاستخدام والتشغيل:
-- تقريباً كل ميزة الآن مرتبطة بدالة برمجية حقيقية 100%
-- مثال: لتفعيل نوم الحيوان وعرض لونه:
-- ToggleSilentSleep(true)
-- print("حالة نوم الحيوان:", GetStatusColor(ScriptConfig.SilentSleep))
