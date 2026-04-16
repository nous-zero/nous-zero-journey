# ================================================
# 통합 설정 스크립트 (1회만 실행)
# 1. Wake Timer 활성화 (절전에서 자동으로 깨어나기)
# 2. 잠금 화면에 알림 표시
# 3. 잠금 화면에서 알림 소리 허용
# ================================================
# 관리자 권한 불필요 (사용자 설정만 변경)

Write-Host "=== 아침 루틴 통합 설정 ===" -ForegroundColor Cyan
Write-Host ""

# --- 1. Wake Timer 활성화 ---
Write-Host "[1/3] Wake Timer 활성화 중..." -ForegroundColor Yellow
try {
    # AC(전원 연결) 모드에서 Wake Timer 허용
    powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_SLEEP BD3B718A-0680-4D9D-8AB2-E1D2B4AC806D 1 | Out-Null
    # DC(배터리) 모드에서도 허용
    powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_SLEEP BD3B718A-0680-4D9D-8AB2-E1D2B4AC806D 1 | Out-Null
    # 현재 전원 계획 적용
    powercfg /SETACTIVE SCHEME_CURRENT | Out-Null
    Write-Host "    ✅ Wake Timer 활성화 완료 (AC + 배터리)" -ForegroundColor Green
    Write-Host "       → 7시에 PC가 자동으로 절전에서 깨어납니다"
} catch {
    Write-Host "    ⚠️ Wake Timer 설정 실패: $_" -ForegroundColor Red
}
Write-Host ""

# --- 2. 잠금 화면에 알림 표시 ---
Write-Host "[2/3] 잠금 화면에 알림 표시 설정 중..." -ForegroundColor Yellow
try {
    $RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
    if (-not (Test-Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $RegPath -Name "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATIONS_ABOVE_LOCK" -Value 1 -Type DWord -Force
    Write-Host "    ✅ 잠금 화면 알림 표시 활성화" -ForegroundColor Green
    Write-Host "       → 잠겨 있어도 알림이 화면에 표시됩니다"
} catch {
    Write-Host "    ⚠️ 레지스트리 설정 실패: $_" -ForegroundColor Red
}
Write-Host ""

# --- 3. 잠금 화면에서 알림 소리 허용 ---
Write-Host "[3/3] 잠금 화면 알림 소리 설정 중..." -ForegroundColor Yellow
try {
    $PushPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications"
    if (-not (Test-Path $PushPath)) {
        New-Item -Path $PushPath -Force | Out-Null
    }
    # Toast 알림 전역 활성화
    Set-ItemProperty -Path $PushPath -Name "ToastEnabled" -Value 1 -Type DWord -Force

    # 방해 금지(Focus Assist) 모드 끄기 (Windows 10/11)
    $QuietPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
    Set-ItemProperty -Path $QuietPath -Name "NOC_GLOBAL_SETTING_TOASTS_ENABLED" -Value 1 -Type DWord -Force

    Write-Host "    ✅ 알림 소리 활성화 완료" -ForegroundColor Green
    Write-Host "       → 잠금 화면에서도 알람 소리가 울립니다"
} catch {
    Write-Host "    ⚠️ 레지스트리 설정 실패: $_" -ForegroundColor Red
}
Write-Host ""

# --- 최종 안내 ---
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ 모든 설정 완료!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️ 수동 확인 권장:" -ForegroundColor Yellow
Write-Host "   설정 > 시스템 > 방해 금지 (또는 집중 지원) → '끔'으로 되어있는지 확인"
Write-Host "   설정 > 시스템 > 알림 → 활성화 확인"
Write-Host ""
Write-Host "🧪 테스트 방법:" -ForegroundColor Cyan
Write-Host "   1. 지금 즉시 실행: Start-ScheduledTask -TaskName 'NousZero-MorningRoutine'"
Write-Host "   2. 잠금 테스트: Win+L로 잠근 뒤 위 명령 실행"
Write-Host ""
Write-Host "⏰ 내일 아침 7시에 자동으로 실행됩니다."
