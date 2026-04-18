Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# ============================================================
# Tesla Control Pannel
# Safe single-file launcher with Tesla-style UI
# - Uses uploaded docs as button sources
# - Shows custom info popups
# - Copies reviewed commands to clipboard
# - Opens AppData / Prefetch locally
# ============================================================

$AppTitle = 'Tesla Control Pannel'
$Subtitle = 'Tool Launcher'

# -----------------------------
# Tool definitions from uploads
# -----------------------------
$Tools = @(
    @{
        Name = 'TeslaPro Macro Finder'
        Kind = 'DocumentCommand'
        RequiresAdmin = $false
        KeepCmdOpen = $true
        Description = 'Scans for macro-related activity on the system.'
        Command = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/TeslaProMacroFinder/main/TeslaProMacroFinder_V3.ps1'')"'
    },
    @{
        Name = 'Doomsday Detector'
        Kind = 'DocumentCommand'
        RequiresAdmin = $true
        KeepCmdOpen = $true
        Description = 'Runs the Doomsday Client Detector from an elevated command prompt.'
        Command = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/DoomsdayDetector/main/DoomsdayClientDetectorV3.ps1'')"'
    },
    @{
        Name = 'Habibi Mod Analyzer'
        Kind = 'DocumentCommand'
        RequiresAdmin = $true
        KeepCmdOpen = $true
        Description = 'Analyzes Minecraft mods, checks hashes, strings, and download origin metadata.'
        Command = 'powershell Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass && powershell Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'
    },
    @{
        Name = 'VPN Finder'
        Kind = 'DocumentCommand'
        RequiresAdmin = $true
        KeepCmdOpen = $true
        Description = 'Checks for active VPN connections and related system traces.'
        Command = 'powershell -ExecutionPolicy Bypass -Command "Invoke-Expression (Invoke-RestMethod ''https://raw.githubusercontent.com/TeslaPros/VPNChecker/main/VPNFinder.ps1'')"'
    },
    @{
        Name = 'Windows Defender Manager'
        Kind = 'DocumentCommand'
        RequiresAdmin = $true
        KeepCmdOpen = $true
        Description = 'Preparation step for security tooling as described in the uploaded guide.'
        Command = 'powershell Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass && powershell Invoke-Expression (Invoke-RestMethod https://pastebin.com/raw/ChxAuDpF)'
    },
    @{
        Name = 'QuickCheck'
        Kind = 'DocumentCommand'
        RequiresAdmin = $true
        KeepCmdOpen = $true
        Description = 'Automated first-look scanner for services, registry integrity, event logs, prefetch, and persistence.'
        Command = 'powershell Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass && powershell Invoke-Expression (Invoke-RestMethod https://pastebin.com/raw/HGLwy7XA)'
    },
    @{
        Name = 'Red Lotus BAM'
        Kind = 'DocumentCommand'
        RequiresAdmin = $true
        KeepCmdOpen = $true
        Description = 'Analyzes Windows execution history using BAM registry data and signature checks.'
        Command = 'powershell Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass && powershell Invoke-Expression (Invoke-RestMethod https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1)'
    },
    @{
        Name = 'Open AppData'
        Kind = 'Folder'
        RequiresAdmin = $false
        KeepCmdOpen = $false
        Description = 'Opens the current user AppData folder in File Explorer.'
        Path = $env:APPDATA
    },
    @{
        Name = 'Open Prefetch'
        Kind = 'Folder'
        RequiresAdmin = $false
        KeepCmdOpen = $false
        Description = 'Opens the Windows Prefetch folder in File Explorer.'
        Path = 'C:\Windows\Prefetch'
    }
)

# -----------------------------
# Helpers
# -----------------------------
function Write-Log {
    param([string]$Message)

    $timestamp = (Get-Date).ToString('HH:mm:ss')
    $line = "[$timestamp] $Message"
    $script:LogBox.AppendText($line + [Environment]::NewLine)
    $script:LogBox.ScrollToEnd()
}

function Set-Status {
    param(
        [string]$State,
        [string]$Details
    )

    $script:StatusValue.Text = $State
    $script:StatusText.Text = $Details
}

function Copy-TextToClipboard {
    param([string]$Text)
    try {
        [System.Windows.Forms.Clipboard]::SetText($Text)
        Write-Log "Copied command to clipboard."
        Set-Status -State 'READY' -Details 'Command copied to clipboard.'
    }
    catch {
        Write-Log "Clipboard copy failed: $($_.Exception.Message)"
        Set-Status -State 'ERROR' -Details 'Clipboard copy failed.'
    }
}

