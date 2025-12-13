# Install VS Code extensions from JSON

$json = Get-Content extensions.json | ConvertFrom-Json

foreach ($ext in $json.extensions) {

    Write-Host "Installing $ext..."

    code --install-extension $ext

}

Write-Host "Extensions installation complete."