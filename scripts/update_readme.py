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
    """logs/ 안의 모든 날짜 폴더의 summary.md에서 학습 로그를 수집"""
    logs = []

    for summary_path in sorted(glob.glob("logs/*/summary.md"), reverse=True):
        date_dir = os.path.basename(os.path.dirname(summary_path))

        with open(summary_path, "r", encoding="utf-8") as f:
            content = f.read()

        title = date_dir  # 기본값: 날짜 폴더명

        match = re.search(r'title:\s*"(.+?)"', content)
        if match:
            title = match.group(1)

        logs.append({
            "date": date_dir,
            "title": title,
            "log_path": summary_path.replace(os.sep, "/"),
        })

    return logs[:10]  # 최근 10개만


def count_topic_files():
    """주제별 학습 파일 수 집계"""
    topics = {}
    phase_dir = "Phase0_기초"
    if not os.path.isdir(phase_dir):
        return topics

    for topic in sorted(os.listdir(phase_dir)):
        topic_path = os.path.join(phase_dir, topic)
        if not os.path.isdir(topic_path):
            continue
        # .ipynb 파일 수 세기
        count = len(glob.glob(os.path.join(topic_path, "*.ipynb")))
        topics[topic] = count
    return topics


def update_readme(logs):
    """README.md 업데이트"""
    readme_path = "README.md"

    if os.path.exists(readme_path):
        with open(readme_path, "r", encoding="utf-8") as f:
            existing = f.read()
    else:
        existing = ""

    # 주제별 진도 섹션
    topics = count_topic_files()
    topic_section = ""
    if topics:
        topic_section = "## 주제별 진도\n\n"
        topic_section += "| 주제 | 파일 수 |\n"
        topic_section += "|------|---------|\n"
        for topic, count in topics.items():
            topic_section += f"| [{topic}](Phase0_기초/{topic}/) | {count} |\n"
        topic_section += "\n"

    # 학습 로그 섹션 생성
    log_section = topic_section + "## 최근 학습 기록\n\n"
    log_section += "| 날짜 | 내용 |\n"
    log_section += "|------|------|\n"

    for log in logs:
        log_section += f"| [{log['date']}]({log['log_path']}) | {log['title']} |\n"

    log_section += "\n"

    # 기존 자동 생성 섹션이 있으면 교체, 없으면 추가
    # "## 주제별 진도"부터 끝까지(또는 다음 비-자동 섹션까지) 교체
    start_marker = "## 주제별 진도"
    alt_marker = "## 최근 학습 기록"

    if start_marker in existing:
        idx = existing.index(start_marker)
        new_readme = existing[:idx].rstrip() + "\n\n" + log_section
    elif alt_marker in existing:
        idx = existing.index(alt_marker)
        new_readme = existing[:idx].rstrip() + "\n\n" + log_section
    else:
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
