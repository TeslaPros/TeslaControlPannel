Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$AppTitle   = "TeslaProControlCenter"
$AppVersion = "1.0"

# De uitgebreide lijst met tools inclusief de nieuwe PowerShell History knop
$Tools = @(
    @{ Name = 'TeslaPro Macro Finder'; Icon = [char]0xE721; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/TeslaProMacroFinder/main/TeslaProMacroFinder_V3.ps1'')"'; Desc = 'Scans the system for macro-related traces.'; ButtonType = 'Primary' },
    @{ Name = 'Doomsday Detector';      Icon = [char]0xE7BA; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/DoomsdayDetector/main/DoomsdayClientDetectorV3.ps1'')"'; Desc = 'Launches Doomsday detection.'; ButtonType = 'Neutral' },
    @{ Name = 'Mod Analyser';           Icon = [char]0xE943; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-RestMethod ''https://raw.githubusercontent.com/xkzuto96/xkzutos-mod-analyzer/main/XkzutosModAnalyzer.ps1'')"'; Desc = 'Analyzes Minecraft mods.'; ButtonType = 'Neutral' },
    @{ Name = 'VPN Finder';             Icon = [char]0xE836; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/VPNChecker/main/VPNFinder.ps1'')"'; Desc = 'Searches for active VPN traces.'; ButtonType = 'Neutral' },
    
    # NIEUWE BUTTON
    @{ Name = 'PowerShell History';     Icon = [char]0xE81C; Kind = 'Special'; Admin = $false; Desc = 'Opent PS History en navigeert naar PSReadline map via Alt+R.'; ButtonType = 'Neutral' },

    @{ Name = 'Security Manager';       Icon = [char]0xE756; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/ChxAuDpF)'; Desc = 'Security-oriented tooling.'; ButtonType = 'Neutral' },
    @{ Name = 'QuickCheck Scanner';     Icon = [char]0xEC92; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/HGLwy7XA)'; Desc = 'Fast first-pass scan.'; ButtonType = 'Neutral' },
    @{ Name = 'Red Lotus BAM';          Icon = [char]0xECA5; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1)'; Desc = 'Inspects BAM data.'; ButtonType = 'Neutral' },
    @{ Name = 'Open AppData';           Icon = [char]0xED25; Kind = 'Folder';  Admin = $false; Path = $env:APPDATA; Desc = 'Opens AppData.'; ButtonType = 'Neutral' },
    @{ Name = 'Open Prefetch';          Icon = [char]0xE8B7; Kind = 'Folder';  Admin = $false; Path = 'C:\Windows\Prefetch'; Desc = 'Opens Prefetch.'; ButtonType = 'Neutral' }
)

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="$AppTitle" Width="1380" Height="860" MinWidth="1260" MinHeight="800"
    WindowStartupLocation="CenterScreen" ResizeMode="CanResizeWithGrip"
    WindowStyle="None" AllowsTransparency="True" Background="Transparent" FontFamily="Segoe UI">

    <Window.Resources>
        <LinearGradientBrush x:Key="WindowBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#05070B" Offset="0"/><GradientStop Color="#09111B" Offset="0.46"/><GradientStop Color="#071B27" Offset="1"/>
        </LinearGradientBrush>
        <LinearGradientBrush x:Key="SidebarBackground" StartPoint="0,0" EndPoint="0,1">
            <GradientStop Color="#0B1118" Offset="0"/><GradientStop Color="#0D1520" Offset="1"/>
        </LinearGradientBrush>
        <LinearGradientBrush x:Key="PrimaryButtonBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#39E5FF" Offset="0"/><GradientStop Color="#00A8D8" Offset="1"/>
        </LinearGradientBrush>
        <LinearGradientBrush x:Key="NeutralButtonBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#182332" Offset="0"/><GradientStop Color="#141C27" Offset="1"/>
        </LinearGradientBrush>
        <LinearGradientBrush x:Key="CardBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#101824" Offset="0"/><GradientStop Color="#0B1017" Offset="1"/>
        </LinearGradientBrush>
        <SolidColorBrush x:Key="BorderBrushSoft" Color="#1C2A3C"/>

        <Style x:Key="ActionButtonStyle" TargetType="Button">
            <Setter Property="Foreground" Value="White"/><Setter Property="FontSize" Value="15"/><Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Height" Value="56"/><Setter Property="Margin" Value="0,0,0,14"/><Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Background" Value="{StaticResource NeutralButtonBrush}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Root" Background="{TemplateBinding Background}" CornerRadius="17" BorderBrush="#203040" BorderThickness="1">
                            <Grid Margin="16,0,16,0">
                                <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="12"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                <Border Width="36" Height="36" CornerRadius="11" Background="#18FFFFFF" VerticalAlignment="Center">
                                    <TextBlock Text="{TemplateBinding Tag}" FontFamily="Segoe MDL2 Assets" FontSize="15" Foreground="White" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                </Border>
                                <ContentPresenter Grid.Column="2" VerticalAlignment="Center"/>
                            </Grid>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="SmallWindowButtonStyle" TargetType="Button">
            <Setter Property="Width" Value="34"/><Setter Property="Height" Value="34"/><Setter Property="Foreground" Value="White"/><Setter Property="Background" Value="#14FFFFFF"/><Setter Property="Template">
                <Setter.Value><ControlTemplate TargetType="Button"><Border Background="{TemplateBinding Background}" CornerRadius="10"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border></ControlTemplate></Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="CardBorderStyle" TargetType="Border">
            <Setter Property="CornerRadius" Value="22"/><Setter Property="Padding" Value="22"/><Setter Property="Background" Value="{StaticResource CardBackground}"/><Setter Property="BorderBrush" Value="{StaticResource BorderBrushSoft}"/><Setter Property="BorderThickness" Value="1"/>
        </Style>
        <Style x:Key="MiniStatStyle" TargetType="Border">
            <Setter Property="CornerRadius" Value="20"/><Setter Property="Padding" Value="18"/><Setter Property="Background" Value="{StaticResource CardBackground}"/><Setter Property="BorderBrush" Value="{StaticResource BorderBrushSoft}"/><Setter Property="BorderThickness" Value="1"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Border CornerRadius="24" Background="{StaticResource WindowBackground}" BorderBrush="#1D2938" BorderThickness="1">
            <Grid>
                <Grid.RowDefinitions><RowDefinition Height="64"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                <Border x:Name="HeaderBar" Grid.Row="0" Background="#0A0F17" CornerRadius="24,24,0,0" BorderBrush="#162232" BorderThickness="0,0,0,1">
                    <Grid Margin="18,0,18,0">
                        <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <Border Width="40" Height="40" CornerRadius="13" Background="#101A27" BorderBrush="#23435D" BorderThickness="1"><TextBlock Text="T" FontSize="20" FontWeight="Bold" Foreground="#7BE9FF" HorizontalAlignment="Center" VerticalAlignment="Center"/></Border>
                            <TextBlock Text="$AppTitle" FontSize="18" FontWeight="SemiBold" Foreground="White" Margin="12,0,0,0" VerticalAlignment="Center"/>
                        </StackPanel>
                        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button x:Name="MinButton" Content="—" Style="{StaticResource SmallWindowButtonStyle}" Margin="0,0,8,0"/>
                            <Button x:Name="CloseButton" Content="✕" Style="{StaticResource SmallWindowButtonStyle}" Background="#1F2330"/>
                        </StackPanel>
                    </Grid>
                </Border>

                <Grid Grid.Row="1" Margin="20">
                    <Grid.ColumnDefinitions><ColumnDefinition Width="320"/><ColumnDefinition Width="20"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                    <Border Grid.Column="0" Background="{StaticResource SidebarBackground}" CornerRadius="22" Padding="20">
                        <Grid>
                            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="18"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                            <TextBlock Text="Control Center" FontSize="24" FontWeight="SemiBold" Foreground="White"/>
                            <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto"><StackPanel x:Name="ToolButtonPanel"/></ScrollViewer>
                            <TextBlock Grid.Row="3" x:Name="VersionText" Text="Version 1.0" Foreground="#74E8FF" HorizontalAlignment="Center"/>
                        </Grid>
                    </Border>

                    <Grid Grid.Column="2">
                        <Grid.RowDefinitions><RowDefinition Height="165"/><RowDefinition Height="18"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                        <Border Grid.Row="0" Style="{StaticResource CardBorderStyle}">
                            <StackPanel>
                                <TextBlock x:Name="StatusText" Text="Ready" FontSize="30" FontWeight="SemiBold" Foreground="White"/>
                                <TextBlock x:Name="SubStatusText" Text="Selecteer een actie links." Foreground="#9DB1C4" Margin="0,8,0,0"/>
                            </StackPanel>
                        </Border>
                        <Border Grid.Row="2" Style="{StaticResource CardBorderStyle}">
                            <TextBox x:Name="ActivityBox" Background="Transparent" Foreground="#D8E8F5" BorderThickness="0" FontFamily="Consolas" IsReadOnly="True" VerticalScrollBarVisibility="Auto" TextWrapping="Wrap"/>
                        </Border>
                    </Grid>
                </Grid>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Elementen koppelen
$HeaderBar       = $window.FindName("HeaderBar")
$CloseButton     = $window.FindName("CloseButton")
$MinButton       = $window.FindName("MinButton")
$ToolButtonPanel = $window.FindName("ToolButtonPanel")
$ActivityBox     = $window.FindName("ActivityBox")
$StatusText      = $window.FindName("StatusText")
$SubStatusText   = $window.FindName("SubStatusText")

# Window Controls
$HeaderBar.Add_MouseLeftButtonDown({ $window.DragMove() })
$CloseButton.Add_Click({ $window.Close() })
$MinButton.Add_Click({ $window.WindowState = 'Minimized' })

# Tool Buttons Genereren
foreach ($T in $Tools) {
    $Btn = New-Object System.Windows.Controls.Button
    $Btn.Style = $window.Resources["ActionButtonStyle"]
    $Btn.Content = $T.Name
    $Btn.Tag = $T.Icon
    
    if ($T.ButtonType -eq 'Primary') { $Btn.Background = $window.Resources["PrimaryButtonBrush"] }

    $Btn.Add_Click({
        $ActivityBox.AppendText("`r`n[LOG] Activeren: $($T.Name)...")
        
        if ($T.Name -eq 'PowerShell History') {
            # Specifieke actie voor de History knop
            Start-Process powershell.exe
            Start-Sleep -Milliseconds 800
            $wshell = New-Object -ComObject WScript.Shell
            $wshell.SendKeys("history{ENTER}")
            Start-Sleep -Milliseconds 300
            $wshell.SendKeys("%r") # Alt + R
            Start-Sleep -Milliseconds 300
            $path = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline"
            $wshell.SendKeys($path)
            $wshell.SendKeys("{ENTER}")
            $ActivityBox.AppendText("`r`n[SUCCESS] PowerShell geopend en navigeren voltooid.")
        }
        elseif ($T.Kind -eq 'Command') {
            Start-Process powershell -ArgumentList $T.Cmd -WindowStyle Normal
        }
        elseif ($T.Kind -eq 'Folder') {
            Invoke-Item $T.Path
        }
        $ActivityBox.ScrollToEnd()
    })

    $ToolButtonPanel.Children.Add($Btn)
}

$ActivityBox.Text = "[SYSTEM] TeslaPro Control Center Geladen.`r`n[SYSTEM] Wachtend op input..."
$window.ShowDialog() | Out-Null