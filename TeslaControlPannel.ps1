Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ============================================================
# TeslaProControlCenter - Premium Edition
# Stable WPF Version
# ============================================================

$AppTitle = 'TeslaProControlCenter'

# ------------------------------------------------------------
# Tool definitions
# ------------------------------------------------------------
$Tools = @(
    @{ Name = 'TeslaPro Macro Finder'; Icon = '&#xE721;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/TeslaProMacroFinder/main/TeslaProMacroFinder_V3.ps1'')"'; Desc = 'Scans the system for macro-related traces and suspicious activity.' },
    @{ Name = 'Doomsday Detector';     Icon = '&#xE7BA;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/DoomsdayDetector/main/DoomsdayClientDetectorV3.ps1'')"'; Desc = 'Launches the Doomsday client detection workflow.' },
    @{ Name = 'Habibi Mod Analyzer';   Icon = '&#xE943;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'; Desc = 'Analyzes Minecraft mods using hashes, metadata, and file indicators.' },
    @{ Name = 'VPN Finder';            Icon = '&#xE836;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/VPNChecker/main/VPNFinder.ps1'')"'; Desc = 'Searches for active VPN connections and related traces.' },
    @{ Name = 'Security Manager';      Icon = '&#xE756;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/ChxAuDpF)'; Desc = 'Prepares and launches additional security-related tooling.' },
    @{ Name = 'QuickCheck Scanner';    Icon = '&#xEC92;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/HGLwy7XA)'; Desc = 'Fast first-pass scanner for registry activity and system logs.' },
    @{ Name = 'Red Lotus BAM';         Icon = '&#xECA5;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1)'; Desc = 'Inspects Windows execution history through BAM analysis.' },
    @{ Name = 'Open AppData';          Icon = '&#xED25;'; Kind = 'Folder';  Admin = $false; Path = $env:APPDATA; Desc = 'Opens the local AppData directory.' },
    @{ Name = 'Open Prefetch';         Icon = '&#xE8B7;'; Kind = 'Folder';  Admin = $false; Path = 'C:\Windows\Prefetch'; Desc = 'Opens the Windows Prefetch directory.' }
)

# ------------------------------------------------------------
# Utility functions
# ------------------------------------------------------------
function New-Brush {
    param([string]$Color)
    return ([System.Windows.Media.BrushConverter]::new()).ConvertFromString($Color)
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
        [string]$Color = '#46E6B0'
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
            Set-Status -State 'READY' -Details 'Folder opened successfully.' -Color '#46E6B0'
        }
        catch {
            Write-Log "Failed to open folder: $($_.Exception.Message)"
            Set-Status -State 'ERROR' -Details 'Folder could not be opened.' -Color '#FF5A6A'
        }
        return
    }

    try {
        Write-Log "Launching: $($Tool.Name)"
        Set-Status -State 'EXECUTING' -Details 'Waiting for elevation or process start...' -Color '#FFC857'

        $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $StartInfo.FileName = 'cmd.exe'
        $StartInfo.Arguments = "/k $($Tool.Cmd)"
        $StartInfo.UseShellExecute = $true

        if ($Tool.Admin) {
            $StartInfo.Verb = 'runas'
        }

        [System.Diagnostics.Process]::Start($StartInfo) | Out-Null

        Write-Log "Launched successfully: $($Tool.Name)"
        Set-Status -State 'READY' -Details 'Tool started successfully.' -Color '#46E6B0'
    }
    catch {
        Write-Log "Launch cancelled or failed: $($_.Exception.Message)"
        Set-Status -State 'ERROR' -Details 'Action was cancelled or failed.' -Color '#FF5A6A'
    }
}

# ------------------------------------------------------------
# Build tool cards
# ------------------------------------------------------------
$toolCards = ''

