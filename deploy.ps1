# GitHub Pages 배포 스크립트
# 사용법: PowerShell에서 .\deploy.ps1

$ErrorActionPreference = "Stop"
$RepoName = "woo-digital-card"

Set-Location $PSScriptRoot

Write-Host "GitHub 로그인 확인 중..." -ForegroundColor Cyan
gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "GitHub에 로그인이 필요합니다. 브라우저가 열리면 안내를 따라주세요." -ForegroundColor Yellow
  gh auth login -h github.com -p https -w
}

$owner = (gh api user -q .login)
Write-Host "계정: $owner" -ForegroundColor Green

$exists = gh repo view "$owner/$RepoName" 2>$null
if ($LASTEXITCODE -ne 0) {
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
gh api -X POST "repos/$owner/$RepoName/pages" -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" 2>$null
if ($LASTEXITCODE -ne 0) {
  gh api -X PUT "repos/$owner/$RepoName/pages" -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" 2>$null
}

$pagesUrl = "https://$owner.github.io/$RepoName/"
Write-Host ""
Write-Host "배포 완료!" -ForegroundColor Green
Write-Host "명함 주소: $pagesUrl" -ForegroundColor Green
Write-Host "QR 코드는 위 주소로 index.html을 연 뒤 생성됩니다." -ForegroundColor Yellow
Start-Process $pagesUrl