function Open-FolderAction {
    param([string]$Path)
    try {
        Start-Process 'explorer.exe' $Path | Out-Null
        Write-Log "Opened folder: $Path"
        Set-Status -State 'READY' -Details "Opened: $Path"
    }
    catch {
        Write-Log "Failed to open folder: $($_.Exception.Message)"
        Set-Status -State 'ERROR' -Details 'Could not open folder.'
    }
}

function Show-ToastPopup {
    param(
        [string]$Title,
        [string]$Message
    )

[xml]$popupXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$Title"
        Width="520"
        Height="320"
        WindowStartupLocation="CenterOwner"
        ResizeMode="NoResize"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Foreground="White"
        ShowInTaskbar="False">
    <Border CornerRadius="24" Background="#081321" BorderBrush="#1E5E90" BorderThickness="1.4" Padding="18">
        <Grid>
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
                <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="40"/>
                </Grid.ColumnDefinitions>

                <StackPanel Orientation="Horizontal">
                    <Border Width="36" Height="36" CornerRadius="10" Background="#0F2137" BorderBrush="#1DAEFF" BorderThickness="1">
                        <TextBlock Text="i" Foreground="#8FE6FF" FontSize="18" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center" TextAlignment="Center" Margin="0,4,0,0"/>
                    </Border>
                    <StackPanel Margin="12,0,0,0">
                        <TextBlock Text="$Title" FontSize="20" FontWeight="SemiBold" Foreground="White"/>
                        <TextBlock Text="Tesla Control Pannel" FontSize="12" Foreground="#8FA5BC"/>
                    </StackPanel>
                </StackPanel>

                <Button Name="ClosePopupButton" Grid.Column="1" Width="32" Height="32" Content="✕" Background="#13263B" Foreground="White" BorderBrush="#224A6B" Cursor="Hand"/>
            </Grid>

            <Border Grid.Row="1" Margin="0,18,0,18" CornerRadius="16" Background="#0C1A2A" BorderBrush="#173751" BorderThickness="1" Padding="14">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                    <TextBlock Name="PopupMessageText" TextWrapping="Wrap" Foreground="#D7E7F6" FontSize="14"/>
                </ScrollViewer>
            </Border>

            <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right">
                <Button Name="OkPopupButton" Content="Close" Width="120" Height="38" Background="#102A44" Foreground="White" BorderBrush="#1DAEFF" Cursor="Hand"/>
            </StackPanel>
        </Grid>
    </Border>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $popupXaml
    $popup = [Windows.Markup.XamlReader]::Load($reader)
    $popup.Owner = $script:MainWindow

    $closeButton = $popup.FindName('ClosePopupButton')
    $okButton = $popup.FindName('OkPopupButton')
    $textBlock = $popup.FindName('PopupMessageText')

    $textBlock.Text = $Message
    $closeButton.Add_Click({ $popup.Close() })
    $okButton.Add_Click({ $popup.Close() })

    $popup.ShowDialog() | Out-Null
}

function Show-ToolPopup {
    param($Tool)

    $commandBlock = if ($Tool.Kind -eq 'DocumentCommand') {
        $Tool.Command
    }
    elseif ($Tool.Kind -eq 'Folder') {
        $Tool.Path
    }
    else {
        ''
    }

    $adminText = if ($Tool.RequiresAdmin) { 'Yes' } else { 'No' }
    $keepOpenText = if ($Tool.KeepCmdOpen) { 'Yes' } else { 'No' }

    $message = @"
Name: $($Tool.Name)

Description:
$($Tool.Description)

Requires Admin: $adminText
Keep CMD Open: $keepOpenText

Action:
$commandBlock
"@

    Show-ToastPopup -Title $Tool.Name -Message $message
    Write-Log "Viewed info for: $($Tool.Name)"
    Set-Status -State 'READY' -Details "Viewed info for $($Tool.Name)."
}

function Invoke-ToolAction {
    param($Tool)

    switch ($Tool.Kind) {
        'Folder' {
            Open-FolderAction -Path $Tool.Path
        }
        'DocumentCommand' {
            Copy-TextToClipboard -Text $Tool.Command
            Show-ToastPopup -Title $Tool.Name -Message "The command for this tool has been copied to your clipboard for manual review and use.`n`nDescription:`n$($Tool.Description)"
            Write-Log "Prepared command for: $($Tool.Name)"
            Set-Status -State 'READY' -Details "Command copied for $($Tool.Name)."
        }
        default {
            Write-Log 'Unknown tool action.'
            Set-Status -State 'ERROR' -Details 'Unknown tool action.'
        }
    }
}