for ($i = 0; $i -lt $Tools.Count; $i++) {
    $t = $Tools[$i]

    $toolCards += @"
    <Border Margin="0,0,0,12"
            CornerRadius="16"
            Background="#141821"
            BorderBrush="#262D39"
            BorderThickness="1">
        <Grid Margin="0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="68"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="78"/>
            </Grid.ColumnDefinitions>

            <Border Grid.Column="0"
                    Margin="12"
                    Width="44"
                    Height="44"
                    CornerRadius="12"
                    Background="#1B2330"
                    BorderBrush="#2B3A4F"
                    BorderThickness="1"
                    HorizontalAlignment="Center"
                    VerticalAlignment="Center">
                <TextBlock Text="$($t.Icon)"
                           FontFamily="Segoe MDL2 Assets"
                           FontSize="20"
                           Foreground="#69C8FF"
                           VerticalAlignment="Center"
                           HorizontalAlignment="Center"/>
            </Border>

            <StackPanel Grid.Column="1" Margin="0,14,12,14" VerticalAlignment="Center">
                <TextBlock Text="$($t.Name)"
                           Foreground="White"
                           FontSize="14"
                           FontWeight="SemiBold"/>
                <TextBlock Text="$($t.Desc)"
                           Foreground="#8C95A5"
                           FontSize="11"
                           TextWrapping="Wrap"
                           Margin="0,5,0,0"/>
            </StackPanel>

            <Button Name="ToolBtn$i"
                    Grid.Column="2"
                    Margin="0,0,14,0"
                    Width="42"
                    Height="42"
                    Content="&#xE768;"
                    FontFamily="Segoe MDL2 Assets"
                    FontSize="14"
                    Cursor="Hand"
                    Style="{StaticResource GlassActionButton}"
                    HorizontalAlignment="Center"
                    VerticalAlignment="Center"/>
        </Grid>
    </Border>
"@
}

# ------------------------------------------------------------
# XAML UI
# ------------------------------------------------------------
$xamlText = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$AppTitle"
        Width="1120"
        Height="760"
        MinWidth="980"
        MinHeight="640"
        WindowStartupLocation="CenterScreen"
        Background="Transparent"
        AllowsTransparency="True"
        WindowStyle="None"
        ResizeMode="CanResizeWithGrip">

    <Window.Resources>

        <SolidColorBrush x:Key="BgOuter" Color="#090B10"/>
        <SolidColorBrush x:Key="BgMain" Color="#0D1017"/>
        <SolidColorBrush x:Key="BgCard" Color="#121722"/>
        <SolidColorBrush x:Key="BgCardSoft" Color="#161C28"/>
        <SolidColorBrush x:Key="BorderSoft" Color="#232B38"/>
        <SolidColorBrush x:Key="BorderBright" Color="#2F3B4E"/>
        <SolidColorBrush x:Key="AccentBlue" Color="#69C8FF"/>
        <SolidColorBrush x:Key="AccentGreen" Color="#46E6B0"/>
        <SolidColorBrush x:Key="AccentGold" Color="#FFC857"/>
        <SolidColorBrush x:Key="TextPrimary" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="TextMuted" Color="#8D98AA"/>
        <SolidColorBrush x:Key="TextSoft" Color="#667287"/>

        <Style x:Key="TitleBarButton" TargetType="Button">
            <Setter Property="Width" Value="38"/>
            <Setter Property="Height" Value="32"/>
            <Setter Property="Margin" Value="4,0,0,0"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#91A0B8"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="FontFamily" Value="Segoe MDL2 Assets"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}" CornerRadius="10">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#18202C"/>
                                <Setter Property="Foreground" Value="White"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#223044"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="GlassActionButton" TargetType="Button">
            <Setter Property="Background" Value="#182434"/>
            <Setter Property="Foreground" Value="#46E6B0"/>
            <Setter Property="BorderBrush" Value="#294056"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="12">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#1F2F44"/>
                                <Setter Property="BorderBrush" Value="#4C84A8"/>
                                <Setter Property="Foreground" Value="#7EF0C5"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter Property="Background" Value="#22364B"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <Border Background="{StaticResource BgOuter}" CornerRadius="24" BorderBrush="#1E2532" BorderThickness="1">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="66"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- Header -->
            <Border Name="Header"
                    Grid.Row="0"
                    Background="#0E121A"
                    CornerRadius="24,24,0,0"
                    BorderBrush="#1B2330"
                    BorderThickness="0,0,0,1">
                <Grid Margin="20,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <Border Width="40"
                                Height="40"
                                CornerRadius="12"
                                Background="#141D29"
                                BorderBrush="#263548"
                                BorderThickness="1"
                                Margin="0,0,14,0">
                            <TextBlock Text="&#xE9CA;"
                                       FontFamily="Segoe MDL2 Assets"
                                       FontSize="18"
                                       Foreground="{StaticResource AccentBlue}"
                                       VerticalAlignment="Center"
                                       HorizontalAlignment="Center"/>
                        </Border>

                        <StackPanel>
                            <TextBlock Text="$AppTitle"
                                       Foreground="White"
                                       FontSize="18"
                                       FontWeight="SemiBold"/>
                            <TextBlock Text="Premium operations dashboard"
                                       Foreground="{StaticResource TextMuted}"
                                       FontSize="11"
                                       Margin="0,2,0,0"/>
                        </StackPanel>
                    </StackPanel>

                    <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                        <Button Name="MinBtn" Content="&#xE921;" Style="{StaticResource TitleBarButton}"/>
                        <Button Name="CloseBtn" Content="&#xE8BB;" Style="{StaticResource TitleBarButton}"/>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- Main -->
            <Grid Grid.Row="1" Margin="20,18,20,20">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="390"/>
                    <ColumnDefinition Width="18"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <!-- Left tools panel -->
                <Border Grid.Column="0"
                        Background="{StaticResource BgMain}"
                        CornerRadius="22"
                        BorderBrush="{StaticResource BorderSoft}"
                        BorderThickness="1">
                    <Grid Margin="18">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="12"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <StackPanel Grid.Row="0">
                            <TextBlock Text="Tool Library"
                                       Foreground="White"
                                       FontSize="17"
                                       FontWeight="SemiBold"/>
                            <TextBlock Text="Launch scanners, inspectors, and quick-access folders."
                                       Foreground="{StaticResource TextMuted}"
                                       FontSize="11"
                                       Margin="0,4,0,0"/>
                        </StackPanel>

                        <ScrollViewer Grid.Row="2"
                                      VerticalScrollBarVisibility="Auto"
                                      HorizontalScrollBarVisibility="Disabled">
                            <StackPanel>
