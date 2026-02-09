local NK_Library = {}
NK_Library.__index = NK_Library

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ThemeColor = Color3.fromRGB(255, 165, 0) -- Pomarańczowy

-- // UTILS
local function ApplySharpText(obj)
    obj.RichText = true
    obj.Font = Enum.Font.GothamBold
    local s = Instance.new("UIStroke", obj)
    s.Thickness = 0.6
    s.Transparency = 0.4
end

local function MakeDraggable(frame, parent)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = parent.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- // GŁÓWNE OKNO
function NK_Library:CreateWindow(Config)
    local self = setmetatable({}, NK_Library)
    
    if CoreGui:FindFirstChild("NK_PREMIUM_HUB") then CoreGui.NK_PREMIUM_HUB:Destroy() end

    self.Gui = Instance.new("ScreenGui", CoreGui)
    self.Gui.Name = "NK_PREMIUM_HUB"
    
    -- GŁÓWNA RAMKA
    self.Main = Instance.new("Frame", self.Gui)
    self.Main.Size = UDim2.new(0, 560, 0, 380)
    self.Main.Position = UDim2.new(0.5, -280, 0.5, -190)
    self.Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    self.Main.BackgroundTransparency = 0.05
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", self.Main)
    MainStroke.Color = Color3.fromRGB(45, 45, 45)

    -- NAGŁÓWEK (WYSTAJĄCY)
    local Header = Instance.new("Frame", self.Main)
    Header.Size = UDim2.new(0, 260, 0, 48)
    Header.Position = UDim2.new(0.5, -130, 0, -30)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Instance.new("UICorner", Header)
    local HStroke = Instance.new("UIStroke", Header)
    HStroke.Color = ThemeColor; HStroke.Thickness = 2
    MakeDraggable(Header, self.Main)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1; Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Text = "<b>" .. (Config.Name or "STUD HUB") .. "</b>"
    ApplySharpText(Title)

    -- SIDEBAR (ZEWNĘTRZNY I LEWITUJĄCY)
    self.Sidebar = Instance.new("Frame", self.Gui)
    self.Sidebar.Size = UDim2.new(0, 65, 0, 300)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    self.Sidebar.BackgroundTransparency = 0.2
    Instance.new("UICorner", self.Sidebar).CornerRadius = UDim.new(0, 10)
    local SStroke = Instance.new("UIStroke", self.Sidebar)
    SStroke.Color = Color3.fromRGB(45, 45, 45)

    -- Logika śledzenia Main przez Sidebar (Floating Sidebar)
    RunService.RenderStepped:Connect(function()
        if self.Main and self.Sidebar then
            local offset = self.Expanded and -175 or -75
            self.Sidebar.Position = UDim2.new(self.Main.Position.X.Scale, self.Main.Position.X.Offset + offset, self.Main.Position.Y.Scale, self.Main.Position.Y.Offset + 40)
        end
    end)

    local SideLayout = Instance.new("UIListLayout", self.Sidebar)
    SideLayout.Padding = UDim.new(0, 12); SideLayout.HorizontalAlignment = "Center"
    Instance.new("UIPadding", self.Sidebar).PaddingTop = UDim.new(0, 15)

    -- PRZYCISK ROZWIJANIA (W LEWO)
    local ExpandBtn = Instance.new("TextButton", self.Sidebar)
    ExpandBtn.Size = UDim2.new(0, 40, 0, 30); ExpandBtn.Text = ">>"; ExpandBtn.TextColor3 = ThemeColor
    ExpandBtn.BackgroundTransparency = 1; ExpandBtn.TextSize = 22; ApplySharpText(ExpandBtn)

    self.Expanded = false
    ExpandBtn.MouseButton1Click:Connect(function()
        self.Expanded = not self.Expanded
        local targetSize = self.Expanded and UDim2.new(0, 160, 0, 300) or UDim2.new(0, 65, 0, 300)
        TweenService:Create(self.Sidebar, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        ExpandBtn.Text = self.Expanded and "<<" or ">>"
        
        for _, btn in pairs(self.Sidebar:GetChildren()) do
            if btn:IsA("TextButton") and btn ~= ExpandBtn then
                btn.Text = self.Expanded and "  " .. btn:GetAttribute("Full") or btn:GetAttribute("Short")
                btn.TextXAlignment = self.Expanded and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
                btn.Size = self.Expanded and UDim2.new(0.9, 0, 0, 45) or UDim2.new(0, 45, 0, 45)
            end
        end
    end)

    self.Container = Instance.new("Frame", self.Main)
    self.Container.Size = UDim2.new(1, -30, 1, -30); self.Container.Position = UDim2.new(0, 15, 0, 15); self.Container.BackgroundTransparency = 1

    return self
end

function NK_Library:CreateTab(Name, Short)
    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = #self.Container:GetChildren() == 1
    Page.ScrollBarThickness = 0; Page.AutomaticCanvasSize = "Y"
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0, 45, 0, 45); TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    TabBtn.Text = Short; TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn:SetAttribute("Full", Name); TabBtn:SetAttribute("Short", Short)
    Instance.new("UICorner", TabBtn); ApplySharpText(TabBtn)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Container:GetChildren()) do p.Visible = false end
        Page.Visible = true
        for _, b in pairs(self.Sidebar:GetChildren()) do if b:IsA("TextButton") and b ~= ExpandBtn then b.TextColor3 = Color3.fromRGB(200,200,200) end end
        TabBtn.TextColor3 = ThemeColor
    end)

    local TabFuncs = {}

    function TabFuncs:CreateToggle(Text, Desc, Callback)
        local State = false
        local Tile = Instance.new("Frame", Page)
        Tile.Size = UDim2.new(1, -10, 0, 60); Tile.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Tile.BackgroundTransparency = 0.4
        Instance.new("UICorner", Tile)

        local T = Instance.new("TextLabel", Tile); T.Text = Text; T.Size = UDim2.new(0.8,0,0.4,0); T.Position = UDim2.new(0,15,0.15,0)
        T.TextColor3 = Color3.fromRGB(255,255,255); T.BackgroundTransparency = 1; ApplySharpText(T); T.TextXAlignment = "Left"; T.TextSize = 15

        local D = Instance.new("TextLabel", Tile); D.Text = Desc; D.Size = UDim2.new(0.8,0,0.3,0); D.Position = UDim2.new(0,15,0.55,0)
        D.TextColor3 = Color3.fromRGB(150, 150, 150); D.BackgroundTransparency = 1; ApplySharpText(D); D.TextXAlignment = "Left"; D.TextSize = 11

        local Switch = Instance.new("TextButton", Tile); Switch.Size = UDim2.new(0, 40, 0, 22); Switch.Position = UDim2.new(1, -55, 0.5, -11)
        Switch.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Switch.Text = ""; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
        local Dot = Instance.new("Frame", Switch); Dot.Size = UDim2.new(0, 16, 0, 16); Dot.Position = UDim2.new(0, 3, 0.5, -8); Dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        Switch.MouseButton1Click:Connect(function()
            State = not State
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = State and ThemeColor or Color3.fromRGB(200, 200, 200)}):Play()
            Callback(State)
        end)
    end

    function TabFuncs:CreateSlider(Text, Min, Max, Default, Callback)
        local Tile = Instance.new("Frame", Page); Tile.Size = UDim2.new(1, -10, 0, 70); Tile.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Instance.new("UICorner", Tile)
        local T = Instance.new("TextLabel", Tile); T.Text = Text .. ": " .. Default; T.Size = UDim2.new(1, -20, 0, 30); T.Position = UDim2.new(0, 15, 0, 8); T.BackgroundTransparency = 1; T.TextColor3 = Color3.fromRGB(255, 255, 255); ApplySharpText(T); T.TextXAlignment = "Left"
        
        local Bar = Instance.new("Frame", Tile); Bar.Size = UDim2.new(0.9, 0, 0, 5); Bar.Position = UDim2.new(0.05, 0, 0.75, 0); Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", Bar)
        local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((Default-Min)/(Max-Min), 0, 1, 0); Fill.BackgroundColor3 = ThemeColor; Instance.new("UICorner", Fill)

        local isDragging = false
        local function Update()
            local mousePos = UserInputService:GetMouseLocation().X
            local barPos = Bar.AbsolutePosition.X
            local barSize = Bar.AbsoluteSize.X
            local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            local val = math.floor(Min + (Max - Min) * percent)
            T.Text = Text .. ": " .. val; Callback(val)
        end

        Tile.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
        RunService.RenderStepped:Connect(function() if isDragging then Update() end end)
    end

    return TabFuncs
