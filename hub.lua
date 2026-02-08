local NK_Hub = {}
NK_Hub.__index = NK_Hub

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local CurrentTheme = Color3.fromRGB(255, 165, 0)
local UIElements = {Strokes = {}, Texts = {}}

-- // FUNKCJA NAPRAWIAJĄCA OSTROŚĆ TEKSTU
local function ApplySharpness(label)
    label.RichText = true
    label.TextSize = label.TextSize -- wymuszenie odświeżenia
    label.Font = Enum.Font.GothamBold
end

local function MakeDraggable(Frame, Handle)
    local dragging, dragInput, dragStart, startPos
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function NK_Hub:CreateWindow(Settings)
    local self = setmetatable({}, NK_Hub)
    self.Gui = Instance.new("ScreenGui", game.CoreGui)
    self.Toggled = true
    self.Bind = Enum.KeyCode.K

    self.Main = Instance.new("Frame", self.Gui)
    self.Main.Size = UDim2.new(0, 580, 0, 420)
    self.Main.Position = UDim2.new(0.5, -290, 0.5, -210)
    self.Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 10)

    local MainStroke = Instance.new("UIStroke", self.Main)
    MainStroke.Color = CurrentTheme; MainStroke.Thickness = 2; table.insert(UIElements.Strokes, MainStroke)

    -- NAGŁÓWEK
    local Header = Instance.new("Frame", self.Main)
    Header.Size = UDim2.new(1, 0, 0, 50); Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Text = "<b>NK HUB</b>"; Title.Size = UDim2.new(1, 0, 1, 0)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.TextSize = 18; ApplySharpness(Title); Title.BackgroundTransparency = 1

    local SettingsIcon = Instance.new("TextButton", Header)
    SettingsIcon.Text = "⚙️"; SettingsIcon.Size = UDim2.new(0, 30, 0, 30); SettingsIcon.Position = UDim2.new(1, -40, 0.5, -15)
    SettingsIcon.BackgroundTransparency = 1; SettingsIcon.TextColor3 = Color3.fromRGB(255, 255, 255); SettingsIcon.TextSize = 20

    -- // SIDEBAR Z WYSUWANIEM
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 60, 0, 330); self.Sidebar.Position = UDim2.new(0, 15, 0, 70)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18); self.Sidebar.ClipsDescendants = true
    Instance.new("UICorner", self.Sidebar)
    local SideStroke = Instance.new("UIStroke", self.Sidebar); SideStroke.Color = CurrentTheme; table.insert(UIElements.Strokes, SideStroke)

    local DrawerToggle = Instance.new("TextButton", self.Sidebar)
    DrawerToggle.Text = ">>"; DrawerToggle.Size = UDim2.new(1, 0, 0, 30); DrawerToggle.BackgroundTransparency = 1
    DrawerToggle.TextColor3 = CurrentTheme; ApplySharpness(DrawerToggle)

    local SideLayout = Instance.new("UIListLayout", self.Sidebar)
    SideLayout.Padding = UDim.new(0, 10); SideLayout.HorizontalAlignment = "Center"

    local Expanded = false
    DrawerToggle.MouseButton1Click:Connect(function()
        Expanded = not Expanded
        TweenService:Create(self.Sidebar, TweenInfo.new(0.3), {Size = Expanded and UDim2.new(0, 140, 0, 330) or UDim2.new(0, 60, 0, 330)}):Play()
        DrawerToggle.Text = Expanded and "<<" or ">>"
        for _, btn in pairs(self.Sidebar:GetChildren()) do
            if btn:IsA("TextButton") and btn ~= DrawerToggle then
                btn.Text = Expanded and "  " .. (btn:GetAttribute("TabName") or "") or (btn:GetAttribute("TabName") or ""):sub(1,1)
                btn.TextXAlignment = Expanded and "Left" or "Center"
            end
        end
    end)

    self.Pages = Instance.new("Frame", self.Main)
    self.Pages.Size = UDim2.new(0, 470, 0, 330); self.Pages.Position = UDim2.new(0, 85, 0, 70); self.Pages.BackgroundTransparency = 1

    MakeDraggable(self.Main, Header)

    -- OBSŁUGA BINDÓW I THEMES
    local SettingsTab = self:CreateTab("Settings")
    SettingsIcon.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages:GetChildren()) do p.Visible = false end
        self.Pages:FindFirstChild("Settings").Visible = true
    end)

    local themes = {["Orange"] = Color3.fromRGB(255,165,0), ["Red"] = Color3.fromRGB(255,50,50), ["Blue"] = Color3.fromRGB(50,150,255), ["Cyan"] = Color3.fromRGB(0,255,255)}
    for name, col in pairs(themes) do
        SettingsTab:CreateToggle("Theme: "..name, "Change UI to "..name, function(s)
            if s then
                CurrentTheme = col
                for _, st in pairs(UIElements.Strokes) do st.Color = col end
            end
        end)
    end

    return self
