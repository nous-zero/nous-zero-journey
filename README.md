# Nous-Zero의 AI 학습 여정

매일 학습한 내용을 기록하고, GitHub/DEV.to/LinkedIn에 자동 배포합니다.

## 구조 (하이브리드: 주제별 + 날짜별)

```
Phase0_기초/              ← 주제별 (포트폴리오)
├── Array/
├── String/
├── Stack/
├── LinkedList/
├── HashMap/
├── BinarySearch/
└── GDPO_주석/

logs/                     ← 날짜별 (꾸준함 + 자동화 트리거)
└── {날짜}/summary.md      ← 그날 한 일 요약
```

- `Phase0_기초/{주제}/YYYY-MM-DD_파일명.ipynb` — 실제 학습 노트북
- `logs/{날짜}/summary.md` — 일일 요약 (GitHub Actions 트리거)
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

## 주제별 진도

| 주제 | 파일 수 |
|------|---------|
| [Array](Phase0_기초/Array/) | 1 |
| [BinarySearch](Phase0_기초/BinarySearch/) | 0 |
| [GDPO_주석](Phase0_기초/GDPO_주석/) | 2 |
| [HashMap](Phase0_기초/HashMap/) | 0 |
| [LinkedList](Phase0_기초/LinkedList/) | 0 |
| [Stack](Phase0_기초/Stack/) | 0 |
| [String](Phase0_기초/String/) | 0 |

## 최근 학습 기록

| 날짜 | 내용 |
|------|------|
| [2026-04-16](logs/2026-04-16/summary.md) | [2026-04-16] GDPO.py 51~100줄 주석 / LeetCode #217 Contains Duplicate |
| [2026-04-15](logs/2026-04-15/summary.md) | [2026-04-15] GDPO.py 51~100줄 주석 / LeetCode #20 |

