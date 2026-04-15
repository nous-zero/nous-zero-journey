"""LinkedIn 자동 포스팅 스크립트

summary.md를 파싱하여 LinkedIn에 학습 기록을 포스팅합니다.

사용법:
    python scripts/publish_linkedin.py path/to/summary.md

환경변수:
    LINKEDIN_ACCESS_TOKEN: LinkedIn OAuth 2.0 액세스 토큰
    LINKEDIN_PERSON_ID: LinkedIn 사용자 ID (URN 형식의 숫자 부분)

LinkedIn API 설정 방법은 SETUP.md를 참고하세요.
"""

import sys
import os
import re
import requests


LINKEDIN_API_URL = "https://api.linkedin.com/v2/ugcPosts"


def parse_summary(filepath):
    """summary.md에서 제목과 본문 추출"""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    title = ""
    body = content

    match = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)$", content, re.DOTALL)
    if match:
        fm_text = match.group(1)
        body = match.group(2).strip()

        title_match = re.search(r'title:\s*"(.+?)"', fm_text)
        if title_match:
            title = title_match.group(1)

    return title, body


def create_linkedin_post(title, body):
    """LinkedIn에 텍스트 포스트 생성"""
    access_token = os.environ.get("LINKEDIN_ACCESS_TOKEN")
    person_id = os.environ.get("LINKEDIN_PERSON_ID")

    if not access_token or not person_id:
        print("LINKEDIN_ACCESS_TOKEN or LINKEDIN_PERSON_ID not set, skipping LinkedIn publish")
        return

    # LinkedIn 포스트용 텍스트 생성 (마크다운 → 플레인텍스트 변환)
    # 코드 블록 제거, 헤딩 → 이모지로 변환
    post_text = f"{title}\n\n"

    # 마크다운을 LinkedIn 친화적 텍스트로 변환
    clean_body = body
    clean_body = re.sub(r"```[\s\S]*?```", "[코드는 GitHub에서 확인]", clean_body)
    clean_body = re.sub(r"^## ", "\n", clean_body, flags=re.MULTILINE)
    clean_body = re.sub(r"^### ", "", clean_body, flags=re.MULTILINE)
    clean_body = re.sub(r"^- ", "  - ", clean_body, flags=re.MULTILINE)

    post_text += clean_body.strip()
    post_text += "\n\n#AI #MachineLearning #DeepLearning #LeetCode #CodingJourney"
    post_text += f"\n\nhttps://github.com/nous-zero/nous-zero-journey"

    # 2000자 제한
    if len(post_text) > 2000:
        post_text = post_text[:1990] + "...\n\n[전체 내용은 GitHub에서]"

    payload = {
        "author": f"urn:li:person:{person_id}",
        "lifecycleState": "PUBLISHED",
        "specificContent": {
            "com.linkedin.ugc.ShareContent": {
                "shareCommentary": {
                    "text": post_text,
                },
                "shareMediaCategory": "NONE",
            }
        },
        "visibility": {
            "com.linkedin.ugc.MemberNetworkVisibility": "PUBLIC",
        },
    }

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
        "X-Restli-Protocol-Version": "2.0.0",
    }

    response = requests.post(LINKEDIN_API_URL, json=payload, headers=headers)

    if response.status_code == 201:
        print(f"LinkedIn post created successfully!")
        post_id = response.json().get("id", "")
        print(f"  Post ID: {post_id}")
    else:
        print(f"LinkedIn publish failed ({response.status_code}): {response.text}")
        sys.exit(1)


def main():
    if len(sys.argv) < 2:
        print("Usage: python publish_linkedin.py <summary.md path>")
        sys.exit(1)

    filepath = sys.argv[1]
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        sys.exit(1)

    title, body = parse_summary(filepath)
    create_linkedin_post(title, body)


if __name__ == "__main__":
    main()
