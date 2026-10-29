-- language: Lua, target: Roblox / Metrópoles RP, executor-ready
-- full suite: aimbot + admin + autofarm + vehicle + gui + anti-afk

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- settings
local Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        Smoothness = 0.15,
        FOV = 120,
        VisibleCheck = true,
        TargetPart = "Head",
        Key = Enum.KeyCode.E
    },
    ESP = {
        Enabled = false,
        Box = true,
        Name = true,
        Distance = true,
        Tracer = false,
        Color = Color3.fromRGB(0, 255, 100)
    },
    Admin = {
        WalkSpeed = 16,
        JumpPower = 50,
        InfiniteJump = false,
        Noclip = false,
        Fly = false,
        FlySpeed = 50
    },
    Vehicle = {
        SpeedBoost = false,
        BoostMultiplier = 2.5,
        GodMode = false
    },
    Farm = {
        AutoFarm = false,
        AutoCollect = false
    },
    Misc = {
        AntiAFK = true,
        InfiniteStamina = false
    }
}

-- gui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MetropolesFullSuite"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 320)
Main.Position = UDim2.new(0.5, -210, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Title.BorderSizePixel = 0
Title.Text = "Metrópoles RP  |  Full Suite"
Title.TextColor3 = Color3.fromRGB(0, 220, 120)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = Main

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -30, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = Main

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(0, 100, 1, -32)
Tabs.Position = UDim2.new(0, 0, 0, 32)
Tabs.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Tabs.BorderSizePixel = 0
Tabs.Parent = Main

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -100, 1, -32)
Content.Position = UDim2.new(0, 100, 0, 32)
Content.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Content.BorderSizePixel = 0
Content.Parent = Main

local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Position = UDim2.new(0, 0, 0, (order-1)*36)
    btn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = Tabs
    return btn
end

local tabAim = createTab("Aimbot", 1)
local tabESP = createTab("ESP", 2)
local tabAdmin = createTab("Admin", 3)
local tabVeh = createTab("Vehicle", 4)
local tabFarm = createTab("Farm", 5)
local tabMisc = createTab("Misc", 6)

local pages = {}
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 400)
    page.Parent = Content
    pages[name] = page
    return page
end

local pageAim = createPage("Aimbot")
local pageESP = createPage("ESP")
local pageAdmin = createPage("Admin")
local pageVeh = createPage("Vehicle")
local pageFarm = createPage("Farm")
local pageMisc = createPage("Misc")

pageAim.Visible = true

local function switchTab(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
    end
end

tabAim.MouseButton1Click:Connect(function() switchTab("Aimbot") end)
tabESP.MouseButton1Click:Connect(function() switchTab("ESP") end)
tabAdmin.MouseButton1Click:Connect(function() switchTab("Admin") end)
tabVeh.MouseButton1Click:Connect(function() switchTab("Vehicle") end)
tabFarm.MouseButton1Click:Connect(function() switchTab("Farm") end)
tabMisc.MouseButton1Click:Connect(function() switchTab("Misc") end)

local function createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -44, 0.5, -10)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(60, 60, 70)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 90) or Color3.fromRGB(60, 60, 70)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)

    return frame
end

local y = 8
local function addToggle(page, text, default, cb)
    local t = createToggle(page, text, default, cb)
    t.Position = UDim2.new(0, 8, 0, y)
    y = y + 36
    return t
end

-- Aimbot page
y = 8
addToggle(pageAim, "Aimbot Enabled", false, function(v) Settings.Aimbot.Enabled = v end)
addToggle(pageAim, "Team Check", false, function(v) Settings.Aimbot.TeamCheck = v end)
addToggle(pageAim, "Visible Check", true, function(v) Settings.Aimbot.VisibleCheck = v end)

-- ESP page
y = 8
addToggle(pageESP, "ESP Enabled", false, function(v) Settings.ESP.Enabled = v end)
addToggle(pageESP, "Box", true, function(v) Settings.ESP.Box = v end)
addToggle(pageESP, "Name", true, function(v) Settings.ESP.Name = v end)
addToggle(pageESP, "Distance", true, function(v) Settings.ESP.Distance = v end)

-- Admin page
y = 8
addToggle(pageAdmin, "Infinite Jump", false, function(v) Settings.Admin.InfiniteJump = v end)
addToggle(pageAdmin, "Noclip", false, function(v) Settings.Admin.Noclip = v end)
addToggle(pageAdmin, "Fly", false, function(v) Settings.Admin.Fly = v end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -16, 0, 24)
speedLabel.Position = UDim2.new(0, 8, 0, y)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "WalkSpeed: 16"
speedLabel.TextColor3 = Color3.fromRGB(200,200,200)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = pageAdmin
y = y + 28

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 80, 0, 24)
speedBox.Position = UDim2.new(0, 8, 0, y)
speedBox.BackgroundColor3 = Color3.fromRGB(30,30,36)
speedBox.Text = "16"
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 13
speedBox.Parent = pageAdmin
speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text)
    if n then
        Settings.Admin.WalkSpeed = n
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = n
        end
        speedLabel.Text = "WalkSpeed: " .. n
    end
end)
y = y + 36

-- Vehicle page
y = 8
addToggle(pageVeh, "Speed Boost", false, function(v) Settings.Vehicle.SpeedBoost = v end)
addToggle(pageVeh, "Vehicle GodMode", false, function(v) Settings.Vehicle.GodMode = v end)

-- Farm page
y = 8
addToggle(pageFarm, "Auto Farm (jobs)", false, function(v) Settings.Farm.AutoFarm = v end)
addToggle(pageFarm, "Auto Collect", false, function(v) Settings.Farm.AutoCollect = v end)