# -----------------------------
# UI generation
# -----------------------------
$toolCardsXaml = ''
for ($i = 0; $i -lt $Tools.Count; $i++) {
    $tool = $Tools[$i]
    $toolCardsXaml += @"
<Border Margin="0,0,0,14" CornerRadius="20" Background="#0D1828" BorderBrush="#173751" BorderThickness="1" Padding="14">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="42"/>
        </Grid.ColumnDefinitions>
        <Button Name="ToolButton$i"
                Grid.Column="0"
                Height="64"
                Margin="0,0,10,0"
                Content="$($tool.Name)"
                Cursor="Hand"
                Background="#102033"
                Foreground="White"
                BorderBrush="#1F5D8F"
                BorderThickness="1.2"
                FontSize="18"
                FontWeight="SemiBold"/>
        <Button Name="InfoButton$i"
                Grid.Column="1"
                Width="34"
                Height="34"
                HorizontalAlignment="Right"
                VerticalAlignment="Top"
                Content="i"
                Cursor="Hand"
                Background="#0F2137"
                Foreground="#8FE6FF"
                BorderBrush="#1F5D8F"
                BorderThickness="1"
                FontSize="15"
                FontWeight="Bold"/>
    </Grid>
</Border>
"@
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="$AppTitle"
        Width="1460"
        Height="920"
        WindowStartupLocation="CenterScreen"
        ResizeMode="CanResize"
        Background="#050B16"
        Foreground="White">
    <Grid>
        <Grid.Background>
            <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                <GradientStop Color="#050B16" Offset="0"/>
                <GradientStop Color="#081529" Offset="0.45"/>
                <GradientStop Color="#041120" Offset="1"/>
            </LinearGradientBrush>
        </Grid.Background>

        <Grid.RowDefinitions>
            <RowDefinition Height="82"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="#0A1322" BorderBrush="#16324A" BorderThickness="0,0,0,1">
            <Grid Margin="18,0,18,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="180"/>
                </Grid.ColumnDefinitions>

                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <Border Width="44" Height="44" CornerRadius="12" Background="#0F2137" BorderBrush="#1DAEFF" BorderThickness="1">
                        <TextBlock Text="T" FontSize="20" FontWeight="Bold" Foreground="#8FE6FF" HorizontalAlignment="Center" VerticalAlignment="Center" TextAlignment="Center" Margin="0,6,0,0"/>
                    </Border>
                    <StackPanel Margin="14,0,0,0">
                        <TextBlock Text="$AppTitle" FontSize="22" FontWeight="SemiBold" Foreground="White"/>
                        <TextBlock Text="$Subtitle" FontSize="12" Foreground="#8FA5BC"/>
                    </StackPanel>
                </StackPanel>

                <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                    <Button Name="TopInfoButton" Content="i" Width="40" Height="40" Margin="0,0,10,0" Background="#13263B" Foreground="White" BorderBrush="#1F3B56" Cursor="Hand"/>
                    <Button Name="MinimizeButton" Content="—" Width="40" Height="40" Margin="0,0,10,0" Background="#13263B" Foreground="White" BorderBrush="#1F3B56" Cursor="Hand"/>
                    <Button Name="CloseButton" Content="✕" Width="40" Height="40" Background="#1A2231" Foreground="White" BorderBrush="#3D4A5E" Cursor="Hand"/>
                </StackPanel>
            </Grid>
        </Border>

        <Grid Grid.Row="1" Margin="18">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="360"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <Border Grid.Column="0" CornerRadius="26" Padding="18" Margin="0,0,16,0" Background="#08111E" BorderBrush="#15324C" BorderThickness="1.2">
                <DockPanel>
                    <StackPanel DockPanel.Dock="Top">
                        <TextBlock Text="TOOL ACTIONS" FontSize="13" FontWeight="Bold" Foreground="#7FB4D6" Margin="4,0,0,14"/>
                    </StackPanel>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel>
                            $toolCardsXaml
                        </StackPanel>
                    </ScrollViewer>
                </DockPanel>
            </Border>

            <Grid Grid.Column="1">
                <Grid.RowDefinitions>
                    <RowDefinition Height="150"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Border Grid.Row="0" Grid.Column="0" CornerRadius="24" Background="#0A1322" BorderBrush="#173751" BorderThickness="1" Margin="0,0,16,16" Padding="18">
                    <StackPanel>
                        <TextBlock Text="SYSTEM STATUS" Foreground="#7FB4D6" FontSize="13" FontWeight="Bold"/>
                        <TextBlock Name="StatusValue" Text="READY" FontSize="32" FontWeight="Bold" Foreground="#73F0A8" Margin="0,10,0,4"/>
                        <TextBlock Name="StatusText" Text="Launcher initialized." Foreground="#D7E7F6" FontSize="14" TextWrapping="Wrap"/>
                    </StackPanel>
                </Border>

                <Border Grid.Row="0" Grid.Column="1" CornerRadius="24" Background="#0A1322" BorderBrush="#173751" BorderThickness="1" Margin="0,0,0,16" Padding="18">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>
                        <TextBlock Text="QUICK NOTES" Foreground="#7FB4D6" FontSize="13" FontWeight="Bold"/>
                        <TextBlock Grid.Row="1" Margin="0,10,0,0" Foreground="#D7E7F6" FontSize="14" TextWrapping="Wrap"
                                   Text="Main button: performs the safe action. Info button: opens a custom popup with details."/>
                        <ProgressBar Grid.Row="2" Margin="0,16,0,0" Height="14" Minimum="0" Maximum="100" Value="100"/>
                    </Grid>
                </Border>

                <Border Grid.Row="1" Grid.ColumnSpan="2" CornerRadius="24" Background="#0A1322" BorderBrush="#173751" BorderThickness="1" Padding="18">
                    <Grid>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <TextBlock Text="ACTIVITY LOG" Foreground="#7FB4D6" FontSize="13" FontWeight="Bold"/>
                        <TextBox Name="LogBox"
                                 Grid.Row="1"
                                 Margin="0,14,0,14"
                                 Background="#08111E"
                                 Foreground="#D7E7F6"
                                 BorderBrush="#173751"
                                 BorderThickness="1"
                                 FontFamily="Consolas"
                                 FontSize="13"
                                 IsReadOnly="True"
                                 AcceptsReturn="True"
                                 VerticalScrollBarVisibility="Auto"
                                 TextWrapping="Wrap"/>
                        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right">
                            <Button Name="ClearLogButton" Content="Clear Log" Width="120" Height="38" Margin="0,0,10,0" Background="#13263B" Foreground="White" BorderBrush="#224A6B" Cursor="Hand"/>
                            <Button Name="AboutButton" Content="About" Width="120" Height="38" Background="#102A44" Foreground="White" BorderBrush="#1DAEFF" Cursor="Hand"/>
                        </StackPanel>
                    </Grid>
                </Border>
            </Grid>
        </Grid>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$MainWindow = [Windows.Markup.XamlReader]::Load($reader)
$script:MainWindow = $MainWindow
$script:LogBox = $MainWindow.FindName('LogBox')
$script:StatusValue = $MainWindow.FindName('StatusValue')
$script:StatusText = $MainWindow.FindName('StatusText')

# Top bar buttons
$TopInfoButton = $MainWindow.FindName('TopInfoButton')
$MinimizeButton = $MainWindow.FindName('MinimizeButton')
$CloseButton = $MainWindow.FindName('CloseButton')
$ClearLogButton = $MainWindow.FindName('ClearLogButton')
$AboutButton = $MainWindow.FindName('AboutButton')

$TopInfoButton.Add_Click({
    Show-ToastPopup -Title 'Information' -Message 'Tesla Control Pannel is a single-file PowerShell launcher with a Tesla-style interface, custom info popups, local folder actions, and clipboard-ready reviewed commands.'
})
$MinimizeButton.Add_Click({ $MainWindow.WindowState = 'Minimized' })
$CloseButton.Add_Click({ $MainWindow.Close() })
$ClearLogButton.Add_Click({
    $script:LogBox.Clear()
    Write-Log 'Log cleared.'
    Set-Status -State 'READY' -Details 'Log cleared.'
})
$AboutButton.Add_Click({
    Show-ToastPopup -Title 'About' -Message 'Buttons were created from your uploaded tool documents plus AppData and Prefetch shortcuts. Main button performs a safe action. Info button explains the tool.'
})

# Tool button events
for ($i = 0; $i -lt $Tools.Count; $i++) {
    $tool = $Tools[$i]
    $toolButton = $MainWindow.FindName("ToolButton$i")
    $infoButton = $MainWindow.FindName("InfoButton$i")

    $toolButton.Add_Click({
        Invoke-ToolAction -Tool $tool
    }.GetNewClosure())

    $infoButton.Add_Click({
        Show-ToolPopup -Tool $tool
    }.GetNewClosure())
}

Write-Log 'Launcher initialized.'
Write-Log 'Loaded tool buttons from uploaded documents.'
Set-Status -State 'READY' -Details 'Launcher initialized and ready.'

$MainWindow.ShowDialog() | Out-Null
