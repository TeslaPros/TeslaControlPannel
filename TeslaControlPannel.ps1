Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Xaml

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$AppTitle   = "TeslaProControlCenter"
$AppVersion = "1.0"

$Tools = @(
    @{ Name = 'TeslaPro Macro Finder'; Icon = [char]0xE721; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/TeslaProMacroFinder/main/TeslaProMacroFinder_V3.ps1'')"'; Desc = 'Scans the system for macro-related traces and suspicious activity.'; ButtonType = 'Primary' },
    @{ Name = 'Doomsday Detector';     Icon = [char]0xE7BA; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/DoomsdayDetector/main/DoomsdayClientDetectorV3.ps1'')"'; Desc = 'Launches the Doomsday client detection workflow.'; ButtonType = 'Neutral' },
    @{ Name = 'Habibi Mod Analyzer';   Icon = [char]0xE943; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1)'; Desc = 'Analyzes Minecraft mods using metadata, hashes, and indicators.'; ButtonType = 'Neutral' },
    @{ Name = 'VPN Finder';            Icon = [char]0xE836; Kind = 'Command'; Admin = $true;  Cmd = 'powershell -ExecutionPolicy Bypass -Command "iex (irm ''https://raw.githubusercontent.com/TeslaPros/VPNChecker/main/VPNFinder.ps1'')"'; Desc = 'Searches for active VPN connections and related traces.'; ButtonType = 'Neutral' },
    @{ Name = 'Security Manager';      Icon = [char]0xE756; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/ChxAuDpF)'; Desc = 'Prepares and launches additional security-oriented tooling.'; ButtonType = 'Neutral' },
    @{ Name = 'QuickCheck Scanner';    Icon = [char]0xEC92; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://pastebin.com/raw/HGLwy7XA)'; Desc = 'Fast first-pass scan for registry activity and logs.'; ButtonType = 'Neutral' },
    @{ Name = 'Red Lotus BAM';         Icon = [char]0xECA5; Kind = 'Command'; Admin = $true;  Cmd = 'powershell Set-ExecutionPolicy Bypass -Scope Process; iex (irm https://raw.githubusercontent.com/PureIntent/ScreenShare/main/RedLotusBam.ps1)'; Desc = 'Inspects Windows execution history using BAM data.'; ButtonType = 'Neutral' },
    @{ Name = 'Open AppData';          Icon = [char]0xED25; Kind = 'Folder';  Admin = $false; Path = $env:APPDATA; Desc = 'Opens the local AppData directory.'; ButtonType = 'Neutral' },
    @{ Name = 'Open Prefetch';         Icon = [char]0xE8B7; Kind = 'Folder';  Admin = $false; Path = 'C:\Windows\Prefetch'; Desc = 'Opens the Windows Prefetch directory.'; ButtonType = 'Neutral' }
)

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="$AppTitle"
    Width="1380"
    Height="860"
    MinWidth="1260"
    MinHeight="800"
    WindowStartupLocation="CenterScreen"
    ResizeMode="CanResizeWithGrip"
    WindowStyle="None"
    AllowsTransparency="True"
    Background="Transparent"
    FontFamily="Segoe UI"
    Opacity="1">

    <Window.Resources>
        <LinearGradientBrush x:Key="WindowBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#05070B" Offset="0"/>
            <GradientStop Color="#09111B" Offset="0.46"/>
            <GradientStop Color="#071B27" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="SidebarBackground" StartPoint="0,0" EndPoint="0,1">
            <GradientStop Color="#0B1118" Offset="0"/>
            <GradientStop Color="#0D1520" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="PrimaryButtonBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#39E5FF" Offset="0"/>
            <GradientStop Color="#00A8D8" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="NeutralButtonBrush" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#182332" Offset="0"/>
            <GradientStop Color="#141C27" Offset="1"/>
        </LinearGradientBrush>

        <LinearGradientBrush x:Key="CardBackground" StartPoint="0,0" EndPoint="1,1">
            <GradientStop Color="#101824" Offset="0"/>
            <GradientStop Color="#0B1017" Offset="1"/>
        </LinearGradientBrush>

        <SolidColorBrush x:Key="BorderBrushSoft" Color="#1C2A3C"/>

        <Style x:Key="ActionButtonStyle" TargetType="Button">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Height" Value="56"/>
            <Setter Property="Margin" Value="0,0,0,14"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Background" Value="{StaticResource NeutralButtonBrush}"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="Root"
                                Background="{TemplateBinding Background}"
                                CornerRadius="17"
                                BorderBrush="#203040"
                                BorderThickness="1">
                            <Border.Effect>
                                <DropShadowEffect BlurRadius="18" ShadowDepth="0" Opacity="0.22"/>
                            </Border.Effect>

                            <Grid Margin="16,0,16,0">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="12"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>

                                <Border Width="36"
                                        Height="36"
                                        CornerRadius="11"
                                        Background="#18FFFFFF"
                                        BorderBrush="#24FFFFFF"
                                        BorderThickness="1"
                                        VerticalAlignment="Center">
                                    <TextBlock Text="{TemplateBinding Tag}"
                                               FontFamily="Segoe MDL2 Assets"
                                               FontSize="15"
                                               Foreground="White"
                                               HorizontalAlignment="Center"
                                               VerticalAlignment="Center"/>
                                </Border>

                                <ContentPresenter Grid.Column="2"
                                                  VerticalAlignment="Center"
                                                  RecognizesAccessKey="True"/>
                            </Grid>
                        </Border>

                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="Root" Property="Opacity" Value="0.97"/>
                                <Setter TargetName="Root" Property="BorderBrush" Value="#35D9FF"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="Root" Property="Opacity" Value="0.82"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="Root" Property="Opacity" Value="0.42"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="SmallWindowButtonStyle" TargetType="Button">
            <Setter Property="Width" Value="34"/>
            <Setter Property="Height" Value="34"/>
            <Setter Property="Margin" Value="8,0,0,0"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="16"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Background" Value="#14FFFFFF"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="BtnBorder" Background="{TemplateBinding Background}" CornerRadius="10">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="BtnBorder" Property="Opacity" Value="0.90"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="BtnBorder" Property="Opacity" Value="0.72"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="CardBorderStyle" TargetType="Border">
            <Setter Property="CornerRadius" Value="22"/>
            <Setter Property="Padding" Value="22"/>
            <Setter Property="Background" Value="{StaticResource CardBackground}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrushSoft}"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>

        <Style x:Key="MiniStatStyle" TargetType="Border">
            <Setter Property="CornerRadius" Value="20"/>
            <Setter Property="Padding" Value="18"/>
            <Setter Property="Background" Value="{StaticResource CardBackground}"/>
            <Setter Property="BorderBrush" Value="{StaticResource BorderBrushSoft}"/>
            <Setter Property="BorderThickness" Value="1"/>
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
                                                <Border Width="6" Margin="2,0,2,0" CornerRadius="6" Background="#38526E"/>
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

    <Grid>
        <Border CornerRadius="24" Background="{StaticResource WindowBackground}" BorderBrush="#1D2938" BorderThickness="1">
            <Border.Effect>
                <DropShadowEffect BlurRadius="30" ShadowDepth="0" Opacity="0.45"/>
            </Border.Effect>

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="64"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Ellipse Width="560" Height="560" Fill="#1DDCFF" Opacity="0.06" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="-190,-180,0,0"/>
                <Ellipse Width="430" Height="430" Fill="#0E86FF" Opacity="0.05" HorizontalAlignment="Right" VerticalAlignment="Bottom" Margin="0,0,-120,-130"/>

                <Border x:Name="HeaderBar" Grid.Row="0" Background="#0A0F17" CornerRadius="24,24,0,0" BorderBrush="#162232" BorderThickness="0,0,0,1">
                    <Grid Margin="18,0,18,0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <Border Width="40" Height="40" CornerRadius="13" Background="#101A27" BorderBrush="#23435D" BorderThickness="1">
                                <TextBlock Text="T" FontSize="20" FontWeight="Bold" Foreground="#7BE9FF" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                            <StackPanel Margin="12,0,0,0" VerticalAlignment="Center">
                                <TextBlock Text="$AppTitle" FontSize="18" FontWeight="SemiBold" Foreground="White"/>
                                <TextBlock Text="TeslaPro Security Tools" FontSize="11" Foreground="#7E92A6" Margin="0,2,0,0"/>
                            </StackPanel>
                        </StackPanel>

                        <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button x:Name="InfoButtonTop" Content="ⓘ" Style="{StaticResource SmallWindowButtonStyle}" Background="#163043"/>
                            <Button x:Name="MinButton" Content="—" Style="{StaticResource SmallWindowButtonStyle}"/>
                            <Button x:Name="CloseButton" Content="✕" Style="{StaticResource SmallWindowButtonStyle}" Background="#1F2330"/>
                        </StackPanel>
                    </Grid>
                </Border>

                <Grid Grid.Row="1" Margin="20">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="320"/>
                        <ColumnDefinition Width="20"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <Border Grid.Column="0" Background="{StaticResource SidebarBackground}" CornerRadius="22" BorderBrush="#192537" BorderThickness="1" Padding="20">
                        <Grid>
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="18"/>
                                <RowDefinition Height="*"/>
                                <RowDefinition Height="20"/>
                                <RowDefinition Height="Auto"/>
                            </Grid.RowDefinitions>

                            <StackPanel>
                                <TextBlock Text="Control Center" FontSize="24" FontWeight="SemiBold" Foreground="White"/>
                                <TextBlock Text="Launch scanners, inspectors, and quick-access folders from one clean window." TextWrapping="Wrap" Margin="0,8,0,0" Foreground="#8EA2B6" FontSize="13"/>
                            </StackPanel>

                            <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                                <StackPanel x:Name="ToolButtonPanel"/>
                            </ScrollViewer>

                            <Border Grid.Row="4" Background="#0B1017" CornerRadius="18" Padding="16" BorderBrush="#1B2837" BorderThickness="1">
                                <Border CornerRadius="14" Background="#101722" Padding="12" BorderBrush="#203042" BorderThickness="1">
                                    <Grid>
                                        <Grid.ColumnDefinitions>
                                            <ColumnDefinition Width="*"/>
                                            <ColumnDefinition Width="Auto"/>
                                        </Grid.ColumnDefinitions>

                                        <StackPanel>
                                            <TextBlock Text="Panel Version" Foreground="#7A92A8" FontSize="11"/>
                                            <TextBlock x:Name="VersionText" Text="Version 1.0" Foreground="#74E8FF" FontSize="16" FontWeight="Bold" Margin="0,4,0,0"/>
                                        </StackPanel>

                                        <Border Grid.Column="1" Width="88" Height="30" CornerRadius="15" Background="#122232" BorderBrush="#234760" BorderThickness="1" VerticalAlignment="Center">
                                            <TextBlock x:Name="StateChip" Text="READY" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#74E8FF" FontSize="12" FontWeight="Bold"/>
                                        </Border>
                                    </Grid>
                                </Border>
                            </Border>
                        </Grid>
                    </Border>

                    <Grid Grid.Column="2">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="165"/>
                            <RowDefinition Height="18"/>
                            <RowDefinition Height="150"/>
                            <RowDefinition Height="18"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <Border Grid.Row="0" Style="{StaticResource CardBorderStyle}">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="290"/>
                                </Grid.ColumnDefinitions>

                                <StackPanel>
                                    <TextBlock x:Name="StatusText" Text="Ready" FontSize="30" FontWeight="SemiBold" Foreground="White"/>
                                    <TextBlock x:Name="SubStatusText" Text="Everything is ready. Pick an action on the left." Margin="0,8,0,0" FontSize="14" Foreground="#9DB1C4"/>
                                    <Border Margin="0,18,0,0" CornerRadius="14" Background="#0B121B" Padding="12" BorderBrush="#1A293A" BorderThickness="1">
                                        <TextBlock Text="A cleaner and sharper control center for TeslaPro tools." Foreground="#84A1BA" TextWrapping="Wrap"/>
                                    </Border>
                                </StackPanel>

                                <Border Grid.Column="1" HorizontalAlignment="Right" Width="260" Height="110" CornerRadius="22" Background="#0B1119" BorderBrush="#1E3145" BorderThickness="1">
                                    <Grid Margin="16">
                                        <Grid.RowDefinitions>
                                            <RowDefinition Height="Auto"/>
                                            <RowDefinition Height="*"/>
                                        </Grid.RowDefinitions>
                                        <TextBlock Text="Panel Status" Foreground="#7990A5" FontSize="12"/>
                                        <StackPanel Grid.Row="1" VerticalAlignment="Center">
                                            <TextBlock x:Name="BigChipText" Text="READY" HorizontalAlignment="Center" Foreground="#74E8FF" FontSize="22" FontWeight="Bold"/>
                                            <TextBlock x:Name="FooterText" Text="Idle" HorizontalAlignment="Center" Foreground="#8FA4B8" FontSize="12" Margin="0,6,0,0"/>
                                        </StackPanel>
                                    </Grid>
                                </Border>
                            </Grid>
                        </Border>

                        <Grid Grid.Row="2">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="16"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="16"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>

                            <Border Grid.Column="0" Style="{StaticResource MiniStatStyle}">
                                <StackPanel>
                                    <TextBlock Text="Step" FontSize="12" Foreground="#7C93A8"/>
                                    <TextBlock x:Name="StepText" Text="Waiting" FontSize="22" FontWeight="SemiBold" Foreground="White" Margin="0,8,0,0"/>
                                    <TextBlock Text="Current panel task." Margin="0,6,0,0" Foreground="#8DA3B7" FontSize="12"/>
                                </StackPanel>
                            </Border>

                            <Border Grid.Column="2" Style="{StaticResource MiniStatStyle}">
                                <StackPanel>
                                    <TextBlock Text="Progress" FontSize="12" Foreground="#7C93A8"/>
                                    <TextBlock x:Name="ProgressLabel" Text="0%" FontSize="22" FontWeight="SemiBold" Foreground="White" Margin="0,8,0,0"/>
                                    <TextBlock Text="Overall progress." Margin="0,6,0,0" Foreground="#8DA3B7" FontSize="12"/>
                                </StackPanel>
                            </Border>

                            <Border Grid.Column="4" Style="{StaticResource MiniStatStyle}">
                                <StackPanel>
                                    <TextBlock Text="Available Tools" FontSize="12" Foreground="#7C93A8"/>
                                    <TextBlock x:Name="ToolCountText" Text="0" FontSize="22" FontWeight="SemiBold" Foreground="White" Margin="0,8,0,0"/>
                                    <TextBlock Text="Configured actions in this panel." Margin="0,6,0,0" Foreground="#8DA3B7" FontSize="12"/>
                                </StackPanel>
                            </Border>
                        </Grid>

                        <Border Grid.Row="4" Style="{StaticResource CardBorderStyle}">
                            <Grid>
                                <Grid.RowDefinitions>
                                    <RowDefinition Height="Auto"/>
                                    <RowDefinition Height="16"/>
                                    <RowDefinition Height="12"/>
                                    <RowDefinition Height="18"/>
                                    <RowDefinition Height="*"/>
                                </Grid.RowDefinitions>

                                <Grid>
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>

                                    <StackPanel>
                                        <TextBlock Text="Activity Console" FontSize="22" FontWeight="SemiBold" Foreground="White"/>
                                        <TextBlock Text="Tool output and current status" Foreground="#91A7BB" FontSize="12" Margin="0,6,0,0"/>
                                    </StackPanel>

                                    <Border Grid.Column="1" Width="140" Height="34" HorizontalAlignment="Right" VerticalAlignment="Top" CornerRadius="17" Background="#0B121B" BorderBrush="#203447" BorderThickness="1">
                                        <TextBlock x:Name="MiniStateText" Text="READY" HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="#74E8FF" FontWeight="Bold"/>
                                    </Border>
                                </Grid>

                                <Border Grid.Row="2" CornerRadius="8" Background="#091018" BorderBrush="#1A2B3C" BorderThickness="1">
                                    <ProgressBar x:Name="MainProgressBar" Height="12" Minimum="0" Maximum="100" Value="0" Background="Transparent" Foreground="#22D6FF" BorderThickness="0"/>
                                </Border>

                                <Border Grid.Row="4"
                                        CornerRadius="18"
                                        Background="#091018"
                                        BorderBrush="#1A2B3C"
                                        BorderThickness="1"
                                        Padding="14">
                                    <TextBox x:Name="ActivityBox"
                                             Background="Transparent"
                                             Foreground="#D8E8F5"
                                             BorderThickness="0"
                                             FontFamily="Consolas"
                                             FontSize="13"
                                             IsReadOnly="True"
                                             VerticalScrollBarVisibility="Auto"
                                             HorizontalScrollBarVisibility="Disabled"
                                             TextWrapping="Wrap"
                                             AcceptsReturn="True"/>
                                </Border>
                            </Grid>
                        </Border>
                    </Grid>
                </Grid>
            </Grid>
        </Border>

        <Grid x:Name="InfoRoot" Visibility="Collapsed" Opacity="0" Background="#A0000000">
            <Border Width="620" Padding="24" CornerRadius="22" Background="#0D141D" BorderBrush="#203447" BorderThickness="1" HorizontalAlignment="Center" VerticalAlignment="Center">
                <Border.Effect>
                    <DropShadowEffect BlurRadius="30" ShadowDepth="0" Opacity="0.35"/>
                </Border.Effect>
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="18"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="20"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <Border Width="44" Height="44" CornerRadius="14" Background="#112130" BorderBrush="#28445C" BorderThickness="1">
                            <TextBlock Text="i" HorizontalAlignment="Center" VerticalAlignment="Center" FontSize="21" FontWeight="Bold" Foreground="#74E8FF"/>
                        </Border>

                        <StackPanel Grid.Column="1" Margin="14,0,0,0">
                            <TextBlock Text="About This Panel" FontSize="22" FontWeight="SemiBold" Foreground="White"/>
                            <TextBlock Text="TeslaProControlCenter" Foreground="#8FA4B8" FontSize="12" Margin="0,4,0,0"/>
                        </StackPanel>

                        <Button x:Name="InfoCloseButton" Grid.Column="2" Content="✕" Width="34" Height="34" Style="{StaticResource SmallWindowButtonStyle}" Background="#1F2330"/>
                    </Grid>

                    <StackPanel Grid.Row="2">
                        <Border CornerRadius="16" Background="#0A1018" BorderBrush="#1C2E40" BorderThickness="1" Padding="16">
                            <TextBlock TextWrapping="Wrap" Foreground="#DCE7F2" FontSize="13">
TeslaProControlCenter 1.0

This panel launches TeslaPro tools and quick-access folders from a single clean interface.

Included quick access:
- Open AppData
- Open Prefetch
                            </TextBlock>
                        </Border>
                    </StackPanel>

                    <StackPanel Grid.Row="4" Orientation="Horizontal" HorizontalAlignment="Right">
                        <Button x:Name="InfoOkButton"
                                Tag="&#xE73E;"
                                Content="Close"
                                Style="{StaticResource ActionButtonStyle}"
                                Background="{StaticResource PrimaryButtonBrush}"
                                Width="140"
                                Margin="0"/>
                    </StackPanel>
                </Grid>
            </Border>
        </Grid>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$HeaderBar         = $window.FindName("HeaderBar")
$CloseButton       = $window.FindName("CloseButton")
$MinButton         = $window.FindName("MinButton")
$InfoButtonTop     = $window.FindName("InfoButtonTop")
$ToolButtonPanel   = $window.FindName("ToolButtonPanel")

$StatusText        = $window.FindName("StatusText")
$SubStatusText     = $window.FindName("SubStatusText")
$StateChip         = $window.FindName("StateChip")
$BigChipText       = $window.FindName("BigChipText")
$MiniStateText     = $window.FindName("MiniStateText")
$FooterText        = $window.FindName("FooterText")
$StepText          = $window.FindName("StepText")
$ProgressLabel     = $window.FindName("ProgressLabel")
$ToolCountText     = $window.FindName("ToolCountText")
$MainProgressBar   = $window.FindName("MainProgressBar")
$VersionText       = $window.FindName("VersionText")
$ActivityBox       = $window.FindName("ActivityBox")

$InfoRoot          = $window.FindName("InfoRoot")
$InfoCloseButton   = $window.FindName("InfoCloseButton")
$InfoOkButton      = $window.FindName("InfoOkButton")

$VersionText.Text = "Version $AppVersion"
$ToolCountText.Text = $Tools.Count.ToString()

function Refresh-Ui {
    $window.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
}

function Show-FadeElement {
    param([System.Windows.UIElement]$Element,[int]$DurationMs=180)
    $Element.Visibility = "Visible"
    $Element.Opacity = 0
    $animation = New-Object System.Windows.Media.Animation.DoubleAnimation
    $animation.From = 0
    $animation.To = 1
    $animation.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds($DurationMs))
    $Element.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $animation)
}

