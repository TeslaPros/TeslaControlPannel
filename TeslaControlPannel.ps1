Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ============================================================
# TeslaProControlCenter
# Ultra Premium WPF Edition - Stable Fixed Build
# ============================================================

$AppTitle = 'TeslaProControlCenter'

$Tools = @(
    @{ Name = 'TeslaPro Macro Finder'; Icon = '&#xE721;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/TeslaProMacroFinder/main/TeslaProMacroFinder_V3.ps1'')"'; Desc = 'Scan the system for macro-related traces and suspicious activity.'; Tag = 'Scanner' },
    @{ Name = 'Doomsday Detector';     Icon = '&#xE7BA;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/DoomsdayDetector/main/DoomsdayClientDetectorV3.ps1'')"'; Desc = 'Launch the Doomsday client detection workflow.'; Tag = 'Detection' },
    @{ Name = 'Habibi Mod Analyzer';   Icon = '&#xE943;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'; Desc = 'Analyze Minecraft mods using metadata, hashes, and indicators.'; Tag = 'Analysis' },
    @{ Name = 'VPN Finder';            Icon = '&#xE836;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/VPNChecker/main/VPNFinder.ps1'')"'; Desc = 'Search for active VPN connections and related traces.'; Tag = 'Network' },
    @{ Name = 'Security Manager';      Icon = '&#xE756;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/ChxAuDpF)'; Desc = 'Prepare and launch additional security-oriented tooling.'; Tag = 'Security' },
    @{ Name = 'QuickCheck Scanner';    Icon = '&#xEC92;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/HGLwy7XA)'; Desc = 'Fast first-pass scan for registry activity and logs.'; Tag = 'Quick Scan' },
    @{ Name = 'Red Lotus BAM';         Icon = '&#xECA5;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1)'; Desc = 'Inspect Windows execution history using BAM data.'; Tag = 'Forensics' },
    @{ Name = 'Open AppData';          Icon = '&#xED25;'; Kind = 'Folder';  Admin = $false; Path = $env:APPDATA; Desc = 'Open the local AppData directory.'; Tag = 'Folder' },
    @{ Name = 'Open Prefetch';         Icon = '&#xE8B7;'; Kind = 'Folder';  Admin = $false; Path = 'C:\Windows\Prefetch'; Desc = 'Open the Windows Prefetch directory.'; Tag = 'Folder' }
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

    if ($Tool.Kind -eq 'Folder') {
        try {
            Start-Process 'explorer.exe' $Tool.Path
            Write-Log "Opened folder: $($Tool.Path)"
            Set-Status -State 'READY' -Details "Opened folder: $($Tool.Name)" -Color '#5CF2C5'
        }
        catch {
            Write-Log "Failed to open folder: $($_.Exception.Message)"
            Set-Status -State 'ERROR' -Details 'Folder action failed.' -Color '#FF6978'
        }
        return
    }

    try {
        Write-Log "Launching $($Tool.Name)..."
        Set-Status -State 'EXECUTING' -Details "Starting $($Tool.Name)..." -Color '#FFC766'

        $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $StartInfo.FileName = 'cmd.exe'
        $StartInfo.Arguments = "/k $($Tool.Cmd)"
        $StartInfo.UseShellExecute = $true

        if ($Tool.Admin) {
            $StartInfo.Verb = 'runas'
        }

        [System.Diagnostics.Process]::Start($StartInfo) | Out-Null

        Write-Log "Started: $($Tool.Name)"
        Set-Status -State 'READY' -Details "$($Tool.Name) launched successfully." -Color '#5CF2C5'
    }
    catch {
        Write-Log "Launch failed or cancelled: $($_.Exception.Message)"
        Set-Status -State 'ERROR' -Details 'Action was cancelled or failed.' -Color '#FF6978'
    }
}

