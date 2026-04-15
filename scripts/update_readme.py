"""README.md 자동 업데이트 스크립트

summary.md가 push될 때마다 README.md의 학습 로그 섹션을 업데이트합니다.

사용법:
    python scripts/update_readme.py path/to/summary.md
"""

import sys
import os
import re
import glob


def get_all_study_logs():
    """모든 날짜 폴더의 summary.md에서 학습 로그를 수집"""
    logs = []

    for summary_path in sorted(glob.glob("*/summary.md"), reverse=True):
        date_dir = os.path.dirname(summary_path)

        with open(summary_path, "r", encoding="utf-8") as f:
            content = f.read()

        title = date_dir  # 기본값: 날짜 폴더명

        match = re.search(r'title:\s*"(.+?)"', content)
        if match:
            title = match.group(1)

        logs.append({"date": date_dir, "title": title})

    return logs[:10]  # 최근 10개만


def update_readme(logs):
    """README.md 업데이트"""
    readme_path = "README.md"

    if os.path.exists(readme_path):
        with open(readme_path, "r", encoding="utf-8") as f:
            existing = f.read()
    else:
        existing = ""

    # 학습 로그 섹션 생성
    log_section = "## 최근 학습 기록\n\n"
    log_section += "| 날짜 | 내용 |\n"
    log_section += "|------|------|\n"

    for log in logs:
        log_section += f"| {log['date']} | {log['title']} |\n"

    log_section += "\n"

    # 기존 학습 로그 섹션이 있으면 교체, 없으면 추가
    marker_start = "## 최근 학습 기록"
    marker_end_pattern = r"\n## (?!최근 학습)"

    if marker_start in existing:
        # 기존 섹션 교체
        parts = existing.split(marker_start, 1)
        after_section = parts[1]

        # 다음 ## 헤딩 찾기
        next_heading = re.search(marker_end_pattern, after_section)
        if next_heading:
            rest = after_section[next_heading.start():]
        else:
            rest = ""

        new_readme = parts[0] + log_section + rest
    else:
        # 섹션 추가
        new_readme = existing.rstrip() + "\n\n" + log_section

    with open(readme_path, "w", encoding="utf-8") as f:
        f.write(new_readme)

    print(f"README.md updated with {len(logs)} study logs")


def main():
    if len(sys.argv) < 2:
        print("Usage: python update_readme.py <summary.md path>")
        sys.exit(1)

    logs = get_all_study_logs()
    if logs:
        update_readme(logs)
    else:
        print("No study logs found")


if __name__ == "__main__":
    main()