function Hide-FadeElement {
    param([System.Windows.UIElement]$Element)
    $Element.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $null)
    $Element.Opacity = 0
    $Element.Visibility = "Collapsed"
}

function Set-ProgressAnimated {
    param([double]$Value,[int]$DurationMs=220)
    if ($Value -lt 0) { $Value = 0 }
    if ($Value -gt 100) { $Value = 100 }

    $animation = New-Object System.Windows.Media.Animation.DoubleAnimation
    $animation.To = $Value
    $animation.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds($DurationMs))
    $animation.EasingFunction = New-Object System.Windows.Media.Animation.QuadraticEase
    $MainProgressBar.BeginAnimation([System.Windows.Controls.ProgressBar]::ValueProperty, $animation)
}

function Set-UiState {
    param(
        [string]$Title,
        [string]$SubTitle,
        [string]$Chip,
        [string]$Step,
        [double]$Progress = 0
    )

    $StatusText.Text    = $Title
    $SubStatusText.Text = $SubTitle
    $StateChip.Text     = $Chip.ToUpper()
    $BigChipText.Text   = $Chip.ToUpper()
    $MiniStateText.Text = $Chip.ToUpper()
    $FooterText.Text    = $Title
    $StepText.Text      = $Step
    $ProgressLabel.Text = ("{0}%" -f [int]$Progress)
    Set-ProgressAnimated $Progress
    Refresh-Ui
}