function Get-FilteredTools {
    param([string]$Query)

    if ([string]::IsNullOrWhiteSpace($Query)) {
        return ,$Tools
    }

    $q = $Query.Trim().ToLowerInvariant()

    @(
        $Tools | Where-Object {
            $_.Name.ToLowerInvariant().Contains($q) -or
            $_.Desc.ToLowerInvariant().Contains($q) -or
            $_.Tag.ToLowerInvariant().Contains($q)
        }
    )
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
    $kind = Escape-XamlText $Tool.Kind
    $icon = $Tool.Icon

    $adminBadge = ''
    if ($Tool.Admin) {
        $adminBadge = @"
<Border Grid.Column="2" Margin="8,0,0,0" Padding="8,2,8,2" Background="#1A2433" BorderBrush="#2E4660" BorderThickness="1" CornerRadius="8">
    <TextBlock Text="ADMIN" Foreground="#78C7FF" FontSize="9" FontWeight="SemiBold"/>
</Border>
"@
    }

    @"
<Border xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Margin="0,0,0,14"
        CornerRadius="20"
        Background="#101722"
        BorderBrush="#1E2A39"
        BorderThickness="1">
    <Grid Margin="18">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="70"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="68"/>
        </Grid.ColumnDefinitions>

        <Border Grid.Column="0"
                Width="54"
                Height="54"
                CornerRadius="16"
                Background="#142235"
                BorderBrush="#274869"
                BorderThickness="1"
                HorizontalAlignment="Center"
                VerticalAlignment="Center">
            <TextBlock Text="$icon"
                       FontFamily="Segoe MDL2 Assets"
                       FontSize="22"
                       Foreground="#7ED0FF"
                       HorizontalAlignment="Center"
                       VerticalAlignment="Center"/>
        </Border>

        <Grid Grid.Column="1" Margin="8,0,12,0">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Grid Grid.Row="0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <TextBlock Grid.Column="0"
                           Text="$name"
                           Foreground="White"
                           FontSize="16"
                           FontWeight="SemiBold"
                           VerticalAlignment="Center"/>

                <Border Grid.Column="2"
                        Padding="10,3,10,3"
                        Background="#141E2B"
                        BorderBrush="#273446"
                        BorderThickness="1"
                        CornerRadius="8"
                        VerticalAlignment="Center">
                    <TextBlock Text="$tag"
                               Foreground="#8FA8C6"
                               FontSize="9"
                               FontWeight="SemiBold"/>
                </Border>
            </Grid>

            <TextBlock Grid.Row="1"
                       Margin="0,8,0,0"
                       Text="$desc"
                       Foreground="#9AA6B8"
                       FontSize="12"
                       TextWrapping="Wrap"/>

            <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,10,0,0">
                <TextBlock Text="&#xE72E;"
                           FontFamily="Segoe MDL2 Assets"
                           Foreground="#5CF2C5"
                           FontSize="11"
                           VerticalAlignment="Center"/>
                <TextBlock Margin="6,0,0,0"
                           Text="$kind"
                           Foreground="#7B899E"
                           FontSize="10"
                           VerticalAlignment="Center"/>
                $adminBadge
            </StackPanel>
        </Grid>

        <Button Name="ToolBtn$Index"
                Grid.Column="2"
                Width="48"
                Height="48"
                Content="&#xE768;"
                FontFamily="Segoe MDL2 Assets"
                FontSize="15"
                Cursor="Hand"
                Background="#122334"
                Foreground="#66F0C6"
                BorderBrush="#2A4C69"
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
            if ($script:LaunchButtonStyle) {
                $btn.Style = $script:LaunchButtonStyle
            }

            $localTool = $tool
            $btn.Add_Click({ Invoke-ToolAction -Tool $localTool }.GetNewClosure())
        }

        [void]$script:ToolStackPanel.Children.Add($card)
    }

    if ($script:ToolCountValue) {
        $script:ToolCountValue.Text = [string]$ToolList.Count
    }
}

