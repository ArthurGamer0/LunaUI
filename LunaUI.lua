--[[
    LunaUI - Eine moderne Luau UI Bibliothek
    Alles in einer Datei für einfache Verwendung
    
    Autor: Assistant
    Version: 1.0.0
]]

local LunaUI = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Library Info
LunaUI.Version = "1.0.0"

-- ========================================
-- THEME SYSTEM
-- ========================================

local Theme = {
    Current = "Dark",
    
    Dark = {
        Background = Color3.fromRGB(15, 15, 25),
        BackgroundSecondary = Color3.fromRGB(20, 20, 35),
        BackgroundTertiary = Color3.fromRGB(25, 25, 40),
        Primary = Color3.fromRGB(120, 119, 255),
        Secondary = Color3.fromRGB(255, 119, 120),
        Success = Color3.fromRGB(119, 255, 120),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        TextTertiary = Color3.fromRGB(150, 150, 150),
        Border = Color3.fromRGB(40, 40, 60),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    
    Light = {
        Background = Color3.fromRGB(250, 250, 255),
        BackgroundSecondary = Color3.fromRGB(245, 245, 250),
        BackgroundTertiary = Color3.fromRGB(240, 240, 245),
        Primary = Color3.fromRGB(100, 99, 255),
        Secondary = Color3.fromRGB(255, 99, 100),
        Success = Color3.fromRGB(99, 255, 100),
        Warning = Color3.fromRGB(255, 180, 80),
        Error = Color3.fromRGB(255, 80, 80),
        TextPrimary = Color3.fromRGB(20, 20, 20),
        TextSecondary = Color3.fromRGB(60, 60, 60),
        TextTertiary = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(220, 220, 230),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

function Theme:GetColor(colorName)
    return self[self.Current][colorName] or Color3.fromRGB(255, 0, 255)
end

function Theme:CreateShadow(size, transparency)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = transparency or 0.8
    shadow.BorderSizePixel = 0
    shadow.Size = UDim2.new(1, size * 2, 1, size * 2)
    shadow.Position = UDim2.fromOffset(-size, -size)
    shadow.ZIndex = -1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, size)
    corner.Parent = shadow
    
    return shadow
end

-- ========================================
-- ANIMATOR SYSTEM
-- ========================================

local Animator = {
    ActiveTweens = {}
}

function Animator:Tween(object, tweenInfo, properties, callback)
    if self.ActiveTweens[object] then
        self.ActiveTweens[object]:Cancel()
    end
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    self.ActiveTweens[object] = tween
    
    tween:Play()
    
    if callback then
        tween.Completed:Connect(function()
            callback()
            self.ActiveTweens[object] = nil
        end)
    else
        tween.Completed:Connect(function()
            self.ActiveTweens[object] = nil
        end)
    end
    
    return tween
end

function Animator:FadeIn(object, duration, callback)
    local originalTransparency = object.BackgroundTransparency
    object.BackgroundTransparency = 1
    
    return self:Tween(object, 
        TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = originalTransparency}, 
        callback
    )
end

function Animator:FadeOut(object, duration, callback)
    return self:Tween(object,
        TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1},
        callback
    )
end

function Animator:SlideIn(object, direction, duration, callback)
    local startPosition = object.Position
    local offsetPosition
    
    if direction == "Left" then
        offsetPosition = UDim2.new(startPosition.X.Scale - 1, startPosition.X.Offset, startPosition.Y.Scale, startPosition.Y.Offset)
    elseif direction == "Right" then
        offsetPosition = UDim2.new(startPosition.X.Scale + 1, startPosition.X.Offset, startPosition.Y.Scale, startPosition.Y.Offset)
    elseif direction == "Top" then
        offsetPosition = UDim2.new(startPosition.X.Scale, startPosition.X.Offset, startPosition.Y.Scale - 1, startPosition.Y.Offset)
    else
        offsetPosition = UDim2.new(startPosition.X.Scale, startPosition.X.Offset, startPosition.Y.Scale + 1, startPosition.Y.Offset)
    end
    
    object.Position = offsetPosition
    
    return self:Tween(object,
        TweenInfo.new(duration or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = startPosition},
        callback
    )
