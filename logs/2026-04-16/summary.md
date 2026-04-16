---
title: "[2026-04-16] GDPO.py 51~100줄 주석 / LeetCode #217 Contains Duplicate"
tags: ["python", "pytorch", "gdpo", "leetcode", "array"]
---

## 오늘 배운 것

### GDPO (GDPO.py 51~100줄)
- Reward / Tool Reward / Reasoning Judge 설정 구조 이해
- `self.gdpo_config.get(key, default)` 패턴으로 안전한 기본값 지정
- `generate_samples` 메서드의 `gen_kwargs` 구성 (top_p, num_return_sequences 등)
- Sequential 모드로 메모리 최적화

### LeetCode #217 Contains Duplicate (Array)
- 이중 for 문 풀이: O(n²) — 직관적이지만 느림
- `set()` 사용 풀이: O(n) — 한 줄로 해결
- 핵심 학습: Python `set`의 '중복 자동 제거' 특성 활용

## 작업 파일

- [Phase0_기초/GDPO_주석/2026-04-16_GDPO_51-100.ipynb](../../Phase0_기초/GDPO_주석/2026-04-16_GDPO_51-100.ipynb)
- [Phase0_기초/Array/2026-04-16_LeetCode#217_ContainsDuplicate.ipynb](../../Phase0_기초/Array/2026-04-16_LeetCode%23217_ContainsDuplicate.ipynb)

## 회고

- 이중 for 문과 set 풀이를 비교하면서 시간복잡도 감을 잡음
- GDPO의 설정 패턴이 파이썬스러운 것을 익숙해지고 있음
- 다음 목표: LeetCode #1 Two Sum (Array + HashMap)
