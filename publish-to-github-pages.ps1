param(
  [string]$RepoName = "kcl-refund-rights"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Host "GitHub CLI (gh) is not installed."
  Write-Host "Install it from https://cli.github.com/ then run: gh auth login"
  exit 1
}

gh auth status | Out-Null

$Owner = gh api user --jq ".login"
if (-not $Owner) {
  throw "Could not determine GitHub username. Run: gh auth login"
}

if (-not (Test-Path ".git")) {
  git init
  git branch -M main
}

git add .
git commit -m "Publish KCL refund rights website" 2>$null
if ($LASTEXITCODE -ne 0) {
  Write-Host "No new changes to commit, continuing..."
}

$RepoFullName = "$Owner/$RepoName"

gh repo view $RepoFullName *> $null
if ($LASTEXITCODE -ne 0) {
  gh repo create $RepoName --public --source . --remote origin --push
} else {
  git remote remove origin 2>$null
  git remote add origin "https://github.com/$RepoFullName.git"
  git push -u origin main
}

try {
  gh api --method POST "repos/$RepoFullName/pages" -f "source[branch]=main" -f "source[path]=/" | Out-Null
} catch {
  gh api --method PUT "repos/$RepoFullName/pages" -f "source[branch]=main" -f "source[path]=/" | Out-Null
}

Write-Host ""
Write-Host "GitHub Pages publication requested."
Write-Host "Your site should become available at:"
Write-Host "https://$Owner.github.io/$RepoName/"
Write-Host ""
Write-Host "If it does not appear immediately, wait 1-3 minutes and refresh."
