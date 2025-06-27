--[[
    Lumina Library
    A modern UI library for Roblox with enhanced animations and sleek design
    Created by T3 Chat, 2025
]]

local Lumina = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Configuration
Lumina.Config = {
    WindowPadding = Vector2.new(15, 15),
    WindowCornerRadius = UDim.new(0, 6),
    WindowBlur = true,
    PrimaryColor = Color3.fromRGB(60, 120, 255),
    SecondaryColor = Color3.fromRGB(32, 32, 38),
    BackgroundColor = Color3.fromRGB(22, 22, 26),
    TextColor = Color3.fromRGB(240, 240, 240),
    Font = Enum.Font.GothamMedium,
    SaveConfig = true,
    ConfigFolder = "LuminaConfig",
    AnimationDuration = 0.3,
    AnimationEasingStyle = Enum.EasingStyle.Quint,
    NotificationPosition = UDim2.new(1, -25, 1, -25),
    NotificationAnchor = Vector2.new(1, 1)
}

-- Create UI Container
function Lumina:Init()
    if self.Initialized then return end
    
    -- Create main UI container
    local LuminaUI = Instance.new("ScreenGui")
    LuminaUI.Name = "LuminaUI"
    LuminaUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LuminaUI.ResetOnSpawn = false
    
    -- Handle parent based on environment
    if RunService:IsStudio() then
        LuminaUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        pcall(function()
            LuminaUI.Parent = CoreGui
        end)
        
        if not LuminaUI.Parent then
            LuminaUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    
    -- Create notification container
    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "NotificationContainer"
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
    NotificationContainer.Position = UDim2.new(1, -310, 0, 0)
    NotificationContainer.AnchorPoint = Vector2.new(0, 0)
    NotificationContainer.Parent = LuminaUI
    
    -- Create notification layout
    local NotificationLayout = Instance.new("UIListLayout")
    NotificationLayout.Name = "NotificationLayout"
    NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    NotificationLayout.Padding = UDim.new(0, 10)
    NotificationLayout.Parent = NotificationContainer
    
    -- Create windows container
    local WindowsContainer = Instance.new("Frame")
    WindowsContainer.Name = "WindowsContainer"
    WindowsContainer.BackgroundTransparency = 1
    WindowsContainer.Size = UDim2.new(1, 0, 1, 0)
    WindowsContainer.Parent = LuminaUI
    
    -- Store references
    self.GUI = LuminaUI
    self.NotificationContainer = NotificationContainer
    self.WindowsContainer = WindowsContainer
    self.Windows = {}
    self.Flags = {}
    self.ActiveNotifications = {}
    self.Initialized = true
    
    return self
end