$xamlText = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$AppTitle"
        Width="1340"
        Height="860"
        MinWidth="1180"
        MinHeight="720"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        AllowsTransparency="True"
        ResizeMode="CanResizeWithGrip"
        Background="Transparent">

    <Window.Resources>

        <LinearGradientBrush x:Key="AppBackgroundBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#06080C" Offset="0"/>
            <GradientStop Color="#09111A" Offset="0.5"/>
            <GradientStop Color="#05070B" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="PanelBrush" StartPoint="0,0" EndPoint="0,1">
            <GradientStop Color="#0D131C" Offset="0"/>
            <GradientStop Color="#0A0F16" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="HeroBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#101B2A" Offset="0"/>
            <GradientStop Color="#0C1520" Offset="0.6"/>
            <GradientStop Color="#0A1018" Offset="1"/>
        </LinearGradientBrush>

        <Style x:Key="ChromeButtonStyle" TargetType="Button">
            <Setter Property="Width" Value="40"/>
            <Setter Property="Height" Value="34"/>
            <Setter Property="Margin" Value="6,0,0,0"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#9EB0C8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontFamily" Value="Segoe MDL2 Assets"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="12">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#152131"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#1D2C41"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="LaunchButtonStyle" TargetType="Button">
            <Setter Property="Background" Value="#122334"/>
            <Setter Property="Foreground" Value="#66F0C6"/>
            <Setter Property="BorderBrush" Value="#2A4C69"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border CornerRadius="15"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}">
                            <Grid>
                                <Ellipse Width="26" Height="26" Fill="#0D1824" Opacity="0.45" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#18314A"/>
                                <Setter Property="BorderBrush" Value="#5DA9DA"/>
                                <Setter Property="Foreground" Value="#8AF7D6"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#21405D"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="QuickActionStyle" TargetType="Button">
            <Setter Property="Background" Value="#111B28"/>
            <Setter Property="Foreground" Value="#B8C5D8"/>
            <Setter Property="BorderBrush" Value="#263447"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="14,10,14,10"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="14">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#162537"/>
                                <Setter Property="BorderBrush" Value="#35506F"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#1D3047"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

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
                                                <Border Width="6"
                                                        Margin="2,0,2,0"
                                                        CornerRadius="6"
                                                        Background="#324256"/>
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
                        <ControlTemplate.Triggers>
                            <Trigger Property="Orientation" Value="Horizontal">
                                <Setter Property="Height" Value="10"/>
                                <Setter Property="Width" Value="Auto"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="TextBox">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Background" Value="#0C131D"/>
            <Setter Property="BorderBrush" Value="#233245"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="14,10,14,10"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TextBox">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="14">
                            <ScrollViewer x:Name="PART_ContentHost"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsKeyboardFocused" Value="True">
                                <Setter Property="BorderBrush" Value="#4D7BA7"/>
                                <Setter Property="Background" Value="#0E1722"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <Border CornerRadius="28"
            BorderBrush="#1B2634"
            BorderThickness="1"
            Background="{StaticResource AppBackgroundBrush}">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="72"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <Border x:Name="HeaderBar"
                    Grid.Row="0"
                    CornerRadius="28,28,0,0"
                    Background="#0A0F16"
                    BorderBrush="#16212D"
                    BorderThickness="0,0,0,1">
                <Grid Margin="22,0,22,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <Border Width="44"
                                Height="44"
                                CornerRadius="14"
                                Background="#102032"
                                BorderBrush="#23415E"
                                BorderThickness="1"
                                Margin="0,0,14,0">
                            <TextBlock Text="&#xEC4A;"
                                       FontFamily="Segoe MDL2 Assets"
                                       Foreground="#7FD1FF"
                                       FontSize="18"
                                       HorizontalAlignment="Center"
                                       VerticalAlignment="Center"/>
                        </Border>

                        <StackPanel>
                            <TextBlock Text="$AppTitle"
                                       Foreground="White"
                                       FontSize="20"
                                       FontWeight="SemiBold"/>
                            <TextBlock Text="Elite operations interface"
                                       Foreground="#8392A8"
                                       FontSize="11"
                                       Margin="0,2,0,0"/>
                        </StackPanel>
                    </StackPanel>

                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                        <Button x:Name="MinBtn" Content="&#xE921;" Style="{StaticResource ChromeButtonStyle}"/>
                        <Button x:Name="CloseBtn" Content="&#xE8BB;" Style="{StaticResource ChromeButtonStyle}"/>
                    </StackPanel>
                </Grid>
            </Border>

            <Grid Grid.Row="1" Margin="24">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="430"/>
                    <ColumnDefinition Width="18"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Border Grid.Column="0"
                        CornerRadius="24"
                        Background="{StaticResource PanelBrush}"
                        BorderBrush="#1B2735"
                        BorderThickness="1">
                    <Grid Margin="22">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="14"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="14"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <StackPanel Grid.Row="0">
                            <TextBlock Text="Tool Library"
                                       Foreground="White"
                                       FontSize="22"
                                       FontWeight="SemiBold"/>
                            <TextBlock Text="High-performance launch surface for scanners, inspectors, and utilities."
                                       Foreground="#8B98AA"
                                       FontSize="12"
                                       Margin="0,6,0,0"
                                       TextWrapping="Wrap"/>
                        </StackPanel>

                        <Grid Grid.Row="2">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>

                            <TextBox x:Name="SearchBox"
                                     Height="44"
                                     VerticalContentAlignment="Center"
                                     Text=""/>

                            <Border Grid.Column="1"
                                    Margin="12,0,0,0"
                                    Padding="14,0,14,0"
                                    Height="44"
                                    Background="#101B28"
                                    BorderBrush="#233245"
                                    BorderThickness="1"
                                    CornerRadius="14">
                                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                                    <TextBlock Text="&#xE721;"
                                               FontFamily="Segoe MDL2 Assets"
                                               Foreground="#7ECFFF"
                                               FontSize="13"
                                               VerticalAlignment="Center"/>
                                    <TextBlock Margin="8,0,0,0"
                                               Text="Search"
                                               Foreground="#9AA8BC"
                                               FontSize="11"
                                               VerticalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                        </Grid>

                        <Border Grid.Row="4"
                                CornerRadius="22"
                                Background="#091019"
                                BorderBrush="#162333"
                                BorderThickness="1">
                            <ScrollViewer Margin="14"
                                          VerticalScrollBarVisibility="Auto"
                                          HorizontalScrollBarVisibility="Disabled"
                                          CanContentScroll="False">
                                <StackPanel x:Name="ToolStackPanel"/>
                            </ScrollViewer>
                        </Border>
                    </Grid>
                </Border>

                <Grid Grid.Column="2">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="190"/>
                        <RowDefinition Height="18"/>
                        <RowDefinition Height="94"/>
                        <RowDefinition Height="18"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0"
                            CornerRadius="24"
                            Background="{StaticResource HeroBrush}"
                            BorderBrush="#1D2B3A"
                            BorderThickness="1">
                        <Grid Margin="24">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="260"/>
                            </Grid.ColumnDefinitions>

                            <StackPanel VerticalAlignment="Center">
                                <TextBlock Text="System State"
                                           Foreground="#90A0B5"
                                           FontSize="12"/>
                                <TextBlock x:Name="StatusValue"
                                           Text="READY"
                                           Foreground="#5CF2C5"
                                           FontSize="42"
                                           FontWeight="Bold"
                                           Margin="0,8,0,0"/>
                                <TextBlock x:Name="StatusText"
                                           Text="System initialized and ready for command execution."
                                           Foreground="#B2BDCB"
                                           FontSize="13"
                                           Margin="0,8,0,0"
                                           TextWrapping="Wrap"/>
                            </StackPanel>

                            <Grid Grid.Column="1" Margin="18,0,0,0">
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="*"/>
                                    <RowDefinition Height="12"/>
                                    <RowDefinition Height="*"/>
                                </Grid.RowDefinitions>

                                <UniformGrid Grid.Row="0" Rows="1" Columns="2">
                                    <Border Margin="0,0,7,0"
                                            CornerRadius="18"
                                            Background="#0F1926"
                                            BorderBrush="#253648"
                                            BorderThickness="1">
                                        <StackPanel Margin="16">
                                            <TextBlock Text="TOOLS"
                                                       Foreground="#78869A"
                                                       FontSize="10"/>
                                            <TextBlock x:Name="ToolCountValue"
                                                       Text="0"
                                                       Foreground="White"
                                                       FontSize="28"
                                                       FontWeight="SemiBold"
                                                       Margin="0,6,0,0"/>
                                        </StackPanel>
                                    </Border>

                                    <Border Margin="7,0,0,0"
                                            CornerRadius="18"
                                            Background="#0F1926"
                                            BorderBrush="#253648"
                                            BorderThickness="1">
                                        <StackPanel Margin="16">
                                            <TextBlock Text="FRAMEWORK"
                                                       Foreground="#78869A"
                                                       FontSize="10"/>
                                            <TextBlock Text="WPF"
                                                       Foreground="White"
                                                       FontSize="28"
                                                       FontWeight="SemiBold"
                                                       Margin="0,6,0,0"/>
                                        </StackPanel>
                                    </Border>
                                </UniformGrid>

                                <Border Grid.Row="2"
                                        CornerRadius="18"
                                        Background="#0D1722"
                                        BorderBrush="#223446"
                                        BorderThickness="1">
                                    <StackPanel Margin="16">
                                        <TextBlock Text="ACTIVE PROFILE"
                                                   Foreground="#78869A"
                                                   FontSize="10"/>
                                        <TextBlock Text="Premium UI"
                                                   Foreground="#7FD1FF"
                                                   FontSize="24"
                                                   FontWeight="SemiBold"
                                                   Margin="0,6,0,0"/>
                                    </StackPanel>
                                </Border>
                            </Grid>
                        </Grid>
                    </Border>

                    <Border Grid.Row="2"
                            CornerRadius="22"
                            Background="{StaticResource PanelBrush}"
                            BorderBrush="#1B2735"
                            BorderThickness="1">
                        <Grid Margin="18">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="12"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="12"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <Button x:Name="OpenAppDataBtn" Grid.Column="0" Style="{StaticResource QuickActionStyle}">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="&#xED25;" FontFamily="Segoe MDL2 Assets" Foreground="#7ECFFF" FontSize="14" VerticalAlignment="Center"/>
                                    <TextBlock Text="  Open AppData" Foreground="White" FontSize="12" FontWeight="SemiBold" VerticalAlignment="Center"/>
                                </StackPanel>
                            </Button>

                            <Button x:Name="OpenPrefetchBtn" Grid.Column="2" Style="{StaticResource QuickActionStyle}">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="&#xE8B7;" FontFamily="Segoe MDL2 Assets" Foreground="#7ECFFF" FontSize="14" VerticalAlignment="Center"/>
                                    <TextBlock Text="  Open Prefetch" Foreground="White" FontSize="12" FontWeight="SemiBold" VerticalAlignment="Center"/>
                                </StackPanel>
                            </Button>

                            <Button x:Name="ClearLogBtn" Grid.Column="4" Style="{StaticResource QuickActionStyle}">
                                <StackPanel Orientation="Horizontal">
                                    <TextBlock Text="&#xE894;" FontFamily="Segoe MDL2 Assets" Foreground="#7ECFFF" FontSize="14" VerticalAlignment="Center"/>
                                    <TextBlock Text="  Clear Console" Foreground="White" FontSize="12" FontWeight="SemiBold" VerticalAlignment="Center"/>
                                </StackPanel>
                            </Button>
                        </Grid>
                    </Border>

                    <Border Grid.Row="4"
                            CornerRadius="24"
                            Background="{StaticResource PanelBrush}"
                            BorderBrush="#1B2735"
                            BorderThickness="1">
                        <Grid Margin="22">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="14"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>

                            <StackPanel Grid.Row="0">
                                <TextBlock Text="Live Console"
                                           Foreground="White"
                                           FontSize="22"
                                           FontWeight="SemiBold"/>
                                <TextBlock Text="Real-time execution history and interface events."
                                           Foreground="#8B98AA"
                                           FontSize="12"
                                           Margin="0,6,0,0"/>
                            </StackPanel>

                            <Border Grid.Row="2"
                                    CornerRadius="22"
                                    Background="#050A11"
                                    BorderBrush="#162436"
                                    BorderThickness="1">
                                <TextBox x:Name="LogBox"
                                         Margin="18"
                                         Background="Transparent"
                                         BorderThickness="0"
                                         Foreground="#77D0FF"
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

