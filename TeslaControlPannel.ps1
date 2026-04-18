Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ============================================================
# TeslaProControlCenter
# Premium Launcher UI
# ============================================================

$AppTitle = 'TeslaProControlCenter'
$AppVersion = 'Version 6.0'

# ------------------------------------------------------------
# Tool definitions
# ------------------------------------------------------------
$Tools = @(
    @{ Name = 'TeslaPro Macro Finder'; Icon = [char]0xE721; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/TeslaProMacroFinder/main/TeslaProMacroFinder_V3.ps1'')"'; Desc = 'Scan the system for macro-related traces and suspicious activity.'; Accent = '#32C8FF' },
    @{ Name = 'Doomsday Detector';     Icon = [char]0xE7BA; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/DoomsdayDetector/main/DoomsdayClientDetectorV3.ps1'')"'; Desc = 'Launch the Doomsday client detection workflow.'; Accent = '#54C7FF' },
    @{ Name = 'Habibi Mod Analyzer';   Icon = [char]0xE943; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'; Desc = 'Analyze Minecraft mods using metadata, hashes, and indicators.'; Accent = '#66D9FF' },
    @{ Name = 'VPN Finder';            Icon = [char]0xE836; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/VPNChecker/main/VPNFinder.ps1'')"'; Desc = 'Search for active VPN connections and related traces.'; Accent = '#68D2FF' },
    @{ Name = 'Security Manager';      Icon = [char]0xE756; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/ChxAuDpF)'; Desc = 'Prepare and launch additional security-oriented tooling.'; Accent = '#77D7FF' },
    @{ Name = 'QuickCheck Scanner';    Icon = [char]0xEC92; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/HGLwy7XA)'; Desc = 'Fast first-pass scan for registry activity and logs.'; Accent = '#43D8FF' },
    @{ Name = 'Red Lotus BAM';         Icon = [char]0xECA5; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1)'; Desc = 'Inspect Windows execution history using BAM data.'; Accent = '#5EDBFF' },
    @{ Name = 'Open AppData';          Icon = [char]0xED25; Kind = 'Folder';  Admin = $false; Path = $env:APPDATA; Desc = 'Open the local AppData directory.'; Accent = '#7FE1FF' },
    @{ Name = 'Open Prefetch';         Icon = [char]0xE8B7; Kind = 'Folder';  Admin = $false; Path = 'C:\Windows\Prefetch'; Desc = 'Open the Windows Prefetch directory.'; Accent = '#95E8FF' }
)

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------
function New-Brush {
    param([string]$Color)
    return ([System.Windows.Media.BrushConverter]::new()).ConvertFromString($Color)
}

function Set-Text {
    param($Control, [string]$Value)
    if ($Control) { $Control.Text = $Value }
}

function Write-Log {
    param([string]$Message)

    if ($script:LogBox) {
        $timestamp = (Get-Date).ToString('HH:mm:ss')
        $script:LogBox.AppendText("[$timestamp]  $Message" + [Environment]::NewLine)
        $script:LogBox.ScrollToEnd()
    }
}

function Set-Status {
    param(
        [string]$State,
        [string]$Details,
        [string]$Color = '#67E8F9'
    )

    if ($script:HeroState) {
        $script:HeroState.Text = $State
        $script:HeroState.Foreground = New-Brush $Color
    }

    if ($script:HeroText) {
        $script:HeroText.Text = $Details
    }

    if ($script:MiniStatusValue) {
        $script:MiniStatusValue.Text = $State.ToUpper()
        $script:MiniStatusValue.Foreground = New-Brush $Color
    }

    if ($script:MiniStatusSub) {
        $script:MiniStatusSub.Text = $Details
    }
}

function Invoke-ToolAction {
    param($Tool)

    if ($Tool.Kind -eq 'Folder') {
        try {
            Start-Process 'explorer.exe' $Tool.Path
            Write-Log "Opened folder: $($Tool.Path)"
            Set-Status -State 'Ready' -Details "Opened $($Tool.Name)." -Color '#67E8F9'
        }
        catch {
            Write-Log "Failed to open folder: $($_.Exception.Message)"
            Set-Status -State 'Error' -Details 'Folder action failed.' -Color '#FF6B7A'
        }
        return
    }

    try {
        Write-Log "Launching $($Tool.Name)..."
        Set-Status -State 'Running' -Details "Starting $($Tool.Name)..." -Color '#FBBF24'
        if ($script:StepValue) { $script:StepValue.Text = $Tool.Name }
        if ($script:ProgressValue) { $script:ProgressValue.Text = 'Working' }

        $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $StartInfo.FileName = 'cmd.exe'
        $StartInfo.Arguments = "/k $($Tool.Cmd)"
        $StartInfo.UseShellExecute = $true

        if ($Tool.Admin) {
            $StartInfo.Verb = 'runas'
        }

        [System.Diagnostics.Process]::Start($StartInfo) | Out-Null

        Write-Log "Started: $($Tool.Name)"
        Set-Status -State 'Ready' -Details "$($Tool.Name) launched successfully." -Color '#67E8F9'
        if ($script:StepValue) { $script:StepValue.Text = 'Completed' }
        if ($script:ProgressValue) { $script:ProgressValue.Text = '100%' }
    }
    catch {
        Write-Log "Launch failed or cancelled: $($_.Exception.Message)"
        Set-Status -State 'Error' -Details 'Action was cancelled or failed.' -Color '#FF6B7A'
        if ($script:StepValue) { $script:StepValue.Text = 'Failed' }
        if ($script:ProgressValue) { $script:ProgressValue.Text = '0%' }
    }
}

function New-NavButtonStyle {
    $style = New-Object System.Windows.Style([System.Windows.Controls.Button])

    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::BackgroundProperty, (New-Brush '#182334'))))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::ForegroundProperty, (New-Brush '#F3F4F6'))))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::BorderBrushProperty, (New-Brush '#24364C'))))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::BorderThicknessProperty, (New-Object System.Windows.Thickness(1)))))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.FrameworkElement]::HeightProperty, 68.0)))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.FrameworkElement]::MarginProperty, (New-Object System.Windows.Thickness(0,0,0,14)))))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::FontSizeProperty, 14.0)))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::FontWeightProperty, [System.Windows.FontWeights]::SemiBold)))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::PaddingProperty, (New-Object System.Windows.Thickness(0)))))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::HorizontalContentAlignmentProperty, [System.Windows.HorizontalAlignment]::Stretch)))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::VerticalContentAlignmentProperty, [System.Windows.VerticalAlignment]::Stretch)))
    [void]$style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Input.Mouse]::CursorProperty, [System.Windows.Input.Cursors]::Hand)))

    $template = New-Object System.Windows.Controls.ControlTemplate([System.Windows.Controls.Button])

    $borderFactory = New-Object System.Windows.FrameworkElementFactory([System.Windows.Controls.Border])
    $borderFactory.SetValue([System.Windows.Controls.Border]::CornerRadiusProperty, (New-Object System.Windows.CornerRadius(18)))
    $borderFactory.SetBinding([System.Windows.Controls.Border]::BackgroundProperty, (New-Object System.Windows.Data.Binding('Background')))
    $borderFactory.SetBinding([System.Windows.Controls.Border]::BorderBrushProperty, (New-Object System.Windows.Data.Binding('BorderBrush')))
    $borderFactory.SetBinding([System.Windows.Controls.Border]::BorderThicknessProperty, (New-Object System.Windows.Data.Binding('BorderThickness')))

    $presenterFactory = New-Object System.Windows.FrameworkElementFactory([System.Windows.Controls.ContentPresenter])
    $presenterFactory.SetValue([System.Windows.Controls.ContentPresenter]::HorizontalAlignmentProperty, [System.Windows.HorizontalAlignment]::Stretch)
    $presenterFactory.SetValue([System.Windows.Controls.ContentPresenter]::VerticalAlignmentProperty, [System.Windows.VerticalAlignment]::Stretch)
    $borderFactory.AppendChild($presenterFactory)
    $template.VisualTree = $borderFactory

    $hoverTrigger = New-Object System.Windows.Trigger
    $hoverTrigger.Property = [System.Windows.UIElement]::IsMouseOverProperty
    $hoverTrigger.Value = $true
    [void]$hoverTrigger.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::BackgroundProperty, (New-Brush '#1E2E46'))))
    [void]$hoverTrigger.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::BorderBrushProperty, (New-Brush '#355172'))))
    $template.Triggers.Add($hoverTrigger)

    $pressedTrigger = New-Object System.Windows.Trigger
    $pressedTrigger.Property = [System.Windows.Controls.Primitives.ButtonBase]::IsPressedProperty
    $pressedTrigger.Value = $true
    [void]$pressedTrigger.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::BackgroundProperty, (New-Brush '#21354F'))))
    $template.Triggers.Add($pressedTrigger)

    $style.Setters.Add((New-Object System.Windows.Setter([System.Windows.Controls.Control]::TemplateProperty, $template)))

    return $style
}