end

function Animator:Scale(object, targetSize, duration, callback)
    return self:Tween(object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
        {Size = targetSize},
        callback
    )
end

function Animator:Bounce(object, intensity, duration, callback)
    local originalSize = object.Size
    local bounceSize = UDim2.new(
        originalSize.X.Scale * (1 + (intensity or 0.1)),
        originalSize.X.Offset,
        originalSize.Y.Scale * (1 + (intensity or 0.1)),
        originalSize.Y.Offset
    )
    
    return self:Tween(object,
        TweenInfo.new(duration or 0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
        {Size = bounceSize},
        function()
            self:Tween(object, TweenInfo.new(0.3), {Size = originalSize}, callback)
        end
    )
end

-- ========================================
-- BUTTON COMPONENT
-- ========================================

local Button = {}
Button.__index = Button

function Button.new(config)
    local self = setmetatable({}, Button)
    
    self.Text = config.Text or "Button"
    self.Size = config.Size or UDim2.fromOffset(120, 35)
    self.Position = config.Position or UDim2.fromOffset(0, 0)
    self.Style = config.Style or "Primary"
    self.Callback = config.Callback or function() end
    self.Parent = config.Parent
    
    self:CreateButton()
    return self
end

function Button:CreateButton()
    self.Frame = Instance.new("TextButton")
    self.Frame.Name = "LunaButton"
    self.Frame.Size = self.Size
    self.Frame.Position = self.Position
    self.Frame.BackgroundColor3 = Theme:GetColor(self.Style)
    self.Frame.BorderSizePixel = 0
    self.Frame.Text = self.Text
    self.Frame.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.Frame.TextSize = 14
    self.Frame.Font = Enum.Font.GothamSemibold
    self.Frame.AutoButtonColor = false
    
    if self.Parent then
        self.Frame.Parent = self.Parent
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.Frame
    
    local shadow = Theme:CreateShadow(8, 0.6)
    shadow.Parent = self.Frame
    
    self:SetupInteractions()
end

function Button:SetupInteractions()
    self.Frame.MouseEnter:Connect(function()
        Animator:Scale(self.Frame, UDim2.new(
            self.Size.X.Scale,
            self.Size.X.Offset + 4,
            self.Size.Y.Scale,
            self.Size.Y.Offset + 2
        ), 0.1)
        
        Animator:Tween(self.Frame, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.new(
                Theme:GetColor(self.Style).R * 1.1,
                Theme:GetColor(self.Style).G * 1.1,
                Theme:GetColor(self.Style).B * 1.1
            )
        })
    end)
    
    self.Frame.MouseLeave:Connect(function()
        Animator:Scale(self.Frame, self.Size, 0.1)
        Animator:Tween(self.Frame, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme:GetColor(self.Style)
        })
    end)
    
    self.Frame.MouseButton1Down:Connect(function()
        Animator:Scale(self.Frame, UDim2.new(
            self.Size.X.Scale,
            self.Size.X.Offset - 2,
            self.Size.Y.Scale,
            self.Size.Y.Offset - 1
        ), 0.05)
    end)
    
    self.Frame.MouseButton1Up:Connect(function()
        Animator:Scale(self.Frame, self.Size, 0.1)
        Animator:Bounce(self.Frame, 0.05, 0.3)
    end)
    
    self.Frame.MouseButton1Click:Connect(function()
        self.Callback()
    end)
end

-- ========================================
-- SLIDER COMPONENT
-- ========================================

local Slider = {}
Slider.__index = Slider

