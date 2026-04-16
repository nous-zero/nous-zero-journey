---
title: "[2026-04-16] GDPO.py 51~100줄 주석 / LeetCode #217 Contains Duplicate"
tags: ["python", "pytorch", "gdpo", "leetcode"]
---
 
## 오늘 배운 것

GDPO.py 51~100줄 주석 / LeetCode #217 Contains Duplicate

## 핵심 코드

```python
# Daily Study Template

# Cell 0: GitHub/Drive 설정 (처음 한 번만 실행)
# Cell 1: 학습 설정 (매일 수정)
# Cell 2~N: 학습 내용 (자유롭게 작성)
"""
오늘 배운 것
여기에 오늘 학습한 내용을 마크다운으로 작성하세요.

배운 개념 1
배운 개념 2
핵심 코드
아래 코드 셀에 핵심 코드를 작성하세요.

회고
오늘 학습에 대한 짧은 회고를 작성하세요.
"""

# # 여기에 오늘 공부한 코드를 작성하세요
# 마지막 셀: 원클릭 배포 (공부 끝나면 실행)

# ================================================
# 마지막 셀: 원클릭 배포 (공부 끝나면 이것만 실행!)
# GitHub push -> Actions가 DEV.to + LinkedIn 자동 발행
# ================================================
```

