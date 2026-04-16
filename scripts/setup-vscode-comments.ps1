# ================================================
# VS Code 한글 주석 색상 구분 자동 설정 (1회만 실행)
# - Better Comments 확장 자동 설치
# - 한글 주석(★ 접두어)을 노란색으로 별도 표시
# - 영어 원본 주석은 기본 회색 유지
# ================================================
$OutputEncoding = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = $OutputEncoding

$SettingsPath = Join-Path $env:APPDATA "Code\User\settings.json"

Write-Host "=== VS Code 한글 주석 색상 구분 설정 ===" -ForegroundColor Cyan
Write-Host ""

# --- 1. Better Comments 확장 설치 ---
Write-Host "[1/2] Better Comments 확장 설치 중..." -ForegroundColor Yellow

$codeCmdPaths = @(
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd"
)
$CodeCmd = $codeCmdPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($CodeCmd) {
    & $CodeCmd --install-extension aaron-bond.better-comments --force 2>&1 | Out-Null
    Write-Host "    ✅ Better Comments 설치 완료" -ForegroundColor Green
} else {
    Write-Host "    ⚠️ code.cmd를 찾지 못함. VS Code에서 수동 설치 필요:" -ForegroundColor Yellow
    Write-Host "       Extensions > 'Better Comments' 검색 > Install"
}

# --- 2. settings.json에 한글 주석 색상 설정 추가 ---
Write-Host ""
Write-Host "[2/2] 한글 주석 색상 설정 적용 중..." -ForegroundColor Yellow

# 기존 설정 로드
$settings = [ordered]@{}
if (Test-Path $SettingsPath) {
    try {
        $content = Get-Content $SettingsPath -Raw -Encoding UTF8
        if ($content -and $content.Trim()) {
            $jsonObj = $content | ConvertFrom-Json
            $jsonObj.PSObject.Properties | ForEach-Object {
                $settings[$_.Name] = $_.Value
            }
        }
    } catch {
        Write-Host "    ⚠️ settings.json 파싱 실패 - 백업 후 새로 생성" -ForegroundColor Yellow
        $backupPath = "${SettingsPath}.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $SettingsPath $backupPath
        $settings = [ordered]@{}
    }
}

# Better Comments 태그: 눈에 편한 부드러운(muted) 팔레트 사용
# 사용 방법: # ★ 한국어 설명 / # ※ 경고 / # ◎ 핵심 개념 / # → 흐름
$betterCommentsTags = @(
    @{
        "tag"             = "★"
        "color"           = "#B8A082"    # 부드러운 샌드스톤 (기본 한글 주석)
        "strikethrough"   = $false
        "underline"       = $false
        "backgroundColor" = "transparent"
        "bold"            = $false
        "italic"          = $false
    },
    @{
        "tag"             = "◎"
        "color"           = "#7A9BB0"    # 부드러운 스틸블루 (핵심 개념)
        "strikethrough"   = $false
        "underline"       = $false
        "backgroundColor" = "transparent"
        "bold"            = $true
        "italic"          = $false
    },
    @{
        "tag"             = "※"
        "color"           = "#B58080"    # 부드러운 로즈 (주의/경고)
        "strikethrough"   = $false
        "underline"       = $false
        "backgroundColor" = "transparent"
        "bold"            = $false
        "italic"          = $false
    },
    @{
        "tag"             = "→"
        "color"           = "#8AAB8A"    # 부드러운 모스 그린 (흐름/단계)
        "strikethrough"   = $false
        "underline"       = $false
        "backgroundColor" = "transparent"
        "bold"            = $false
        "italic"          = $false
    }
)

$settings["better-comments.tags"] = $betterCommentsTags
$settings["better-comments.multilineComments"] = $true

# JSON 저장 (UTF-8 BOM 없이)
$json = $settings | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($SettingsPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Host "    ✅ 색상 태그 4개 등록 (눈에 편한 muted 팔레트):" -ForegroundColor Green
Write-Host "       ★ 샌드스톤 (기본 한글 주석)"
Write-Host "       ◎ 스틸블루 (핵심 개념)"
Write-Host "       ※ 로즈 (주의/경고)"
Write-Host "       → 모스그린 (흐름/단계)"

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ 설정 완료!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔄 VS Code를 재시작하면 적용됩니다."
Write-Host ""
Write-Host "📝 한글 주석 예시:"
Write-Host '   if x > 10:  # ★ x가 10보다 크면 (금색)'
Write-Host '   y = calc()  # ◎ 핵심: 메모리 할당 (시안)'
Write-Host '   # ※ 주의: 이 함수는 deprecated (빨강)'
Write-Host '   # → 다음 단계: 정규화 (연두)'
