Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ============================================================
# TeslaProControlCenter
# ============================================================

$AppTitle = 'TeslaProControlCenter'

$Tools = @(
    @{ Name = 'TeslaPro Macro Finder'; Icon = '&#xE721;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/TeslaProMacroFinder/main/TeslaProMacroFinder_V3.ps1'')"'; Desc = 'Scan the system for macro-related traces and suspicious activity.'; Tag = 'Scanner' },
    @{ Name = 'Doomsday Detector';     Icon = '&#xE7BA;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/DoomsdayDetector/main/DoomsdayClientDetectorV3.ps1'')"'; Desc = 'Launch the Doomsday client detection workflow.'; Tag = 'Detection' },
    @{ Name = 'Habibi Mod Analyzer';   Icon = '&#xE943;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'; Desc = 'Analyze Minecraft mods using metadata, hashes, and indicators.'; Tag = 'Analysis' },
    @{ Name = 'VPN Finder';            Icon = '&#xE836;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/VPNChecker/main/VPNFinder.ps1'')"'; Desc = 'Search for active VPN connections and related traces.'; Tag = 'Network' },
    @{ Name = 'Security Manager';      Icon = '&#xE756;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/ChxAuDpF)'; Desc = 'Prepare and launch additional security-oriented tooling.'; Tag = 'Security' },
    @{ Name = 'QuickCheck Scanner';    Icon = '&#xEC92;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/HGLwy7XA)'; Desc = 'Fast first-pass scan for registry activity and logs.'; Tag = 'Quick Scan' },
    @{ Name = 'Red Lotus BAM';         Icon = '&#xECA5;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1)'; Desc = 'Inspect Windows execution history using BAM data.'; Tag = 'Forensics' }
)

function New-Brush {
    param([string]$Color)
    ([System.Windows.Media.BrushConverter]::new()).ConvertFromString($Color)
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
        [string]$Color = '#5CF2C5'
    )
    if ($script:StatusValue) {
        $script:StatusValue.Text = $State
        $script:StatusValue.Foreground = New-Brush $Color
    }
    if ($script:StatusText) {
        $script:StatusText.Text = $Details
    }
}

function Invoke-ToolAction {
    param($Tool)
    try {
        Write-Log "Launching $($Tool.Name)..."
        Set-Status -State 'RUNNING' -Details "Executing $($Tool.Name)..." -Color '#FFC766'

        $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $StartInfo.FileName = 'cmd.exe'
        $StartInfo.Arguments = "/k $($Tool.Cmd)"
        $StartInfo.UseShellExecute = $true
        if ($Tool.Admin) { $StartInfo.Verb = 'runas' }

        [System.Diagnostics.Process]::Start($StartInfo) | Out-Null

        Write-Log "$($Tool.Name) launched."
        Set-Status -State 'READY' -Details "$($Tool.Name) launched successfully." -Color '#5CF2C5'
    }
    catch {
        Write-Log "Failed: $($_.Exception.Message)"
        Set-Status -State 'ERROR' -Details 'Action was cancelled or failed.' -Color '#FF6978'
    }
}

function Escape-XamlText {
    param([string]$Text)
    if ($null -eq $Text) { return '' }
    $Text.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;').Replace("'", '&apos;')
}

function Load-XamlFragment {
    param([string]$Xaml)
    $stringReader = New-Object System.IO.StringReader($Xaml)
    $xmlReader = [System.Xml.XmlReader]::Create($stringReader)
    [Windows.Markup.XamlReader]::Load($xmlReader)
}

