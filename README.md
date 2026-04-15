# Nous-Zero의 AI 학습 여정

매일 학습한 내용을 기록하고, GitHub/DEV.to/LinkedIn에 자동 배포합니다.

## 구조
- 날짜별 폴더 (예: 2026-04-15/)
  - LeetCode 풀이
  - GDPO.py 코드 주석 작업
  - `summary.md` — 학습 요약 (자동 생성)
- `templates/` — Colab 노트북 템플릿
- `scripts/` — 자동 배포 스크립트
- `.github/workflows/` — GitHub Actions 파이프라인

## 자동화 파이프라인

```
Colab 학습 -> 마지막 셀 실행 -> GitHub push
                                  |
                          GitHub Actions 자동 실행
                          |- DEV.to 블로그 발행 (초안)
                          |- LinkedIn 포스트 발행
                          |- README 학습 기록 업데이트
```

설정 방법은 [SETUP.md](SETUP.md)를 참고하세요.

## 목표
- LeetCode Easy 30문제
- GDPO.py 전체 한국어 주석
- Google L3/L4 AI Engineer

## 최근 학습 기록

| 날짜 | 내용 |
|------|------|
| 2026-04-15 | [2026-04-15] LeetCode #20 Valid Parentheses 완료 / GDPO 51~100줄 주석 |
