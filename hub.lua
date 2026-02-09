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
    obj.Font = Enum.Font.Ubuntu -- Wygląda bardziej nowocześnie
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        local stroke = Instance.new("UIStroke", obj)
        stroke.Thickness = 0.5
        stroke.Transparency = 0.6
    end
end

function NK_Hub:CreateWindow(Settings)
    local self = setmetatable({}, NK_Hub)
    self.Gui = Instance.new("ScreenGui", game.CoreGui)
    self.Bind = Enum.KeyCode.K
    self.Toggled = true

    -- GŁÓWNE OKNO (GLASS EFFECT)
    self.Main = Instance.new("Frame", self.Gui)
    self.Main.Size = UDim2.new(0, 600, 0, 400)
    self.Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    self.Main.BackgroundTransparency = 0.1
    
    local Corner = Instance.new("UICorner", self.Main); Corner.CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", self.Main)
    MainStroke.Color = CurrentTheme; MainStroke.Thickness = 1.5; MainStroke.ApplyStrokeMode = "Border"
    table.insert(UIElements.Strokes, MainStroke)

    -- NAGŁÓWEK (BEZ RAMKI, LEKKI)
    local Header = Instance.new("Frame", self.Main)
    Header.Size = UDim2.new(1, 0, 0, 40); Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Text = "<font color='#ffffff'>STUD</font> <font color='#" .. CurrentTheme:ToHex() .. "'>HUB</font>"
    Title.Size = UDim2.new(1, 0, 1, 0); Title.TextSize = 18; Modernise(Title); Title.BackgroundTransparency = 1

    -- SIDEBAR (PŁYWAJĄCY)
    self.Sidebar = Instance.new("Frame", self.Main)
    self.Sidebar.Size = UDim2.new(0, 50, 0, 320); self.Sidebar.Position = UDim2.new(0, 10, 0, 60)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25); self.Sidebar.BackgroundTransparency = 0.3
    Instance.new("UICorner", self.Sidebar).CornerRadius = UDim.new(0, 10)
    
    local SideLayout = Instance.new("UIListLayout", self.Sidebar)
    SideLayout.Padding = UDim.new(0, 15); SideLayout.HorizontalAlignment = "Center"; SideLayout.VerticalAlignment = "Center"

    self.Pages = Instance.new("Frame", self.Main)
    self.Pages.Size = UDim2.new(0, 510, 0, 320); self.Pages.Position = UDim2.new(0, 75, 0, 60); self.Pages.BackgroundTransparency = 1

    -- Płynne otwieranie
    self.Main.CanvasGroup = Instance.new("CanvasGroup", self.Gui) -- Dla lepszych efektów fade
    
    return self
end

function NK_Hub:CreateTab(Name, Icon)
    local Page = Instance.new("ScrollingFrame", self.Pages)
    Page.Name = Name; Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = #self.Pages:GetChildren() == 1
    Page.ScrollBarThickness = 0; Page.AutomaticCanvasSize = "Y"
    local Layout = Instance.new("UIListLayout", Page); Layout.Padding = UDim.new(0, 8)

    -- PRZYCISK Z IKONĄ
    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0, 35, 0, 35); TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBtn.Text = Icon or Name:sub(1,1); TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200); TabBtn.TextSize = 20
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8); Modernise(TabBtn)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages:GetChildren()) do p.Visible = false end
        Page.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme}):Play()
    end)

    local Funcs = {}

    function Funcs:CreateToggle(Text, Desc, Callback)
        local State = false
        local Tile = Instance.new("Frame", Page)
        Tile.Size = UDim2.new(1, -10, 0, 55); Tile.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Tile.BackgroundTransparency = 0.5
        Instance.new("UICorner", Tile)

        local T = Instance.new("TextLabel", Tile); T.Text = Text; T.Size = UDim2.new(0.8,0,0.5,0); T.Position = UDim2.new(0,12,0.15,0)
        T.TextColor3 = Color3.fromRGB(255,255,255); T.BackgroundTransparency = 1; Modernise(T); T.TextXAlignment = "Left"; T.TextSize = 14

        local D = Instance.new("TextLabel", Tile); D.Text = Desc; D.Size = UDim2.new(0.8,0,0.3,0); D.Position = UDim2.new(0,12,0.55,0)
        D.TextColor3 = Color3.fromRGB(150,150,150); D.BackgroundTransparency = 1; Modernise(D); D.TextXAlignment = "Left"; D.TextSize = 11

        local Clicker = Instance.new("TextButton", Tile); Clicker.Size = UDim2.new(1,0,1,0); Clicker.BackgroundTransparency = 1; Clicker.Text = ""
        
        local Switch = Instance.new("Frame", Tile); Switch.Size = UDim2.new(0,34,0,18); Switch.Position = UDim2.new(1,-45,0.5,-9)
        Switch.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)
        local Dot = Instance.new("Frame", Switch); Dot.Size = UDim2.new(0,12,0,12); Dot.Position = UDim2.new(0,3,0.5,-6); Dot.BackgroundColor3 = Color3.fromRGB(200,200,200)
        Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)

        Clicker.MouseButton1Click:Connect(function()
            State = not State
            TweenService:Create(Dot, TweenInfo.new(0.2), {Position = State and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6), BackgroundColor3 = State and CurrentTheme or Color3.fromRGB(200,200,200)}):Play()
            Callback(State)
        end)
    end

    return Funcs
end

return NK_Hub