function Slider.new(config)
    local self = setmetatable({}, Slider)
    
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Value = config.Value or 50
    self.Size = config.Size or UDim2.fromOffset(200, 35)
    self.Position = config.Position or UDim2.fromOffset(0, 0)
    self.Callback = config.Callback or function() end
    self.Parent = config.Parent
    self.IsDragging = false
    
    self:CreateSlider()
    return self
end

function Slider:CreateSlider()
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "LunaSlider"
    self.Frame.Size = self.Size
    self.Frame.Position = self.Position
    self.Frame.BackgroundTransparency = 1
    
    if self.Parent then
        self.Frame.Parent = self.Parent
    end
    
    -- Track
    self.Track = Instance.new("Frame")
    self.Track.Size = UDim2.new(1, -20, 0, 4)
    self.Track.Position = UDim2.new(0, 10, 0.5, -2)
    self.Track.BackgroundColor3 = Theme:GetColor("BackgroundTertiary")
    self.Track.BorderSizePixel = 0
    self.Track.Parent = self.Frame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = self.Track
    
    -- Fill
    self.Fill = Instance.new("Frame")
    self.Fill.Size = UDim2.fromScale(self:GetPercentage(), 1)
    self.Fill.BackgroundColor3 = Theme:GetColor("Primary")
    self.Fill.BorderSizePixel = 0
    self.Fill.Parent = self.Track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = self.Fill
    
    -- Handle
    self.Handle = Instance.new("Frame")
    self.Handle.Size = UDim2.fromOffset(18, 18)
    self.Handle.Position = UDim2.new(self:GetPercentage(), -9, 0.5, -9)
    self.Handle.BackgroundColor3 = Theme:GetColor("Primary")
    self.Handle.BorderSizePixel = 0
    self.Handle.Parent = self.Frame
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 9)
    handleCorner.Parent = self.Handle
    
    -- Value Label
    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Size = UDim2.fromOffset(50, 20)
    self.ValueLabel.Position = UDim2.new(1, -55, 0, 0)
    self.ValueLabel.BackgroundColor3 = Theme:GetColor("BackgroundSecondary")
    self.ValueLabel.BackgroundTransparency = 0.2
    self.ValueLabel.BorderSizePixel = 0
    self.ValueLabel.Text = tostring(self.Value)
    self.ValueLabel.TextColor3 = Theme:GetColor("TextPrimary")
    self.ValueLabel.TextSize = 12
    self.ValueLabel.Font = Enum.Font.Gotham
    self.ValueLabel.Parent = self.Frame
    
    local labelCorner = Instance.new("UICorner")
    labelCorner.CornerRadius = UDim.new(0, 4)
    labelCorner.Parent = self.ValueLabel
    
    self:SetupInteractions()
end

function Slider:GetPercentage()
    return (self.Value - self.Min) / (self.Max - self.Min)
end

function Slider:SetupInteractions()
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - self.Track.AbsolutePosition.X) / self.Track.AbsoluteSize.X, 0, 1)
        self.Value = math.floor(self.Min + (self.Max - self.Min) * relativeX)
        
        local percentage = self:GetPercentage()
        
        Animator:Tween(self.Fill, TweenInfo.new(0.1), {Size = UDim2.fromScale(percentage, 1)})
        Animator:Tween(self.Handle, TweenInfo.new(0.1), {Position = UDim2.new(percentage, -9, 0.5, -9)})
        
        self.ValueLabel.Text = tostring(self.Value)
        self.Callback(self.Value)
    end
    
    self.Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            Animator:Scale(self.Handle, UDim2.fromOffset(22, 22), 0.1)
        end
    end)
    
    self.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            self.IsDragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.IsDragging then
            self.IsDragging = false
            Animator:Scale(self.Handle, UDim2.fromOffset(18, 18), 0.1)
        end
    end)
end

-- ========================================
-- TEXTBOX COMPONENT
-- ========================================

local TextBox = {}
TextBox.__index = TextBox