function New-ToolCardXaml {
    param(
        [Parameter(Mandatory)]$Tool,
        [Parameter(Mandatory)][int]$Index
    )

    $name = Escape-XamlText $Tool.Name
    $desc = Escape-XamlText $Tool.Desc
    $tag  = Escape-XamlText $Tool.Tag
    $icon = $Tool.Icon

    $adminBadge = ''
    if ($Tool.Admin) {
        $adminBadge = @'
<Border Margin="6,0,0,0" Padding="6,2,6,2" Background="#0D1E30" BorderBrush="#1E3A55" BorderThickness="1" CornerRadius="6">
    <TextBlock Text="ADMIN" Foreground="#5AABDC" FontSize="8" FontWeight="SemiBold"/>
</Border>
'@
    }

    @"
<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Margin="0,0,0,8"
        CornerRadius="14"
        Background="#0C1219"
        BorderBrush="#161F2A"
        BorderThickness="1">
    <Grid Margin="14,12,14,12">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="42"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="44"/>
        </Grid.ColumnDefinitions>

        <Border Grid.Column="0"
                Width="36"
                Height="36"
                CornerRadius="10"
                Background="#0F1E2E"
                BorderBrush="#1E3347"
                BorderThickness="1"
                HorizontalAlignment="Center"
                VerticalAlignment="Center">
            <TextBlock Text="$icon"
                       FontFamily="Segoe MDL2 Assets"
                       FontSize="16"
                       Foreground="#6BBFE0"
                       HorizontalAlignment="Center"
                       VerticalAlignment="Center"/>
        </Border>

        <StackPanel Grid.Column="1" Margin="12,0,10,0" VerticalAlignment="Center">
            <StackPanel Orientation="Horizontal">
                <TextBlock Text="$name"
                           Foreground="#E8EEF5"
                           FontSize="13"
                           FontWeight="SemiBold"/>
                $adminBadge
                <Border Margin="6,0,0,0" Padding="6,2,6,2" Background="#0A1622" BorderBrush="#1A2D3F" BorderThickness="1" CornerRadius="6">
                    <TextBlock Text="$tag" Foreground="#607A95" FontSize="8" FontWeight="SemiBold"/>
                </Border>
            </StackPanel>
            <TextBlock Margin="0,4,0,0"
                       Text="$desc"
                       Foreground="#5A6A7E"
                       FontSize="11"
                       TextWrapping="Wrap"/>
        </StackPanel>

        <Button Name="ToolBtn$Index"
                Grid.Column="2"
                Width="36"
                Height="36"
                Content="&#xE768;"
                FontFamily="Segoe MDL2 Assets"
                FontSize="13"
                Cursor="Hand"
                Background="#0F2236"
                Foreground="#50D4B0"
                BorderBrush="#1E3F5A"
                BorderThickness="1"
                HorizontalAlignment="Center"
                VerticalAlignment="Center"/>
    </Grid>
</Border>
"@
}

function Render-ToolCards {
    param([array]$ToolList)
    if (-not $script:ToolStackPanel) { return }
    $script:ToolStackPanel.Children.Clear()

    for ($i = 0; $i -lt $ToolList.Count; $i++) {
        $tool = $ToolList[$i]
        $cardXaml = New-ToolCardXaml -Tool $tool -Index $i
        $card = Load-XamlFragment -Xaml $cardXaml

        $btn = $card.FindName("ToolBtn$i")
        if ($btn) {
            if ($script:LaunchButtonStyle) { $btn.Style = $script:LaunchButtonStyle }
            $localTool = $tool
            $btn.Add_Click({ Invoke-ToolAction -Tool $localTool }.GetNewClosure())
        }
        [void]$script:ToolStackPanel.Children.Add($card)
    }
}