function Add-ToolButton {
    param(
        [Parameter(Mandatory)]$Tool,
        [Parameter(Mandatory)]$ParentPanel
    )

    $button = New-Object System.Windows.Controls.Button
    $button.Style = $script:NavButtonStyle
    $button.ToolTip = $Tool.Desc

    if ($Tool.Name -eq 'TeslaPro Macro Finder') {
        $button.Background = New-Brush '#22BDE8'
        $button.BorderBrush = New-Brush '#4DD7F4'
        $button.Foreground = New-Brush '#FFFFFF'
    }
    elseif ($Tool.Name -eq 'Open AppData' -or $Tool.Name -eq 'Open Prefetch') {
        $button.Background = New-Brush '#18263A'
    }
    elseif ($Tool.Name -like '*Exit*') {
        $button.Background = New-Brush '#3B1F29'
    }

    $grid = New-Object System.Windows.Controls.Grid
    $grid.Margin = New-Object System.Windows.Thickness(14,0,14,0)

    [void]$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))
    $grid.ColumnDefinitions[0].Width = New-Object System.Windows.GridLength(54)

    [void]$grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition))
    $grid.ColumnDefinitions[1].Width = New-Object System.Windows.GridLength(1, [System.Windows.GridUnitType]::Star)

    $iconBorder = New-Object System.Windows.Controls.Border
    $iconBorder.Width = 42
    $iconBorder.Height = 42
    $iconBorder.CornerRadius = New-Object System.Windows.CornerRadius(14)
    $iconBorder.Background = New-Brush '#FFFFFF18'
    $iconBorder.BorderBrush = New-Brush '#FFFFFF14'
    $iconBorder.BorderThickness = New-Object System.Windows.Thickness(1)
    $iconBorder.HorizontalAlignment = 'Center'
    $iconBorder.VerticalAlignment = 'Center'
    [System.Windows.Controls.Grid]::SetColumn($iconBorder, 0)

    $iconText = New-Object System.Windows.Controls.TextBlock
    $iconText.Text = [string]$Tool.Icon
    $iconText.FontFamily = 'Segoe MDL2 Assets'
    $iconText.FontSize = 16
    $iconText.Foreground = New-Brush '#F8FAFC'
    $iconText.HorizontalAlignment = 'Center'
    $iconText.VerticalAlignment = 'Center'
    $iconBorder.Child = $iconText

    $textStack = New-Object System.Windows.Controls.StackPanel
    $textStack.VerticalAlignment = 'Center'
    [System.Windows.Controls.Grid]::SetColumn($textStack, 1)

    $titleText = New-Object System.Windows.Controls.TextBlock
    $titleText.Text = $Tool.Name
    $titleText.FontSize = 13
    $titleText.FontWeight = 'SemiBold'
    $titleText.Foreground = New-Brush '#F8FAFC'

    $textStack.Children.Add($titleText) | Out-Null

    $grid.Children.Add($iconBorder) | Out-Null
    $grid.Children.Add($textStack) | Out-Null

    $button.Content = $grid
    $button.Add_Click({ Invoke-ToolAction -Tool $Tool }.GetNewClosure())

    $ParentPanel.Children.Add($button) | Out-Null
}

