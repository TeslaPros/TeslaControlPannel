Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ============================================================
# Tesla Control Panel - PREMIUM EDITION (STABLE V3)
# ============================================================

$AppTitle = 'TESLA CONTROL PANEL'

# Tool definities
$Tools = @(
    @{ Name = 'TeslaPro Macro Finder'; Icon = '&#xE721;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/TeslaProMacroFinder/main/TeslaProMacroFinder_V3.ps1'')"'; Desc = 'Scant systeem op macro-gerelateerde activiteit.' },
    @{ Name = 'Doomsday Detector';     Icon = '&#xE7BA;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/DoomsdayDetector/main/DoomsdayClientDetectorV3.ps1'')"'; Desc = 'Lanceert de Doomsday Client Detector.' },
    @{ Name = 'Habibi Mod Analyzer';   Icon = '&#xE943;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'; Desc = 'Analyseert Minecraft mods op hashes en metadata.' },
    @{ Name = 'VPN Finder';            Icon = '&#xE836;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/VPNChecker/main/VPNFinder.ps1'')"'; Desc = 'Zoekt naar actieve VPN verbindingen en sporen.' },
    @{ Name = 'Security Manager';      Icon = '&#xE756;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/ChxAuDpF)'; Desc = 'Voorbereiding voor security tooling.' },
    @{ Name = 'QuickCheck Scanner';    Icon = '&#xEC92;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/HGLwy7XA)'; Desc = 'Automated first-look scanner voor registry en logs.' },
    @{ Name = 'Red Lotus BAM';         Icon = '&#xECA5;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1)'; Desc = 'Analyseert Windows execution history via BAM data.' },
    @{ Name = 'Open AppData';          Icon = '&#xED25;'; Kind = 'Folder';  Admin = $false; Path = $env:APPDATA; Desc = 'Opent de lokale AppData folder.' },
    @{ Name = 'Open Prefetch';         Icon = '&#xE8B7;'; Kind = 'Folder';  Admin = $false; Path = 'C:\Windows\Prefetch'; Desc = 'Opent de Windows Prefetch folder.' }
)

function Write-Log {
    param([string]$Message)
    if ($script:LogBox) {
        $timestamp = (Get-Date).ToString('HH:mm:ss')
        $script:LogBox.AppendText("[$timestamp] > $Message" + [Environment]::NewLine)
        $script:LogBox.ScrollToEnd()
    }
}

function Set-Status {
    param(
        [string]$State,
        [string]$Details,
        [string]$Color = "#00FFA3"
    )

    if ($script:StatusValue) {
        $script:StatusValue.Text = $State
        $script:StatusValue.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($Color)
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
            Write-Log "Folder geopend: $($Tool.Path)"
            Set-Status -State "READY" -Details "Folder geopend." -Color "#00FFA3"
        }
        catch {
            Write-Log "Fout bij openen folder: $($_.Exception.Message)"
            Set-Status -State "ERROR" -Details "Folder kon niet geopend worden." -Color "#FF4B4B"
        }
        return
    }

    try {
        Write-Log "Starten van: $($Tool.Name)..."
        Set-Status -State "EXECUTING" -Details "Wachten op admin..." -Color "#FFCC00"

        $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $StartInfo.FileName = "cmd.exe"
        $StartInfo.Arguments = "/k $($Tool.Cmd)"
        $StartInfo.UseShellExecute = $true

        if ($Tool.Admin) {
            $StartInfo.Verb = "runas"
        }

        [System.Diagnostics.Process]::Start($StartInfo) | Out-Null
        Write-Log "Tool gestart: $($Tool.Name)"
        Set-Status -State "READY" -Details "Tool actief." -Color "#00FFA3"
    }
    catch {
        Write-Log "Fout/Geweigerd: $($_.Exception.Message)"
        Set-Status -State "ERROR" -Details "Actie geannuleerd." -Color "#FF4B4B"
    }
}