function Write-Activity {
    param([string]$Text)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $ActivityBox.AppendText("[$timestamp] $Text`r`n")
    $ActivityBox.ScrollToEnd()
    Refresh-Ui
}

function Show-InfoOverlay { Show-FadeElement -Element $InfoRoot -DurationMs 180 }
function Hide-InfoOverlay { Hide-FadeElement -Element $InfoRoot }

function Invoke-ToolAction {
    param($Tool)

    try {
        if ($Tool.Kind -eq 'Folder') {
            Set-UiState "Opening folder" "Launching $($Tool.Name)." "Working" "Folder Access" 35
            Write-Activity "[INFO] Opening folder: $($Tool.Name)"
            Start-Process 'explorer.exe' $Tool.Path
            Set-UiState "Ready" "$($Tool.Name) opened successfully." "Ready" "Completed" 100
            Write-Activity "[OK] Folder opened: $($Tool.Path)"
            return
        }

        Set-UiState "Launching tool" "Starting $($Tool.Name)." "Running" $Tool.Name 45
        Write-Activity "[INFO] Launching: $($Tool.Name)"

        $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $StartInfo.FileName = "cmd.exe"
        $StartInfo.Arguments = "/k $($Tool.Cmd)"
        $StartInfo.UseShellExecute = $true

        if ($Tool.Admin) {
            $StartInfo.Verb = "runas"
        }

        [System.Diagnostics.Process]::Start($StartInfo) | Out-Null

        Set-UiState "Ready" "$($Tool.Name) launched successfully." "Ready" "Completed" 100
        Write-Activity "[OK] Started: $($Tool.Name)"
    }
    catch {
        $message = if ($_.Exception -and $_.Exception.Message) { $_.Exception.Message } else { "Unknown error." }
        Set-UiState "Action failed" $message "Error" "Failed" 0
        Write-Activity "[ERROR] $message"
    }
}

