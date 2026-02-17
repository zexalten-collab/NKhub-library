local NK_Library = {}
NK_Library.__index = NK_Library

-- // SERVICES
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- // THEME
local Theme = {
    Accent = Color3.fromRGB(255,165,0),
    Background = Color3.fromRGB(13,13,13),
    Surface = Color3.fromRGB(18,18,18),
    Surface2 = Color3.fromRGB(24,24,24),
    Stroke = Color3.fromRGB(40,40,40),
    Text = Color3.fromRGB(255,255,255),
    TextDim = Color3.fromRGB(140,140,140)
}

----------------------------------------------------
-- UTILS
----------------------------------------------------

local function Corner(obj,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,r)
    c.Parent = obj
end

local function Stroke(obj,color,t)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = t or 1
    s.Parent = obj
end

local function Text(obj,size,color)
    obj.Font = Enum.Font.GothamBold
    obj.TextSize = size
    obj.TextColor3 = color or Theme.Text
    obj.BackgroundTransparency = 1
end

local function Drag(top,main)
    local drag, start, pos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            start = input.Position
            pos = main.Position
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - start
            main.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
        end
    end)
end

----------------------------------------------------
-- WINDOW
----------------------------------------------------

function NK_Library:CreateWindow(cfg)
    local self = setmetatable({},NK_Library)
    cfg = cfg or {}
    self.Keybind = cfg.Keybind or Enum.KeyCode.RightControl

    if CoreGui:FindFirstChild("StudHub") then CoreGui.StudHub:Destroy() end

    self.Gui = Instance.new("ScreenGui",CoreGui)
    self.Gui.Name = "StudHub"

    self.Main = Instance.new("Frame",self.Gui)
    self.Main.Size = UDim2.new(0,520,0,340)
    self.Main.Position = UDim2.new(0.5,-260,0.5,-170)
    self.Main.BackgroundColor3 = Theme.Background
    self.Main.ClipsDescendants = true
    Corner(self.Main,10)
    Stroke(self.Main)

    local Header = Instance.new("Frame",self.Gui)
    Header.Size = UDim2.new(0,220,0,45)
    Header.BackgroundColor3 = Theme.Surface
    Corner(Header,8)
    Stroke(Header,Theme.Accent,1)

    local Title = Instance.new("TextLabel",Header)
    Title.Size = UDim2.new(1,0,1,0)
    Title.Text = cfg.Name or "STUD HUB"
    Text(Title,16)
    Drag(Header,self.Main)

    self.Side = Instance.new("Frame",self.Gui)
    self.Side.Size = UDim2.new(0,60,0,250)
    self.Side.BackgroundColor3 = Theme.Surface
    Corner(self.Side,8)
    Stroke(self.Side)

    local SideLayout = Instance.new("UIListLayout",self.Side)
    SideLayout.Padding = UDim.new(0,6)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    self.Container = Instance.new("Frame",self.Main)
    self.Container.Size = UDim2.new(1,-20,1,-20)
    self.Container.Position = UDim2.new(0,10,0,10)
    self.Container.BackgroundTransparency = 1

    -- Mobile System
    local MobileButton = Instance.new("TextButton", self.Gui)
    MobileButton.Size = UDim2.new(0, 100, 0, 35)
    MobileButton.Position = UDim2.new(0.5, -50, 0, 15)
    MobileButton.BackgroundColor3 = Theme.Surface
    MobileButton.Text = "NK HUB"
    MobileButton.Visible = false
    Text(MobileButton, 14, Theme.Accent)
    Corner(MobileButton, 8)
    Stroke(MobileButton, Theme.Accent, 1)

    local function ToggleUI(state)
        if state then
            self.Main.Visible = true
            self.Side.Visible = true
            Header.Visible = true
            self.Main:TweenSize(UDim2.new(0,520,0,340), "Out", "Back", 0.3, true)
            MobileButton.Visible = false
        else
            self.Main:TweenSize(UDim2.new(0,0,0,0), "In", "Back", 0.3, true, function()
                self.Main.Visible = false
                self.Side.Visible = false
                Header.Visible = false
                MobileButton.Visible = true
            end)
        end
    end