function TextBox.new(config)
    local self = setmetatable({}, TextBox)
    
    self.PlaceholderText = config.PlaceholderText or "Enter text..."
    self.Text = config.Text or ""
    self.Size = config.Size or UDim2.fromOffset(200, 35)
    self.Position = config.Position or UDim2.fromOffset(0, 0)
    self.Callback = config.Callback or function() end
    self.Parent = config.Parent
    self.IsFocused = false
    
    self:CreateTextBox()
    return self
end

function TextBox:CreateTextBox()
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "LunaTextBox"
    self.Frame.Size = self.Size
    self.Frame.Position = self.Position
    self.Frame.BackgroundColor3 = Theme:GetColor("BackgroundTertiary")
    self.Frame.BackgroundTransparency = 0.3
    self.Frame.BorderSizePixel = 0
    
    if self.Parent then
        self.Frame.Parent = self.Parent
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.Frame
    
    self.Stroke = Instance.new("UIStroke")
    self.Stroke.Color = Theme:GetColor("Border")
    self.Stroke.Thickness = 1
    self.Stroke.Parent = self.Frame
    
    self.TextInput = Instance.new("TextBox")
    self.TextInput.Size = UDim2.new(1, -20, 1, 0)
    self.TextInput.Position = UDim2.fromOffset(10, 0)
    self.TextInput.BackgroundTransparency = 1
    self.TextInput.Text = self.Text
    self.TextInput.PlaceholderText = self.PlaceholderText
    self.TextInput.TextColor3 = Theme:GetColor("TextPrimary")
    self.TextInput.PlaceholderColor3 = Theme:GetColor("TextTertiary")
    self.TextInput.TextSize = 14
    self.TextInput.Font = Enum.Font.Gotham
    self.TextInput.TextXAlignment = Enum.TextXAlignment.Left
    self.TextInput.TextYAlignment = Enum.TextYAlignment.Center
    self.TextInput.ClearTextOnFocus = false
    self.TextInput.Parent = self.Frame
    
    self:SetupInteractions()
end

function TextBox:SetupInteractions()
    self.TextInput.Focused:Connect(function()
        self.IsFocused = true
        
        Animator:Tween(self.Stroke, TweenInfo.new(0.2), {
            Color = Theme:GetColor("Primary"),
            Thickness = 2
        })
        
        Animator:Tween(self.Frame, TweenInfo.new(0.2), {BackgroundTransparency = 0.1})
        Animator:Scale(self.Frame, UDim2.new(
            self.Size.X.Scale,
            self.Size.X.Offset + 4,
            self.Size.Y.Scale,
            self.Size.Y.Offset + 2
        ), 0.1)
    end)
    
    self.TextInput.FocusLost:Connect(function()
        self.IsFocused = false
        
        Animator:Tween(self.Stroke, TweenInfo.new(0.2), {
            Color = Theme:GetColor("Border"),
            Thickness = 1
        })
        
        Animator:Tween(self.Frame, TweenInfo.new(0.2), {BackgroundTransparency = 0.3})
        Animator:Scale(self.Frame, self.Size, 0.1)
        
        self.Callback(self.TextInput.Text)
    end)
end

-- ========================================
-- TOGGLE COMPONENT
-- ========================================

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(config)
    local self = setmetatable({}, Toggle)
    
    self.Enabled = config.Enabled or false
    self.Size = config.Size or UDim2.fromOffset(50, 25)
    self.Position = config.Position or UDim2.fromOffset(0, 0)
    self.Callback = config.Callback or function() end
    self.Parent = config.Parent
    
    self:CreateToggle()
    return self
end

