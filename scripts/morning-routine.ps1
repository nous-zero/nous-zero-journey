# ================================================
# 아침 학습 루틴 - 매일 아침 자동 실행
# - Windows 알림 표시
# - Chrome에서 3개 탭 열기:
#   1. LeetCode: CLAUDE.md에서 찾은 오늘의 문제 페이지
#   2. Colab: daily-study-template.ipynb 직접 로드
#   3. GitHub: 레포 메인
# ================================================

$RepoRoot        = Split-Path $PSScriptRoot -Parent
$ClaudeMd        = Join-Path $RepoRoot "CLAUDE.md"
$GdpoPath        = "C:\Users\745ra\OneDrive\바탕 화면\BIO\코드\GDPO.py"
$GdpoNotebookDir = Join-Path $RepoRoot "Phase0_기초\GDPO_주석"

# URL 경로 인코딩 함수 (한글/특수문자 포함된 경로 처리)
function ConvertTo-UrlPath([string]$path) {
    $parts = $path -replace '\\', '/' -split '/'
    $encoded = $parts | ForEach-Object {
        if ($_) { [uri]::EscapeDataString($_) } else { '' }
    }
    return ($encoded -join '/')
}

# --- 가장 최근의 한글 주석 GDPO 노트북 찾기 ---
$LatestGdpoNotebookUrl  = "https://github.com/nous-zero/nous-zero-journey/tree/main/Phase0_%EA%B8%B0%EC%B4%88/GDPO_%EC%A3%BC%EC%84%9D"
$LatestGdpoNotebookName = $null

if (Test-Path $GdpoNotebookDir) {
    $latestNb = Get-ChildItem -Path $GdpoNotebookDir -Filter "*.ipynb" -ErrorAction SilentlyContinue |
                Sort-Object Name -Descending |
                Select-Object -First 1
    if ($latestNb) {
        $LatestGdpoNotebookName = $latestNb.Name
        $relPath = "Phase0_기초/GDPO_주석/$($latestNb.Name)"
        $encodedRel = ConvertTo-UrlPath $relPath
        # Colab에서 GitHub 파일 직접 로드 (편집 가능)
        $LatestGdpoNotebookUrl = "https://colab.research.google.com/github/nous-zero/nous-zero-journey/blob/main/$encodedRel"
    }
}

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

$NextGdpoLine  = $null
$NextGdpoRange = "미결정"

