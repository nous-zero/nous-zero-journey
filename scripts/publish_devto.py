"""DEV.to 자동 발행 스크립트

summary.md를 파싱하여 DEV.to에 블로그 포스트를 발행합니다.
기본적으로 draft(초안) 상태로 발행되므로 DEV.to에서 확인 후 직접 공개할 수 있습니다.

사용법:
    python scripts/publish_devto.py path/to/summary.md

환경변수:
    DEVTO_API_KEY: DEV.to API 키 (https://dev.to/settings/extensions)
"""

import sys
import os
import json
import re
import requests


DEVTO_API_URL = "https://dev.to/api/articles"


def parse_summary(filepath):
    """summary.md에서 frontmatter와 본문을 파싱"""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # YAML frontmatter 파싱
    frontmatter = {}
    body = content

    match = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)$", content, re.DOTALL)
    if match:
        fm_text = match.group(1)
        body = match.group(2).strip()

        # title 추출
        title_match = re.search(r'title:\s*"(.+?)"', fm_text)
        if title_match:
            frontmatter["title"] = title_match.group(1)

        # tags 추출
        tags_match = re.search(r"tags:\s*\[(.+?)\]", fm_text)
        if tags_match:
            tags_str = tags_match.group(1)
            frontmatter["tags"] = [
                t.strip().strip("\"'") for t in tags_str.split(",")
            ]

    return frontmatter, body


def publish_to_devto(frontmatter, body):
    """DEV.to API로 포스트 발행 (초안 상태)"""
    api_key = os.environ.get("DEVTO_API_KEY")
    if not api_key:
        print("DEVTO_API_KEY not set, skipping DEV.to publish")
        return

    title = frontmatter.get("title", "Daily Study Log")
    tags = frontmatter.get("tags", [])

    # DEV.to는 태그 4개까지만 허용
    tags = tags[:4]

    # 본문에 GitHub 링크 추가
    github_link = "\n\n---\n*이 글은 [nous-zero-journey](https://github.com/nous-zero/nous-zero-journey)에서 자동 발행되었습니다.*\n"
    full_body = body + github_link

    payload = {
        "article": {
            "title": title,
            "body_markdown": full_body,
            "published": False,  # 초안으로 발행 (DEV.to에서 확인 후 공개)
            "tags": tags,
            "series": "Nous-Zero AI Learning Journey",
        }
    }

    headers = {
        "api-key": api_key,
        "Content-Type": "application/json",
    }

    response = requests.post(DEVTO_API_URL, json=payload, headers=headers)

    if response.status_code == 201:
        article = response.json()
        print(f"DEV.to draft created: {article.get('url', 'unknown')}")
        print(f"  ID: {article.get('id')}")
        print(f"  Edit at: https://dev.to/dashboard")
    else:
        print(f"DEV.to publish failed ({response.status_code}): {response.text}")
        sys.exit(1)


def main():
    if len(sys.argv) < 2:
        print("Usage: python publish_devto.py <summary.md path>")
        sys.exit(1)

    filepath = sys.argv[1]
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        sys.exit(1)

    frontmatter, body = parse_summary(filepath)
    publish_to_devto(frontmatter, body)


if __name__ == "__main__":
    main()