# ------------------------------------------------------------
# Main XAML
# ------------------------------------------------------------
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$AppTitle"
        Width="1400"
        Height="920"
        MinWidth="1180"
        MinHeight="760"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        AllowsTransparency="True"
        ResizeMode="CanResizeWithGrip"
        Background="Transparent">

    <Window.Resources>
        <LinearGradientBrush x:Key="AppBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#04070C" Offset="0"/>
            <GradientStop Color="#07101A" Offset="0.55"/>
            <GradientStop Color="#06111A" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="PanelBackground" StartPoint="0,0" EndPoint="1,0">
            <GradientStop Color="#09111B" Offset="0"/>
            <GradientStop Color="#08101A" Offset="1"/>
        </LinearGradientBrush>

        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="10"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Grid Background="Transparent">
                            <Track Name="PART_Track" IsDirectionReversed="True">
                                <Track.Thumb>
                                    <Thumb>
                                        <Thumb.Template>
                                            <ControlTemplate TargetType="Thumb">
                                                <Border Width="6" Margin="2,0,2,0" CornerRadius="6" Background="#31445A"/>
                                            </ControlTemplate>
                                        </Thumb.Template>
                                    </Thumb>
                                </Track.Thumb>
                                <Track.DecreaseRepeatButton>
                                    <RepeatButton Command="ScrollBar.LineUpCommand" Opacity="0" IsTabStop="False"/>
                                </Track.DecreaseRepeatButton>
                                <Track.IncreaseRepeatButton>
                                    <RepeatButton Command="ScrollBar.LineDownCommand" Opacity="0" IsTabStop="False"/>
                                </Track.IncreaseRepeatButton>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Border Background="{StaticResource AppBackground}" CornerRadius="24" BorderBrush="#14304A" BorderThickness="1">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="78"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- Title bar -->
            <Border x:Name="HeaderBar" Grid.Row="0" Background="#07111C" CornerRadius="24,24,0,0" BorderBrush="#12304B" BorderThickness="0,0,0,1">
                <Grid Margin="20,0,18,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <Border Width="50" Height="50" CornerRadius="16" Background="#10233A" BorderBrush="#2D4D70" BorderThickness="1" Margin="0,0,14,0">
                            <TextBlock Text="T" Foreground="#7AD9FF" FontWeight="Bold" FontSize="22" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>

                        <StackPanel>
                            <TextBlock Text="$AppTitle" Foreground="White" FontSize="18" FontWeight="SemiBold"/>
                            <TextBlock Text="TeslaPro Security Tools" Foreground="#7F93AA" FontSize="11" Margin="0,3,0,0"/>
                        </StackPanel>
                    </StackPanel>

                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                        <Border Width="42" Height="42" CornerRadius="13" Background="#12253A" BorderBrush="#1A334D" BorderThickness="1" Margin="0,0,10,0">
                            <TextBlock Text="&#xE946;" FontFamily="Segoe MDL2 Assets" Foreground="#E5F4FF" FontSize="15" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <Button x:Name="MinBtn" Width="42" Height="42" Margin="0,0,10,0" Background="#1A2230" BorderBrush="#1A2230" Foreground="White" FontFamily="Segoe MDL2 Assets" Content="&#xE921;" FontSize="16" Cursor="Hand"/>
                        <Button x:Name="CloseBtn" Width="42" Height="42" Background="#1F2634" BorderBrush="#1F2634" Foreground="White" FontFamily="Segoe MDL2 Assets" Content="&#xE8BB;" FontSize="16" Cursor="Hand"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- Main -->
            <Grid Grid.Row="1" Margin="22,18,22,22">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="370"/>
                    <ColumnDefinition Width="22"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- Left panel -->
                <Border Grid.Column="0" Background="#07111A" CornerRadius="24" BorderBrush="#12304A" BorderThickness="1">
                    <Grid Margin="24">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="26"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="24"/>
                            <RowDefinition Height="210"/>
                        </Grid.RowDefinitions>

                        <StackPanel Grid.Row="0">
                            <TextBlock Text="Control Center" Foreground="White" FontSize="28" FontWeight="Bold"/>
                            <TextBlock Text="Launch scanners, inspectors, and quick-access folders from one clean window." Foreground="#93A4B8" FontSize="12" Margin="0,10,0,0" TextWrapping="Wrap"/>
                        </StackPanel>

                        <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                            <StackPanel x:Name="ToolButtonsPanel"/>
                        </ScrollViewer>

                        <Border Grid.Row="4" Background="#0A1521" CornerRadius="20" BorderBrush="#163550" BorderThickness="1">
                            <Grid Margin="18">
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="*"/>
                                    <RowDefinition Height="Auto"/>
                                </Grid.RowDefinitions>

                                <TextBlock Text="Install Path" Foreground="#89A0B9" FontSize="12"/>
                                <TextBlock x:Name="InstallPathText" Grid.Row="1" Margin="0,10,0,0" Text="$env:USERPROFILE\Downloads\TeslaPro-Tools" Foreground="White" FontSize="13" TextWrapping="Wrap"/>

                                <Border Grid.Row="3" Margin="0,16,0,0" Background="#0E2031" CornerRadius="18" BorderBrush="#234763" BorderThickness="1">
                                    <Grid Margin="14">
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>

                                        <StackPanel>
                                            <TextBlock Text="Launcher Version" Foreground="#89A0B9" FontSize="11"/>
                                            <TextBlock Text="$AppVersion" Foreground="#6EDFFF" FontSize="16" FontWeight="Bold" Margin="0,8,0,0"/>
                                        </StackPanel>

                                        <Border Grid.Column="1" Width="88" Height="36" CornerRadius="18" Background="#112A42" BorderBrush="#29506E" BorderThickness="1" VerticalAlignment="Center">
                                            <TextBlock x:Name="MiniStatusValue" Text="IDLE" Foreground="#6EDFFF" FontSize="12" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                        </Border>
                                    </Grid>
                                </Border>
                            </Grid>
                        </Border>
                    </Grid>
                </Border>

                <!-- Right panel -->
                <Grid Grid.Column="2">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="200"/>
                        <RowDefinition Height="20"/>
                        <RowDefinition Height="180"/>
                        <RowDefinition Height="20"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- Hero -->
                    <Border Grid.Row="0" Background="#09121D" CornerRadius="26" BorderBrush="#12304A" BorderThickness="1">
                        <Grid Margin="26">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="310"/>
                            </Grid.ColumnDefinitions>

                            <StackPanel VerticalAlignment="Center">
                                <TextBlock x:Name="HeroState" Text="Ready" Foreground="White" FontSize="36" FontWeight="Bold"/>
                                <TextBlock x:Name="HeroText" Text="Everything is ready. Pick an action on the left." Foreground="#9CB0C6" FontSize="13" Margin="0,8,0,0"/>
                                <Border Margin="0,22,0,0" Background="#08101A" BorderBrush="#163550" BorderThickness="1" CornerRadius="16">
                                    <TextBlock x:Name="MiniStatusSub" Margin="16,12,16,12" Text="This launcher helps you run TeslaPro security tools in a clean and simple way." Foreground="#7F9AB7" FontSize="12"/>
                                </Border>
                            </StackPanel>

                            <Border Grid.Column="1" Margin="24,0,0,0" Background="#07111A" CornerRadius="22" BorderBrush="#163550" BorderThickness="1">
                                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                                    <TextBlock Text="Launcher Status" Foreground="#88A0BA" FontSize="12" HorizontalAlignment="Center"/>
                                    <TextBlock x:Name="StatusBoxValue" Text="IDLE" Foreground="#6EDFFF" FontSize="30" FontWeight="Bold" Margin="0,12,0,0" HorizontalAlignment="Center"/>
                                    <TextBlock x:Name="StatusBoxSub" Text="Ready" Foreground="#90A4BA" FontSize="12" Margin="0,8,0,0" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                        </Grid>
                    </Border>

                    <!-- Stats -->
                    <Grid Grid.Row="2">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="20"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="20"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <Border Grid.Column="0" Background="#09121D" CornerRadius="24" BorderBrush="#12304A" BorderThickness="1">
                            <StackPanel Margin="22">
                                <TextBlock Text="Step" Foreground="#90A6BE" FontSize="12"/>
                                <TextBlock x:Name="StepValue" Text="Waiting" Foreground="White" FontSize="28" FontWeight="Bold" Margin="0,12,0,0"/>
                                <TextBlock Text="Current launcher task." Foreground="#8EA1B7" FontSize="12" Margin="0,8,0,0"/>
                            </StackPanel>
                        </Border>

                        <Border Grid.Column="2" Background="#09121D" CornerRadius="24" BorderBrush="#12304A" BorderThickness="1">
                            <StackPanel Margin="22">
                                <TextBlock Text="Progress" Foreground="#90A6BE" FontSize="12"/>
                                <TextBlock x:Name="ProgressValue" Text="0%" Foreground="White" FontSize="28" FontWeight="Bold" Margin="0,12,0,0"/>
                                <TextBlock Text="Overall progress." Foreground="#8EA1B7" FontSize="12" Margin="0,8,0,0"/>
                            </StackPanel>
                        </Border>

                        <Border Grid.Column="4" Background="#09121D" CornerRadius="24" BorderBrush="#12304A" BorderThickness="1">
                            <StackPanel Margin="22">
                                <TextBlock Text="Available Tools" Foreground="#90A6BE" FontSize="12"/>
                                <TextBlock x:Name="ToolCountValue" Text="0" Foreground="White" FontSize="28" FontWeight="Bold" Margin="0,12,0,0"/>
                                <TextBlock Text="Configured actions in this panel." Foreground="#8EA1B7" FontSize="12" Margin="0,8,0,0"/>
                            </StackPanel>
                        </Border>
                    </Grid>

                    <!-- Activity -->
                    <Border Grid.Row="4" Background="#09121D" CornerRadius="26" BorderBrush="#12304A" BorderThickness="1">
                        <Grid Margin="26">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="14"/>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="18"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>

                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="180"/>
                                </Grid.ColumnDefinitions>

                                <StackPanel>
                                    <TextBlock Text="Activity" Foreground="White" FontSize="28" FontWeight="Bold"/>
                                    <TextBlock Text="Live output from TeslaProControlCenter" Foreground="#8EA4BC" FontSize="12" Margin="0,8,0,0"/>
                                </StackPanel>

                                <Border Grid.Column="1" Width="170" Height="40" CornerRadius="20" Background="#08131F" BorderBrush="#163550" BorderThickness="1" HorizontalAlignment="Right" VerticalAlignment="Center">
                                    <TextBlock x:Name="ActivityPill" Text="IDLE" Foreground="#6EDFFF" FontSize="12" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                            </Grid>

                            <Border Grid.Row="2" Background="#06111A" BorderBrush="#15344E" BorderThickness="1" CornerRadius="10" Height="12"/>

                            <Border Grid.Row="4" Background="#07111A" BorderBrush="#163550" BorderThickness="1" CornerRadius="20">
                                <TextBox x:Name="LogBox"
                                         Margin="18"
                                         Background="Transparent"
                                         BorderThickness="0"
                                         Foreground="#EAF6FF"
                                         FontFamily="Consolas"
                                         FontSize="12"
                                         IsReadOnly="True"
                                         AcceptsReturn="True"
                                         TextWrapping="Wrap"
                                         VerticalScrollBarVisibility="Auto"/>
                            </Border>
                        </Grid>
                    </Border>
                </Grid>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