try {
    $Window = Load-XamlFragment -Xaml $xamlText

    $script:LogBox         = $Window.FindName('LogBox')
    $script:StatusValue    = $Window.FindName('StatusValue')
    $script:StatusText     = $Window.FindName('StatusText')
    $script:ToolStackPanel = $Window.FindName('ToolStackPanel')
    $script:ToolCountValue = $Window.FindName('ToolCountValue')
    $script:LaunchButtonStyle = $Window.Resources['LaunchButtonStyle']

    $HeaderBar       = $Window.FindName('HeaderBar')
    $MinBtn          = $Window.FindName('MinBtn')
    $CloseBtn        = $Window.FindName('CloseBtn')
    $SearchBox       = $Window.FindName('SearchBox')
    $OpenAppDataBtn  = $Window.FindName('OpenAppDataBtn')
    $OpenPrefetchBtn = $Window.FindName('OpenPrefetchBtn')
    $ClearLogBtn     = $Window.FindName('ClearLogBtn')

    Render-ToolCards -ToolList $Tools

    if ($HeaderBar) {
        $HeaderBar.Add_MouseLeftButtonDown({
            try { $Window.DragMove() } catch {}
        })
    }

    if ($MinBtn) {
        $MinBtn.Add_Click({
            $Window.WindowState = 'Minimized'
        })
    }

    if ($CloseBtn) {
        $CloseBtn.Add_Click({
            $Window.Close()
        })
    }

    if ($SearchBox) {
        $SearchBox.Add_TextChanged({
            $filtered = Get-FilteredTools -Query $SearchBox.Text
            Render-ToolCards -ToolList $filtered
        })
    }

    if ($OpenAppDataBtn) {
        $OpenAppDataBtn.Add_Click({
            $tool = $Tools | Where-Object { $_.Name -eq 'Open AppData' } | Select-Object -First 1
            if ($tool) { Invoke-ToolAction -Tool $tool }
        })
    }

    if ($OpenPrefetchBtn) {
        $OpenPrefetchBtn.Add_Click({
            $tool = $Tools | Where-Object { $_.Name -eq 'Open Prefetch' } | Select-Object -First 1
            if ($tool) { Invoke-ToolAction -Tool $tool }
        })
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
    Write-Log 'Stable premium interface loaded.'
    Write-Log 'Ready for tool execution.'
    Set-Status -State 'READY' -Details 'System initialized and ready for command execution.' -Color '#5CF2C5'

    [void]$Window.ShowDialog()
}
catch {
    Write-Error "UI failed to load: $($_.Exception.Message)"
}
