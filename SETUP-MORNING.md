# 아침 학습 루틴 자동 설정

매일 아침 **7시**에 자동으로:
- 💻 Windows 알림 표시 (알람 소리 반복)
- 🌐 Chrome에서 3개 탭 열기:
  - **LeetCode**: CLAUDE.md 로드맵에서 다음에 풀 문제의 페이지
  - **Colab**: `daily-study-template.ipynb` 바로 열림
  - **GitHub**: 레포 메인
- 📝 **VS Code에서 GDPO.py의 다음 주석 구간으로 바로 점프**
  - 예: CLAUDE.md의 "101줄~ 🔲"를 읽고 VS Code가 101번 라인으로 커서 이동

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
| 101줄~ | 🔲 |   ← 오늘 작업할 구간
```

처음 나오는 숫자(101)를 추출해서 VS Code가 **GDPO.py의 101번 라인**으로 커서를 이동시킵니다.

**전제 조건**:
- GDPO.py 파일이 `C:\Users\745ra\AIGEN\GDPO.py` 에 있어야 함
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

### 3. 확인

등록이 성공하면 아래 메시지가 표시됩니다:
```
✅ 등록 완료!
내일 아침 07:00 에 자동으로 실행됩니다.
```

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