```python
import torch
from typing import Tuple, Optional, List # Needed for type hints

# # ================================================
# # Cell 2: 학습 코드
# # ================================================

# #"GDPO.py 51~100줄 주석

# To make the 'self' variables and methods runnable, they need to be part of a class.
# This is a placeholder class to contain the code snippets from GDPO.py.
class GDPOAgent:
    def __init__(self, gdpo_config, tokenizer, max_new_tokens, G):
        self.gdpo_config = gdpo_config
        self.tokenizer = tokenizer
        self.max_new_tokens = max_new_tokens
        self.G = G

        #Reward config / 보상(Reward) 관련 설정
        self.use_conditioned_rewards = self.gdpo_config.get("use_conditioned_rewards",False)
                              # 조건부 보상 여부. 기본 False
        self.accuracy_threshold = self.gdpo_config.get("accuracy_threshold",1.0)
                              # 정확도 기준점. 기본 1.0(100%)
        self.target_length = self.gdpo_config.get("target_length",1024)
                              # 목표 출력 길이(토큰수). 기본 1024 # Corrected: added #

        # Tool Reward config / 도구 사용 보상 설정 (GDPO 논문. 기본값 : 활성화)
        self.enable_tool_reward = self.gdpo_config.get("enable_tool_reward", True)
                              # 도구 사용 보상 활성화 여부. 기본 True(켜짐)
        self.tool_correctness_threshold=self.gdpo_config.get("enable_tool_reward", True) # Assuming intentional re-use of key
                              # 도구 정답 판단 기준점. 기본 1.5

        #Reasoning Judge config / 추론 품질 심사 설정
        self.enable_reasoning_judge = self.gdpo_config.get("enable_reasoning_judge",False)
                              #추론 품질 심사 사용 여부.기본 False
        self.reasoning_judge = None # 심사도구. 아직 없으므로 None으로 초기화
        self.reasoning_quality_threshold = 0.5
                              # 추론 품질 합격 기준. 0.5(50점 이상이면 통과)

        if self.enable_reasoning_judge: #만약 추론 심사가 켜져 있다면
            # from utils.reasoning_judge import Reasoningjudge # Commented out as utils is not available
            # self.reasoning_judge = Reasoningjudge()
            print("ReasoningJudge is enabled but not initialized as utils.reasoning_judge is not available.")
                              # 심사 도구를 실제로 만들어서 저장

        # Memory Optimization config / 메모리 최적화 설정
        self.sequential = self.gdpo_config.get("sequential", False)
                              #순차 처리 모드. True면 메모리 절약, 기본 False

    def generate_samles(            # "샘플을 생성하라"는 기능(함수)을 만든다
        self,             # 이 상자(클래스) 자신
        model: torch.nn.Module, #AI 언어 모델(생성에 사용)
        input_ids:torch.Tensor, #입력 텍스트를 숫자로 바꾼 것(B, seq_len) 형태
        attention_mask: torch. Tensor # 어떤 토큰을 봐야 하는지 표시 (B, seq_len) 형태
    ) -> Tuple[torch.Tensor, Optional[torch.Tensor], int]:
                                # 반환값: (생성된 시퀀스, 온도 보상값 또는 None, 실제 그룹 크기)
        """
        온도 대비 샘플링 옵션이 있는 샘플 생성 함수

        Args(입력값):
          model: 언어 모델
          input_ids: 입력 토큰 ID (B=배치크기, seq_len=문장길이)
          attention_mask: 어텐션 마스크

        Returns(반환값):
          sequences: 생성된 시퀀스 (B * effective_G, seq_len)
          temperature_rewards: 온도 라벨 또는 None
          effective_G: 실제 그룹 크기 (G또는 2G)
        """
        gen_kwargs = { #생성(generation)에 필요한 설정값들을 딕셔너리로 묶음
          "max_new_tokens":self.max_new_tokens, # 최대 생성 토큰수 # Corrected: removed @
          "do_sample": True, #True = 확룰적으로 다양하게 생성(False면 항상 같은 결과)
          "top_p": 0.95,  # 상위 95% 확률 토큰 중에서만 선택 (nucleus sampling) # Corrected: added comma
          "pad_token_id": self.tokenizer.pad_token_id,
                            #문장 길이 맞추기용 패팅 토큰 iD
          "eos_token_id": self.tokenizer.eos_token_id,
                            #문장 끝을 알리는 토큰 ID
          "num_return_sequences": self.G,
                            # 한 입력당 G개의 답변을 생성
          "use_cache":False, # 캐시 사용 안 함 (메모리 절약)
                       }
        # Placeholder for generation logic
        # For demonstration, returning dummy values
        return torch.empty(1), None, 1


# LeetCode #217 Contains Duplicate" 배열, 중복 확인

# 217. Contains Duplicate
# Easy
# Given an integer array nums, return true if any value appears at least
# twice in the array, and return false if every element is distinct.

#   # 정수 배열 nums가 주어졌을때,
#   # 배열에 어떤 값이 두번 이상 나타나면 true를 출력하고
#   # 모든 요소가 서로 다르면 false를 출력하세요.

# Example 1:

# Input: nums = [1,2,3,1]

# Output: true

# Explanation:

# The element 1 occurs at the indices 0 and 3.

# Example 2:

# Input: nums = [1,2,3,4]

# Output: false

# Explanation:

# All elements are distinct.

# Example 3:

# Input: nums = [1,1,1,3,3,4,3,2,4,2]

# Output: true

# -----------------------

# LeetCode #1회 for 문 활용

class SolutionForLoop: # Renamed to avoid clash with Solution below
  def containsDuplicate(self, nums: List[int])->bool: # 중복성에 대한 기능
    for i in range(len(nums)): # 첫번째 숫자
        for j in range(i+1, len(nums)): # 첫번째 숫자 다음 숫자들과 비교
          if nums[i] == nums[j]: # i와 j의 같은 숫자 있다면
              return True # True를 출력
    return False #없으면 False 출력 # Corrected: Fasle -> False

# 집합 사용
class Solution:
    def containsDuplicate(self, nums: List[int]) -> bool:
        return len(nums) !=len(set(nums))
          # 중복을 자동으로 제거한 집합이 원래 길이와 다르면 중복 출력

# LeetCode #217 Contains Duplicate" 배열, 중복 확인에서
# for 문 / set(nums) 학습
"""
for 변수 in 반복할것: 반복할것 안에서 하나씩 꺼내서-> 변수에 담고-> 코드 실행
ex) for i in range(5):
print(i)
출력
0
1
2
3
4

for i in range(2,6):
  print(i)
출력
2
3
4
5

nums = [10,20,30]
for n in nums:
  print(n)
출력
10
20
30

for i in range(3):
  for j in range(3):
    print(i,j)
출력
00
01
02
10
11
12
20
21
22
"""

# Constraints:

# 1 <= nums.length <= 105
# -109 <= nums[i] <= 109
```

