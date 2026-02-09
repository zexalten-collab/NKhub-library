local NK_Library = {}
NK_Library.__index = NK_Library

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ThemeColor = Color3.fromRGB(255, 165, 0) -- Pomarańczowy jak na zdjęciu

-- // POMOCNICZE FUNKCJE WIZUALNE
local function CreateStroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or ThemeColor
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = "Border"
    return s
end

local function ApplyModernText(obj)
    obj.Font = Enum.Font.GothamBold
    obj.RichText = true
    local s = Instance.new("UIStroke", obj)
    s.Thickness = 0.5
    s.Transparency = 0.5
end

function NK_Library:CreateWindow(Config)
    local self = setmetatable({}, NK_Library)
    self.Title = Config.Name or "NK HUB"
    
    -- GŁÓWNY GUI
    self.Gui = Instance.new("ScreenGui", game.CoreGui)
    self.Gui.Name = "NK_Rayfield_Style"
    
    -- GŁÓWNE OKNO
    self.Main = Instance.new("Frame", self.Gui)
    self.Main.Size = UDim2.new(0, 0, 0, 0) -- Animacja otwierania
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.Main.BackgroundTransparency = 0.05
    self.Main.ClipsDescendants = true
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 10)
    CreateStroke(self.Main, Color3.fromRGB(40, 40, 40), 1.2)

    -- NAGŁÓWEK (STUD HUB STYLE)
    local Header = Instance.new("Frame", self.Main)
    Header.Size = UDim2.new(0, 220, 0, 40)
    Header.Position = UDim2.new(0.5, -110, 0, -20)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", Header)
    local HStroke = CreateStroke(Header, ThemeColor, 1.5)

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, 0, 1, 0); TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "<b>" .. self.Title .. "</b>"; TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
    TitleLabel.TextSize = 16; ApplyModernText(TitleLabel)

    -- SIDEBAR (ANIMOWANY)
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 60, 0, 300)
    self.Sidebar.Position = UDim2.new(0, 15, 0, 60)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.Sidebar.BackgroundTransparency = 0.2; self.Sidebar.ClipsDescendants = true
    Instance.new("UICorner", self.Sidebar)

    local SideLayout = Instance.new("UIListLayout", self.Sidebar)
    SideLayout.Padding = UDim.new(0, 10); SideLayout.HorizontalAlignment = "Center"; SideLayout.VerticalAlignment = "Top"

    -- PRZYCISK ROZWIJANIA SIDEBARA
    local ExpandBtn = Instance.new("TextButton", self.Sidebar)
    ExpandBtn.Size = UDim2.new(1, 0, 0, 30); ExpandBtn.Text = ">>"; ExpandBtn.TextColor3 = ThemeColor
    ExpandBtn.BackgroundTransparency = 1; ExpandBtn.TextSize = 18; ApplyModernText(ExpandBtn)

    local SidebarExpanded = false
    ExpandBtn.MouseButton1Click:Connect(function()
        SidebarExpanded = not SidebarExpanded
        TweenService:Create(self.Sidebar, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = SidebarExpanded and UDim2.new(0, 160, 0, 300) or UDim2.new(0, 60, 0, 300)}):Play()
        ExpandBtn.Text = SidebarExpanded and "<<" or ">>"
        for _, btn in pairs(self.Sidebar:GetChildren()) do
            if btn:IsA("TextButton") and btn ~= ExpandBtn then
                btn.Text = SidebarExpanded and "  " .. btn:GetAttribute("FullName") or btn:GetAttribute("ShortName")
                btn.TextXAlignment = SidebarExpanded and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
            end
        end
    end)

    -- KONTENER NA STRONY
    self.Pages = Instance.new("Frame", self.Main)
    self.Pages.Size = UDim2.new(0, 440, 0, 300); self.Pages.Position = UDim2.new(0, 90, 0, 60); self.Pages.BackgroundTransparency = 1

    -- ANIMACJA OTWIERANIA (RAYFIELD STYLE)
    self.Main:TweenSize(UDim2.new(0, 580, 0, 400), "Out", "Quart", 0.6, true)

    return self
end