function Add-ToolButton {
    param(
        [Parameter(Mandatory)]$Tool,
        [Parameter(Mandatory)]$Panel
    )

    $button = New-Object System.Windows.Controls.Button
    $button.Style = $window.Resources["ActionButtonStyle"]
    $button.Tag = [string]$Tool.Icon
    $button.Content = $Tool.Name

    switch ($Tool.ButtonType) {
        'Primary' { $button.Background = $window.Resources["PrimaryButtonBrush"] }
        default   { $button.Background = $window.Resources["NeutralButtonBrush"] }
    }

    $button.ToolTip = $Tool.Desc
    $button.Add_Click({ Invoke-ToolAction -Tool $Tool }.GetNewClosure())
    $Panel.Children.Add($button) | Out-Null
}

foreach ($tool in $Tools) {
    Add-ToolButton -Tool $tool -Panel $ToolButtonPanel
}

$HeaderBar.Add_MouseLeftButtonDown({
    try { $window.DragMove() } catch {}
})

$CloseButton.Add_Click({ $window.Close() })
$MinButton.Add_Click({ $window.WindowState = "Minimized" })

$InfoButtonTop.Add_Click({ Show-InfoOverlay })
$InfoCloseButton.Add_Click({ Hide-InfoOverlay })
$InfoOkButton.Add_Click({ Hide-InfoOverlay })

$InfoRoot.Add_MouseDown({
    if ($_.OriginalSource -eq $InfoRoot) {
        Hide-InfoOverlay
    }
})

$window.Add_PreviewKeyDown({
    param($sender, $e)
    if ($InfoRoot.Visibility -eq "Visible" -and $e.Key -eq "Escape") {
        Hide-InfoOverlay
        $e.Handled = $true
    }
})

try {
    $window.Opacity = 0
    $window.Add_ContentRendered({
        $fadeIn = New-Object System.Windows.Media.Animation.DoubleAnimation
        $fadeIn.From = 0
        $fadeIn.To = 1
        $fadeIn.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(220))
        $window.BeginAnimation([System.Windows.Window]::OpacityProperty, $fadeIn)
    })
}
catch {}

Set-UiState "Ready" "Everything is ready. Pick an action on the left." "Ready" "Waiting" 0
Write-Activity "[OK] TeslaProControlCenter started"
Write-Activity "[INFO] Ready"
Write-Activity "[INFO] AppData and Prefetch restored"
Write-Activity "[INFO] Version 1.0 loaded"

$window.ShowDialog() | Out-Null