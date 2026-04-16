# ================================================
# 아침 학습 루틴 - 매일 아침 자동 실행
# - Windows 알림 표시
# - Chrome에서 3개 탭 열기:
#   1. LeetCode: CLAUDE.md에서 찾은 오늘의 문제 페이지
#   2. Colab: daily-study-template.ipynb 직접 로드
#   3. GitHub: 레포 메인
# ================================================

$RepoRoot   = Split-Path $PSScriptRoot -Parent
$ClaudeMd   = Join-Path $RepoRoot "CLAUDE.md"

# --- LeetCode 문제 번호 -> URL slug 매핑 (CLAUDE.md 로드맵 전체) ---
$ProblemSlugs = @{
    "1"   = "two-sum"
    "9"   = "palindrome-number"
    "13"  = "roman-to-integer"
    "14"  = "longest-common-prefix"
    "20"  = "valid-parentheses"
    "21"  = "merge-two-sorted-lists"
    "26"  = "remove-duplicates-from-sorted-array"
    "28"  = "find-the-index-of-the-first-occurrence-in-a-string"
    "35"  = "search-insert-position"
    "58"  = "length-of-last-word"
    "69"  = "sqrtx"
    "83"  = "remove-duplicates-from-sorted-list"
    "88"  = "merge-sorted-array"
    "121" = "best-time-to-buy-and-sell-stock"
    "136" = "single-number"
    "141" = "linked-list-cycle"
    "169" = "majority-element"
    "206" = "reverse-linked-list"
    "217" = "contains-duplicate"
    "225" = "implement-stack-using-queues"
    "232" = "implement-queue-using-stacks"
    "242" = "valid-anagram"
    "268" = "missing-number"
    "283" = "move-zeroes"
    "349" = "intersection-of-two-arrays"
    "387" = "first-unique-character-in-a-string"
    "412" = "fizz-buzz"
    "448" = "find-all-numbers-disappeared-in-an-array"
    "704" = "binary-search"
}

# --- CLAUDE.md에서 다음에 풀 문제 파싱 ---
$NextProblemNum   = $null
$NextProblemName  = $null
$NextDayLabel     = "Day ?"
$LeetCodeUrl      = "https://leetcode.com/problemset/"

if (Test-Path $ClaudeMd) {
    $inLeetCodeSection = $false
    foreach ($line in (Get-Content $ClaudeMd -Encoding UTF8)) {
        # LeetCode 섹션 시작 감지
        if ($line -match "^### LeetCode") {
            $inLeetCodeSection = $true
            continue
        }
        # 다음 ### 섹션이 오면 LeetCode 섹션 종료
        if ($inLeetCodeSection -and $line -match "^### ") {
            break
        }
        # 🔲 상태 (미완료)인 첫 번째 행 찾기
        if ($inLeetCodeSection -and $line -match "🔲") {
            # 예: "| Day 2 | #217 Contains Duplicate | 🔲 |"
            if ($line -match '\|\s*(Day[^|]+?)\s*\|\s*#(\d+)\s+([^|]+?)\s*\|') {
                $NextDayLabel    = $matches[1].Trim()
                $NextProblemNum  = $matches[2]
                $NextProblemName = $matches[3].Trim()
                break
            }
            # 여러 문제가 있는 행 (예: "문자열 단계 (#9 #14 #13 #58 #28)")
            # 첫 번째 번호만 추출
            elseif ($line -match '\|\s*(Day[^|]+?)\s*\|.*?#(\d+)') {
                $NextDayLabel    = $matches[1].Trim()
                $NextProblemNum  = $matches[2]
                $NextProblemName = "다음 단계 시작"
                break
            }
        }
    }
}

# --- 문제 번호를 URL로 변환 ---
if ($NextProblemNum -and $ProblemSlugs.ContainsKey($NextProblemNum)) {
    $LeetCodeUrl = "https://leetcode.com/problems/$($ProblemSlugs[$NextProblemNum])/"
}

$TodayLabel = if ($NextProblemNum) {
    "$NextDayLabel : #$NextProblemNum $NextProblemName"
} else {
    "모든 문제 완료! 🎉"
}

Write-Host "📚 오늘의 LeetCode 문제: $TodayLabel"
Write-Host "🔗 URL: $LeetCodeUrl"

# --- 1. Windows Toast 알림 ---
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] > $null

$AppId = "Nous-Zero.MorningRoutine"

# XML 특수문자 escape
$SafeLabel = $TodayLabel -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'

$ToastXml = @"
<toast duration="long" scenario="alarm">
    <visual>
        <binding template="ToastGeneric">
            <text>☀️ 좋은 아침 Hoony님! 오늘도 화이팅</text>
            <text>오늘의 문제: $SafeLabel</text>
            <text>LeetCode + Colab 템플릿 + GitHub을 열었습니다 📚</text>
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
    # Fallback: BalloonTip
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $Notify = New-Object System.Windows.Forms.NotifyIcon
    $Notify.Icon = [System.Drawing.SystemIcons]::Information
    $Notify.BalloonTipTitle = "☀️ 좋은 아침 Hoony님!"
    $Notify.BalloonTipText = "오늘의 문제: $TodayLabel"
    $Notify.Visible = $true
    $Notify.ShowBalloonTip(10000)
    Start-Sleep -Seconds 11
    $Notify.Dispose()
}

# --- 2. Chrome에서 3개 탭을 한 창에 열기 ---
$Urls = @(
    $LeetCodeUrl,
    "https://colab.research.google.com/github/nous-zero/nous-zero-journey/blob/main/templates/daily-study-template.ipynb",
    "https://github.com/nous-zero/nous-zero-journey"
)

$ChromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
)
$ChromeExe = $ChromePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($ChromeExe) {
    Start-Process -FilePath $ChromeExe -ArgumentList (@("--new-window") + $Urls)
    Write-Host "✅ Chrome에서 3개 탭 열기 완료"
} else {
    foreach ($url in $Urls) {
        Start-Process $url
        Start-Sleep -Milliseconds 500
    }
    Write-Host "⚠️ Chrome을 찾지 못해 기본 브라우저로 열었습니다"
}

Write-Host ""
Write-Host "🎯 오늘의 체크리스트:"
Write-Host "   1. $TodayLabel 풀기 (오전 7:00~7:30)"
Write-Host "   2. GDPO.py 50줄 주석 (오전 8:30~9:00)"
Write-Host "   3. GitHub 정리 (오후 10:00~10:20)"
Write-Host ""
Write-Host "💡 다음 문제로 넘어가려면:"
Write-Host "   $ClaudeMd 에서 해당 Day 행의 '🔲'을 '✅ 완료'로 수정"
