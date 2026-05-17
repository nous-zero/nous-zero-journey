---
title: "[2026-05-17] LeetCode #26 Remove Duplicates from Sorted Array"
tags: ["python", "leetcode", "array"]
---

## 오늘 배운 것

**LeetCode #26 — Remove Duplicates from Sorted Array (Easy)**

정렬된 배열에서 중복을 제거하고(in-place), 고유 원소의 개수 `k`를 반환하는 문제.

- **투 포인터(two-pointer) 기법**: 포인터 두 개를 따로 굴린다.
  - `i` (읽기 포인터): `for`문으로 배열 전체를 1번 칸부터 순서대로 훑는다.
  - `write_index` (쓰기 포인터): 고유값을 채워 넣을 위치. 새 값을 쓸 때마다 한 칸 전진.
- `nums[i] != nums[i-1]` → 현재 칸 값 ≠ 바로 왼쪽 칸 값. 배열이 *정렬*돼 있으므로, 직전 값과 다르면 처음 보는 새 고유값이다.
- `write_index = 1`로 시작하는 이유: 0번 칸에는 이미 첫 고유값(`nums[0]`)이 있어 다시 쓸 필요가 없다. 두 번째 고유값부터 채울 1번 칸이 시작점.
- `write_index += 1`: 한 칸 채웠으면 포인터를 옮겨야 다음 값이 *다음 칸*에 들어간다. 안 옮기면 덮어쓰기로 이전 값이 사라진다.

**함께 정리한 Python 기초 개념**

- `for`문: 시퀀스의 각 항목을 순서대로 빠짐없이 반복. 반복 변수 `i`는 `for`문이 자동으로 만들어 준다(따로 `i = 0` 불필요).
- `if`문: 함수가 아니라 **조건문**. 조건이 참일 때만 들여쓴 블록을 실행한다.
- `==`(같다, 비교) ↔ `=`(대입)은 다르다. `!=`는 "같지 않다". Python에서 `!` 하나만으로는 연산자가 아니다(논리 부정은 `not`).
- `for`, `if` 문은 `:` 콜론으로 끝내고, 다음 줄부터 들여쓰기로 블록을 만든다.

## 핵심 코드

```python
class Solution:
    def removeDuplicates(self, nums: list[int]) -> int:
        write_index = 1
        for i in range(1, len(nums)):
            if nums[i] != nums[i - 1]:
                nums[write_index] = nums[i]
                write_index += 1
        return write_index
```

- `range(1, len(nums))` — 0번 칸은 비교 대상이 없으므로 1번 칸부터 훑는다.
- `nums[i] != nums[i-1]`이 참이면 새 고유값 → `write_index` 칸에 복사하고 포인터 전진.
- 거짓(중복)이면 아무것도 안 하고 건너뛴다.
- 마지막에 `write_index`(채워 넣은 고유값 개수 = `k`)를 반환.
- 결과: 배열 앞쪽 `k`칸에 고유값이 정렬된 채 남는다. Runtime 0 ms로 Accepted.

## 회고

처음 작성한 코드에는 실수가 5개 있었다 — 입력 배열 덮어쓰기, `if i=0`(불필요 + 문법 오류), 콜론 누락 2곳, `if` 블록 본문 비어 있음. 하나씩 고쳐 정답을 완성했지만, 제출 단계에서 `IndentationError`가 또 났다. 코드가 틀린 게 아니라 복사·붙여넣기 과정에서 들여쓰기가 어긋난 환경 문제였다.

오늘 가장 크게 느낀 것: 알고리즘을 모르는 게 아니라, 한국어로 이해한 내용을 Python 문법으로 "번역"하는 단계에서 막힌다는 것. write_index 로직을 말로는 정확히 설명했는데 코드로는 한 줄도 못 옮겼던 게 그 증거다. 에러 메시지를 "실패"가 아니라 "어디를 고치라는 안내"로 읽는 연습도 됐다.

## 작업 파일

- [2026-05-17_LeetCode26_RemoveDuplicates.ipynb](../../Phase0_기초/Array/2026-05-17_LeetCode26_RemoveDuplicates.ipynb)

## 핵심 코드

```python
# ================================================
# 🔵 학습 코드 — 여기에 오늘 공부한 코드를 작성
# ================================================

class Solution:
    def removeDuplicates(self, nums: list[int]) -> int:
        write_index = 1
        for i in range(1, len(nums)):
            if nums[i] != nums[i - 1]:
                nums[write_index] = nums[i]
                write_index += 1
        return write_index
```