-- Create a notification
function Lumina:Notify(options)
    if not self.Initialized then
        self:Init()
    end
    
    -- Default options
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or "This is a notification"
    local icon = options.Icon or "rbxassetid://10723424505" -- Default info icon
    local duration = options.Duration or 5
    local theme = options.Theme or "Default" -- Default, Success, Warning, Error
    local callback = options.Callback
    
    -- Set theme colors
    local themeColors = {
        Default = Color3.fromRGB(60, 120, 255),
        Success = Color3.fromRGB(72, 220, 105),
        Warning = Color3.fromRGB(255, 178, 62),
        Error = Color3.fromRGB(255, 75, 75)
    }
    
    local themeColor = themeColors[theme] or themeColors.Default
    
    -- Create notification frame
    local notification = Instance.new("Frame")
    notification.Name = "Notification_" .. tostring(#self.ActiveNotifications + 1)
    notification.Size = UDim2.new(0, 300, 0, 0) -- Start with 0 height, will animate
    notification.BackgroundColor3 = self.Config.BackgroundColor
    notification.BorderSizePixel = 0
    notification.AnchorPoint = Vector2.new(0.5, 1)
    notification.Position = UDim2.new(0.5, 0, 1, 0)
    notification.ClipsDescendants = true
    notification.BackgroundTransparency = 0.1
    notification.Parent = self.NotificationContainer
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Config.WindowCornerRadius
    corner.Parent = notification
    
    -- Create shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014237321"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.ZIndex = -1
    shadow.Parent = notification
    
    -- Create accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 5, 1, 0)
    accentBar.BackgroundColor3 = themeColor
    accentBar.BorderSizePixel = 0
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.Parent = notification
    
    -- Create icon
    local iconFrame = Instance.new("ImageLabel")
    iconFrame.Name = "Icon"
    iconFrame.Size = UDim2.new(0, 30, 0, 30)
    iconFrame.BackgroundTransparency = 1
    iconFrame.Position = UDim2.new(0, 15, 0, 15)
    iconFrame.Image = icon
    iconFrame.Parent = notification
    
    -- Create title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -60, 0, 20)
    titleLabel.Position = UDim2.new(0, 55, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = self.Config.Font
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = self.Config.TextColor
    titleLabel.Text = title
    titleLabel.Parent = notification
    
    -- Create content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, -70, 0, 0) -- Will be resized based on text
    contentLabel.Position = UDim2.new(0, 55, 0, 35)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 14
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.TextWrapped = true
    contentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    contentLabel.Text = content
    contentLabel.Parent = notification
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    closeButton.Parent = notification
    
    -- Calculate content height based on text
    local textSize = TextService:GetTextSize(
        content,
        14,
        Enum.Font.Gotham,
        Vector2.new(230, 1000)
    )
    
    local notificationHeight = math.max(60, textSize.Y + 50) -- Minimum 60px height
    contentLabel.Size = UDim2.new(1, -70, 0, textSize.Y)
    
    -- Set notification height
    notification.Size = UDim2.new(0, 300, 0, notificationHeight)
    
    -- Add to active notifications
    table.insert(self.ActiveNotifications, notification)
    
    -- Animate in
    notification.BackgroundTransparency = 1
    accentBar.BackgroundTransparency = 1
    iconFrame.ImageTransparency = 1
    titleLabel.TextTransparency = 1
    contentLabel.TextTransparency = 1
    closeButton.TextTransparency = 1
    shadow.ImageTransparency = 1
    
    -- Create tween
    local tweenInfo = TweenInfo.new(
        self.Config.AnimationDuration,
        self.Config.AnimationEasingStyle,
        Enum.EasingDirection.Out
    )
    
    local fadeInProperties = {
        BackgroundTransparency = 0.1,
    }
    
    local fadeInPropertiesAccent = {
        BackgroundTransparency = 0,
    }
    
    local fadeInPropertiesImage = {
        ImageTransparency = 0,
    }
    
    local fadeInPropertiesShadow = {
        ImageTransparency = 0.5,
    }
    
    local fadeInPropertiesText = {
        TextTransparency = 0,
    }
    
    -- Play tweens
    TweenService:Create(notification, tweenInfo, fadeInProperties):Play()
    TweenService:Create(accentBar, tweenInfo, fadeInPropertiesAccent):Play()
    TweenService:Create(iconFrame, tweenInfo, fadeInPropertiesImage):Play()
    TweenService:Create(shadow, tweenInfo, fadeInPropertiesShadow):Play()
    TweenService:Create(titleLabel, tweenInfo, fadeInPropertiesText):Play()
    TweenService:Create(contentLabel, tweenInfo, fadeInPropertiesText):Play()
    TweenService:Create(closeButton, tweenInfo, fadeInPropertiesText):Play()
    
    -- Close button click
    closeButton.MouseButton1Click:Connect(function()
        self:CloseNotification(notification)
        if callback then
            callback()
        end
    end)
    
    -- Auto close after duration
    if duration and duration > 0 then
        task.delay(duration, function()
            if notification and notification.Parent then
                self:CloseNotification(notification)
            end
        end)
    end
    
    -- Progress bar for duration
    if duration and duration > 0 then
        local progressBar = Instance.new("Frame")
        progressBar.Name = "ProgressBar"
        progressBar.Size = UDim2.new(1, 0, 0, 3)
        progressBar.Position = UDim2.new(0, 0, 1, -3)
        progressBar.BackgroundColor3 = themeColor
        progressBar.BorderSizePixel = 0
        progressBar.Parent = notification
        
        -- Animate progress bar
        local progressTween = TweenService:Create(
            progressBar,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0, 0, 0, 3)}
        )
        progressTween:Play()
    end
    
    -- Hover effects
    notification.MouseEnter:Connect(function()
        TweenService:Create(
            notification,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundTransparency = 0}
        ):Play()
    end)
    
    notification.MouseLeave:Connect(function()
        TweenService:Create(
            notification,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundTransparency = 0.1}
        ):Play()
    end)
    
    return notification
end

