# 아침 학습 루틴 자동 설정

매일 아침 **7시**에 자동으로:
- 💻 Windows 알림 표시 (알람 소리 반복)
- 🌐 Chrome에서 **3개 탭** 열기:
  - **탭 1 - LeetCode**: CLAUDE.md 로드맵에서 다음에 풀 문제의 페이지
  - **탭 2 - Colab 템플릿**: `daily-study-template.ipynb` 새 작업용
  - **탭 3 - GitHub**: 레포 메인
- 📝 **VS Code에서 두 파일 동시 열기**:
  - 왼쪽: 원본 GDPO.py (다음 주석 구간으로 자동 점프)
  - 오른쪽: 한글 주석 학습용 파일 (Claude CLI가 자동 생성, 색상 구분)

## GDPO 학습 흐름 (Claude CLI 자동 생성)

매일 아침 7시에 **자동으로 한글 주석이 달린 학습용 파일이 생성**됩니다:

- 원본: `GDPO.py` (영어 주석만)
- 학습용 (자동 생성): `GDPO_학습용_{범위}.py` (한글 주석 추가)

VS Code가 **두 파일을 동시에 열어** 나란히 비교하며 학습 가능합니다.

### 작동 방식 (실행 순서 - 복원력 설계)

**1단계: 즉시 열리는 것들 (실패 안 함)**
1. Windows Toast 알림 표시
2. Chrome 3개 탭 열기 (LeetCode, Colab, GitHub)
3. VS Code로 GDPO.py 열기 (다음 구간 라인으로 자동 점프)
   - 어제 생성한 학습용 파일이 있으면 함께 열기

**2단계: 백그라운드 생성 (실패해도 루틴 완료됨)**
4. CLAUDE.md에서 다음 🔲 구간 파싱 (예: 101~150줄)
5. GDPO.py에서 해당 구간 추출
6. `claude -p` (Claude CLI)로 한글 주석 생성 요청 (최대 **90초** 대기)
7. 생성 성공 시 → VS Code에 추가 탭으로 열기
8. 타임아웃/실패 시 → 경고 메시지만 남기고 계속 진행

> 💡 **설계 의도**: Claude CLI 생성이 네트워크/인증 문제로 실패해도 Chrome과 VS Code는 이미 열려 있어 **학습을 바로 시작할 수 있습니다**.

### 학습 흐름

