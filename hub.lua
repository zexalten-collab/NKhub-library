local NK_Hub = {}
NK_Hub.__index = NK_Hub

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- // SYSTEM DRAGU (NAPRAWIONY - PRZYPISANY DO UCHWYTU)
local function MakeDraggable(Frame, Handle)
    local dragging, dragInput, dragStart, startPos
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- // GŁÓWNE OKNO
function NK_Hub:CreateWindow(Settings)
    local self = setmetatable({}, NK_Hub)
    self.Gui = Instance.new("ScreenGui", game.CoreGui)
    self.Gui.Name = "NK_HUB_MASTER"
    
    self.Main = Instance.new("Frame", self.Gui)
    self.Main.Size = UDim2.new(0, 580, 0, 420)
    self.Main.Position = UDim2.new(0.5, -290, 0.5, -210)
    self.Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 12)

    -- Pomarańczowy Border
    local MainStroke = Instance.new("UIStroke", self.Main)
    MainStroke.Color = Color3.fromRGB(255, 165, 0)
    MainStroke.Thickness = 2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Nagłówek (Teraz służy jako uchwyt do przesuwania)
    local Header = Instance.new("Frame", self.Main)
    Header.Size = UDim2.new(1, 0, 0, 70) -- Większy obszar do chwytania
    Header.BackgroundTransparency = 1
    
    local HeaderVisual = Instance.new("Frame", Header)
    HeaderVisual.Size = UDim2.new(0, 400, 0, 55)
    HeaderVisual.Position = UDim2.new(0.5, -200, 0.15, 0)
    HeaderVisual.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Instance.new("UICorner", HeaderVisual)
    Instance.new("UIStroke", HeaderVisual).Color = Color3.fromRGB(255, 165, 0)

    local Title = Instance.new("TextLabel", HeaderVisual)
    Title.Text = "<b>NK HUB</b>"
    Title.Size = UDim2.new(1, 0, 0.6, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = "GothamBold"; Title.TextSize = 20; Title.RichText = true; Title.BackgroundTransparency = 1

    local Sub = Instance.new("TextLabel", HeaderVisual)
    Sub.Text = Settings.GameName or "Universal Menu"
    Sub.Position = UDim2.new(0, 0, 0.5, 0); Sub.Size = UDim2.new(1, 0, 0.4, 0)
    Sub.TextColor3 = Color3.fromRGB(180, 180, 180); Sub.Font = "GothamBold"; Sub.TextSize = 12
    Sub.BackgroundTransparency = 1; Sub.RichText = true

    -- Sidebar
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 65, 0, 310); self.Sidebar.Position = UDim2.new(0.03, 0, 0.22, 0)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18); Instance.new("UICorner", self.Sidebar)
    Instance.new("UIStroke", self.Sidebar).Color = Color3.fromRGB(255, 165, 0)

    local SideLayout = Instance.new("UIListLayout", self.Sidebar)
    SideLayout.Padding = UDim.new(0, 12); SideLayout.HorizontalAlignment = "Center"; SideLayout.VerticalAlignment = "Center"

    self.Pages = Instance.new("Frame", self.Main)
    self.Pages.Size = UDim2.new(0, 460, 0, 310); self.Pages.Position = UDim2.new(0.18, 0, 0.22, 0)
    self.Pages.BackgroundTransparency = 1

    MakeDraggable(self.Main, Header)
    return self
end