-- Close notification
function Lumina:CloseNotification(notification)
    -- Create tween
    local tweenInfo = TweenInfo.new(
        self.Config.AnimationDuration,
        self.Config.AnimationEasingStyle,
        Enum.EasingDirection.Out
    )
    
    local fadeOutProperties = {
        BackgroundTransparency = 1,
        Position = UDim2.new(1.5, 0, 1, 0)
    }
    
    -- Play tween
    local tween = TweenService:Create(notification, tweenInfo, fadeOutProperties)
    tween:Play()
    
    -- Fade out all children
    for _, child in pairs(notification:GetChildren()) do
        if child:IsA("Frame") then
            TweenService:Create(child, tweenInfo, {BackgroundTransparency = 1}):Play()
        elseif child:IsA("TextLabel") or child:IsA("TextButton") then
            TweenService:Create(child, tweenInfo, {TextTransparency = 1}):Play()
        elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
            TweenService:Create(child, tweenInfo, {ImageTransparency = 1}):Play()
        end
    end
    
    -- Remove notification after tween
    tween.Completed:Connect(function()
        notification:Destroy()
        
        -- Remove from active notifications
        for i, v in pairs(self.ActiveNotifications) do
            if v == notification then
                table.remove(self.ActiveNotifications, i)
                break
            end
        end
    end)
end