if (Test-Path $ClaudeMd) {
    $section = ""
    foreach ($line in (Get-Content $ClaudeMd -Encoding UTF8)) {
        # 섹션 감지
        if ($line -match "^### LeetCode") {
            $section = "leetcode"
            continue
        }
        if ($line -match "^### GDPO") {
            $section = "gdpo"
            continue
        }
        # 다음 ### 섹션이 오면 현재 섹션 종료
        if ($section -and $line -match "^### " -and $line -notmatch "LeetCode|GDPO") {
            $section = ""
        }

        # LeetCode: 🔲 상태(미완료) 첫 번째 행
        if ($section -eq "leetcode" -and $line -match "🔲" -and -not $NextProblemNum) {
            if ($line -match '\|\s*(Day[^|]+?)\s*\|\s*#(\d+)\s+([^|]+?)\s*\|') {
                $NextDayLabel    = $matches[1].Trim()
                $NextProblemNum  = $matches[2]
                $NextProblemName = $matches[3].Trim()
            }
            elseif ($line -match '\|\s*(Day[^|]+?)\s*\|.*?#(\d+)') {
                $NextDayLabel    = $matches[1].Trim()
                $NextProblemNum  = $matches[2]
                $NextProblemName = "다음 단계 시작"
            }
        }

        # GDPO: 🔲 상태(미완료) 첫 번째 행
        if ($section -eq "gdpo" -and $line -match "🔲" -and -not $NextGdpoLine) {
            # 지원 형식: "| 101~150줄 | 🔲 |", "| 101줄~ | 🔲 |", "| 101줄부터 | 🔲 |"
            # 1단계: 첫 번째 숫자 추출 (시작 라인)
            if ($line -match '\|\s*(\d+)') {
                $NextGdpoLine = $matches[1]
                # 2단계: | 와 | 사이의 텍스트 전체를 범위 표기로 저장
                if ($line -match '\|\s*([^|]+?)\s*\|\s*🔲') {
                    $NextGdpoRange = $matches[1].Trim()
                }
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
if ($NextGdpoLine) {
    Write-Host "📖 오늘의 GDPO 구간: $NextGdpoRange (VS Code에서 라인 ${NextGdpoLine}로 이동)"
} else {
    Write-Host "📖 GDPO: 모든 구간 완료! 🎉"
}
if ($LatestGdpoNotebookName) {
    Write-Host "📘 한글 주석 참고 노트북: $LatestGdpoNotebookName"
} else {
    Write-Host "📘 한글 주석 노트북: 없음 (첫 작업)"
}

# --- 1. Windows Toast 알림 ---
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] > $null

$AppId = "Nous-Zero.MorningRoutine"

# XML 특수문자 escape
$SafeLabel = $TodayLabel -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;'
$SafeGdpo  = if ($NextGdpoLine) { "GDPO $NextGdpoRange" } else { "GDPO 완료" }

$ToastXml = @"
<toast duration="long" scenario="alarm">
    <visual>
        <binding template="ToastGeneric">
            <text>☀️ 좋은 아침 Hoony님! 오늘도 화이팅</text>
            <text>오늘의 문제: $SafeLabel</text>
            <text>$SafeGdpo · LeetCode · Colab · GitHub · 한글주석 노트북 열림 📚</text>
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

# --- 2. Chrome에서 4개 탭을 한 창에 열기 ---
# 탭 1: LeetCode 오늘의 문제
# 탭 2: Colab 빈 템플릿 (새 작업용)
# 탭 3: GitHub 레포 메인
# 탭 4: 가장 최근 한글 주석 GDPO 노트북 (참고용, 한글 주석 스타일 확인)
$Urls = @(
    $LeetCodeUrl,
    "https://colab.research.google.com/github/nous-zero/nous-zero-journey/blob/main/templates/daily-study-template.ipynb",
    "https://github.com/nous-zero/nous-zero-journey",
    $LatestGdpoNotebookUrl
)

$ChromePaths = @(
    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "${env:LOCALAPPDATA}\Google\Chrome\Application\chrome.exe"
)
$ChromeExe = $ChromePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($ChromeExe) {
    Start-Process -FilePath $ChromeExe -ArgumentList (@("--new-window") + $Urls)
    Write-Host "✅ Chrome에서 4개 탭 열기 완료"
} else {
    foreach ($url in $Urls) {
        Start-Process $url
        Start-Sleep -Milliseconds 500
    }
    Write-Host "⚠️ Chrome을 찾지 못해 기본 브라우저로 열었습니다"
}

# --- 3. VS Code로 GDPO.py 해당 라인으로 바로 점프 ---
if (Test-Path $GdpoPath) {
    # VS Code 실행 파일 찾기 (설치 위치가 다양함)
    $VSCodePaths = @(
        "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles}\Microsoft VS Code\Code.exe",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
    )
    $VSCodeExe = $VSCodePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($VSCodeExe) {
        if ($NextGdpoLine) {
            # -g 플래그로 특정 라인으로 점프
            Start-Process -FilePath $VSCodeExe -ArgumentList @("-g", "${GdpoPath}:${NextGdpoLine}")
            Write-Host "✅ VS Code로 GDPO.py 라인 $NextGdpoLine 열기 완료"
        } else {
            Start-Process -FilePath $VSCodeExe -ArgumentList @($GdpoPath)
            Write-Host "✅ VS Code로 GDPO.py 열기 완료 (모든 구간 완료)"
        }
    } else {
        # VS Code가 없으면 기본 앱으로 열기
        Start-Process $GdpoPath
        Write-Host "⚠️ VS Code를 찾지 못해 기본 연결 앱으로 열었습니다"
    }
} else {
    Write-Host "⚠️ GDPO.py를 찾을 수 없습니다: $GdpoPath"
}

Write-Host ""
Write-Host "🎯 오늘의 체크리스트:"
Write-Host "   1. $TodayLabel 풀기 (오전 7:00~7:30)"
if ($NextGdpoLine) {
    Write-Host "   2. GDPO.py $NextGdpoRange 한국어 주석 (오전 8:30~9:00)"
} else {
    Write-Host "   2. GDPO.py 전체 완료! 다음 Phase 준비"
}
Write-Host "   3. GitHub 정리 (오후 10:00~10:20)"
Write-Host ""
Write-Host "💡 다음 과제로 넘어가려면:"
Write-Host "   $ClaudeMd 에서 해당 행의 '🔲'을 '✅ 완료'로 수정"