$xamlText = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$AppTitle"
        Width="960"
        Height="680"
        MinWidth="860"
        MinHeight="560"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        AllowsTransparency="True"
        ResizeMode="CanResizeWithGrip"
        Background="Transparent">

    <Window.Resources>

        <SolidColorBrush x:Key="AppBg" Color="#080D13"/>
        <SolidColorBrush x:Key="PanelBg" Color="#0A1018"/>
        <SolidColorBrush x:Key="CardBg"  Color="#0C1219"/>

        <Style x:Key="ChromeBtn" TargetType="Button">
            <Setter Property="Width" Value="32"/>
            <Setter Property="Height" Value="32"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#5A6E84"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontFamily" Value="Segoe MDL2 Assets"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="8">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#121D28"/>
                                <Setter Property="Foreground" Value="#C8D5E3"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="LaunchButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="#0F2236"/>
            <Setter Property="Foreground" Value="#50D4B0"/>
            <Setter Property="BorderBrush" Value="#1E3F5A"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border CornerRadius="10"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#163048"/>
                                <Setter Property="BorderBrush" Value="#3A82B5"/>
                                <Setter Property="Foreground" Value="#7CEDD0"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#1C3E5A"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="ActionBtn" TargetType="Button">
            <Setter Property="Background" Value="#0C1721"/>
            <Setter Property="Foreground" Value="#7A93AD"/>
            <Setter Property="BorderBrush" Value="#172535"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,8"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="10">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"
                                              Margin="{TemplateBinding Padding}"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#112030"/>
                                <Setter Property="BorderBrush" Value="#264A69"/>
                                <Setter Property="Foreground" Value="#C0D0E0"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#162C40"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="6"/>
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
                                                <Border Width="4" Margin="1,0" CornerRadius="4" Background="#1E3048"/>
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

    <!-- Root border with outer glow effect -->
    <Border CornerRadius="18"
            BorderBrush="#131E2A"
            BorderThickness="1"
            Background="{StaticResource AppBg}">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="54"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- Title Bar -->
            <Border x:Name="HeaderBar"
                    Grid.Row="0"
                    CornerRadius="18,18,0,0"
                    Background="#07101A"
                    BorderBrush="#101C28"
                    BorderThickness="0,0,0,1">
                <Grid Margin="18,0,14,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <Border Width="30" Height="30" CornerRadius="9"
                                Background="#0C1E2F" BorderBrush="#1A3349" BorderThickness="1" Margin="0,0,10,0">
                            <TextBlock Text="&#xEC4A;" FontFamily="Segoe MDL2 Assets"
                                       Foreground="#5BACD6" FontSize="14"
                                       HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <TextBlock Text="$AppTitle" Foreground="#D0DCE8" FontSize="14" FontWeight="SemiBold" VerticalAlignment="Center"/>
                        <TextBlock Text="  —  Elite Operations Interface" Foreground="#374D62" FontSize="11" VerticalAlignment="Center" Margin="0,1,0,0"/>
                    </StackPanel>

                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                        <Button x:Name="MinBtn"   Content="&#xE921;" Style="{StaticResource ChromeBtn}"/>
                        <Button x:Name="CloseBtn" Content="&#xE8BB;" Style="{StaticResource ChromeBtn}" Margin="4,0,0,0"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- Main Layout -->
            <Grid Grid.Row="1" Margin="14,14,14,14">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="360"/>
                    <ColumnDefinition Width="14"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- Left: Tool List -->
                <Border Grid.Column="0"
                        CornerRadius="14"
                        Background="{StaticResource PanelBg}"
                        BorderBrush="#111C28"
                        BorderThickness="1">
                    <Grid Margin="14">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="10"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <StackPanel Grid.Row="0">
                            <TextBlock Text="Tool Library"
                                       Foreground="#C8D8E8"
                                       FontSize="15"
                                       FontWeight="SemiBold"/>
                            <TextBlock Text="Select a tool to launch it with elevated privileges."
                                       Foreground="#374F68"
                                       FontSize="11"
                                       Margin="0,4,0,0"/>
                        </StackPanel>

                        <Border Grid.Row="2"
                                CornerRadius="10"
                                Background="#07101A"
                                BorderBrush="#0E1C28"
                                BorderThickness="1">
                            <ScrollViewer Margin="10"
                                          VerticalScrollBarVisibility="Auto"
                                          HorizontalScrollBarVisibility="Disabled"
                                          CanContentScroll="False">
                                <StackPanel x:Name="ToolStackPanel"/>
                            </ScrollViewer>
                        </Border>
                    </Grid>
                </Border>

                <!-- Right: Status + Console -->
                <Grid Grid.Column="2">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="110"/>
                        <RowDefinition Height="10"/>
                        <RowDefinition Height="46"/>
                        <RowDefinition Height="10"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- Status Card -->
                    <Border Grid.Row="0"
                            CornerRadius="14"
                            Background="{StaticResource PanelBg}"
                            BorderBrush="#111C28"
                            BorderThickness="1">
                        <Grid Margin="18,14,18,14">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <StackPanel VerticalAlignment="Center">
                                <TextBlock Text="System State" Foreground="#36526A" FontSize="10" FontWeight="SemiBold"/>
                                <TextBlock x:Name="StatusValue"
                                           Text="READY"
                                           Foreground="#5CF2C5"
                                           FontSize="28"
                                           FontWeight="Bold"
                                           Margin="0,4,0,0"/>
                                <TextBlock x:Name="StatusText"
                                           Text="System initialized and ready for command execution."
                                           Foreground="#4A6276"
                                           FontSize="11"
                                           Margin="0,4,0,0"
                                           TextWrapping="Wrap"/>
                            </StackPanel>

                            <!-- Subtle accent dot -->
                            <Ellipse Grid.Column="1"
                                     Width="8" Height="8"
                                     Fill="#5CF2C5"
                                     VerticalAlignment="Center"
                                     HorizontalAlignment="Right"
                                     Margin="0,0,4,0"
                                     Opacity="0.6"/>
                        </Grid>
                    </Border>

                    <!-- Action Bar -->
                    <Border Grid.Row="2"
                            CornerRadius="14"
                            Background="{StaticResource PanelBg}"
                            BorderBrush="#111C28"
                            BorderThickness="1">
                        <Grid Margin="14,0,14,0">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="10"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <TextBlock Grid.Column="0"
                                       Text="Live Console"
                                       Foreground="#4A6276"
                                       FontSize="11"
                                       VerticalAlignment="Center"/>

                            <Button x:Name="ClearLogBtn"
                                    Grid.Column="2"
                                    Style="{StaticResource ActionBtn}">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="&#xE894;" FontFamily="Segoe MDL2 Assets"
                                               FontSize="12" VerticalAlignment="Center"/>
                                    <TextBlock Text="  Clear" FontSize="11" FontWeight="SemiBold"
                                               VerticalAlignment="Center" Margin="0,0,0,0"/>
                                </StackPanel>
                            </Button>
                        </Grid>
                    </Border>

                    <!-- Console -->
                    <Border Grid.Row="4"
                            CornerRadius="14"
                            Background="#050A10"
                            BorderBrush="#0D1A26"
                            BorderThickness="1">
                        <TextBox x:Name="LogBox"
                                 Margin="14"
                                 Background="Transparent"
                                 BorderThickness="0"
                                 Foreground="#3D7FA8"
                                 FontFamily="Consolas"
                                 FontSize="11"
                                 IsReadOnly="True"
                                 AcceptsReturn="True"
                                 TextWrapping="Wrap"
                                 VerticalScrollBarVisibility="Auto"/>
                    </Border>
                </Grid>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

