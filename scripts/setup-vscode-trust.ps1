# ================================================
# VS Code Workspace Trust 자동 비활성화 (1회만 실행)
# - 매번 'Trust this folder' 묻지 않도록 설정
# - 모든 폴더를 신뢰된 것으로 취급 (학습용 PC에서만 권장)
# ================================================
# UTF-8 인코딩 강제
$OutputEncoding = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = $OutputEncoding

$SettingsPath = Join-Path $env:APPDATA "Code\User\settings.json"

Write-Host "=== VS Code Workspace Trust 비활성화 ===" -ForegroundColor Cyan
Write-Host "설정 파일: $SettingsPath"
Write-Host ""

# 설정 디렉터리 생성 (처음 VS Code 설치 후 아직 사용자 설정이 없는 경우)
$SettingsDir = Split-Path $SettingsPath -Parent
if (-not (Test-Path $SettingsDir)) {
    New-Item -Path $SettingsDir -ItemType Directory -Force | Out-Null
    Write-Host "📁 설정 디렉터리 생성: $SettingsDir"
}

# 기존 설정 읽기 (또는 빈 객체)
$settings = [ordered]@{}
if (Test-Path $SettingsPath) {
    try {
        $content = Get-Content $SettingsPath -Raw -Encoding UTF8
        # 빈 파일이면 빈 객체 유지
        if ($content -and $content.Trim()) {
            # PowerShell 5.1의 ConvertFrom-Json은 해시테이블 반환 못하므로 수동 변환
            $jsonObj = $content | ConvertFrom-Json
            $jsonObj.PSObject.Properties | ForEach-Object {
                $settings[$_.Name] = $_.Value
            }
        }
        Write-Host "📄 기존 설정 파일 로드 (항목: $($settings.Count)개)"
    } catch {
        Write-Host "⚠️ 기존 settings.json 파싱 실패 - 백업 후 새로 생성" -ForegroundColor Yellow
        $backupPath = "${SettingsPath}.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $SettingsPath $backupPath
        Write-Host "   백업: $backupPath"
        $settings = [ordered]@{}
    }
} else {
    Write-Host "📝 settings.json이 없어서 새로 생성합니다"
}

# Workspace Trust 관련 설정 추가/덮어쓰기
$trustSettings = @{
    "security.workspace.trust.enabled"        = $false
    "security.workspace.trust.startupPrompt"  = "never"
    "security.workspace.trust.banner"         = "never"
    "security.workspace.trust.untrustedFiles" = "open"
    "security.workspace.trust.emptyWindow"    = $true
}

foreach ($key in $trustSettings.Keys) {
    $settings[$key] = $trustSettings[$key]
    Write-Host "   ✅ $key = $($trustSettings[$key])"
}

# JSON으로 저장 (한글 주석이 있을 수 있으므로 UTF-8 BOM 없이)
$json = $settings | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($SettingsPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ VS Code Trust 비활성화 완료!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔄 다음 VS Code 실행부터 다음 동작이 적용됩니다:"
Write-Host "   - 'Trust this folder' 질문 안 나옴"
Write-Host "   - Restricted Mode 배너 안 표시"
Write-Host "   - 모든 파일 편집/실행 즉시 가능"
Write-Host ""
Write-Host "⚠️  주의: Workspace Trust는 악성 코드 실행 방지 기능입니다."
Write-Host "   개인 학습 PC에만 권장. 업무용 PC/공용 PC에서는 켜두세요."
Write-Host ""
Write-Host "📌 되돌리려면:"
Write-Host "   VS Code > 설정 > 'workspace trust' 검색 > 'Enabled' 체크"
