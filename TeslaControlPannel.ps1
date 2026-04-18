Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ============================================================
# Tesla Control Panel - PREMIUM EDITION
# ============================================================

$AppTitle = 'TESLA CONTROL PANEL'
$Subtitle = 'SYSTEM DIAGNOSTICS & SECURITY'

# Tool definities met bijbehorende Icon-Hex (Segoe MDL2 Assets)
$Tools = @(
    @{ Name = 'TeslaPro Macro Finder'; Icon = '&#xE721;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/TeslaProMacroFinder/main/TeslaProMacroFinder_V3.ps1'')"'; Desc = 'Scant systeem op macro-gerelateerde activiteit.' },
    @{ Name = 'Doomsday Detector';     Icon = '&#xE7BA;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/DoomsdayDetector/main/DoomsdayClientDetectorV3.ps1'')"'; Desc = 'Lanceert de Doomsday Client Detector.' },
    @{ Name = 'Habibi Mod Analyzer';   Icon = '&#xE943;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'; Desc = 'Analyseert Minecraft mods op hashes en metadata.' },
    @{ Name = 'VPN Finder';           Icon = '&#xE836;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/VPNChecker/main/VPNFinder.ps1'')"'; Desc = 'Zoekt naar actieve VPN verbindingen en sporen.' },
    @{ Name = 'Security Manager';     Icon = '&#xE756;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/ChxAuDpF)'; Desc = 'Voorbereiding voor security tooling.' },
    @{ Name = 'QuickCheck Scanner';    Icon = '&#xEC92;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/HGLwy7XA)'; Desc = 'Automated first-look scanner voor registry en logs.' },
    @{ Name = 'Red Lotus BAM';        Icon = '&#xECA5;'; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1)'; Desc = 'Analyseert Windows execution history via BAM data.' },
    @{ Name = 'Open AppData';         Icon = '&#xED25;'; Kind = 'Folder';  Admin = $false; Path = $env:APPDATA; Desc = 'Opent de lokale AppData folder.' },
    @{ Name = 'Open Prefetch';        Icon = '&#xE8B7;'; Kind = 'Folder';  Admin = $false; Path = 'C:\Windows\Prefetch'; Desc = 'Opent de Windows Prefetch folder.' }
)

# -----------------------------
# LOGICA & FUNCTIES
# -----------------------------
function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString('HH:mm:ss')
    $script:LogBox.AppendText("[$timestamp] > $Message" + [Environment]::NewLine)
    $script:LogBox.ScrollToEnd()
}

function Set-Status {
    param([string]$State, [string]$Details, [string]$Color = "#00FFA3")
    $script:StatusValue.Text = $State
    $script:StatusValue.Foreground = $Color
    $script:StatusText.Text = $Details
}

function Invoke-ToolAction {
    param($Tool)
    
    if ($Tool.Kind -eq 'Folder') {
        try {
            Start-Process 'explorer.exe' $Tool.Path
            Write-Log "Folder geopend: $($Tool.Path)"
        } catch { Write-Log "Fout bij openen folder." }
        return
    }

    # Het commando DIRECT uitvoeren als Admin
    try {
        Write-Log "Starten van: $($Tool.Name)..."
        Set-Status -State "EXECUTING" -Details "Wachten op admin permissie..." -Color "#FFCC00"
        
        $Argument = "/k $($Tool.Cmd)"
        $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $StartInfo.FileName = "cmd.exe"
        $StartInfo.Arguments = $Argument
        if ($Tool.Admin) { $StartInfo.Verb = "runas" }

        [System.Diagnostics.Process]::Start($StartInfo) | Out-Null
        
        Write-Log "Succesvol uitgevoerd: $($Tool.Name)"
        Set-Status -State "READY" -Details "Tool draait in extern venster." -Color "#00FFA3"
    }
    catch {
        Write-Log "Fout of geweigerd: $($_.Exception.Message)"
        Set-Status -State "ERROR" -Details "Uitvoering geannuleerd." -Color "#FF4B4B"
    }
}

