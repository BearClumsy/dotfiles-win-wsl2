# Windows uninstall script for dotfiles terminals
# Run from PowerShell as Administrator:
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#   .\uninstall-windows.ps1

$ErrorActionPreference = "Stop"

# --- 1. Choose what to uninstall ---
Write-Host ""
Write-Host "Choose what to uninstall:"
Write-Host "  1) Alacritty"
Write-Host "  2) WezTerm"
Write-Host "  3) Windows Terminal (restore default settings)"
Write-Host ""
$choice = Read-Host "Enter 1, 2 or 3"

if ($choice -ne "1" -and $choice -ne "2" -and $choice -ne "3") {
    Write-Error "Invalid choice '$choice'. Run the script again and enter 1, 2 or 3."
    exit 1
}

if ($choice -eq "1") {

    Write-Host ""
    Write-Host "Uninstalling Alacritty..."
    winget uninstall --id Alacritty.Alacritty -e

    $configDir = "$env:APPDATA\alacritty"
    if (Test-Path $configDir) {
        Remove-Item -Recurse -Force $configDir
        Write-Host "Removed config: $configDir"
    }

    Write-Host "Alacritty uninstalled."

} elseif ($choice -eq "2") {

    Write-Host ""
    Write-Host "Uninstalling WezTerm..."
    winget uninstall --id wez.wezterm -e

    $configDir = "$env:USERPROFILE\.config\wezterm"
    if (Test-Path $configDir) {
        Remove-Item -Recurse -Force $configDir
        Write-Host "Removed config: $configDir"
    }

    Write-Host "WezTerm uninstalled."

} else {

    Write-Host ""
    Write-Host "Restoring Windows Terminal default settings..."

    $wtConfigDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $settingsFile = "$wtConfigDir\settings.json"

    if (Test-Path $settingsFile) {
        Remove-Item -Force $settingsFile
        Write-Host "Removed settings.json - Windows Terminal will regenerate defaults on next launch."
    } else {
        Write-Host "No settings.json found at $settingsFile, nothing to restore."
    }

    Write-Host "Windows Terminal settings restored to defaults."

}

Write-Host ""
Write-Host "Done."