# ------------------------------------------------------------
# Load UI
# ------------------------------------------------------------
$reader = New-Object System.Xml.XmlNodeReader $xaml
$Window = [Windows.Markup.XamlReader]::Load($reader)

# ------------------------------------------------------------
# Bind controls
# ------------------------------------------------------------
$script:HeroState      = $Window.FindName('HeroState')
$script:HeroText       = $Window.FindName('HeroText')
$script:LogBox         = $Window.FindName('LogBox')
$script:MiniStatusValue= $Window.FindName('MiniStatusValue')
$script:MiniStatusSub  = $Window.FindName('MiniStatusSub')
$script:StepValue      = $Window.FindName('StepValue')
$script:ProgressValue  = $Window.FindName('ProgressValue')
$script:ToolCountValue = $Window.FindName('ToolCountValue')

$HeaderBar             = $Window.FindName('HeaderBar')
$MinBtn                = $Window.FindName('MinBtn')
$CloseBtn              = $Window.FindName('CloseBtn')
$ToolButtonsPanel      = $Window.FindName('ToolButtonsPanel')
$StatusBoxValue        = $Window.FindName('StatusBoxValue')
$StatusBoxSub          = $Window.FindName('StatusBoxSub')
$ActivityPill          = $Window.FindName('ActivityPill')