-- // TABS
function NK_Hub:CreateTab(Name)
    local Page = Instance.new("ScrollingFrame", self.Pages)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = #self.Pages:GetChildren() == 1
    Page.ScrollBarThickness = 2; Page.AutomaticCanvasSize = "Y"; Page.BorderSizePixel = 0
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0, 42, 0, 42); TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = Name:sub(1,1); TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = "GothamBold"; Instance.new("UICorner", TabBtn)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages:GetChildren()) do p.Visible = false end
        Page.Visible = true
    end)

    local Funcs = {}

    -- // SLIDER (NAPRAWIONY)
    function Funcs:CreateSlider(Text, Min, Max, Default, Callback)
        local Tile = Instance.new("Frame", Page)
        Tile.Size = UDim2.new(1, -15, 0, 85); Tile.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Tile.Active = true
        Instance.new("UICorner", Tile)

        local T = Instance.new("TextLabel", Tile)
        T.Text = "<b>" .. Text .. ": " .. Default .. "</b>"
        T.Size = UDim2.new(1, -20, 0, 35); T.Position = UDim2.new(0, 15, 0, 5)
        T.TextColor3 = Color3.fromRGB(255, 255, 255); T.Font = "GothamBold"; T.RichText = true
        T.BackgroundTransparency = 1; T.TextXAlignment = "Left"

        local Bar = Instance.new("Frame", Tile)
        Bar.Name = "SliderBar"; Bar.Size = UDim2.new(0.9, 0, 0, 6); Bar.Position = UDim2.new(0.05, 0, 0.7, 0)
        Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", Bar)

        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((Default-Min)/(Max-Min), 0, 1, 0); Fill.BackgroundColor3 = Color3.fromRGB(255, 165, 0); Instance.new("UICorner", Fill)

        local isDragging = false
        local function Update(input)
            local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(Min + (Max - Min) * pos)
            T.Text = "<b>" .. Text .. ": " .. val .. "</b>"; Callback(val)
        end

        Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = true; Update(i) end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
        UserInputService.InputChanged:Connect(function(i) if isDragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
    end

    function Funcs:CreateToggle(Text, Desc, Callback)
        local State = false
        local Tile = Instance.new("TextButton", Page)
        Tile.Size = UDim2.new(1, -15, 0, 75); Tile.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Tile.Text = ""
        Tile.ClipsDescendants = true; Instance.new("UICorner", Tile)

        local T = Instance.new("TextLabel", Tile)
        T.Text = "<b>" .. Text .. "</b>"; T.Size = UDim2.new(0.7, 0, 0.5, 0); T.Position = UDim2.new(0, 15, 0.15, 0)
        T.TextColor3 = Color3.fromRGB(255, 255, 255); T.Font = "GothamBold"; T.TextSize = 15; T.RichText = true
        T.TextXAlignment = "Left"; T.BackgroundTransparency = 1

        local D = Instance.new("TextLabel", Tile)
        D.Text = Desc; D.Size = UDim2.new(0.7, 0, 0.4, 0); D.Position = UDim2.new(0, 15, 0.55, 0)
        D.TextColor3 = Color3.fromRGB(255, 165, 0); D.Font = "GothamBold"; D.TextSize = 13
        D.TextXAlignment = "Left"; D.BackgroundTransparency = 1; D.RichText = true

        local Switch = Instance.new("Frame", Tile)
        Switch.Size = UDim2.new(0, 45, 0, 22); Switch.Position = UDim2.new(0.85, 0, 0.35, 0)
        Switch.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

        Tile.MouseButton1Click:Connect(function()
            State = not State
            TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = State and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(45, 45, 45)}):Play()
            Callback(State)
        end)
    end

    return Funcs
end

-- // POWIADOMIENIA
function NK_Hub:Notification(Title, Content, Duration)
    local Notif = Instance.new("Frame", self.Gui)
    Notif.Size = UDim2.new(0, 250, 0, 80); Notif.Position = UDim2.new(1, 20, 0.8, 0)
    Notif.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", Notif)
    Instance.new("UIStroke", Notif).Color = Color3.fromRGB(255, 165, 0)
    
    local T = Instance.new("TextLabel", Notif)
    T.Text = "<b>" .. Title .. "</b>"; T.Size = UDim2.new(1, 0, 0.4, 0); T.TextColor3 = Color3.fromRGB(255, 255, 255)
    T.Font = "GothamBold"; T.RichText = true; T.BackgroundTransparency = 1; T.TextSize = 14
    
    local C = Instance.new("TextLabel", Notif)
    C.Text = Content; C.Size = UDim2.new(1, -20, 0.6, 0); C.Position = UDim2.new(0, 10, 0.4, 0)
    C.TextColor3 = Color3.fromRGB(200, 200, 200); C.Font = "GothamBold"; C.TextSize = 12; C.BackgroundTransparency = 1; C.TextWrapped = true

    Notif:TweenPosition(UDim2.new(1, -270, 0.8, 0), "Out", "Back", 0.5)
    task.delay(Duration or 5, function()
        Notif:TweenPosition(UDim2.new(1, 20, 0.8, 0), "In", "Back", 0.5)
        task.wait(0.5); Notif:Destroy()
    end)
end

return NK_Hub
