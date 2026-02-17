local NK_Library = {}
NK_Library.__index = NK_Library

-- // SERVICES
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- // THEME (Stud Hub style)
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

----------------------------------------------------
-- DRAG
----------------------------------------------------

local function Drag(top,main)
    local drag = false
    local start
    local pos

    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            start = input.Position
            pos = main.Position
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - start
            main.Position = UDim2.new(
                pos.X.Scale,
                pos.X.Offset + delta.X,
                pos.Y.Scale,
                pos.Y.Offset + delta.Y
            )
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

    if CoreGui:FindFirstChild("StudHub") then
        CoreGui.StudHub:Destroy()
    end

    self.Gui = Instance.new("ScreenGui",CoreGui)
    self.Gui.Name = "StudHub"

    ------------------------------------------------
    -- MAIN
    ------------------------------------------------

    self.Main = Instance.new("Frame",self.Gui)
    self.Main.Size = UDim2.new(0,520,0,340)
    self.Main.Position = UDim2.new(0.5,-260,0.5,-170)
    self.Main.BackgroundColor3 = Theme.Background

    Corner(self.Main,10)
    Stroke(self.Main)

    ------------------------------------------------
    -- HEADER (FLOATING)
    ------------------------------------------------

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

    ------------------------------------------------
    -- SIDEBAR FLOATING
    ------------------------------------------------

    self.Side = Instance.new("Frame",self.Gui)
    self.Side.Size = UDim2.new(0,60,0,250)
    self.Side.BackgroundColor3 = Theme.Surface

    Corner(self.Side,8)
    Stroke(self.Side)

    local SideLayout = Instance.new("UIListLayout",self.Side)
    SideLayout.Padding = UDim.new(0,6)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    ------------------------------------------------
    -- FOLLOW SYSTEM
    ------------------------------------------------

    RunService.RenderStepped:Connect(function()
        Header.Position = UDim2.new(
            self.Main.Position.X.Scale,
            self.Main.Position.X.Offset + 150,
            self.Main.Position.Y.Scale,
            self.Main.Position.Y.Offset - 30
        )

        self.Side.Position = UDim2.new(
            self.Main.Position.X.Scale,
            self.Main.Position.X.Offset - 70,
            self.Main.Position.Y.Scale,
            self.Main.Position.Y.Offset + 40
        )
    end)

    ------------------------------------------------
    -- CONTAINER
    ------------------------------------------------

    self.Container = Instance.new("Frame",self.Main)
    self.Container.Size = UDim2.new(1,-20,1,-20)
    self.Container.Position = UDim2.new(0,10,0,10)
    self.Container.BackgroundTransparency = 1

    ------------------------------------------------
    -- KEYBIND
    ------------------------------------------------

    UIS.InputBegan:Connect(function(i,g)
        if g then return end
        if i.KeyCode == self.Keybind then
            self.Main.Visible = not self.Main.Visible
            self.Side.Visible = self.Main.Visible
            Header.Visible = self.Main.Visible
        end
    end)

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

    -- Wklej to pod Corner(Button, 6) w image_4d723f.png
    local BtnLabel = Instance.new("TextLabel", Button)
    BtnLabel.Size = UDim2.new(1, 0, 1, 0)
    BtnLabel.Text = name -- Ustawia nazwę lub emotkę, którą wpiszesz w skrypcie
    BtnLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnLabel.BackgroundTransparency = 1
    BtnLabel.Font = Enum.Font.GothamBold
    BtnLabel.TextSize = 24

    local Indicator = Instance.new("Frame",Button)
    Indicator.Name = "Indicator" -- POPRAWKA: Nadanie nazwy dla pętli
    Indicator.Size = UDim2.new(0,3,1,0)
    Indicator.BackgroundColor3 = Theme.Accent
    Indicator.Visible = false

    local Page = Instance.new("ScrollingFrame",self.Container)
    Page.Size = UDim2.new(1,0,1,0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0

    local Layout = Instance.new("UIListLayout",Page)
    Layout.Padding = UDim.new(0,6)

-- Odnajdź tę sekcję w funkcji NK_Library:CreateTab(name)
Button.MouseButton1Click:Connect(function()
    for _, v in pairs(self.Container:GetChildren()) do
        if v:IsA("ScrollingFrame") then
            v.Visible = false
        end
    end

    for _, v in pairs(self.Side:GetChildren()) do
        -- KLUCZOWA POPRAWKA: Sprawdzamy czy to TextButton i czy MA Indicator
        if v:IsA("TextButton") then
            local targetIndicator = v:FindFirstChild("Indicator")
            if targetIndicator then
                targetIndicator.Visible = false
            end
        end
    end

    Page.Visible = true
    -- Upewnij się, że lokalna zmienna Indicator jest dostępna w tym zasięgu
    if Indicator then 
        Indicator.Visible = true 
    end
end)

    ------------------------------------------------
    -- TOGGLE (REAL STUD HUB STYLE)
    ------------------------------------------------

    function Tab:CreateToggle(text,default,callback)
        local state = default or false

        local Card = Instance.new("Frame",Page)
        Card.Size = UDim2.new(1,-6,0,45)
        Card.BackgroundColor3 = Theme.Surface

        Corner(Card,6)
        Stroke(Card)

-- Wewnątrz NK_Library:CreateTab -> Tab:CreateToggle
        local Label = Instance.new("TextLabel", Card)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.Text = text -- TA LINIA JEST KLUCZOWA, musi przypisywać zmienną 'text'
        Label.TextXAlignment = Enum.TextXAlignment.Left -- Opcjonalnie: wyrównanie do lewej
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

            TweenService:Create(Dot,TweenInfo.new(.2),{
                Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
            }):Play()

            TweenService:Create(Toggle,TweenInfo.new(.2),{
                BackgroundColor3 = state and Theme.Accent or Theme.Surface2
            }):Play()

            if callback then
                callback(state)
            end
        end)
    end

    return Tab
end

return NK_Library
