---
title: "[2026-05-17] GDPO.py 101~150줄 한국어 주석"
tags: ["python", "pytorch", "gdpo"]
---

## 오늘 배운 것

여기에 오늘 학습한 내용을 마크다운으로 작성하세요.

- 배운 개념 1: Length Reward
  seq_len이 target_len보다 길면 보상을 감소
  목표 길이보다 길어질수록 점수 줄어듦.
  반대로 목표 길이 이하라면 length_score=1.0
- 배운 개념 2: Accuracy Reward
  reference가 제공되면 생성된 텍스트에 포함 여부를 확인.
  단순히 ref_text in text로 포함 여부 체크하여 acc_score = 1.0부여.
  hard reward로 다른 보상에 조건을 걸 수 있음.

## 핵심 코드

if seq_len > target_len:
  
   목표 길이를 초과하면 보상감소

acc_score - 0.0
  if refereces and i < len(renferences):
  ref_textf = references[i]
  
   단순히 참조 텍스트가 생성 결과에 포함되는지 확인

조건부 보상 적용( 정확도 기반)
if use_conditioned_rewards:

## 회고

오늘은 GDPO의 보상 구조를 이해하는 학습을 시도.
정확도 보상 > 조건부 보상 > 길이/형식 보상의 흐름을 학습.
코드에 오타가 있어 실제 실행시 에러가 날시 수정 하는 과정도 필요함.
다음 학습에서 GDPO Loss 계산 과정을 더 깊게 살펴보고, 실제 학습 루프에서 어떻게 적용되는지 확인할 예정.

## 작업 파일

- [2026-05-17_GDPO_101-150.ipynb](../../Phase0_기초/GDPO_주석/2026-05-17_GDPO_101-150.ipynb)

## 핵심 코드

```python
# ================================================
# 🔵 학습 코드 — 여기에 오늘 읽은 GDPO.py 부분을 한국어 주석과 함께 작성
# ================================================

# The following reward calculation block is commented out because variables like
# seq_len and target_len are not defined in this scope. This code likely needs
# to be part of a function or class method where these variables are accessible.
#
# if seq_len > target_len:
#   # Decay reward beyond target length
#   length_score = max(0.0, 1.0 - (seq_len - target_len) / target_len)
# else:
#   length_score = 1.0
# # 3. Accuracy Reward (Hard reward - computed first as it may condition others)
# # if references (ground truth texts) are proviced, we check for containment or exact match.
# # For now, we assume simple containment of the reference of the reference answer in the generated <answer> block.
# acc_acore = 0.0
# if refereces and i < len(references):
#   ref_text = references[i]
#   # in a real secnario, we'd parse the <answer> part and compare.
#   # SimplifiedL Check if reference is inside generation.
#   if ref_text in text:
#     acc_score = 1.0
#
# # 4. Apply Conditioned Rewards (Paper Eq. 8)
# #Easier rewards (format, length)are conditioned on harder reward (accuracy)
# if use_conditioned_rewards:
#   format_score = condition_reward(format_score, accscore, condition_threshold)
#   length_score = condition_reward(length_score, acc_score, condition_threshold)
#
# ... (계속)
```