-- Misc page
y = 8
addToggle(pageMisc, "Anti-AFK", true, function(v) Settings.Misc.AntiAFK = v end)
addToggle(pageMisc, "Infinite Stamina", false, function(v) Settings.Misc.InfiniteStamina = v end)

-- Aimbot logic
local function isVisible(part)
    if not Settings.Aimbot.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

local function getClosest()
    local closest = nil
    local shortest = Settings.Aimbot.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Settings.Aimbot.TargetPart) then
            if Settings.Aimbot.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local part = plr.Character[Settings.Aimbot.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and isVisible(part) then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = part
                end
            end
        end
    end
    return closest
end

local holding = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.Aimbot.Key then
        holding = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.Aimbot.Key then
        holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot.Enabled and holding then
        local target = getClosest()
        if target then
            local cf = Camera.CFrame
            local goal = CFrame.new(cf.Position, target.Position)
            Camera.CFrame = cf:Lerp(goal, Settings.Aimbot.Smoothness)
        end
    end
end)

-- ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_Folder"
espFolder.Parent = ScreenGui

local function clearESP()
    for _, v in ipairs(espFolder:GetChildren()) do
        v:Destroy()
    end
end

local function createESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Settings.ESP.Color
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Settings.ESP.Color
    name.Visible = false

    local dist = Drawing.new("Text")
    dist.Size = 12
    dist.Center = true
    dist.Outline = true
    dist.Color = Settings.ESP.Color
    dist.Visible = false

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not Settings.ESP.Enabled or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
            box.Visible = false
            name.Visible = false
            dist.Visible = false
            return
        end
        local hrp = plr.Character.HumanoidRootPart
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local size = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0)).Y)
            box.Size = Vector2.new(size * 1.5, size * 2)
            box.Position = Vector2.new(pos.X - box.Size.X/2, pos.Y - box.Size.Y/2)
            box.Visible = Settings.ESP.Box

            name.Text = plr.Name
            name.Position = Vector2.new(pos.X, pos.Y - size - 16)
            name.Visible = Settings.ESP.Name

            local d = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
            dist.Text = d .. "m"
            dist.Position = Vector2.new(pos.X, pos.Y + size + 4)
            dist.Visible = Settings.ESP.Distance
        else
            box.Visible = false
            name.Visible = false
            dist.Visible = false
        end
    end)

    plr.AncestryChanged:Connect(function()
        if not plr.Parent then
            conn:Disconnect()
            box:Remove()
            name:Remove()
            dist:Remove()
        end
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end
Players.PlayerAdded:Connect(createESP)

-- Admin features
local flyBV, flyBG
local function toggleFly(state)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if state then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = hrp
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9e4
        flyBG.Parent = hrp
        char.Humanoid.PlatformStand = true
    else
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        char.Humanoid.PlatformStand = false
    end
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- walkspeed
    if hum.WalkSpeed \~= Settings.Admin.WalkSpeed then
        hum.WalkSpeed = Settings.Admin.WalkSpeed
    end

    -- infinite jump
    if Settings.Admin.InfiniteJump then
        hum.JumpPower = 50
        UserInputService.JumpRequest:Connect(function()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end

    -- noclip
    if Settings.Admin.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- fly
    if Settings.Admin.Fly and flyBV and flyBG then
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        flyBV.Velocity = dir.Unit * Settings.Admin.FlySpeed
        flyBG.CFrame = Camera.CFrame
    end
end)

-- reconnect fly toggle
local oldFly
RunService.Heartbeat:Connect(function()
    if Settings.Admin.Fly \~= oldFly then
        toggleFly(Settings.Admin.Fly)
        oldFly = Settings.Admin.Fly
    end
end)

-- Vehicle
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local seat = char:FindFirstChildOfClass("Humanoid") and char.Humanoid.SeatPart
    if seat and seat:IsA("VehicleSeat") then
        local veh = seat.Parent
        if Settings.Vehicle.SpeedBoost and veh then
            for _, v in ipairs(veh:GetDescendants()) do
                if v:IsA("VehicleSeat") or v:IsA("BasePart") then
                    -- simple boost via BodyVelocity if present or torque
                end
            end
            -- apply velocity boost
            if seat.Throttle > 0 then
                local bv = seat:FindFirstChild("BoostBV") or Instance.new("BodyVelocity")
                bv.Name = "BoostBV"
                bv.MaxForce = Vector3.new(9e4, 0, 9e4)
                bv.Velocity = seat.CFrame.LookVector * (seat.MaxSpeed * Settings.Vehicle.BoostMultiplier)
                bv.Parent = seat
            end
        end
        if Settings.Vehicle.GodMode and veh then
            for _, p in ipairs(veh:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = true
                    -- health spoof if network owner
                end
            end
        end
    end
end)

-- Anti-AFK
if Settings.Misc.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- Auto Farm placeholder (game-specific remotes needed)
-- Metrópoles RP uses custom remotes for jobs/money. Scan ReplicatedStorage for RemoteEvents
task.spawn(function()
    while true do
        if Settings.Farm.AutoFarm then
            -- example: fire common job remotes if found
            for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (remote.Name:lower():find("job") or remote.Name:lower():find("money") or remote.Name:lower():find("pay")) then
                    -- pcall(function() remote:FireServer() end)
                end
            end
        end
        task.wait(2)
    end
end)

print("[Metrópoles Full Suite] carregado. Segure E para aimbot. Arraste a janela.")