$script:NavButtonStyle = New-NavButtonStyle

# ------------------------------------------------------------
# Populate tools
# ------------------------------------------------------------
foreach ($tool in $Tools) {
    Add-ToolButton -Tool $tool -ParentPanel $ToolButtonsPanel
}

if ($script:ToolCountValue) {
    $script:ToolCountValue.Text = [string]$Tools.Count
}

# ------------------------------------------------------------
# Window controls
# ------------------------------------------------------------
$HeaderBar.Add_MouseLeftButtonDown({
    try { $Window.DragMove() } catch {}
})

$MinBtn.Add_Click({
    $Window.WindowState = 'Minimized'
})

$CloseBtn.Add_Click({
    $Window.Close()
})

# ------------------------------------------------------------
# Initial state
# ------------------------------------------------------------
if ($StatusBoxValue) { $StatusBoxValue.Text = 'IDLE' }
if ($StatusBoxSub)   { $StatusBoxSub.Text = 'Ready' }
if ($ActivityPill)   { $ActivityPill.Text = 'IDLE' }

Set-Status -State 'Ready' -Details 'Everything is ready. Pick an action on the left.' -Color '#6EDFFF'
Write-Log '[OK] TeslaProControlCenter started'
Write-Log '[INFO] Ready'
Write-Log '[INFO] AppData and Prefetch actions restored'

# ------------------------------------------------------------
# Show
# ------------------------------------------------------------
[void]$Window.ShowDialog()