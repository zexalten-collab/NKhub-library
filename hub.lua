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
    s.Thickness = 0.5
    s.Transparency = 0.5 -- Poprawa czytelności
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

-- // WINDOW CREATION
function NK_Library:CreateWindow(Config)
    local self = setmetatable({}, NK_Library)
    self.Tabs = {}
    
    self.Gui = Instance.new("ScreenGui", CoreGui)
    self.Gui.Name = "NK_PRO_UI"

    -- GŁÓWNY CIEŃ / GLOW
    self.Main = Instance.new("Frame", self.Gui)
    self.Main.Size = UDim2.new(0, 0, 0, 0) -- Start animacji
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.Main.BackgroundTransparency = 0.05
    self.Main.ClipsDescendants = true
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 10)
    local MainStroke = Instance.new("UIStroke", self.Main)
    MainStroke.Color = Color3.fromRGB(45, 45, 45)

    -- NAGŁÓWEK (STUD HUB STYLE)
    local Header = Instance.new("Frame", self.Main)
    Header.Size = UDim2.new(0, 240, 0, 45)
    Header.Position = UDim2.new(0.5, -120, 0, -22)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", Header)
    local HStroke = Instance.new("UIStroke", Header)
    HStroke.Color = ThemeColor; HStroke.Thickness = 1.5
    MakeDraggable(Header, self.Main)

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1; Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Text = "<b>" .. (Config.Name or "NK HUB") .. "</b>"
    ApplySharpText(Title)

    -- SIDEBAR
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 65, 0, 310)
    self.Sidebar.Position = UDim2.new(0, 15, 0, 65)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.Sidebar.BackgroundTransparency = 0.3; self.Sidebar.ClipsDescendants = true
    Instance.new("UICorner", self.Sidebar)

    local SideLayout = Instance.new("UIListLayout", self.Sidebar)
    SideLayout.Padding = UDim.new(0, 10); SideLayout.HorizontalAlignment = "Center"
    Instance.new("UIPadding", self.Sidebar).PaddingTop = UDim.new(0, 10)

    -- PRZYCISK ROZWIJANIA SIDEBARA (AF -> AUTOFARM)
    local ExpandBtn = Instance.new("TextButton", self.Sidebar)
    ExpandBtn.Size = UDim2.new(0, 40, 0, 30); ExpandBtn.Text = ">>"; ExpandBtn.TextColor3 = ThemeColor
    ExpandBtn.BackgroundTransparency = 1; ExpandBtn.TextSize = 20; ApplySharpText(ExpandBtn)

    self.Expanded = false
    ExpandBtn.MouseButton1Click:Connect(function()
        self.Expanded = not self.Expanded
        TweenService:Create(self.Sidebar, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = self.Expanded and UDim2.new(0, 160, 0, 310) or UDim2.new(0, 65, 0, 310)}):Play()
        ExpandBtn.Text = self.Expanded and "<<" or ">>"
        
        for _, btn in pairs(self.Sidebar:GetChildren()) do
            if btn:IsA("TextButton") and btn ~= ExpandBtn then
                btn.Text = self.Expanded and "  " .. btn:GetAttribute("Full") or btn:GetAttribute("Short")
                btn.TextXAlignment = self.Expanded and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
                if self.Expanded then btn.Size = UDim2.new(0.9, 0, 0, 40) else btn.Size = UDim2.new(0, 45, 0, 40) end
            end
        end
    end)

    -- CONTAINER NA STRONY
    self.Container = Instance.new("Frame", self.Main)
    self.Container.Size = UDim2.new(0, 470, 0, 310); self.Container.Position = UDim2.new(0, 95, 0, 65); self.Container.BackgroundTransparency = 1

    -- ANIMACJA OTWIERANIA (RAYFIELD STYLE)
    self.Main:TweenSize(UDim2.new(0, 600, 0, 400), "Out", "Quart", 0.6, true)

    return self
end

