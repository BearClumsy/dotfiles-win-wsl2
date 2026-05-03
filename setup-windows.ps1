# Windows setup script for dotfiles (Alacritty or WezTerm + WSL)
# Run from PowerShell as Administrator:
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#   .\setup-windows.ps1

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- 1. Check winget ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install App Installer from the Microsoft Store and re-run."
    exit 1
}

# --- 2. Choose terminal ---
Write-Host ""
Write-Host "Choose terminal to set up:"
Write-Host "  1) Alacritty         (working configuration)"
Write-Host "  2) WezTerm           (GPU or software rendering)"
Write-Host "  3) Windows Terminal  (recommended for Windows 365 / Cloud PC)"
Write-Host ""
$termChoice = Read-Host "Enter 1, 2 or 3"

if ($termChoice -ne "1" -and $termChoice -ne "2" -and $termChoice -ne "3") {
    Write-Error "Invalid choice '$termChoice'. Run the script again and enter 1, 2 or 3."
    exit 1
}

# --- 3. Install Hack Nerd Font (shared) ---
Write-Host ""
Write-Host "Installing Hack Nerd Font..."
$fontZip = "$env:TEMP\HackNerdFont.zip"
$fontDir = "$env:TEMP\HackNerdFont"
$fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip" -OutFile $fontZip
Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force

if (-not (Test-Path $fontsFolder)) { New-Item -ItemType Directory -Path $fontsFolder | Out-Null }

Get-ChildItem "$fontDir\*.ttf" | ForEach-Object {
    $dest = "$fontsFolder\$($_.Name)"
    if (Test-Path $dest) {
        Write-Host "  Skipping $($_.Name) (already installed)"
    } else {
        Copy-Item $_.FullName $dest -Force
        $regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontName = $_.BaseName + " (TrueType)"
        Set-ItemProperty -Path $regPath -Name $fontName -Value $dest
    }
}

Remove-Item $fontZip, $fontDir -Recurse -Force
Write-Host "Hack Nerd Font installed."

# ===========================================================================
if ($termChoice -eq "1") {
# ===========================================================================
# --- Alacritty setup ---

    Write-Host ""
    Write-Host "Installing Alacritty..."
    winget install --id Alacritty.Alacritty -e --source winget --accept-package-agreements --accept-source-agreements

    Write-Host "Copying Alacritty config..."
    $alacrittyConfigDir = "$env:APPDATA\alacritty"
    if (-not (Test-Path $alacrittyConfigDir)) {
        New-Item -ItemType Directory -Path $alacrittyConfigDir | Out-Null
    }

    $srcConfig = Join-Path $scriptDir "alacritty\alacritty.toml"
    if (Test-Path $srcConfig) {
        Copy-Item $srcConfig "$alacrittyConfigDir\alacritty.toml" -Force
        Write-Host "Alacritty config copied to $alacrittyConfigDir\alacritty.toml"
    } else {
        Write-Warning "alacritty\alacritty.toml not found next to this script. Skipping."
    }

    $terminalName = "Alacritty"

# ===========================================================================
} elseif ($termChoice -eq "2") {
# ===========================================================================
# --- WezTerm setup ---

    Write-Host ""
    Write-Host "Choose your Windows environment for WezTerm:"
    Write-Host "  1) Windows 365 (Cloud PC) + WSL2"
    Write-Host "  2) Native Windows 10 / 11 + WSL2"
    Write-Host ""
    $weztermEnv = Read-Host "Enter 1 or 2"

    if ($weztermEnv -ne "1" -and $weztermEnv -ne "2") {
        Write-Error "Invalid choice '$weztermEnv'. Run the script again and enter 1 or 2."
        exit 1
    }

    Write-Host ""
    Write-Host "Installing WezTerm..."
    winget install --id wez.wezterm -e --source winget --accept-package-agreements --accept-source-agreements

    $weztermConfigDir = "$env:USERPROFILE\.config\wezterm"
    if (-not (Test-Path $weztermConfigDir)) {
        New-Item -ItemType Directory -Path $weztermConfigDir | Out-Null
    }

    if ($weztermEnv -eq "1") {
        $srcLua = Join-Path $scriptDir "wezterm\wezterm-win365.lua"
        $envLabel = "Windows 365 (Software rendering)"
    } else {
        $srcLua = Join-Path $scriptDir "wezterm\wezterm-win10.lua"
        $envLabel = "Native Windows (OpenGL rendering)"
    }

    if (Test-Path $srcLua) {
        Copy-Item $srcLua "$weztermConfigDir\wezterm.lua" -Force
        Write-Host "WezTerm config ($envLabel) copied to $weztermConfigDir\wezterm.lua"
    } else {
        Write-Warning "Source config '$srcLua' not found next to this script. Skipping."
    }

    $terminalName = "WezTerm"

# ===========================================================================
} elseif ($termChoice -eq "3") {
# ===========================================================================
# --- Windows Terminal setup ---

    Write-Host ""
    Write-Host "Choose your Windows environment for Windows Terminal:"
    Write-Host "  1) Windows 365 (Cloud PC) - always Catppuccin Mocha"
    Write-Host "  2) Native Windows 10 / 11 - follows system light/dark theme"
    Write-Host ""
    $wtEnv = Read-Host "Enter 1 or 2"

    if ($wtEnv -ne "1" -and $wtEnv -ne "2") {
        Write-Error "Invalid choice '$wtEnv'. Run the script again and enter 1 or 2."
        exit 1
    }

    Write-Host ""
    Write-Host "Installing Windows Terminal..."
    winget install --id Microsoft.WindowsTerminal -e --source winget --accept-package-agreements --accept-source-agreements

    $wtConfigDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    if (-not (Test-Path $wtConfigDir)) {
        Write-Warning "Windows Terminal config directory not found at $wtConfigDir"
        Write-Warning "Open Windows Terminal once first, then re-run this script."
        exit 1
    }

    if ($wtEnv -eq "1") {
        $srcSettings = Join-Path $scriptDir "windows-terminal\settings-win365.json"
        $envLabel = "Windows 365 (Catppuccin Mocha)"
        Write-Host "Creating Win365 marker in WSL2..."
        wsl.exe -- bash -c "mkdir -p ~/.cache && touch ~/.cache/win365"
    } else {
        $srcSettings = Join-Path $scriptDir "windows-terminal\settings.json"
        $envLabel = "Native Windows (auto light/dark theme)"
        Write-Host "Removing Win365 marker from WSL2 (if present)..."
        wsl.exe -- bash -c "rm -f ~/.cache/win365"
    }

    if (Test-Path $srcSettings) {
        Copy-Item $srcSettings "$wtConfigDir\settings.json" -Force
        Write-Host "Windows Terminal config ($envLabel) copied to $wtConfigDir\settings.json"
    } else {
        Write-Warning "Source config '$srcSettings' not found next to this script. Skipping."
    }

    $terminalName = "Windows Terminal"
}

# --- 4. Check WSL ---
Write-Host ""
$wslCheck = wsl --status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "WSL does not appear to be installed."
    Write-Host "Run in PowerShell (Admin): wsl --install"
    Write-Host "Then reboot and re-run this script."
} else {
    Write-Host "WSL is installed."
    Write-Host ""
    Write-Host "Next: open $terminalName, then inside WSL run:"
    Write-Host "  git clone https://github.com/BearClumsy/dotfiles ~/.dotfiles"
    Write-Host "  bash ~/.dotfiles/setup-linux.sh"
}

Write-Host ""
Write-Host "Done! Open $terminalName to launch WSL."