-- PRZYCISK ZAMYKANIA X (Teraz przypisany do głównego okna dla poprawnej pozycji)
    local CloseBtn = Instance.new("TextButton", self.Main) -- Zmienione z Header na self.Main
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5) -- Pozycja w prawym górnym rogu głównego okna
    CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    CloseBtn.Text = "×"
    CloseBtn.ZIndex = 10 -- Upewniamy się, że jest na wierzchu
    Text(CloseBtn, 22, Color3.fromRGB(255, 100, 100))
    Corner(CloseBtn, 6)
    Stroke(CloseBtn, Color3.fromRGB(60, 60, 60), 1)

    CloseBtn.MouseButton1Click:Connect(function() 
        ToggleUI(false) 
    end)
    
    RunService.RenderStepped:Connect(function()
        Header.Position = UDim2.new(self.Main.Position.X.Scale, self.Main.Position.X.Offset + 150, self.Main.Position.Y.Scale, self.Main.Position.Y.Offset - 30)
        self.Side.Position = UDim2.new(self.Main.Position.X.Scale, self.Main.Position.X.Offset - 70, self.Main.Position.Y.Scale, self.Main.Position.Y.Offset + 40)
    end)

    UIS.InputBegan:Connect(function(i,g)
        if not g and i.KeyCode == self.Keybind then ToggleUI(not self.Main.Visible) end
    end)

    -- Info label o keybindzie (Poprawiony font)
    local KeyInfo = Instance.new("TextLabel", self.Main)
    KeyInfo.Size = UDim2.new(1, 0, 0, 20)
    KeyInfo.Position = UDim2.new(0, 0, 1, -25)
    KeyInfo.Text = "Show/Hide UI: (" .. tostring(self.Keybind.Name) .. ")"
    Text(KeyInfo, 12, Theme.TextDim)
    KeyInfo.Font = Enum.Font.Gotham -- Naprawiono błąd GothamItalic

    return self
end

----------------------------------------------------
-- TAB
----------------------------------------------------

function NK_Library:CreateTab(name)
    local Tab = {}
    local Button = Instance.new("TextButton",self.Side)
    Button.Size = UDim2.new(0,40,0,40)
    Button.BackgroundColor3 = Theme.Surface2
    Button.Text = ""
    Corner(Button,6)

    local BtnLabel = Instance.new("TextLabel", Button)
    BtnLabel.Size = UDim2.new(1, 0, 1, 0)
    BtnLabel.Text = name
    Text(BtnLabel, 28)

    local Indicator = Instance.new("Frame",Button)
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0,3,1,0)
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.Visible = false

    local Page = Instance.new("ScrollingFrame",self.Container)
    Page.Size = UDim2.new(1,0,1,0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Instance.new("UIListLayout",Page).Padding = UDim.new(0,6)

    Button.MouseButton1Click:Connect(function()
        for _, v in pairs(self.Container:GetChildren()) do
            if v:IsA("ScrollingFrame") then v.Visible = false end
        end
        for _, v in pairs(self.Side:GetChildren()) do
            if v:IsA("TextButton") and v:FindFirstChild("Indicator") then v.Indicator.Visible = false end
        end
        Page.Visible = true
        Indicator.Visible = true
        
        -- Tab Pop Animation
        Button:TweenSize(UDim2.new(0,35,0,35), "Out", "Quad", 0.1, true, function()
            Button:TweenSize(UDim2.new(0,40,0,40), "Out", "Quad", 0.1)
        end)
    end)

    function Tab:CreateToggle(text,default,callback)
        local state = default or false
        local Card = Instance.new("Frame",Page)
        Card.Size = UDim2.new(1,-6,0,45)
        Card.BackgroundColor3 = Theme.Surface
        Corner(Card,6)
        Stroke(Card)

        local Label = Instance.new("TextLabel", Card)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.Text = text
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Text(Label, 14)

        local Toggle = Instance.new("Frame",Card)
        Toggle.Size = UDim2.new(0,36,0,18)
        Toggle.Position = UDim2.new(1,-50,0.5,-9)
        Toggle.BackgroundColor3 = state and Theme.Accent or Theme.Surface2
        Corner(Toggle,20)

        local Dot = Instance.new("Frame",Toggle)
        Dot.Size = UDim2.new(0,14,0,14)
        Dot.Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
        Dot.BackgroundColor3 = Color3.new(1,1,1)
        Corner(Dot,20)

        local Click = Instance.new("TextButton",Card)
        Click.Size = UDim2.new(1,0,1,0)
        Click.BackgroundTransparency = 1
        Click.Text = ""
        Click.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(Dot,TweenInfo.new(.2),{Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
            TweenService:Create(Toggle,TweenInfo.new(.2),{BackgroundColor3 = state and Theme.Accent or Theme.Surface2}):Play()
            if callback then callback(state) end
        end)
    end
    return Tab
end

return NK_Library