$toolCards = ""
for ($i = 0; $i -lt $Tools.Count; $i++) {
    $t = $Tools[$i]
    $toolCards += @"
    <Border Margin="0,0,0,10" CornerRadius="10" Background="#121418" BorderBrush="#2A2E36" BorderThickness="1">
        <Grid Padding="10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="40"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="40"/>
            </Grid.ColumnDefinitions>

            <TextBlock Grid.Column="0"
                       Text="$($t.Icon)"
                       FontFamily="Segoe MDL2 Assets"
                       FontSize="20"
                       Foreground="#00A3FF"
                       VerticalAlignment="Center"
                       HorizontalAlignment="Center"/>

            <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="10,0">
                <TextBlock Text="$($t.Name)"
                           FontWeight="Bold"
                           Foreground="White"
                           FontSize="14"/>
                <TextBlock Text="$($t.Desc)"
                           Foreground="#666666"
                           FontSize="10"
                           TextWrapping="Wrap"/>
            </StackPanel>

            <Button Name="ToolBtn$i"
                    Grid.Column="2"
                    Content="&#xE768;"
                    FontFamily="Segoe MDL2 Assets"
                    FontSize="14"
                    Background="Transparent"
                    Foreground="#00FFA3"
                    BorderThickness="0"
                    Cursor="Hand"/>
        </Grid>
    </Border>
"@
}

$xamlText = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$AppTitle"
        Width="950"
        Height="650"
        WindowStartupLocation="CenterScreen"
        Background="#0A0A0B"
        WindowStyle="None"
        AllowsTransparency="True">
    <Border BorderBrush="#1F2229" BorderThickness="1" CornerRadius="15">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="50"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <Border Name="Header" Grid.Row="0" Background="#0D0D0F" CornerRadius="15,15,0,0">
                <Grid Margin="15,0">
                    <TextBlock Text="&#xE950;  $AppTitle"
                               FontFamily="Segoe MDL2 Assets"
                               Foreground="#00A3FF"
                               FontSize="16"
                               FontWeight="Bold"
                               VerticalAlignment="Center"/>

                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button Name="MinBtn"
                                Content="&#xE921;"
                                FontFamily="Segoe MDL2 Assets"
                                Background="Transparent"
                                Foreground="Gray"
                                Width="35"
                                BorderThickness="0"/>
                        <Button Name="CloseBtn"
                                Content="&#xE8BB;"
                                FontFamily="Segoe MDL2 Assets"
                                Background="Transparent"
                                Foreground="Gray"
                                Width="35"
                                BorderThickness="0"/>
                    </StackPanel>
                </Grid>
            </Border>

            <Grid Grid.Row="1" Margin="15">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="350"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Border Grid.Column="0" Background="#0D0D0F" CornerRadius="10" Padding="10" Margin="0,0,10,0">
                    <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                        <StackPanel>
$toolCards
                        </StackPanel>
                    </ScrollViewer>
                </Border>

                <Grid Grid.Column="1">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="130"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0" Background="#0D0D0F" CornerRadius="10" Padding="15" Margin="0,0,0,10">
                        <StackPanel>
                            <TextBlock Name="StatusValue"
                                       Text="READY"
                                       Foreground="#00FFA3"
                                       FontSize="28"
                                       FontWeight="Black"/>
                            <TextBlock Name="StatusText"
                                       Text="Systeem gereed voor gebruik."
                                       Foreground="#888888"
                                       FontSize="12"/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Row="1" Background="#050505" CornerRadius="10" BorderBrush="#1A1A1A" BorderThickness="1">
                        <TextBox Name="LogBox"
                                 Background="Transparent"
                                 Foreground="#00A3FF"
                                 BorderThickness="0"
                                 IsReadOnly="True"
                                 FontFamily="Consolas"
                                 FontSize="11"
                                 Margin="10"
                                 TextWrapping="Wrap"
                                 VerticalScrollBarVisibility="Auto"
                                 AcceptsReturn="True"/>
                    </Border>
                </Grid>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

# Niet-WPF properties strippen voor zekerheid
$xamlText = $xamlText `
    -replace '\s+LetterSpacing="[^"]*"', '' `
    -replace '\s+CharacterSpacing="[^"]*"', '' `
    -replace '\s+TextWrappingMode="[^"]*"', '' `
    -replace '\s+CornerRadius="[^"]*"', ' CornerRadius="10"'

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
        $btn = $Window.FindName("ToolBtn$i")
        if ($btn) {
            $btn.Add_Click({ Invoke-ToolAction -Tool $tool }.GetNewClosure())
        }
    }

    Write-Log "Tesla Panel online."
    Set-Status -State "READY" -Details "Systeem gereed voor gebruik." -Color "#00FFA3"
    [void]$Window.ShowDialog()
}
catch {
    Write-Error "Fout bij laden van UI: $($_.Exception.Message)"
}
