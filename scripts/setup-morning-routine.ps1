# ================================================
# 작업 스케줄러 등록 - 매일 아침 7시 morning-routine.ps1 실행
# 1회만 실행하면 됩니다. 관리자 권한 불필요.
# ================================================

$TaskName    = "NousZero-MorningRoutine"
$ScriptPath  = Join-Path $PSScriptRoot "morning-routine.ps1"
$TriggerTime = "07:00"

if (-not (Test-Path $ScriptPath)) {
    Write-Host "❌ 스크립트를 찾을 수 없습니다: $ScriptPath" -ForegroundColor Red
    Write-Host "   morning-routine.ps1이 같은 폴더에 있는지 확인하세요." -ForegroundColor Red
    exit 1
}

Write-Host "=== 아침 학습 루틴 등록 ===" -ForegroundColor Cyan
Write-Host "작업 이름: $TaskName"
Write-Host "실행 시간: 매일 $TriggerTime"
Write-Host "스크립트 : $ScriptPath"
Write-Host ""

# 기존 작업이 있으면 제거
try {
    $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existing) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "🔄 기존 작업 제거 후 재등록합니다" -ForegroundColor Yellow
    }
} catch {}

# 작업 구성
$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""

$Trigger = New-ScheduledTaskTrigger -Daily -At $TriggerTime

$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -WakeToRun `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10) `
    -RestartCount 1 `
    -RestartInterval (New-TimeSpan -Minutes 2) `
    -MultipleInstances IgnoreNew

$Principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType Interactive `
    -RunLevel Limited

try {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $Action `
        -Trigger $Trigger `
        -Settings $Settings `
        -Principal $Principal `
        -Description "매일 아침 7시에 LeetCode/Colab/GitHub 학습 페이지를 자동으로 엽니다" | Out-Null

    Write-Host ""
    Write-Host "✅ 등록 완료!" -ForegroundColor Green
    Write-Host ""
    Write-Host "적용된 복원력 설정:" -ForegroundColor Cyan
    Write-Host "   - ExecutionTimeLimit: 10분 (넘으면 자동 종료)"
    Write-Host "   - RestartCount: 실패 시 1회 재시도 (2분 후)"
    Write-Host "   - MultipleInstances: 중복 실행 방지"
    Write-Host ""
    Write-Host "내일 아침 $TriggerTime 에 자동으로 실행됩니다."
    Write-Host ""
    Write-Host "📌 지금 테스트하려면:" -ForegroundColor Cyan
    Write-Host "   Start-ScheduledTask -TaskName '$TaskName'"
    Write-Host ""
    Write-Host "📌 등록 해제하려면:" -ForegroundColor Cyan
    Write-Host "   Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false"
    Write-Host ""
    Write-Host "📌 작업 확인하려면:" -ForegroundColor Cyan
    Write-Host "   Get-ScheduledTask -TaskName '$TaskName'"
    Write-Host "   (또는 '작업 스케줄러' 앱에서 'NousZero-MorningRoutine' 검색)"
} catch {
    Write-Host ""
    Write-Host "❌ 등록 실패: $_" -ForegroundColor Red
    Write-Host "   관리자 권한이 필요할 수 있습니다. PowerShell을 관리자로 실행 후 다시 시도하세요." -ForegroundColor Yellow
}