function NK_Library:CreateTab(Name, Short)
    local Page = Instance.new("ScrollingFrame", self.Pages)
    Page.Name = Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = #self.Pages:GetChildren() == 1
    Page.ScrollBarThickness = 0; Page.AutomaticCanvasSize = "Y"
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0, 45, 0, 40); TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBtn.Text = Short; TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn:SetAttribute("FullName", Name); TabBtn:SetAttribute("ShortName", Short)
    Instance.new("UICorner", TabBtn); ApplyModernText(TabBtn)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages:GetChildren()) do p.Visible = false end
        Page.Visible = true
    end)

    local Elements = {}

    function Elements:CreateToggle(Text, Desc, Callback)
        local State = false
        local Tile = Instance.new("Frame", Page)
        Tile.Size = UDim2.new(1, -10, 0, 50); Tile.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Tile.BackgroundTransparency = 0.5
        Instance.new("UICorner", Tile)

        local T = Instance.new("TextLabel", Tile); T.Text = Text; T.Size = UDim2.new(0.8,0,0.5,0); T.Position = UDim2.new(0,15,0.15,0)
        T.TextColor3 = Color3.fromRGB(255,255,255); T.BackgroundTransparency = 1; ApplyModernText(T); T.TextXAlignment = "Left"; T.TextSize = 14

        local Switch = Instance.new("TextButton", Tile); Switch.Size = UDim2.new(0, 36, 0, 18); Switch.Position = UDim2.new(1, -50, 0.5, -9)
        Switch.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Switch.Text = ""; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
        local Dot = Instance.new("Frame", Switch); Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = UDim2.new(0, 3, 0.5, -6); Dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        Switch.MouseButton1Click:Connect(function()
            State = not State
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = State and ThemeColor or Color3.fromRGB(200, 200, 200)}):Play()
            Callback(State)
        end)
    end

    function Elements:CreateSlider(Text, Min, Max, Default, Callback)
        local Tile = Instance.new("Frame", Page); Tile.Size = UDim2.new(1, -10, 0, 65); Tile.BackgroundColor3 = Color3.fromRGB(22,22,22); Instance.new("UICorner", Tile)
        local T = Instance.new("TextLabel", Tile); T.Text = Text .. ": " .. Default; T.Size = UDim2.new(1,-20,0,30); T.Position = UDim2.new(0,15,0,5); T.BackgroundTransparency = 1; T.TextColor3 = Color3.fromRGB(255,255,255); ApplyModernText(T); T.TextXAlignment = "Left"
        
        local Bar = Instance.new("Frame", Tile); Bar.Size = UDim2.new(0.9, 0, 0, 4); Bar.Position = UDim2.new(0.05, 0, 0.75, 0); Bar.BackgroundColor3 = Color3.fromRGB(45,45,45); Instance.new("UICorner", Bar)
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

    return Elements
end

function NK_Library:Notification(Title, Content, Duration)
    local Notif = Instance.new("Frame", self.Gui); Notif.Size = UDim2.new(0, 250, 0, 80); Notif.Position = UDim2.new(1, 20, 0.85, 0); Notif.BackgroundColor3 = Color3.fromRGB(20,20,20); Instance.new("UICorner", Notif)
    CreateStroke(Notif, ThemeColor, 1.2)
    local T = Instance.new("TextLabel", Notif); T.Text = Title; T.Size = UDim2.new(1,0,0.4,0); T.TextColor3 = Color3.fromRGB(255,255,255); ApplyModernText(T)
    local C = Instance.new("TextLabel", Notif); C.Text = Content; C.Size = UDim2.new(1,-20,0.6,0); C.Position = UDim2.new(0,10,0.4,0); C.TextColor3 = Color3.fromRGB(180,180,180); ApplyModernText(C); C.TextSize = 12

    Notif:TweenPosition(UDim2.new(1, -270, 0.85, 0), "Out", "Quart", 0.5)
    task.delay(Duration or 3, function() Notif:TweenPosition(UDim2.new(1, 20, 0.85, 0), "In", "Quart", 0.5); task.wait(0.5); Notif:Destroy() end)
end

return NK_Library
