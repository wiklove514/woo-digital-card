# GitHub Pages 배포 스크립트
# 사용법: PowerShell에서 .\deploy.ps1

$RepoName = "woo-digital-card"
Set-Location $PSScriptRoot

function Test-GhLoggedIn {
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  gh auth status 2>&1 | Out-Null
  $ok = ($LASTEXITCODE -eq 0)
  $ErrorActionPreference = $prev
  return $ok
}

Write-Host "GitHub 로그인 확인 중..." -ForegroundColor Cyan
if (-not (Test-GhLoggedIn)) {
  Write-Host ""
  Write-Host "GitHub 로그인이 필요합니다." -ForegroundColor Yellow
  Write-Host "아래 안내에 따라 선택하세요 (보통 그대로 Enter):" -ForegroundColor Yellow
  Write-Host "  - GitHub.com / HTTPS / Login with a web browser" -ForegroundColor DarkGray
  Write-Host ""
  gh auth login -h github.com -p https -w
  if (-not (Test-GhLoggedIn)) {
    Write-Host ""
    Write-Host "로그인이 완료되지 않았습니다. 브라우저에서 승인 후 다시 .\deploy.ps1 을 실행하세요." -ForegroundColor Red
    exit 1
  }
}

$ErrorActionPreference = "Stop"

$owner = (gh api user -q .login)
Write-Host "계정: $owner" -ForegroundColor Green

$prev = $ErrorActionPreference
$ErrorActionPreference = "Continue"
gh repo view "$owner/$RepoName" 2>&1 | Out-Null
$repoExists = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $prev

if (-not $repoExists) {
  Write-Host "저장소 생성: $RepoName" -ForegroundColor Cyan
  gh repo create $RepoName --public --source=. --remote=origin --description "우인경 디지털 명함"
} else {
  Write-Host "기존 저장소 사용: $owner/$RepoName" -ForegroundColor Cyan
  git remote get-url origin 2>$null
  if ($LASTEXITCODE -ne 0) {
    git remote add origin "https://github.com/$owner/$RepoName.git"
  }
}

$branch = git branch --show-current
if (-not $branch) { git checkout -b main; $branch = "main" }
if ($branch -ne "main") { git branch -M main; $branch = "main" }

git add -A
git diff --staged --quiet
if ($LASTEXITCODE -ne 0) {
  git commit -m "Update digital business card"
}

Write-Host "GitHub에 업로드 중..." -ForegroundColor Cyan
git push -u origin main

Write-Host "GitHub Pages 활성화 중..." -ForegroundColor Cyan
$prev = $ErrorActionPreference
$ErrorActionPreference = "Continue"
gh api -X POST "repos/$owner/$RepoName/pages" -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
  gh api -X PUT "repos/$owner/$RepoName/pages" -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" 2>&1 | Out-Null
}
$ErrorActionPreference = $prev

$pagesUrl = "https://$owner.github.io/$RepoName/"
Write-Host ""
Write-Host "배포 완료!" -ForegroundColor Green
Write-Host "명함 주소: $pagesUrl" -ForegroundColor Green
Write-Host "QR 코드는 위 주소로 접속하면 자동으로 표시됩니다." -ForegroundColor Yellow
Start-Process $pagesUrl