try {
    $Window = Load-XamlFragment -Xaml $xamlText

    $script:LogBox         = $Window.FindName('LogBox')
    $script:StatusValue    = $Window.FindName('StatusValue')
    $script:StatusText     = $Window.FindName('StatusText')
    $script:ToolStackPanel = $Window.FindName('ToolStackPanel')
    $script:LaunchButtonStyle = $Window.Resources['LaunchButtonStyle']

    $HeaderBar   = $Window.FindName('HeaderBar')
    $MinBtn      = $Window.FindName('MinBtn')
    $CloseBtn    = $Window.FindName('CloseBtn')
    $ClearLogBtn = $Window.FindName('ClearLogBtn')

    Render-ToolCards -ToolList $Tools

    if ($HeaderBar) {
        $HeaderBar.Add_MouseLeftButtonDown({ try { $Window.DragMove() } catch {} })
    }

    if ($MinBtn) {
        $MinBtn.Add_Click({ $Window.WindowState = 'Minimized' })
    }

    if ($CloseBtn) {
        $CloseBtn.Add_Click({ $Window.Close() })
    }

    if ($ClearLogBtn) {
        $ClearLogBtn.Add_Click({
            if ($script:LogBox) {
                $script:LogBox.Clear()
                Write-Log 'Console cleared.'
            }
        })
    }

    Write-Log 'TeslaProControlCenter initialized.'
    Write-Log 'Ready for tool execution.'
    Set-Status -State 'READY' -Details 'System initialized and ready for command execution.' -Color '#5CF2C5'

    [void]$Window.ShowDialog()
}
catch {
    Write-Error "UI failed to load: $($_.Exception.Message)"
}
