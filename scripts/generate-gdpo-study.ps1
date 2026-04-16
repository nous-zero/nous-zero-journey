# ================================================
# GDPO 학습용 한글 주석 파일 자동 생성
# - CLAUDE.md에서 다음 🔲 구간 읽기
# - GDPO.py에서 해당 줄 추출
# - Claude CLI로 한글 주석 자동 생성
# - GDPO_학습용_{범위}.py로 저장
# ================================================

# UTF-8 인코딩 강제 (PowerShell 5.1이 기본 ANSI로 한글 보내면 깨짐)
$OutputEncoding = New-Object System.Text.UTF8Encoding $false
[Console]::OutputEncoding = $OutputEncoding
[Console]::InputEncoding  = $OutputEncoding

$RepoRoot = Split-Path $PSScriptRoot -Parent
$ClaudeMd = Join-Path $RepoRoot "CLAUDE.md"
$GdpoPath = "C:\Users\745ra\OneDrive\바탕 화면\BIO\코드\GDPO.py"
$StudyDir = "C:\Users\745ra\OneDrive\바탕 화면\BIO\코드"

# --- CLAUDE.md에서 다음 GDPO 🔲 구간 파싱 ---
$StartLine = $null
$EndLine   = $null

if (Test-Path $ClaudeMd) {
    $inGdpoSection = $false
    foreach ($line in (Get-Content $ClaudeMd -Encoding UTF8)) {
        if ($line -match "^### GDPO") {
            $inGdpoSection = $true
            continue
        }
        if ($inGdpoSection -and $line -match "^### " -and $line -notmatch "GDPO") {
            break
        }
        if ($inGdpoSection -and $line -match "🔲" -and -not $StartLine) {
            # 형식 1: "| 101~150줄 | 🔲 |" → 시작 101, 끝 150
            if ($line -match '\|\s*(\d+)\s*~\s*(\d+)\s*줄') {
                $StartLine = [int]$matches[1]
                $EndLine   = [int]$matches[2]
            }
            # 형식 2: "| 101줄~ | 🔲 |" → 시작 101, 끝 +50
            elseif ($line -match '\|\s*(\d+)\s*줄') {
                $StartLine = [int]$matches[1]
                $EndLine   = $StartLine + 49
            }
        }
    }
}

if (-not $StartLine) {
    Write-Host "⚠️ CLAUDE.md에서 다음 🔲 GDPO 구간을 찾지 못했습니다." -ForegroundColor Yellow
    exit 0
}

Write-Host "📖 대상 구간: ${StartLine}~${EndLine}줄"

# --- 구간에 해당하는 코드 추출 ---
if (-not (Test-Path $GdpoPath)) {
    Write-Host "❌ GDPO.py를 찾을 수 없습니다: $GdpoPath" -ForegroundColor Red
    exit 1
}

$allLines = Get-Content $GdpoPath -Encoding UTF8
$startIdx = $StartLine - 1
$endIdx   = [Math]::Min($EndLine - 1, $allLines.Count - 1)

if ($startIdx -ge $allLines.Count) {
    Write-Host "⚠️ 구간이 파일 길이(${$allLines.Count}줄)를 초과합니다." -ForegroundColor Yellow
    exit 0
}

$snippet = ($allLines[$startIdx..$endIdx]) -join "`n"

# --- 출력 파일 경로 ---
$StudyFile = Join-Path $StudyDir "GDPO_학습용_${StartLine}-${EndLine}.py"

# 이미 생성되어 있으면 재생성 건너뛰기 (시간 절약)
if (Test-Path $StudyFile) {
    Write-Host "✅ 학습용 파일이 이미 존재합니다: $StudyFile"
    Write-Host "   (재생성이 필요하면 파일을 삭제 후 다시 실행하세요)"
    exit 0
}

# --- Claude CLI 프롬프트 작성 ---
# 따옴표(`") 사용 최소화 - PowerShell argument 파서 이슈 방지
# 임시 파일에 저장해 stdin으로 전달하므로 큰 따옴표도 안전
$prompt = @"
박정훈(Python 초보자)이 학습용으로 읽을 수 있도록, 아래 Python 코드의 각 줄마다 한국어 주석을 추가해주세요.

규칙:
1. 원본 코드는 그대로 유지 (문자 하나 바꾸지 말 것)
2. 각 코드 줄 오른쪽에 # 형태로 한국어 설명 추가
3. 이미 영어 주석이 있는 줄은 그 아래에 한국어 설명 추가
4. 전문 용어는 괄호로 쉬운 설명 병기 (예: 텐서는 행렬 형태의 숫자 묶음)
5. 설명 텍스트 없이 한글 주석이 추가된 Python 코드만 출력
6. 마크다운 코드 블록 없이 순수 Python 코드만 출력
7. 파일 접근 시도 금지 - 코드는 아래에 전부 포함되어 있음

GDPO.py ${StartLine}~${EndLine}줄 원본 코드:

$snippet
"@

# --- Claude CLI 존재 확인 ---
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
    Write-Host "❌ 'claude' CLI를 찾을 수 없습니다." -ForegroundColor Red
    Write-Host "   설치 확인: where.exe claude" -ForegroundColor Yellow
    Write-Host "   미설치 시: https://docs.claude.com/claude-code" -ForegroundColor Yellow
    exit 1
}

Write-Host "🤖 Claude CLI 호출 중... (20~60초 소요)"

# --- Claude CLI 실행 ---
# PowerShell 5.1은 argument에 긴 문자열+따옴표가 포함되면 잘리므로,
# 프롬프트를 UTF-8 임시 파일에 쓰고 stdin으로 전달. 인코딩도 UTF-8 유지.
$tempInput = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "claude_prompt_$([System.Guid]::NewGuid()).txt")
[System.IO.File]::WriteAllText($tempInput, $prompt, [System.Text.UTF8Encoding]::new($false))

try {
    # Get-Content로 UTF-8 읽어서 파이프로 전달 ($OutputEncoding은 이미 UTF-8 설정됨)
    $result = Get-Content -Path $tempInput -Raw -Encoding UTF8 | & claude -p 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Claude CLI 실행 실패 (exit $LASTEXITCODE)" -ForegroundColor Red
        Write-Host $result
        Remove-Item -Path $tempInput -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # --- 결과 저장 ---
    $header = @"
# ================================================
# GDPO.py ${StartLine}~${EndLine}줄 - 한글 주석 학습용 (자동 생성)
# 생성 시각: $(Get-Date -Format 'yyyy-MM-dd HH:mm')
# 원본 파일: $GdpoPath
# ※ 이 파일은 학습 참고용. 본인의 노트북에 스스로 작성하며 학습하세요.
# ================================================

"@
    ($header + $result) | Out-File -FilePath $StudyFile -Encoding UTF8
    Write-Host "✅ 학습용 파일 생성 완료: $StudyFile"
} catch {
    Write-Host "❌ 오류 발생: $_" -ForegroundColor Red
    exit 1
} finally {
    # 임시 파일 정리
    Remove-Item -Path $tempInput -Force -ErrorAction SilentlyContinue
}
