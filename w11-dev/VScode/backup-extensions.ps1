# Backup VS Code extensions to JSON

$extensions = code --list-extensions

$json = @{extensions = $extensions} | ConvertTo-Json

$json | Out-File -FilePath extensions.json -Encoding UTF8

Write-Host "Extensions backed up to extensions.json"