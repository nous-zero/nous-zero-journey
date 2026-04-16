# ================================================
# 아침 학습 루틴 - 매일 아침 자동 실행
# - Windows 알림 표시
# - Chrome에서 3개 탭 열기 (LeetCode, Colab, GitHub)
# ================================================

# --- 1. Windows Toast 알림 ---
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] > $null

$AppId = "Nous-Zero.MorningRoutine"

$ToastXml = @"
<toast duration="long" scenario="alarm">
    <visual>
        <binding template="ToastGeneric">
            <text>☀️ 좋은 아침! 오늘도 화이팅</text>
            <text>LeetCode, Colab, GitHub을 열었습니다.</text>
            <text>Phase0 기초 학습 시간입니다 📚</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Looping.Alarm" loop="true" />
    <actions>
        <action content="확인" arguments="dismiss" />
    </actions>
</toast>
"@

try {
    $XmlDocument = New-Object Windows.Data.Xml.Dom.XmlDocument
    $XmlDocument.LoadXml($ToastXml)
    $Toast = [Windows.UI.Notifications.ToastNotification]::new($XmlDocument)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppId).Show($Toast)
    Write-Host "✅ 알림 표시 완료"
} catch {
    # 최신 Toast API 실패 시 BalloonTip으로 fallback
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $Notify = New-Object System.Windows.Forms.NotifyIcon
    $Notify.Icon = [System.Drawing.SystemIcons]::Information
    $Notify.BalloonTipTitle = "☀️ 좋은 아침! 오늘도 화이팅"
    $Notify.BalloonTipText = "LeetCode, Colab, GitHub을 열었습니다. Phase0 기초 학습 시간입니다 📚"
    $Notify.Visible = $true
    $Notify.ShowBalloonTip(10000)
    Start-Sleep -Seconds 11
    $Notify.Dispose()
}

# --- 2. Chrome에서 3개 탭을 한 창에 열기 ---
$Urls = @(
    "https://leetcode.com/problemset/",
    "https://colab.research.google.com/",
    "https://github.com/nous-zero/nous-zero-journey"
)

# Chrome 경로 탐색
$ChromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
)

$ChromeExe = $ChromePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($ChromeExe) {
    # --new-window로 새 창에 3개 탭 한꺼번에 열기
    Start-Process -FilePath $ChromeExe -ArgumentList (@("--new-window") + $Urls)
    Write-Host "✅ Chrome에서 3개 탭 열기 완료"
} else {
    # Chrome이 없으면 기본 브라우저로 열기
    foreach ($url in $Urls) {
        Start-Process $url
        Start-Sleep -Milliseconds 500
    }
    Write-Host "⚠️ Chrome을 찾지 못해 기본 브라우저로 열었습니다"
}

Write-Host ""
Write-Host "🎯 오늘의 학습 체크리스트:"
Write-Host "   1. LeetCode Easy 한 문제 풀기"
Write-Host "   2. GDPO.py 주석 작업 (50줄)"
Write-Host "   3. Colab 템플릿으로 push"