end

function NK_Library:Notification(Title, Content, Duration)
    local Notif = Instance.new("Frame", self.Gui)
    Notif.Size = UDim2.new(0, 280, 0, 100)
    Notif.Position = UDim2.new(1, 30, 0.85, 0)
    Notif.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 10)
    local ns = Instance.new("UIStroke", Notif); ns.Color = ThemeColor; ns.Thickness = 2
    
    local T = Instance.new("TextLabel", Notif); T.Text = "<b>" .. Title .. "</b>"; T.Size = UDim2.new(1, 0, 0.4, 0); T.TextColor3 = Color3.fromRGB(255, 255, 255); ApplySharpText(T); T.TextSize = 16
    local C = Instance.new("TextLabel", Notif); C.Text = Content; C.Size = UDim2.new(1, -20, 0.5, 0); C.Position = UDim2.new(0, 10, 0.4, 0); C.TextColor3 = Color3.fromRGB(180, 180, 180); ApplySharpText(C); C.TextSize = 13; C.TextWrapped = true

    Notif:TweenPosition(UDim2.new(1, -300, 0.85, 0), "Out", "Back", 0.5, true)
    task.delay(Duration or 3, function()
        Notif:TweenPosition(UDim2.new(1, 30, 0.85, 0), "In", "Quart", 0.5, true)
        task.wait(0.5); Notif:Destroy()
    end)
end

return NK_Library