function Toggle:CreateToggle()
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "LunaToggle"
    self.Frame.Size = self.Size
    self.Frame.Position = self.Position
    self.Frame.BackgroundColor3 = self.Enabled and Theme:GetColor("Primary") or Theme:GetColor("BackgroundTertiary")
    self.Frame.BorderSizePixel = 0
    
    if self.Parent then
        self.Frame.Parent = self.Parent
    end
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0.5, 0)
    trackCorner.Parent = self.Frame
    
    local thumbSize = self.Size.Y.Offset - 4
    self.Thumb = Instance.new("Frame")
    self.Thumb.Size = UDim2.fromOffset(thumbSize, thumbSize)
    self.Thumb.Position = self.Enabled and 
        UDim2.new(1, -thumbSize - 2, 0.5, -thumbSize/2) or 
        UDim2.fromOffset(2, 2)
    self.Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.Thumb.BorderSizePixel = 0
    self.Thumb.Parent = self.Frame
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0.5, 0)
    thumbCorner.Parent = self.Thumb
    
    self.ClickDetector = Instance.new("TextButton")
    self.ClickDetector.Size = UDim2.fromScale(1, 1)
    self.ClickDetector.BackgroundTransparency = 1
    self.ClickDetector.Text = ""
    self.ClickDetector.Parent = self.Frame
    
    self:SetupInteractions()
end

function Toggle:SetupInteractions()
    self.ClickDetector.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    self.ClickDetector.MouseEnter:Connect(function()
        local hoverScale = self.Size.Y.Offset + 2
        Animator:Scale(self.Thumb, UDim2.fromOffset(hoverScale, hoverScale), 0.1)
    end)
    
    self.ClickDetector.MouseLeave:Connect(function()
        local normalScale = self.Size.Y.Offset - 4
        Animator:Scale(self.Thumb, UDim2.fromOffset(normalScale, normalScale), 0.1)
    end)
end

function Toggle:Toggle()
    self.Enabled = not self.Enabled
    
    local thumbSize = self.Size.Y.Offset - 4
    local targetPosition = self.Enabled and 
        UDim2.new(1, -thumbSize - 2, 0.5, -thumbSize/2) or 
        UDim2.fromOffset(2, 2)
    
    local targetColor = self.Enabled and Theme:GetColor("Primary") or Theme:GetColor("BackgroundTertiary")
    
    Animator:Tween(self.Thumb, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = targetPosition
    })
    
    Animator:Tween(self.Frame, TweenInfo.new(0.2), {BackgroundColor3 = targetColor})
    Animator:Bounce(self.Thumb, 0.1, 0.4)
    
    self.Callback(self.Enabled)
end

-- ========================================
-- NOTIFICATION SYSTEM
-- ========================================

local Notification = {}
Notification.__index = Notification
Notification.ActiveNotifications = {}
Notification.Container = nil

function Notification.new(config)
    local self = setmetatable({}, Notification)
    
    self.Title = config.Title or "Notification"
    self.Description = config.Description or ""
    self.Duration = config.Duration or 3
    self.Type = config.Type or "Info"
    
    if not Notification.Container then
        Notification:CreateContainer()
    end
    
    self:CreateNotification()
    return self
end

function Notification:CreateContainer()
    Notification.Container = Instance.new("Frame")
    Notification.Container.Name = "NotificationContainer"
    Notification.Container.Size = UDim2.fromOffset(350, 0)
    Notification.Container.Position = UDim2.new(1, -360, 0, 10)
    Notification.Container.BackgroundTransparency = 1
    Notification.Container.Parent = game.Players.LocalPlayer.PlayerGui
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = Notification.Container
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Notification.Container.Size = UDim2.fromOffset(350, layout.AbsoluteContentSize.Y)
    end)
end

