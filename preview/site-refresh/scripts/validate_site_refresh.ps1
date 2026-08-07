$ErrorActionPreference = "Stop"

function Assert-Contains {
  param(
    [string]$Path,
    [string]$Pattern,
    [string]$Message
  )

  $content = Get-Content -Raw -Encoding UTF8 $Path
  if ($content -notmatch $Pattern) {
    throw $Message
  }
}

function Assert-NotContains {
  param(
    [string]$Path,
    [string]$Pattern,
    [string]$Message
  )

  $content = Get-Content -Raw -Encoding UTF8 $Path
  if ($content -match $Pattern) {
    throw $Message
  }
}

function Assert-NoFiles {
  param(
    [string]$Path,
    [string]$Message
  )

  if ((Test-Path $Path) -and (Get-ChildItem -Path $Path -File | Measure-Object).Count -gt 0) {
    throw $Message
  }
}

$requiredPages = @(
  "_pages/about.md",
  "_pages/research.md",
  "_pages/teaching.md",
  "_pages/service.md"
)

foreach ($page in $requiredPages) {
  if (!(Test-Path $page)) {
    throw "Missing required page: $page"
  }
}

Assert-Contains "_pages/about.md" "title:\s*Home" "Homepage nav title should be Home."
Assert-Contains "_pages/about.md" "Assistant Professor" "Homepage should use the current Assistant Professor title."
Assert-Contains "_pages/about.md" "CUHK Business School" "Homepage should identify CUHK Business School."
Assert-Contains "_pages/about.md" "Department of Decisions, Operations and Technology" "Homepage should identify the current department."
Assert-NotContains "_pages/about.md" "will be joining|fifth-year Ph\.D\. candidate" "Homepage still contains stale career-stage language."
Assert-Contains "_pages/about.md" "news:\s*false" "Homepage should not render the news section."
Assert-NotContains "_pages/about.md" "/publications/|/cv/|CV\.pdf" "Homepage should not link to removed publications or CV pages."
Assert-NotContains "_layouts/about.liquid" "/news/" "About layout should not contain a dormant news section link."
Assert-NotContains "_config.yml" "permalink:\s*/news/:path/|announcements:" "Config should not publish or configure news."

Assert-Contains "_pages/research.md" "Platform Operations" "Research page should describe platform operations."
Assert-Contains "_pages/research.md" "Network Diffusion" "Research page should describe network diffusion."
Assert-Contains "_pages/research.md" "\{\%\s*bibliography\s*\%\}" "Research page should render the full publication list."

$removedPages = @(
  "_pages/publications.md",
  "_pages/cv.md",
  "_pages/news.md"
)

foreach ($page in $removedPages) {
  if (Test-Path $page) {
    throw "Removed page should not exist: $page"
  }
}

Assert-NotContains "_data/cv.yml" "Albert Einstein|Nobel Prize|Theoretical Physics" "CV data still contains al-folio placeholder content."
Assert-NotContains "assets/json/resume.json" "Albert Einstein|Theoretical Physics|Quantum" "JSON resume still contains al-folio placeholder content."
Assert-NotContains "README.md" "^#\s+al-folio" "README still starts with upstream al-folio content."
Assert-NotContains "README.md" "publications, teaching, service, and CV" "README should describe the current page structure."

Assert-NoFiles "_posts" "Demo blog posts should be removed."
Assert-NoFiles "_projects" "Demo project pages should be removed."
Assert-NoFiles "_news" "News items should be removed."

$demoPaths = @(
  "assets/img/readme_preview",
  "assets/audio/epicaly-short-113909.mp3",
  "assets/video/pexels-engin-akyurt-6069112-960x540-30fps.mp4",
  "assets/jupyter/blog.ipynb",
  "assets/plotly/demo.html",
  "assets/pdf/example_pdf.pdf",
  "lighthouse_results",
  "reports"
)

foreach ($path in $demoPaths) {
  if (Test-Path $path) {
    throw "Demo artifact should be removed: $path"
  }
}

$workflowFiles = Get-ChildItem ".github/workflows" -File | Select-Object -ExpandProperty Name
$expectedWorkflows = @("deploy.yml", "preview.yml")
$unexpectedWorkflows = $workflowFiles | Where-Object { $expectedWorkflows -notcontains $_ }
if ($unexpectedWorkflows.Count -gt 0) {
  throw "Unexpected upstream workflows remain: $($unexpectedWorkflows -join ', ')"
}

Assert-Contains ".github/workflows/preview.yml" "branches:\s*\r?\n\s*-\s*codex/site-refresh" "Preview workflow should run only from codex/site-refresh."
Assert-Contains ".github/workflows/preview.yml" "--baseurl /preview/site-refresh" "Preview workflow should build with the preview baseurl."
Assert-Contains ".github/workflows/preview.yml" "target-folder:\s*preview/site-refresh" "Preview workflow should deploy into the gh-pages preview folder."
Assert-Contains ".github/workflows/preview.yml" "clean:\s*false" "Preview workflow should not clean the live gh-pages root."

Write-Host "Site refresh validation passed."
