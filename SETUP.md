# 자동 배포 파이프라인 설정 가이드

## 1단계: Colab 템플릿 사용하기

1. `templates/daily-study-template.ipynb`를 Google Drive에 복사
2. Colab에서 열기
3. Cell 0 실행 (GitHub 설정 — 처음 한 번만)
4. Cell 1에서 `TODAY_MEMO`, `TAGS`, `NOTEBOOK_NAME` 수정
5. 학습 내용 작성
6. 마지막 셀 실행 → 자동으로 GitHub push + summary.md 생성

## 2단계: DEV.to 연동 (선택)

### API 키 발급
1. [DEV.to](https://dev.to) 가입/로그인
2. Settings > Extensions > DEV Community API Keys
3. "Generate API Key" 클릭 → 키 복사

### GitHub Secrets 설정
1. GitHub 레포 > Settings > Secrets and variables > Actions
2. "New repository secret" 클릭
3. Name: `DEVTO_API_KEY`, Value: 위에서 복사한 키

### 활성화
1. GitHub 레포 > Settings > Secrets and variables > Actions > Variables 탭
2. "New repository variable" 클릭
3. Name: `ENABLE_DEVTO`, Value: `true`

## 3단계: LinkedIn 연동 (선택)

### LinkedIn API 앱 만들기
1. [LinkedIn Developer Portal](https://www.linkedin.com/developers/) 접속
2. "Create App" 클릭
3. 앱 이름, 회사 페이지 등 입력
4. Products 탭 > "Share on LinkedIn" 추가 요청

### 액세스 토큰 발급
1. Auth 탭에서 OAuth 2.0 settings 확인
2. Redirect URL 설정: `https://localhost:8080/callback`
3. 다음 URL로 브라우저 접속 (client_id 교체):
   ```
   https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=YOUR_CLIENT_ID&redirect_url=https://localhost:8080/callback&scope=w_member_social
   ```
4. 인증 후 받은 code로 토큰 교환:
   ```bash
   curl -X POST https://www.linkedin.com/oauth/v2/accessToken \
     -d "grant_type=authorization_code" \
     -d "code=YOUR_CODE" \
     -d "client_id=YOUR_CLIENT_ID" \
     -d "client_secret=YOUR_CLIENT_SECRET" \
     -d "redirect_uri=https://localhost:8080/callback"
   ```

### Person ID 확인
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  "https://api.linkedin.com/v2/me"
```
응답의 `id` 값이 Person ID입니다.

### GitHub Secrets 설정
1. `LINKEDIN_ACCESS_TOKEN`: 위에서 받은 토큰
2. `LINKEDIN_PERSON_ID`: 위에서 확인한 ID

### 활성화
1. GitHub 레포 > Settings > Variables 탭
2. Name: `ENABLE_LINKEDIN`, Value: `true`

## 4단계: Colab Secrets 설정

Colab에서 GitHub에 push하려면 토큰이 필요합니다:

1. [GitHub Personal Access Token](https://github.com/settings/tokens) 생성
   - 권한: `repo` (전체)
2. Colab 왼쪽 사이드바 > 열쇠 아이콘 > Secrets
3. Name: `GITHUB_TOKEN`, Value: 생성한 토큰

## 참고사항

- DEV.to 포스트는 **초안(draft)** 상태로 발행됩니다. DEV.to 대시보드에서 확인 후 직접 공개하세요.
- LinkedIn 포스트는 즉시 공개됩니다.
- LinkedIn 토큰은 60일 후 만료됩니다. 갱신이 필요합니다.
- DEV.to/LinkedIn 연동은 선택사항입니다. 설정하지 않으면 GitHub push + README 업데이트만 동작합니다.