1. **VS Code 왼쪽 탭**: 원본 GDPO.py (라인 101로 자동 점프)
2. **VS Code 오른쪽 탭**: `GDPO_학습용_101-150.py` (한글 주석 자동 생성됨)
3. 두 탭을 비교하며 학습 (Ctrl+`\` 단축키로 split view)
4. Chrome 탭 4 (본인 과거 노트북) 스타일도 참고
5. **탭 2 Colab 템플릿**에 **본인만의 한글 주석 작성** (카피 아닌 본인 이해)
6. 마지막 셀 실행 → GitHub 자동 push

### 전제조건

- Claude CLI(`claude` 명령)가 PATH에 있어야 함
- Claude 로그인 상태 (`claude auth` 완료)
- 같은 구간의 파일이 이미 있으면 **재생성 건너뜀** (시간 절약)
- 다시 생성하려면 `GDPO_학습용_101-150.py` 파일을 삭제 후 재실행

## 오늘 풀 문제는 어떻게 정해지나?

레포 루트의 **CLAUDE.md** 파일을 스크립트가 자동으로 읽습니다.
"LeetCode" 섹션의 표에서 **처음 나오는 🔲 상태 행의 문제**가 오늘의 문제입니다.

### 예시

```markdown
| Day | 문제 | 상태 |
|-----|------|------|
| Day 1 | #1 Two Sum | ✅ 완료 |
| Day 2 | #217 Contains Duplicate | ✅ 완료 |
| Day 3 | #121 Best Time to Buy/Sell Stock | 🔲 |   ← 오늘 풀 문제
```

이 상태라면 아침 7시에 `https://leetcode.com/problems/best-time-to-buy-and-sell-stock/`이 열립니다.

## GDPO 다음 구간은 어떻게 정해지나?

CLAUDE.md의 **"GDPO.py 코드 읽기"** 섹션도 자동으로 읽습니다:

```markdown
| 구간 | 상태 |
|------|------|
| 1~50줄 | ✅ 완료 |
| 51~100줄 | ✅ 완료 |
| 101~150줄 | 🔲 |   ← 오늘 작업할 구간
```

처음 나오는 숫자(101)를 추출해서 VS Code가 **GDPO.py의 101번 라인**으로 커서를 이동시킵니다.

**전제 조건**:
- GDPO.py 파일이 `C:\Users\745ra\OneDrive\바탕 화면\BIO\코드\GDPO.py` 에 있어야 함
- VS Code가 설치되어 있어야 함
- 경로가 다르면 `scripts/morning-routine.ps1` 상단의 `$GdpoPath` 수정

## 완료 시 할 일 (LeetCode + GDPO 공통)

CLAUDE.md에서 해당 행을 직접 수정:

```markdown
| Day 3 | #121 Best Time to Buy/Sell Stock | ✅ 완료 |
| 101~150줄 | ✅ 완료 |
```

다음날 아침부터 자동으로 다음 🔲 과제가 열립니다.

## 설정 방법 (1회만 실행)

### 1. PowerShell 열기

시작 메뉴에서 `PowerShell` 검색 → **Windows PowerShell** 실행 (관리자 권한 불필요)

### 2. 작업 스케줄러 등록

```powershell
cd "C:\Users\745ra\nous-zero-journey"
powershell -ExecutionPolicy Bypass -File ".\scripts\setup-morning-routine.ps1"
```

### 3. Wake Timer + 잠금 화면 알림 설정 (권장)

절전 모드에서 자동으로 깨어나고, 잠금 화면에서도 알림이 울리게 합니다:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\setup-wake-and-notifications.ps1"
```

이 스크립트가 설정하는 것:
- ✅ Wake Timer 활성화 (절전에서 자동 기상)
- ✅ 잠금 화면에 알림 표시 허용
- ✅ 알림 소리 활성화

### 4. VS Code Workspace Trust 비활성화 (권장)

매번 "Trust this folder?" 묻지 않도록 설정:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\setup-vscode-trust.ps1"
```

설정되는 내용:
- ✅ Restricted Mode 배너 자동 제거
- ✅ 모든 폴더 자동 신뢰
- ✅ 모든 파일 편집/실행 즉시 가능

⚠️ 개인 학습 PC에서만 권장. 되돌리려면 VS Code 설정에서 "workspace trust" 검색 → Enabled 체크.

### 5. VS Code 한글 주석 색상 구분 (권장)

Better Comments 확장으로 한글 주석을 눈에 띄게 표시:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\setup-vscode-comments.ps1"
```

설정되는 내용:
- ✅ Better Comments 확장 자동 설치
- ✅ 색상 태그 4개 자동 등록:

| 접두어 | 색상 | 용도 |
|--------|------|------|
| `★` | 샌드스톤 (부드러운 베이지) | 기본 한국어 설명 |
| `◎` | 스틸블루 (부드러운 청회색) | 핵심 개념/중요 포인트 |
| `※` | 로즈 (부드러운 분홍) | 주의/경고 |
| `→` | 모스그린 (부드러운 녹색) | 처리 흐름/단계 |

눈에 편한 muted 팔레트로 장시간 읽기에 적합합니다.

### 한글 주석 예시

```python
if seq_len > target_len:  # ★ 시퀀스 길이가 목표보다 크면 (금색)
    length_score = max(0.0, ...)  # ◎ 핵심: 길이 페널티 계산 (시안)
    # ※ 주의: seq_len이 0이면 나눗셈 오류 (빨강)
    # → 다음: else 블록에서 짧은 경우 처리 (연두)
```

아침 루틴의 `generate-gdpo-study.ps1`이 자동으로 이 접두어를 사용해서 한글 주석을 생성하므로, 확장만 설치하면 색상이 바로 적용됩니다.

## 바로 테스트

내일까지 기다리지 않고 지금 테스트하려면:

```powershell
Start-ScheduledTask -TaskName "NousZero-MorningRoutine"
```

실행 결과:
- 알림 팝업이 화면 우측 하단에 표시됨
- Chrome에서 새 창이 열리며 3개 탭 자동 로드

## 시간 변경

7시 → 다른 시간으로 바꾸려면 `scripts/setup-morning-routine.ps1`의 아래 줄을 수정 후 재실행:

```powershell
$TriggerTime = "07:00"   # 원하는 시간으로 변경 (예: "06:30", "08:00")
```

## URL 변경

LeetCode/Colab/GitHub 외 다른 사이트를 원한다면 `scripts/morning-routine.ps1`에서 수정:

```powershell
$Urls = @(
    "https://leetcode.com/problemset/",
    "https://colab.research.google.com/",
    "https://github.com/nous-zero/nous-zero-journey"
    # 여기에 URL 추가 가능
)
```

## 해제

더 이상 자동 실행을 원하지 않으면:

```powershell
Unregister-ScheduledTask -TaskName "NousZero-MorningRoutine" -Confirm:$false
```

또는 작업 스케줄러 앱에서 `NousZero-MorningRoutine` 검색 → 삭제

## 📋 진단 및 로그

모든 아침 루틴 실행은 **`%USERPROFILE%\morning-routine.log`** 에 자동 기록됩니다.

### 로그 확인 명령

```powershell
# 최근 100줄 보기
Get-Content "$env:USERPROFILE\morning-routine.log" -Tail 100

# 실시간으로 보기 (루틴 실행 중 모니터링)
Get-Content "$env:USERPROFILE\morning-routine.log" -Wait -Tail 30
```

### 작업 스케줄러 결과 확인

```powershell
Get-ScheduledTaskInfo -TaskName "NousZero-MorningRoutine" |
    Format-List LastRunTime, LastTaskResult, NextRunTime
```

| 결과 코드 | 의미 |
|-----------|------|
| `0` | 정상 완료 |
| `267011` | 트리거 시 PC가 꺼져있어서 실행 안 됨 |
| `3221225786` (0xC000013A) | 스크립트가 강제 종료됨 (CTRL+C) |
| 기타 | 로그 파일에서 상세 확인 |

### 로그 로테이션

파일이 1MB를 넘으면 최근 500줄만 유지되므로 **수동 정리 불필요**합니다.

## 문제 해결

### 알림이 안 뜸
- Windows 설정 > 시스템 > 알림 및 작업 → "알림 받기" 활성화 확인
- **"집중 지원" 모드**가 활성화되어 있으면 알림이 표시되지 않을 수 있음
  - 설정 > 시스템 > 집중 지원 → **"해제"** 선택 권장
  - "우선 순위만"으로 두면 일반 알림이 알림 센터로만 가고 화면에 안 뜸
  - "해당 시간 동안" 자동 규칙의 스위치를 끄세요 (끄지 않으면 23:00-07:00 우선 순위만 적용)

### PC가 잠자기 상태였을 때
- 스크립트에 `-WakeToRun` 옵션이 있어 PC를 깨워서 실행합니다
- 단, 완전히 꺼진(shutdown) PC는 깨어나지 않습니다. 절전/최대 절전 모드는 깨어남

### Chrome이 열리지 않음
- 기본 브라우저로 대신 열립니다 (fallback 동작)
- Chrome 설치 경로가 비표준이면 `morning-routine.ps1`의 `$ChromePaths`에 경로 추가

### VS Code가 안 열리거나 학습용 파일이 생성 안 됨
새 구조에서는 **VS Code가 Claude CLI보다 먼저** 실행되므로 VS Code는 거의 항상 열립니다.

학습용 한글 주석 파일 생성만 실패하는 경우:
- 로그 확인: `Get-Content "$env:USERPROFILE\morning-routine.log" -Tail 30`
- "타임아웃 (90초 초과)" 메시지가 있으면:
  - Claude CLI 인증 상태 확인: `claude auth status`
  - 수동 생성: `powershell -ExecutionPolicy Bypass -File "C:\Users\745ra\nous-zero-journey\scripts\generate-gdpo-study.ps1"`
- 네트워크 연결 확인 (Claude API 호출 필요)

### 실행 정책 오류
PowerShell에서 `ExecutionPolicy` 오류가 나면:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## 작동 원리

- **Windows 작업 스케줄러**가 매일 7시에 PowerShell 스크립트를 실행
- 스크립트가 Windows 10/11의 Toast Notification API 사용하여 알림 표시
- Chrome을 `--new-window` 옵션으로 실행하여 3개 탭이 새 창에 한번에 로드됨
- PC가 절전 모드면 `WakeToRun` 설정으로 깨워서 실행