-- // TAB CREATION
function NK_Library:CreateTab(Name, Short)
    local Page = Instance.new("ScrollingFrame", self.Container)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = #self.Container:GetChildren() == 1
    Page.ScrollBarThickness = 2; Page.ScrollBarImageColor3 = ThemeColor; Page.AutomaticCanvasSize = "Y"
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0, 45, 0, 40); TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBtn.Text = Short; TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn:SetAttribute("Full", Name); TabBtn:SetAttribute("Short", Short)
    Instance.new("UICorner", TabBtn); ApplySharpText(TabBtn)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Container:GetChildren()) do p.Visible = false end
        Page.Visible = true
    end)

    local TabFuncs = {}

    -- // TOGGLE
    function TabFuncs:CreateToggle(Text, Desc, Callback)
        local State = false
        local Tile = Instance.new("Frame", Page)
        Tile.Size = UDim2.new(1, -20, 0, 55); Tile.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Tile.BackgroundTransparency = 0.5
        Instance.new("UICorner", Tile)

        local T = Instance.new("TextLabel", Tile); T.Text = Text; T.Size = UDim2.new(0.8,0,0.5,0); T.Position = UDim2.new(0,15,0.15,0)
        T.TextColor3 = Color3.fromRGB(255,255,255); T.BackgroundTransparency = 1; ApplySharpText(T); T.TextXAlignment = "Left"; T.TextSize = 14

        local D = Instance.new("TextLabel", Tile); D.Text = Desc; D.Size = UDim2.new(0.8,0,0.3,0); D.Position = UDim2.new(0,15,0.55,0)
        D.TextColor3 = Color3.fromRGB(150,150,150); D.BackgroundTransparency = 1; ApplySharpText(D); D.TextXAlignment = "Left"; D.TextSize = 11

        local Switch = Instance.new("TextButton", Tile); Switch.Size = UDim2.new(0, 38, 0, 20); Switch.Position = UDim2.new(1, -55, 0.5, -10)
        Switch.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Switch.Text = ""; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
        local Dot = Instance.new("Frame", Switch); Dot.Size = UDim2.new(0, 14, 0, 14); Dot.Position = UDim2.new(0, 3, 0.5, -7); Dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        Switch.MouseButton1Click:Connect(function()
            State = not State
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = State and ThemeColor or Color3.fromRGB(200, 200, 200)}):Play()
            Callback(State)
        end)
    end

    -- // SLIDER
    function TabFuncs:CreateSlider(Text, Min, Max, Default, Callback)
        local Tile = Instance.new("Frame", Page); Tile.Size = UDim2.new(1, -20, 0, 65); Tile.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Instance.new("UICorner", Tile)
        local T = Instance.new("TextLabel", Tile); T.Text = Text .. ": " .. Default; T.Size = UDim2.new(1, -20, 0, 30); T.Position = UDim2.new(0, 15, 0, 5); T.BackgroundTransparency = 1; T.TextColor3 = Color3.fromRGB(255, 255, 255); ApplySharpText(T); T.TextXAlignment = "Left"
        
        local Bar = Instance.new("Frame", Tile); Bar.Size = UDim2.new(0.9, 0, 0, 4); Bar.Position = UDim2.new(0.05, 0, 0.75, 0); Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", Bar)
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

-- // NOTIFICATION SYSTEM
function NK_Library:Notification(Title, Content, Duration)
    local Notif = Instance.new("Frame", self.Gui); Notif.Size = UDim2.new(0, 260, 0, 90); Notif.Position = UDim2.new(1, 20, 0.8, 0); Notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", Notif)
    local ns = Instance.new("UIStroke", Notif); ns.Color = ThemeColor; ns.Thickness = 1.2
    local T = Instance.new("TextLabel", Notif); T.Text = "<b>" .. Title .. "</b>"; T.Size = UDim2.new(1, 0, 0.4, 0); T.TextColor3 = Color3.fromRGB(255, 255, 255); ApplySharpText(T)
    local C = Instance.new("TextLabel", Notif); C.Text = Content; C.Size = UDim2.new(1, -20, 0.6, 0); C.Position = UDim2.new(0, 10, 0.4, 0); C.TextColor3 = Color3.fromRGB(180, 180, 180); ApplySharpText(C); C.TextSize = 12

    Notif:TweenPosition(UDim2.new(1, -280, 0.8, 0), "Out", "Quart", 0.5)
    task.delay(Duration or 3, function() Notif:TweenPosition(UDim2.new(1, 20, 0.8, 0), "In", "Quart", 0.5); task.wait(0.5); Notif:Destroy() end)
end

return NK_Library