-- Create a window
function Lumina:MakeWindow(options)
    if not self.Initialized then
        self:Init()
    end
    
    -- Default options
    options = options or {}
    local name = options.Name or "Lumina Window"
    local hidePremium = options.HidePremium or false
    local saveConfig = options.SaveConfig or self.Config.SaveConfig
    local configFolder = options.ConfigFolder or self.Config.ConfigFolder
    local introEnabled = options.IntroEnabled or true
    local introText = options.IntroText or name
    local introIcon = options.IntroIcon or "rbxassetid://10723424505"
    local icon = options.Icon or "rbxassetid://10723424505"
    local closeCallback = options.CloseCallback
    
    -- Create window object
    local window = {}
    window.Tabs = {}
    window.Name = name
    window.SaveConfig = saveConfig
    window.ConfigFolder = configFolder
    
    -- Create window frame
    local windowFrame = Instance.new("Frame")
    windowFrame.Name = "WindowFrame"
    windowFrame.Size = UDim2.new(0, 600, 0, 400)
    windowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    windowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    windowFrame.BackgroundColor3 = self.Config.BackgroundColor
    windowFrame.BorderSizePixel = 0
    windowFrame.Parent = self.WindowsContainer
    windowFrame.Visible = false
    
    -- Create window corner radius
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = self.Config.WindowCornerRadius
    windowCorner.Parent = windowFrame
    
    -- Create window shadow
    local windowShadow = Instance.new("ImageLabel")
    windowShadow.Name = "Shadow"
    windowShadow.BackgroundTransparency = 1
    windowShadow.Image = "rbxassetid://6014237321"
    windowShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    windowShadow.ImageTransparency = 0.5
    windowShadow.Size = UDim2.new(1, 30, 1, 30)
    windowShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    windowShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    windowShadow.ZIndex = -1
    windowShadow.Parent = windowFrame
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = self.Config.SecondaryColor
    titleBar.BorderSizePixel = 0
    titleBar.Parent = windowFrame
    
    -- Create title bar corner radius
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = self.Config.WindowCornerRadius
    titleBarCorner.Parent = titleBar
    
    -- Create title bar fixer (to prevent corner radius on bottom)
    local titleBarFixer = Instance.new("Frame")
    titleBarFixer.Name = "TitleBarFixer"
    titleBarFixer.Size = UDim2.new(1, 0, 0, 10)
    titleBarFixer.Position = UDim2.new(0, 0, 1, -10)
    titleBarFixer.BackgroundColor3 = self.Config.SecondaryColor
    titleBarFixer.BorderSizePixel = 0
    titleBarFixer.ZIndex = 0
    titleBarFixer.Parent = titleBar
    
    -- Create title icon
    local titleIcon = Instance.new("ImageLabel")
    titleIcon.Name = "TitleIcon"
    titleIcon.Size = UDim2.new(0, 20, 0, 20)
    titleIcon.Position = UDim2.new(0, 10, 0, 10)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Image = icon
    titleIcon.Parent = titleBar
    
    -- Create title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 40, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = self.Config.Font
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.TextColor3 = self.Config.TextColor
    titleText.Text = name
    titleText.Parent = titleBar
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -40, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.Parent = titleBar
    
    -- Create tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 150, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = self.Config.SecondaryColor
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = windowFrame
    
    -- Create tab container corner radius
    local tabContainerCorner = Instance.new("UICorner")
    tabContainerCorner.CornerRadius = self.Config.WindowCornerRadius
    tabContainerCorner.Parent = tabContainer
    
    -- Create tab container fixer (to prevent corner radius on right)
    local tabContainerFixer = Instance.new("Frame")
    tabContainerFixer.Name = "TabContainerFixer"
    tabContainerFixer.Size = UDim2.new(0, 10, 1, 0)
    tabContainerFixer.Position = UDim2.new(1, -10, 0, 0)
    tabContainerFixer.BackgroundColor3 = self.Config.SecondaryColor
    tabContainerFixer.BorderSizePixel = 0
    tabContainerFixer.ZIndex = 0
    tabContainerFixer.Parent = tabContainer
    
    -- Create tab list
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.Size = UDim2.new(1, -10, 1, -10)
    tabList.Position = UDim2.new(0, 5, 0, 5)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.ScrollingDirection = Enum.ScrollingDirection.Y
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabList.Parent = tabContainer
    
    -- Create tab list layout
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.Name = "TabListLayout"
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 5)
    tabListLayout.Parent = tabList
    
    -- Create tab content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -150, 1, -40)
    contentContainer.Position = UDim2.new(0, 150, 0, 40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = windowFrame
    
    -- Make window draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = windowFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            windowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Close button click
    closeButton.MouseButton1Click:Connect(function()
        windowFrame.Visible = false
        if closeCallback then
            closeCallback()
        end
    end)
    
    -- Store references
    window.Frame = windowFrame
    window.TabList = tabList
    window.ContentContainer = contentContainer
    
    -- Add to windows
    table.insert(self.Windows, window)
    
    -- Show intro
    if introEnabled then
        windowFrame.Visible = false
        self:Notify({
            Title = "Welcome",
            Content = introText,
            Icon = introIcon,
            Duration = 3,
            Theme = "Default",
            Callback = function()
                windowFrame.Visible = true
            end
        })
    else
        windowFrame.Visible = true
    end
    
    -- Window methods
    function window:MakeTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabIcon = options.Icon or "rbxassetid://10734983707"
        local premiumOnly = options.PremiumOnly or false
        
        -- Create tab object
        local tab = {}
        tab.Name = tabName
        tab.Items = {}
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Button"
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.BackgroundColor3 = Lumina.Config.SecondaryColor
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabList
        
        -- Create tab button corner radius
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 4)
        tabButtonCorner.Parent = tabButton
        
        -- Create tab icon
        local tabIconLabel = Instance.new("ImageLabel")
        tabIconLabel.Name = "Icon"
        tabIconLabel.Size = UDim2.new(0, 20, 0, 20)
        tabIconLabel.Position = UDim2.new(0, 10, 0.5, -10)
        tabIconLabel.BackgroundTransparency = 1
        tabIconLabel.Image = tabIcon
        tabIconLabel.Parent = tabButton
        
        -- Create tab text
        local tabTextLabel = Instance.new("TextLabel")
        tabTextLabel.Name = "Text"
        tabTextLabel.Size = UDim2.new(1, -40, 1, 0)
        tabTextLabel.Position = UDim2.new(0, 40, 0, 0)
        tabTextLabel.BackgroundTransparency = 1
        tabTextLabel.Font = Lumina.Config.Font
        tabTextLabel.TextSize = 16
        tabTextLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabTextLabel.TextColor3 = Lumina.Config.TextColor
        tabTextLabel.Text = tabName
        tabTextLabel.Parent = tabButton
        
        -- Create selection indicator
        local selectionIndicator = Instance.new("Frame")
        selectionIndicator.Name = "SelectionIndicator"
        selectionIndicator.Size = UDim2.new(0, 4, 0, 24)
        selectionIndicator.Position = UDim2.new(0, 0, 0.5, -12)
        selectionIndicator.BackgroundColor3 = Lumina.Config.PrimaryColor
        selectionIndicator.BorderSizePixel = 0
        selectionIndicator.Visible = false
        selectionIndicator.Parent = tabButton
        
        -- Create tab content frame
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollingDirection = Enum.ScrollingDirection.Y
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        -- Create content layout
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Name = "ContentLayout"
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        -- Create content padding
        local contentPadding = Instance.new("UIPadding")
        contentPadding.Name = "ContentPadding"
        contentPadding.PaddingTop = UDim.new(0, 5)
        contentPadding.PaddingBottom = UDim.new(0, 5)
        contentPadding.PaddingLeft = UDim.new(0, 5)
        contentPadding.PaddingRight = UDim.new(0, 5)
        contentPadding.Parent = tabContent
        
        -- Update canvas size when items are added
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab button click
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, otherTab in pairs(window.Tabs) do
                if otherTab.Content then
                    otherTab.Content.Visible = false
                end
                if otherTab.Button and otherTab.Button:FindFirstChild("SelectionIndicator") then
                    otherTab.Button.SelectionIndicator.Visible = false
                    
                    -- Reset unselected tab button appearance
                    TweenService:Create(
                        otherTab.Button,
                        TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                        {BackgroundColor3 = Lumina.Config.SecondaryColor}
                    ):Play()
                end
            end
            
            -- Show this tab
            tabContent.Visible = true
            selectionIndicator.Visible = true
            
            -- Animate selection
            TweenService:Create(
                tabButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                {BackgroundColor3 = Lumina.Config.PrimaryColor:Lerp(Lumina.Config.SecondaryColor, 0.8)}
            ):Play()
        end)
        
        -- Hover effects
        tabButton.MouseEnter:Connect(function()
            if not selectionIndicator.Visible then
                TweenService:Create(
                    tabButton,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = Lumina.Config.SecondaryColor:Lerp(Lumina.Config.PrimaryColor, 0.2)}
                ):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not selectionIndicator.Visible then
                TweenService:Create(
                    tabButton,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = Lumina.Config.SecondaryColor}
                ):Play()
            end
        end)
        
        -- Store references
        tab.Button = tabButton
        tab.Content = tabContent
        
        -- Add to tabs
        table.insert(window.Tabs, tab)
        
        -- If this is the first tab, select it
        if #window.Tabs == 1 then
            tabButton.MouseButton1Click:Fire()
        end
        
        -- Tab methods
        function tab:AddSection(options)
            options = options or {}
            local sectionName = options.Name or "Section"
            
            -- Create section object
            local section = {}
            
            -- Create section frame
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = sectionName .. "Section"
            sectionFrame.Size = UDim2.new(1, 0, 0, 36) -- Initial height, will be resized
            sectionFrame.BackgroundColor3 = Lumina.Config.SecondaryColor
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tabContent
            
            -- Create section corner radius
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 4)
            sectionCorner.Parent = sectionFrame
            
            -- Create section title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Size = UDim2.new(1, -20, 0, 26)
            sectionTitle.Position = UDim2.new(0, 10, 0, 5)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Font = Lumina.Config.Font
            sectionTitle.TextSize = 15
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.TextColor3 = Lumina.Config.TextColor
            sectionTitle.Text = sectionName
            sectionTitle.Parent = sectionFrame
            
            -- Create content container
            local sectionContent = Instance.new("Frame")
            sectionContent.Name = "Content"
            sectionContent.Size = UDim2.new(1, -20, 0, 0) -- Will be resized
            sectionContent.Position = UDim2.new(0, 10, 0, 36)
            sectionContent.BackgroundTransparency = 1
            sectionContent.BorderSizePixel = 0
            sectionContent.Parent = sectionFrame
            
            -- Create content layout
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.Name = "SectionLayout"
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 8)
            sectionLayout.Parent = sectionContent
            
            -- Update section size when content is added
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionContent.Size = UDim2.new(1, -20, 0, sectionLayout.AbsoluteContentSize.Y)
                sectionFrame.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 46)
            end)
            
            -- Store references
            section.Frame = sectionFrame
            section.Content = sectionContent
            
            -- Return the section with element adding methods
            return section
        end
        
        -- Element creation methods
        function tab:AddButton(options)
            options = options or {}
            local buttonName = options.Name or "Button"
            local callback = options.Callback or function() end
            
            -- Create button frame
            local buttonFrame = Instance.new("Frame")
            buttonFrame.Name = buttonName .. "ButtonFrame"
            buttonFrame.Size = UDim2.new(1, 0, 0, 36)
            buttonFrame.BackgroundTransparency = 1
            buttonFrame.Parent = tabContent
            
            -- Create button
            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.Size = UDim2.new(1, 0, 1, 0)
            button.BackgroundColor3 = Lumina.Config.SecondaryColor
            button.BorderSizePixel = 0
            button.Text = ""
            button.AutoButtonColor = false
            button.Parent = buttonFrame
            
            -- Create button corner radius
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = button
            
            -- Create button text
            local buttonText = Instance.new("TextLabel")
            buttonText.Name = "Text"
            buttonText.Size = UDim2.new(1, -20, 1, 0)
            buttonText.Position = UDim2.new(0, 10, 0, 0)
            buttonText.BackgroundTransparency = 1
            buttonText.Font = Lumina.Config.Font
            buttonText.TextSize = 15
            buttonText.TextXAlignment = Enum.TextXAlignment.Left
            buttonText.TextColor3 = Lumina.Config.TextColor
            buttonText.Text = buttonName
            buttonText.Parent = button
            
            -- Create button icon
            local buttonIcon = Instance.new("ImageLabel")
            buttonIcon.Name = "Icon"
            buttonIcon.Size = UDim2.new(0, 20, 0, 20)
            buttonIcon.Position = UDim2.new(1, -30, 0.5, -10)
            buttonIcon.BackgroundTransparency = 1
            buttonIcon.Image = "rbxassetid://10734898835" -- Arrow icon
            buttonIcon.Parent = button
            
            -- Button click
            button.MouseButton1Click:Connect(function()
                -- Animation
                TweenService:Create(
                    button,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = Lumina.Config.PrimaryColor}
                ):Play()
                
                TweenService:Create(
                    buttonIcon,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                    {Position = UDim2.new(1, -25, 0.5, -10)}
                ):Play()
                
                task.delay(0.1, function()
                    TweenService:Create(
                        button,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                        {BackgroundColor3 = Lumina.Config.SecondaryColor}
                    ):Play()
                    
                    TweenService:Create(
                        buttonIcon,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                        {Position = UDim2.new(1, -30, 0.5, -10)}
                    ):Play()
                end)
                
                -- Callback
                callback()
            end)
            
            -- Hover effects
            button.MouseEnter:Connect(function()
                TweenService:Create(
                    button,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = Lumina.Config.SecondaryColor:Lerp(Lumina.Config.PrimaryColor, 0.2)}
                ):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(
                    button,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = Lumina.Config.SecondaryColor}
                ):Play()
            end)
            
            return buttonFrame
        end
        
        function tab:AddToggle(options)
            options = options or {}
            local toggleName = options.Name or "Toggle"
            local defaultValue = options.Default or false
            local callback = options.Callback or function() end
            local flag = options.Flag
            local save = options.Save or false
            
            -- Create toggle object
            local toggle = {}
            toggle.Value = defaultValue
            
            -- Create toggle frame
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = toggleName .. "ToggleFrame"
            toggleFrame.Size = UDim2.new(1, 0, 0, 36)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = tabContent
            
            -- Create toggle background
            local toggleBackground = Instance.new("TextButton")
            toggleBackground.Name = "Background"
            toggleBackground.Size = UDim2.new(1, 0, 1, 0)
            toggleBackground.BackgroundColor3 = Lumina.Config.SecondaryColor
            toggleBackground.BorderSizePixel = 0
            toggleBackground.Text = ""
            toggleBackground.AutoButtonColor = false
            toggleBackground.Parent = toggleFrame
            
            -- Create toggle corner radius
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 4)
            toggleCorner.Parent = toggleBackground
            
            -- Create toggle text
            local toggleText = Instance.new("TextLabel")
            toggleText.Name = "Text"
            toggleText.Size = UDim2.new(1, -60, 1, 0)
            toggleText.Position = UDim2.new(0, 10, 0, 0)
            toggleText.BackgroundTransparency = 1
            toggleText.Font = Lumina.Config.Font
            toggleText.TextSize = 15
            toggleText.TextXAlignment = Enum.TextXAlignment.Left
            toggleText.TextColor3 = Lumina.Config.TextColor
            toggleText.Text = toggleName
            toggleText.Parent = toggleBackground
            
            -- Create toggle indicator
            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Name = "Indicator"
            toggleIndicator.Size = UDim2.new(0, 40, 0, 22)
            toggleIndicator.Position = UDim2.new(1, -50, 0.5, -11)
            toggleIndicator.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            toggleIndicator.BorderSizePixel = 0
            toggleIndicator.Parent = toggleBackground
            
            -- Create indicator corner radius
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(1, 0)
            indicatorCorner.Parent = toggleIndicator
            
            -- Create toggle knob
            local toggleKnob = Instance.new("Frame")
            toggleKnob.Name = "Knob"
            toggleKnob.Size = UDim2.new(0, 18, 0, 18)
            toggleKnob.Position = UDim2.new(0, 2, 0.5, -9)
            toggleKnob.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            toggleKnob.BorderSizePixel = 0
            toggleKnob.Parent = toggleIndicator
            
            -- Create knob corner radius
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = toggleKnob
            
            -- Function to update toggle state
            local function updateToggle()
                local toggleTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
                
                if toggle.Value then
                    -- Enabled state
                    TweenService:Create(
                        toggleIndicator,
                        toggleTweenInfo,
                        {BackgroundColor3 = Lumina.Config.PrimaryColor}
                    ):Play()
                    
                    TweenService:Create(
                        toggleKnob,
                        toggleTweenInfo,
                        {Position = UDim2.new(0, 20, 0.5, -9)}
                    ):Play()
                else
                    -- Disabled state
                    TweenService:Create(
                        toggleIndicator,
                        toggleTweenInfo,
                        {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}
                    ):Play()
                    
                    TweenService:Create(
                        toggleKnob,
                        toggleTweenInfo,
                        {Position = UDim2.new(0, 2, 0.5, -9)}
                    ):Play()
                end
                
                -- Update flag
                if flag then
                    Lumina.Flags[flag] = toggle.Value
                end
                
                -- Call callback
                callback(toggle.Value)
            end
            
            -- Set initial state
            toggle.Value = defaultValue
            updateToggle()
            
            -- Toggle click
            toggleBackground.MouseButton1Click:Connect(function()
                toggle.Value = not toggle.Value
                updateToggle()
            end)
            
            -- Hover effects
            toggleBackground.MouseEnter:Connect(function()
                TweenService:Create(
                    toggleBackground,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = Lumina.Config.SecondaryColor:Lerp(Lumina.Config.PrimaryColor, 0.2)}
                ):Play()
            end)
            
            toggleBackground.MouseLeave:Connect(function()
                TweenService:Create(
                    toggleBackground,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = Lumina.Config.SecondaryColor}
                ):Play()
            end)
            
            -- Set method
            function toggle:Set(value)
                toggle.Value = value
                updateToggle()
            end
            
            -- Add to flags if needed
            if flag then
                Lumina.Flags[flag] = toggle.Value
            end
            
            return toggle
        end
        
        function tab:AddSlider(options)
            options = options or {}
            local sliderName = options.Name or "Slider"
            local minValue = options.Min or 0
            local maxValue = options.Max or 100
            local defaultValue = options.Default or minValue
            local increment = options.Increment or 1
            local valueName = options.ValueName or ""
            local callback = options.Callback or function() end
            local flag = options.Flag
            local save = options.Save or false
            
            -- Ensure default is within range
            defaultValue = math.clamp(defaultValue, minValue, maxValue)
            
            -- Create slider object
            local slider = {}
            slider.Value = defaultValue
            
            -- Create slider frame
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = sliderName .. "SliderFrame"
            sliderFrame.Size = UDim2.new(1, 0, 0, 56)
            sliderFrame.BackgroundTransparency = 1
            sliderFrame.Parent = tabContent
            
            -- Create slider background
            local sliderBackground = Instance.new("Frame")
            sliderBackground.Name = "Background"
            sliderBackground.Size = UDim2.new(1, 0, 1, 0)
            sliderBackground.BackgroundColor3 = Lumina.Config.SecondaryColor
            sliderBackground.BorderSizePixel = 0
            sliderBackground.Parent = sliderFrame
            
            -- Create slider corner radius
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 4)
            sliderCorner.Parent = sliderBackground
            
            -- Create slider text
            local sliderText = Instance.new("TextLabel")
            sliderText.Name = "Text"
            sliderText.Size = UDim2.new(1, -20, 0, 24)
            sliderText.Position = UDim2.new(0, 10, 0, 6)
            sliderText.BackgroundTransparency = 1
            sliderText.Font = Lumina.Config.Font
            sliderText.TextSize = 15
            sliderText.TextXAlignment = Enum.TextXAlignment.Left
            sliderText.TextColor3 = Lumina.Config.TextColor
            sliderText.Text = sliderName
            sliderText.Parent = sliderBackground
            
            -- Create value text
            local valueText = Instance.new("TextLabel")
            valueText.Name = "ValueText"
            valueText.Size = UDim2.new(0, 70, 0, 24)
            valueText.Position = UDim2.new(1, -80, 0, 6)
            valueText.BackgroundTransparency = 1
            valueText.Font = Lumina.Config.Font
            valueText.TextSize = 15
            valueText.TextXAlignment = Enum.TextXAlignment.Right
            valueText.TextColor3 = Lumina.Config.PrimaryColor
            valueText.Text = tostring(defaultValue) .. " " .. valueName
            valueText.Parent = sliderBackground
            
            -- Create slider bar background
            local sliderBarBackground = Instance.new("Frame")
            sliderBarBackground.Name = "SliderBarBackground"
            sliderBarBackground.Size = UDim2.new(1, -20, 0, 6)
            sliderBarBackground.Position = UDim2.new(0, 10, 0, 36)
            sliderBarBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            sliderBarBackground.BorderSizePixel = 0
            sliderBarBackground.Parent = sliderBackground
            
            -- Create slider bar background corner radius
            local sliderBarBackgroundCorner = Instance.new("UICorner")
            sliderBarBackgroundCorner.CornerRadius = UDim.new(1, 0)
            sliderBarBackgroundCorner.Parent = sliderBarBackground
            
            -- Create slider bar
            local sliderBar = Instance.new("Frame")
            sliderBar.Name = "SliderBar"
            sliderBar.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
            sliderBar.BackgroundColor3 = Lumina.Config.PrimaryColor
            sliderBar.BorderSizePixel = 0
            sliderBar.Parent = sliderBarBackground
            
            -- Create slider bar corner radius
            local sliderBarCorner = Instance.new("UICorner")
            sliderBarCorner.CornerRadius = UDim.new(1, 0)
            sliderBarCorner.Parent = sliderBar
            
            -- Create slider knob
            local sliderKnob = Instance.new("Frame")
            sliderKnob.Name = "SliderKnob"
            sliderKnob.Size = UDim2.new(0, 12, 0, 12)
            sliderKnob.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 0.5, -6)
            sliderKnob.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
            sliderKnob.BorderSizePixel = 0
            sliderKnob.Parent = sliderBarBackground
            
            -- Create slider knob corner radius
            local sliderKnobCorner = Instance.new("UICorner")
            sliderKnobCorner.CornerRadius = UDim.new(1, 0)
            sliderKnobCorner.Parent = sliderKnob
            
            -- Function to update slider
            local function updateSlider(value)
                -- Round to increment
                value = math.floor((value - minValue) / increment + 0.5) * increment + minValue
                
                -- Clamp value
                value = math.clamp(value, minValue, maxValue)
                
                -- Update value
                slider.Value = value
                
                -- Update UI
                local percent = (value - minValue) / (maxValue - minValue)
                
                TweenService:Create(
                    sliderBar,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                    {Size = UDim2.new(percent, 0, 1, 0)}
                ):Play()
                
                TweenService:Create(
                    sliderKnob,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                    {Position = UDim2.new(percent, 0, 0.5, -6)}
                ):Play()
                
                valueText.Text = tostring(value) .. " " .. valueName
                
                -- Update flag
                if flag then
                    Lumina.Flags[flag] = value
                end
                
                -- Call callback
                callback(value)
            end
            
            -- Set initial value
            updateSlider(defaultValue)
            
            -- Slider functionality
            local dragging = false
            
            sliderBarBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    
                    -- Calculate value based on mouse position
                    local offsetX = math.clamp(input.Position.X - sliderBarBackground.AbsolutePosition.X, 0, sliderBarBackground.AbsoluteSize.X)
                    local percent = offsetX / sliderBarBackground.AbsoluteSize.X
                    local value = minValue + (maxValue - minValue) * percent
                    
                    updateSlider(value)
                end
            end)
            
            sliderKnob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    -- Calculate value based on mouse position
                    local offsetX = math.clamp(input.Position.X - sliderBarBackground.AbsolutePosition.X, 0, sliderBarBackground.AbsoluteSize.X)
                    local percent = offsetX / sliderBarBackground.AbsoluteSize.X
                    local value = minValue + (maxValue - minValue) * percent
                    
                    updateSlider(value)
                end
            end)
            
            -- Hover effects
            sliderBackground.MouseEnter:Connect(function()
                TweenService:Create(
                    sliderBackground,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = Lumina.Config.SecondaryColor:Lerp(Lumina.Config.PrimaryColor, 0.1)}
                ):Play()
            end)
            
            sliderBackground.MouseLeave:Connect(function()
                TweenService:Create(
                    sliderBackground,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = Lumina.Config.SecondaryColor}
                ):Play()
            end)
            
            -- Set method
            function slider:Set(value)
                updateSlider(value)
            end
            
            -- Add to flags if needed
            if flag then
                Lumina.Flags[flag] = slider.Value
            end
            
            return slider
        end
        
        -- Add more element methods as needed
        
        return tab
    end
    
    return window
end

-- Destroy the library
function Lumina:Destroy()
    if self.GUI then
        self.GUI:Destroy()
        self.Initialized = false
    end
end

return Lumina
