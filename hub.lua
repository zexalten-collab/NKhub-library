local NK_Hub = {}
NK_Hub.__index = NK_Hub

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local CurrentTheme = Color3.fromRGB(255, 165, 0)
local UIElements = {Strokes = {}}

-- // FUNKCJA DLA ULTRA-WYRAŹNEGO TEKSTU I EFEKTÓW
local function Modernise(obj)
    obj.RichText = true
    obj.Font = Enum.Font.GothamMedium
    local s = Instance.new("UIStroke", obj)
    s.Thickness = 0.5
    s.Transparency = 0.5
end

function NK_Hub:CreateWindow(Settings)
    local self = setmetatable({}, NK_Hub)
    self.Gui = Instance.new("ScreenGui", game.CoreGui)
    self.Gui.Name = "NK_HUB_MODERN"
    self.Bind = Enum.KeyCode.K
    self.Toggled = true

    -- GŁÓWNE OKNO (GLASS EFFECT)
    self.Main = Instance.new("Frame", self.Gui)
    self.Main.Size = UDim2.new(0, 550, 0, 380)
    self.Main.Position = UDim2.new(0.5, -275, 0.5, -190)
    self.Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.Main.BackgroundTransparency = 0.05
    Instance.new("UICorner", self.Main).CornerRadius = UDim.new(0, 10)
    
    local MainStroke = Instance.new("UIStroke", self.Main)
    MainStroke.Color = Color3.fromRGB(40, 40, 40); MainStroke.Thickness = 1.2
    
    -- NAGŁÓWEK (W STYLU STUD HUB)
    local HeaderCard = Instance.new("Frame", self.Main)
    HeaderCard.Size = UDim2.new(0, 200, 0, 45)
    HeaderCard.Position = UDim2.new(0.5, -100, 0, -22)
    HeaderCard.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", HeaderCard)
    local HStroke = Instance.new("UIStroke", HeaderCard)
    HStroke.Color = CurrentTheme; table.insert(UIElements.Strokes, HStroke)
    
    local Title = Instance.new("TextLabel", HeaderCard)
    Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1
    Title.Text = "<b>NK</b> <font color='#" .. CurrentTheme:ToHex() .. "'>HUB</font>"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.TextSize = 18; Modernise(Title)

    -- SIDEBAR (LEWITUJĄCY)
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 55, 0, 280)
    self.Sidebar.Position = UDim2.new(0, 15, 0.5, -140)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.Sidebar.BackgroundTransparency = 0.2
    Instance.new("UICorner", self.Sidebar).CornerRadius = UDim.new(0, 10)
    
    local SideLayout = Instance.new("UIListLayout", self.Sidebar)
    SideLayout.Padding = UDim.new(0, 15); SideLayout.HorizontalAlignment = "Center"; SideLayout.VerticalAlignment = "Center"

    self.Pages = Instance.new("Frame", self.Main)
    self.Pages.Size = UDim2.new(0, 450, 0, 300); self.Pages.Position = UDim2.new(0, 85, 0, 50); self.Pages.BackgroundTransparency = 1

    -- ZĘBATKA (W ROGU)
    local SettingsBtn = Instance.new("ImageButton", self.Main)
    SettingsBtn.Size = UDim2.new(0, 22, 0, 22); SettingsBtn.Position = UDim2.new(1, -35, 0, 15)
    SettingsBtn.Image = "rbxassetid://6031280245"; SettingsBtn.BackgroundTransparency = 1; SettingsBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)

    return self
end

function NK_Hub:CreateTab(Name, IconID)
    local Page = Instance.new("ScrollingFrame", self.Pages)
    Page.Name = Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = #self.Pages:GetChildren() == 1
    Page.ScrollBarThickness = 0; Page.AutomaticCanvasSize = "Y"
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

    -- IKONA ZAMIAST LITERY
    local TabBtn = Instance.new("ImageButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0, 32, 0, 32); TabBtn.BackgroundTransparency = 1
    TabBtn.Image = IconID or "rbxassetid://6023426915" -- Domyślna ikona domu
    TabBtn.ImageColor3 = Page.Visible and CurrentTheme or Color3.fromRGB(150, 150, 150)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages:GetChildren()) do p.Visible = false end
        for _, b in pairs(self.Sidebar:GetChildren()) do if b:IsA("ImageButton") then b.ImageColor3 = Color3.fromRGB(150, 150, 150) end end
        Page.Visible = true; TabBtn.ImageColor3 = CurrentTheme
    end)

    local Funcs = {}
    function Funcs:CreateToggle(Text, Desc, Callback)
        local State = false
        local Tile = Instance.new("Frame", Page)
        Tile.Size = UDim2.new(1, -10, 0, 50); Tile.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Tile.BackgroundTransparency = 0.4
        Instance.new("UICorner", Tile)

        local T = Instance.new("TextLabel", Tile); T.Text = Text; T.Size = UDim2.new(1, -60, 1, 0); T.Position = UDim2.new(0, 15, 0, 0)
        T.TextColor3 = Color3.fromRGB(230, 230, 230); T.BackgroundTransparency = 1; Modernise(T); T.TextXAlignment = "Left"; T.TextSize = 14

        local Switch = Instance.new("TextButton", Tile); Switch.Size = UDim2.new(0, 36, 0, 18); Switch.Position = UDim2.new(1, -50, 0.5, -9)
        Switch.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Switch.Text = ""; Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
        local Dot = Instance.new("Frame", Switch); Dot.Size = UDim2.new(0, 12, 0, 12); Dot.Position = UDim2.new(0, 3, 0.5, -6); Dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

        Switch.MouseButton1Click:Connect(function()
            State = not State
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = State and CurrentTheme or Color3.fromRGB(200, 200, 200)}):Play()
            Callback(State)
        end)
    end
    return Funcs
end

return NK_Hub