# -----------------------------
# UI GENERATIE (XAML)
# -----------------------------
$toolCardsXaml = ""
for ($i = 0; $i -lt $Tools.Count; $i++) {
    $t = $Tools[$i]
    $toolCardsXaml += @"
    <Border Margin="0,0,0,12" CornerRadius="12" Background="#121418" BorderBrush="#2A2E36" BorderThickness="1">
        <Grid Padding="10">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="50"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="40"/>
            </Grid.ColumnDefinitions>
            
            <TextBlock Grid.Column="0" Text="$($t.Icon)" FontFamily="Segoe MDL2 Assets" FontSize="24" Foreground="#00A3FF" VerticalAlignment="Center" HorizontalAlignment="Center"/>
            
            <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="10,0,0,0">
                <TextBlock Text="$($t.Name)" FontWeight="Bold" Foreground="White" FontSize="15"/>
                <TextBlock Text="$($t.Desc)" Foreground="#666" FontSize="11" TextWrapping="Wrap"/>
            </StackPanel>

            <Button Name="ToolBtn$i" Grid.Column="2" Content="&#xE768;" FontFamily="Segoe MDL2 Assets" FontSize="16" Background="Transparent" Foreground="#00FFA3" BorderThickness="0" Cursor="Hand" ToolTip="Uitvoeren"/>
        </Grid>
    </Border>
"@
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$AppTitle" Width="1000" Height="700" WindowStartupLocation="CenterScreen" 
        Background="#0A0A0B" WindowStyle="None" AllowsTransparency="True">
    <Border BorderBrush="#1F2229" BorderThickness="1" CornerRadius="20">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="60"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>
            
            <Border Grid.Row="0" Background="#0D0D0F" CornerRadius="20,20,0,0" MouseLeftButtonDown="DragWindow">
                <Grid Margin="20,0">
                    <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                        <TextBlock Text="&#xE950;" FontFamily="Segoe MDL2 Assets" Foreground="#00A3FF" FontSize="20" VerticalAlignment="Center" Margin="0,0,15,0"/>
                        <TextBlock Text="$AppTitle" Foreground="White" FontSize="18" FontWeight="ExtraBold" VerticalAlignment="Center" LetterSpacing="2"/>
                    </StackPanel>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button Name="MinBtn" Content="&#xE921;" FontFamily="Segoe MDL2 Assets" Background="Transparent" Foreground="Gray" Width="40" BorderThickness="0"/>
                        <Button Name="CloseBtn" Content="&#xE8BB;" FontFamily="Segoe MDL2 Assets" Background="Transparent" Foreground="Gray" Width="40" BorderThickness="0"/>
                    </StackPanel>
                </Grid>
            </Border>

            <Grid Grid.Row="1" Margin="20">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="400"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Border Grid.Column="0" Background="#0D0D0F" CornerRadius="15" Padding="15" Margin="0,0,10,0">
                    <DockPanel>
                        <TextBlock DockPanel.Dock="Top" Text="COMMAND CENTER" Foreground="#444" FontSize="10" FontWeight="Bold" Margin="0,0,0,15" LetterSpacing="1"/>
                        <ScrollViewer VerticalScrollBarVisibility="Hidden">
                            <StackPanel> $toolCardsXaml </StackPanel>
                        </ScrollViewer>
                    </DockPanel>
                </Border>

                <Grid Grid.Column="1" Margin="10,0,0,0">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="160"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Border Grid.Row="0" Background="#0D0D0F" CornerRadius="15" Padding="20" Margin="0,0,0,15">
                        <StackPanel>
                            <TextBlock Text="SYSTEM OPERATIONAL STATUS" Foreground="#444" FontSize="10" FontWeight="Bold" Margin="0,0,0,10"/>
                            <TextBlock Name="StatusValue" Text="READY" Foreground="#00FFA3" FontSize="36" FontWeight="Black"/>
                            <TextBlock Name="StatusText" Text="All systems nominal. Waiting for input..." Foreground="#888" FontSize="13" Margin="0,5,0,0"/>
                        </StackPanel>
                    </Border>

                    <Border Grid.Row="1" Background="#050505" CornerRadius="15" BorderBrush="#1A1A1A" BorderThickness="1">
                        <DockPanel Padding="15">
                            <TextBlock DockPanel.Dock="Top" Text="LIVE ACTIVITY LOG" Foreground="#333" FontSize="10" FontWeight="Bold" Margin="0,0,0,10"/>
                            <TextBox Name="LogBox" Background="Transparent" Foreground="#00A3FF" BorderThickness="0" IsReadOnly="True" FontFamily="Consolas" FontSize="12" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
                        </DockPanel>
                    </Border>
                </Grid>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

# -----------------------------
# STARTUP & EVENTS
# -----------------------------
$reader = New-Object System.Xml.XmlNodeReader $xaml
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Elementen koppelen
$script:LogBox = $Window.FindName('LogBox')
$script:StatusValue = $Window.FindName('StatusValue')
$script:StatusText = $Window.FindName('StatusText')

# Venster acties
$Window.Add_MouseLeftButtonDown({ $Window.DragMove() })
$Window.FindName('CloseBtn').Add_Click({ $Window.Close() })
$Window.FindName('MinBtn').Add_Click({ $Window.WindowState = 'Minimized' })

# Tool Buttons koppelen
for ($i = 0; $i -lt $Tools.Count; $i++) {
    $t = $Tools[$i]
    $btn = $Window.FindName("ToolBtn$i")
    $btn.Add_Click({ Invoke-ToolAction -Tool $t }.GetNewClosure())
}

Write-Log "Tesla Premium Control Panel geladen."
Write-Log "Gereed voor veilige admin-uitvoering."

$Window.ShowDialog() | Out-Null