end

function NK_Hub:CreateTab(Name)
    local Page = Instance.new("ScrollingFrame", self.Pages)
    Page.Name = Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = #self.Pages:GetChildren() == 1
    Page.ScrollBarThickness = 2; Page.AutomaticCanvasSize = "Y"; Page.BorderSizePixel = 0
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0, 40, 0, 40); TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabBtn.Text = Name:sub(1,1); TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ApplySharpness(TabBtn)
    TabBtn:SetAttribute("TabName", Name); Instance.new("UICorner", TabBtn)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages:GetChildren()) do p.Visible = false end
        Page.Visible = true
    end)

    local Funcs = {}

    function Funcs:CreateToggle(Text, Desc, Callback)
        local State = false
        local Tile = Instance.new("TextButton", Page); Tile.Size = UDim2.new(1, -10, 0, 70); Tile.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Tile.Text = ""
        Instance.new("UICorner", Tile)

        local T = Instance.new("TextLabel", Tile); T.Text = "<b>"..Text.."</b>"; T.Size = UDim2.new(0.7,0,0.5,0); T.Position = UDim2.new(0,10,0.1,0)
        T.TextColor3 = Color3.fromRGB(255,255,255); T.BackgroundTransparency = 1; ApplySharpness(T); T.TextXAlignment = "Left"

        local D = Instance.new("TextLabel", Tile); D.Text = Desc; D.Size = UDim2.new(0.7,0,0.4,0); D.Position = UDim2.new(0,10,0.5,0)
        D.TextColor3 = CurrentTheme; D.BackgroundTransparency = 1; ApplySharpness(D); D.TextXAlignment = "Left"; D.TextSize = 12
        table.insert(UIElements.Texts, D)

        local Switch = Instance.new("Frame", Tile); Switch.Size = UDim2.new(0,40,0,20); Switch.Position = UDim2.new(0.85,0,0.4,0)
        Switch.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

        RunService.RenderStepped:Connect(function() 
            D.TextColor3 = CurrentTheme
            if State then Switch.BackgroundColor3 = CurrentTheme end
        end)

        Tile.MouseButton1Click:Connect(function()
            State = not State
            TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = State and CurrentTheme or Color3.fromRGB(40,40,40)}):Play()
            Callback(State)
        end)
    end

    return Funcs
end

function NK_Hub:Notification(Title, Content, Duration)
    local Notif = Instance.new("Frame", self.Gui); Notif.Size = UDim2.new(0, 240, 0, 70); Notif.Position = UDim2.new(1, 20, 0.85, 0); Notif.BackgroundColor3 = Color3.fromRGB(15,15,15)
    local Stroke = Instance.new("UIStroke", Notif); Stroke.Color = CurrentTheme; table.insert(UIElements.Strokes, Stroke)
    Instance.new("UICorner", Notif)
    
    local T = Instance.new("TextLabel", Notif); T.Text = "<b>"..Title.."</b>"; T.Size = UDim2.new(1,0,0.4,0); T.TextColor3 = Color3.fromRGB(255,255,255); ApplySharpness(T)
    local C = Instance.new("TextLabel", Notif); C.Text = Content; C.Size = UDim2.new(1,-20,0.6,0); C.Position = UDim2.new(0,10,0.4,0); C.TextColor3 = Color3.fromRGB(180,180,180); ApplySharpness(C); C.TextSize = 12

    Notif:TweenPosition(UDim2.new(1, -260, 0.85, 0), "Out", "Quart", 0.5)
    task.delay(Duration or 3, function() Notif:TweenPosition(UDim2.new(1, 20, 0.85, 0), "In", "Quart", 0.5) task.wait(0.5); Notif:Destroy() end)
end

return NK_Hub
