# Run this when you download a new .pem file from AWS
# Usage: .\fix-pem.ps1 C:\Users\Admin\Downloads\your-key.pem

param(
    [Parameter(Mandatory=$true)]
    [string]$PemPath
)

if (-not (Test-Path $PemPath)) {
    Write-Host "File not found: $PemPath" -ForegroundColor Red
    exit 1
}

Write-Host "Fixing permissions for: $PemPath" -ForegroundColor Yellow

# Take ownership
takeown /f $PemPath | Out-Null

# Reset and set only current user read access
icacls $PemPath /reset
icacls $PemPath /inheritance:r
icacls $PemPath /grant "${env:USERNAME}:(R,W)"

Write-Host "Done! You can now use this .pem file." -ForegroundColor Green