function Notification:CreateNotification()
    self.Frame = Instance.new("Frame")
    self.Frame.Size = UDim2.fromOffset(340, 80)
    self.Frame.BackgroundColor3 = Theme:GetColor("BackgroundSecondary")
    self.Frame.BackgroundTransparency = 0.1
    self.Frame.BorderSizePixel = 0
    self.Frame.LayoutOrder = #Notification.ActiveNotifications + 1
    self.Frame.Parent = Notification.Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.Frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self:GetTypeColor()
    stroke.Thickness = 2
    stroke.Parent = self.Frame
    
    -- Icon
    self.Icon = Instance.new("TextLabel")
    self.Icon.Size = UDim2.fromOffset(24, 24)
    self.Icon.Position = UDim2.fromOffset(20, 12)
    self.Icon.BackgroundTransparency = 1
    self.Icon.Text = self:GetTypeIcon()
    self.Icon.TextColor3 = self:GetTypeColor()
    self.Icon.TextSize = 18
    self.Icon.Font = Enum.Font.GothamBold
    self.Icon.Parent = self.Frame
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -80, 0, 20)
    self.TitleLabel.Position = UDim2.fromOffset(55, 12)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Theme:GetColor("TextPrimary")
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Font = Enum.Font.GothamSemibold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.Frame
    
    -- Description
    if self.Description ~= "" then
        self.DescriptionLabel = Instance.new("TextLabel")
        self.DescriptionLabel.Size = UDim2.new(1, -80, 0, 40)
        self.DescriptionLabel.Position = UDim2.fromOffset(55, 32)
        self.DescriptionLabel.BackgroundTransparency = 1
        self.DescriptionLabel.Text = self.Description
        self.DescriptionLabel.TextColor3 = Theme:GetColor("TextSecondary")
        self.DescriptionLabel.TextSize = 12
        self.DescriptionLabel.Font = Enum.Font.Gotham
        self.DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
        self.DescriptionLabel.TextWrapped = true
        self.DescriptionLabel.Parent = self.Frame
    end
    
    -- Close button
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Size = UDim2.fromOffset(20, 20)
    self.CloseButton.Position = UDim2.new(1, -30, 0, 10)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseButton.BackgroundTransparency = 0.9
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Theme:GetColor("TextSecondary")
    self.CloseButton.TextSize = 14
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.Frame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = self.CloseButton
    
    table.insert(Notification.ActiveNotifications, self)
    
    self:SetupInteractions()
    self:AnimateIn()
    
    if self.Duration > 0 then
        spawn(function()
            wait(self.Duration)
            self:Dismiss()
        end)
    end
end

function Notification:GetTypeColor()
    local colors = {
        Info = Theme:GetColor("Primary"),
        Success = Theme:GetColor("Success"),
        Warning = Theme:GetColor("Warning"),
        Error = Theme:GetColor("Error")
    }
    return colors[self.Type] or colors.Info
end

function Notification:GetTypeIcon()
    local icons = {
        Info = "ⓘ",
        Success = "✓",
        Warning = "!",
        Error = "✕"
    }
    return icons[self.Type] or icons.Info
end

function Notification:SetupInteractions()
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Dismiss()
    end)
end

function Notification:AnimateIn()
    self.Frame.Position = UDim2.fromOffset(350, 0)
    self.Frame.BackgroundTransparency = 1
    
    Animator:SlideIn(self.Frame, "Right", 0.4)
    Animator:FadeIn(self.Frame, 0.3)
end

function Notification:Dismiss()
    Animator:SlideOut(self.Frame, "Right", 0.3, function()
        for i, notification in ipairs(Notification.ActiveNotifications) do
            if notification == self then
                table.remove(Notification.ActiveNotifications, i)
                break
            end
        end
        self.Frame:Destroy()
    end)
end

-- ========================================
-- WINDOW COMPONENT
-- ========================================

local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    
    self.Title = config.Title or "LunaUI Window"
    self.Size = config.Size or UDim2.fromOffset(500, 400)
    self.Position = config.Position or UDim2.fromScale(0.5, 0.5)
    self.Parent = config.Parent or game.Players.LocalPlayer.PlayerGui
    self.Tabs = {}
    self.ActiveTab = nil
    
    self:CreateWindow()
    return self