$toolCards
                            </StackPanel>
                        </ScrollViewer>
                    </Grid>
                </Border>

                <!-- Right dashboard -->
                <Grid Grid.Column="2">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="170"/>
                        <RowDefinition Height="16"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- Status / metrics -->
                    <Grid Grid.Row="0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="1.25*"/>
                            <ColumnDefinition Width="14"/>
                            <ColumnDefinition Width="1*"/>
                        </Grid.ColumnDefinitions>

                        <Border Grid.Column="0"
                                Background="{StaticResource BgMain}"
                                CornerRadius="22"
                                BorderBrush="{StaticResource BorderSoft}"
                                BorderThickness="1">
                            <Grid Margin="22">
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="14"/>
                                    <RowDefinition Height="*"/>
                                </Grid.RowDefinitions>

                                <StackPanel>
                                    <TextBlock Text="System State"
                                               Foreground="{StaticResource TextMuted}"
                                               FontSize="11"/>
                                    <TextBlock Name="StatusValue"
                                               Text="READY"
                                               Foreground="{StaticResource AccentGreen}"
                                               FontSize="34"
                                               FontWeight="Bold"
                                               Margin="0,8,0,0"/>
                                    <TextBlock Name="StatusText"
                                               Text="System initialized and ready for command execution."
                                               Foreground="#A0A8B6"
                                               FontSize="12"
                                               Margin="0,6,0,0"/>
                                </StackPanel>
                            </Grid>
                        </Border>

                        <Border Grid.Column="2"
                                Background="{StaticResource BgMain}"
                                CornerRadius="22"
                                BorderBrush="{StaticResource BorderSoft}"
                                BorderThickness="1">
                            <Grid Margin="18">
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="12"/>
                                    <RowDefinition Height="*"/>
                                </Grid.RowDefinitions>

                                <TextBlock Text="Overview"
                                           Foreground="White"
                                           FontSize="15"
                                           FontWeight="SemiBold"/>

                                <UniformGrid Grid.Row="2" Rows="1" Columns="2">
                                    <Border Margin="0,0,8,0"
                                            Background="{StaticResource BgCardSoft}"
                                            CornerRadius="16"
                                            BorderBrush="{StaticResource BorderBright}"
                                            BorderThickness="1">
                                        <StackPanel Margin="14">
                                            <TextBlock Text="TOOLS"
                                                       Foreground="{StaticResource TextSoft}"
                                                       FontSize="10"/>
                                            <TextBlock Text="$($Tools.Count)"
                                                       Foreground="White"
                                                       FontSize="24"
                                                       FontWeight="SemiBold"
                                                       Margin="0,6,0,0"/>
                                        </StackPanel>
                                    </Border>

                                    <Border Margin="8,0,0,0"
                                            Background="{StaticResource BgCardSoft}"
                                            CornerRadius="16"
                                            BorderBrush="{StaticResource BorderBright}"
                                            BorderThickness="1">
                                        <StackPanel Margin="14">
                                            <TextBlock Text="MODE"
                                                       Foreground="{StaticResource TextSoft}"
                                                       FontSize="10"/>
                                            <TextBlock Text="WPF UI"
                                                       Foreground="White"
                                                       FontSize="24"
                                                       FontWeight="SemiBold"
                                                       Margin="0,6,0,0"/>
                                        </StackPanel>
                                    </Border>
                                </UniformGrid>
                            </Grid>
                        </Border>
                    </Grid>

                    <!-- Log panel -->
                    <Border Grid.Row="2"
                            Background="{StaticResource BgMain}"
                            CornerRadius="22"
                            BorderBrush="{StaticResource BorderSoft}"
                            BorderThickness="1">
                        <Grid Margin="20">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="12"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>

                            <DockPanel Grid.Row="0">
                                <StackPanel DockPanel.Dock="Left">
                                    <TextBlock Text="Live Console"
                                               Foreground="White"
                                               FontSize="16"
                                               FontWeight="SemiBold"/>
                                    <TextBlock Text="Real-time activity and launch history."
                                               Foreground="{StaticResource TextMuted}"
                                               FontSize="11"
                                               Margin="0,4,0,0"/>
                                </StackPanel>
                            </DockPanel>

                            <Border Grid.Row="2"
                                    Background="#0A0D13"
                                    CornerRadius="18"
                                    BorderBrush="#1D2632"
                                    BorderThickness="1">
                                <TextBox Name="LogBox"
                                         Background="Transparent"
                                         Foreground="#78CFFF"
                                         BorderThickness="0"
                                         IsReadOnly="True"
                                         FontFamily="Consolas"
                                         FontSize="12"
                                         Margin="16"
                                         TextWrapping="Wrap"
                                         VerticalScrollBarVisibility="Auto"
                                         AcceptsReturn="True"/>
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
# Load and initialize UI
# ------------------------------------------------------------
try {
    [xml]$xaml = $xamlText
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $Window = [Windows.Markup.XamlReader]::Load($reader)

    $script:LogBox      = $Window.FindName('LogBox')
    $script:StatusValue = $Window.FindName('StatusValue')
    $script:StatusText  = $Window.FindName('StatusText')

    $Header   = $Window.FindName('Header')
    $CloseBtn = $Window.FindName('CloseBtn')
    $MinBtn   = $Window.FindName('MinBtn')

    if ($Header) {
        $Header.Add_MouseLeftButtonDown({
            try { $Window.DragMove() } catch {}
        })
    }

    if ($CloseBtn) {
        $CloseBtn.Add_Click({
            $Window.Close()
        })
    }

    if ($MinBtn) {
        $MinBtn.Add_Click({
            $Window.WindowState = 'Minimized'
        })
    }

    for ($i = 0; $i -lt $Tools.Count; $i++) {
        $tool = $Tools[$i]
        $btn  = $Window.FindName("ToolBtn$i")
        if ($btn) {
            $btn.Add_Click({ Invoke-ToolAction -Tool $tool }.GetNewClosure())
        }
    }

    Write-Log 'TeslaProControlCenter initialized.'
    Write-Log 'Premium interface loaded successfully.'
    Set-Status -State 'READY' -Details 'System initialized and ready for command execution.' -Color '#46E6B0'

    [void]$Window.ShowDialog()
}
catch {
    Write-Error "UI failed to load: $($_.Exception.Message)"
}
