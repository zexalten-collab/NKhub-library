local NK_Library = {}
NK_Library.__index = NK_Library

-- // SERVICES
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- // CONFIG
local ThemeColor = Color3.fromRGB(255,165,0)
local Background = Color3.fromRGB(16,16,16)
local LightBackground = Color3.fromRGB(26,26,26)
local StrokeColor = Color3.fromRGB(60,60,60)

----------------------------------------------------
-- UTILS
----------------------------------------------------

local function CreateCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,radius or 8)
    c.Parent = obj
end

local function CreateStroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or StrokeColor
    s.Thickness = thickness or 1
    s.Parent = obj
end

local function ApplyText(label, size)
    label.Font = Enum.Font.GothamBold
    label.TextSize = size or 14
    label.TextColor3 = Color3.new(1,1,1)
    label.RichText = true
end

----------------------------------------------------
-- DRAG SYSTEM (FIXED)
----------------------------------------------------

local function MakeDraggable(topbar, object)

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart

        object.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    topbar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()

                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end

            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end

    end)

    UserInputService.InputChanged:Connect(function(input)

        if input == dragInput and dragging then
            update(input)
        end

    end)

end

----------------------------------------------------
-- WINDOW
----------------------------------------------------

function NK_Library:CreateWindow(config)

    local self = setmetatable({}, NK_Library)

    config = config or {}

    self.Keybind = config.Keybind or Enum.KeyCode.RightControl
    self.Visible = true
    self.Tabs = {}

    if CoreGui:FindFirstChild("NK_UI") then
        CoreGui.NK_UI:Destroy()
    end

    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "NK_UI"
    self.Gui.Parent = CoreGui
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    ------------------------------------------------
    -- MAIN
    ------------------------------------------------

    self.Main = Instance.new("Frame")
    self.Main.Parent = self.Gui
    self.Main.Size = UDim2.new(0,550,0,360)
    self.Main.Position = UDim2.new(0.5,-275,0.5,-180)
    self.Main.BackgroundColor3 = Background

    CreateCorner(self.Main,10)
    CreateStroke(self.Main)

    ------------------------------------------------
    -- TOPBAR
    ------------------------------------------------

    local Topbar = Instance.new("Frame")
    Topbar.Parent = self.Main
    Topbar.Size = UDim2.new(1,0,0,40)
    Topbar.BackgroundColor3 = LightBackground

    CreateCorner(Topbar,10)
    CreateStroke(Topbar,ThemeColor,1)

    local Title = Instance.new("TextLabel")
    Title.Parent = Topbar
    Title.Size = UDim2.new(1,0,1,0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name or "STUD HUB"

    ApplyText(Title,16)

    MakeDraggable(Topbar,self.Main)

    ------------------------------------------------
    -- SIDEBAR
    ------------------------------------------------

    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Parent = self.Main
    self.Sidebar.Size = UDim2.new(0,140,1,-40)
    self.Sidebar.Position = UDim2.new(0,0,0,40)
    self.Sidebar.BackgroundColor3 = LightBackground

    CreateStroke(self.Sidebar)

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = self.Sidebar
    Layout.Padding = UDim.new(0,5)

    ------------------------------------------------
    -- CONTENT
    ------------------------------------------------

    self.Container = Instance.new("Frame")
    self.Container.Parent = self.Main
    self.Container.Size = UDim2.new(1,-140,1,-40)
    self.Container.Position = UDim2.new(0,140,0,40)
    self.Container.BackgroundTransparency = 1

    ------------------------------------------------
    -- KEYBIND SYSTEM
    ------------------------------------------------

    UserInputService.InputBegan:Connect(function(input,gpe)

        if gpe then return end

        if input.KeyCode == self.Keybind then

            self.Visible = not self.Visible

            self.Main.Visible = self.Visible

        end

    end)

    return self

end

----------------------------------------------------
-- TAB
----------------------------------------------------

function NK_Library:CreateTab(name)

    local Tab = {}

    local Button = Instance.new("TextButton")
    Button.Parent = self.Sidebar
    Button.Size = UDim2.new(1,0,0,40)
    Button.BackgroundColor3 = Background
    Button.Text = name

    ApplyText(Button,14)

    CreateStroke(Button)

    local Page = Instance.new("ScrollingFrame")
    Page.Parent = self.Container
    Page.Size = UDim2.new(1,0,1,0)
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Page
    Layout.Padding = UDim.new(0,6)

    Button.MouseButton1Click:Connect(function()

        for _,v in pairs(self.Container:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end

        Page.Visible = true

    end)

    ------------------------------------------------
    -- TOGGLE
    ------------------------------------------------

    function Tab:CreateToggle(text,default,callback)

        local enabled = default or false

        local Frame = Instance.new("Frame")
        Frame.Parent = Page
        Frame.Size = UDim2.new(1,-10,0,40)
        Frame.BackgroundColor3 = LightBackground

        CreateCorner(Frame,6)

        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.Size = UDim2.new(1,-60,1,0)
        Label.Position = UDim2.new(0,10,0,0)
        Label.BackgroundTransparency = 1
        Label.Text = text

        ApplyText(Label,14)

        local Toggle = Instance.new("Frame")
        Toggle.Parent = Frame
        Toggle.Size = UDim2.new(0,40,0,20)
        Toggle.Position = UDim2.new(1,-50,0.5,-10)
        Toggle.BackgroundColor3 = enabled and ThemeColor or Color3.fromRGB(60,60,60)

        CreateCorner(Toggle,20)

        local Button = Instance.new("TextButton")
        Button.Parent = Frame
        Button.Size = UDim2.new(1,0,1,0)
        Button.BackgroundTransparency = 1
        Button.Text = ""

        Button.MouseButton1Click:Connect(function()

            enabled = not enabled

            TweenService:Create(
                Toggle,
                TweenInfo.new(0.2),
                {BackgroundColor3 = enabled and ThemeColor or Color3.fromRGB(60,60,60)}
            ):Play()

            if callback then
                callback(enabled)
            end

        end)

    end

    ------------------------------------------------
    -- KEYBIND SETTING
    ------------------------------------------------

    function Tab:CreateKeybind(text,default,callback)

        local current = default

        local Frame = Instance.new("Frame")
        Frame.Parent = Page
        Frame.Size = UDim2.new(1,-10,0,40)
        Frame.BackgroundColor3 = LightBackground

        CreateCorner(Frame,6)

        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.Size = UDim2.new(0.6,0,1,0)
        Label.BackgroundTransparency = 1
        Label.Text = text

        ApplyText(Label)

        local Button = Instance.new("TextButton")
        Button.Parent = Frame
        Button.Size = UDim2.new(0.4,-10,0,26)
        Button.Position = UDim2.new(0.6,10,0.5,-13)
        Button.BackgroundColor3 = Background
        Button.Text = current.Name

        ApplyText(Button)

        Button.MouseButton1Click:Connect(function()

            Button.Text = "..."

            local conn
            conn = UserInputService.InputBegan:Connect(function(input)

                if input.KeyCode ~= Enum.KeyCode.Unknown then

                    current = input.KeyCode

                    Button.Text = current.Name

                    if callback then
                        callback(current)
                    end

                    conn:Disconnect()

                end

            end)

        end)

    end

    return Tab

end

----------------------------------------------------
-- NOTIFICATION
----------------------------------------------------

function NK_Library:Notify(title,text,time)

    local Frame = Instance.new("Frame")
    Frame.Parent = self.Gui
    Frame.Size = UDim2.new(0,250,0,80)
    Frame.Position = UDim2.new(1,-260,1,-90)
    Frame.BackgroundColor3 = Background

    CreateCorner(Frame,8)
    CreateStroke(Frame,ThemeColor)

    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.Size = UDim2.new(1,0,0.4,0)
    Title.BackgroundTransparency = 1
    Title.Text = title

    ApplyText(Title,16)

    local Text = Instance.new("TextLabel")
    Text.Parent = Frame
    Text.Size = UDim2.new(1,-10,0.6,0)
    Text.Position = UDim2.new(0,5,0.4,0)
    Text.BackgroundTransparency = 1
    Text.Text = text
    Text.TextWrapped = true

    ApplyText(Text,14)

    task.delay(time or 3,function()
        Frame:Destroy()
    end)

end

return NK_Library