end

function Window:CreateWindow()
    self.Frame = Instance.new("Frame")
    self.Frame.Name = "LunaWindow"
    self.Frame.Size = self.Size
    self.Frame.Position = self.Position
    self.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Frame.BackgroundColor3 = Theme:GetColor("Background")
    self.Frame.BackgroundTransparency = 0.1
    self.Frame.BorderSizePixel = 0
    self.Frame.Parent = self.Parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.Frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme:GetColor("Border")
    stroke.Thickness = 1
    stroke.Parent = self.Frame
    
    local shadow = Theme:CreateShadow(15, 0.7)
    shadow.Parent = self.Frame
    
    self:CreateTitleBar()
    self:CreateContentArea()
    self:SetupDragging()
    
    Animator:SlideIn(self.Frame, "Top", 0.5)
    Animator:FadeIn(self.Frame, 0.3)
end

function Window:CreateTitleBar()
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = Theme:GetColor("BackgroundSecondary")
    self.TitleBar.BackgroundTransparency = 0.3
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = self.TitleBar
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.fromOffset(15, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Theme:GetColor("TextPrimary")
    self.TitleLabel.TextSize = 16
    self.TitleLabel.Font = Enum.Font.GothamSemibold
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar
    
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Size = UDim2.fromOffset(30, 30)
    self.CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
    self.CloseButton.BackgroundColor3 = Theme:GetColor("Error")
    self.CloseButton.BackgroundTransparency = 0.8
    self.CloseButton.BorderSizePixel = 0
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.CloseButton.TextSize = 18
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.Parent = self.TitleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = self.CloseButton
    
    self.CloseButton.MouseEnter:Connect(function()
        Animator:Tween(self.CloseButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.2})
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        Animator:Tween(self.CloseButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.8})
    end)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
end

function Window:CreateContentArea()
    self.ContentArea = Instance.new("ScrollingFrame")
    self.ContentArea.Size = UDim2.new(1, -20, 1, -60)
    self.ContentArea.Position = UDim2.fromOffset(10, 50)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.BorderSizePixel = 0
    self.ContentArea.ScrollBarThickness = 4
    self.ContentArea.ScrollBarImageColor3 = Theme:GetColor("Primary")
    self.ContentArea.Parent = self.Frame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = self.ContentArea
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentArea.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
    end)
end

function Window:SetupDragging()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Window:AddElement(element)
    if element.Frame then
        element.Frame.Parent = self.ContentArea
    else
        element.Parent = self.ContentArea
    end
end

function Window:Close()
    Animator:SlideOut(self.Frame, "Top", 0.3, function()
        self.Frame:Destroy()
    end)
    Animator:FadeOut(self.Frame, 0.3)
end

-- ========================================
-- MAIN LUNAUI FUNCTIONS
-- ========================================

function LunaUI:Init(parent)
    parent = parent or game.Players.LocalPlayer.PlayerGui
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LunaUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = parent
    
    return screenGui
end

function LunaUI:CreateWindow(config)
    return Window.new(config)
end

function LunaUI:CreateButton(config)
    return Button.new(config)
end

function LunaUI:CreateSlider(config)
    return Slider.new(config)
end

function LunaUI:CreateTextBox(config)
    return TextBox.new(config)
end

function LunaUI:CreateToggle(config)
    return Toggle.new(config)
end

function LunaUI:CreateNotification(config)
    return Notification.new(config)
end

function LunaUI:SetTheme(themeName)
    if Theme[themeName] then
        Theme.Current = themeName
    end
end

function LunaUI:GetTheme()
    return Theme.Current
end

-- Components für direkten Zugriff
LunaUI.Button = Button
LunaUI.Slider = Slider
LunaUI.TextBox = TextBox
LunaUI.Toggle = Toggle
LunaUI.Window = Window
LunaUI.Notification = Notification

return LunaUI
