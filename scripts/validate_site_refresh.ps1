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
  "_pages/publications.md",
  "_pages/teaching.md",
  "_pages/service.md",
  "_pages/cv.md"
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

Assert-Contains "_pages/research.md" "Platform Operations" "Research page should describe platform operations."
Assert-Contains "_pages/research.md" "Network Diffusion" "Research page should describe network diffusion."
Assert-NotContains "_pages/research.md" "\{\%\s*bibliography" "Research page should be an overview, not the full publication list."

Assert-Contains "_pages/publications.md" "nav:\s*true" "Publications page should be visible in navigation."
Assert-Contains "_pages/publications.md" "\{\%\s*bibliography\s*\%\}" "Publications page should render the bibliography."

Assert-Contains "_pages/cv.md" "title:\s*CV" "CV page should use a polished title."
Assert-Contains "_pages/cv.md" "nav:\s*true" "CV page should be visible in navigation."
Assert-Contains "_pages/cv.md" "CV\.pdf" "CV page should link to the real CV PDF."

Assert-NotContains "_data/cv.yml" "Albert Einstein|Nobel Prize|Theoretical Physics" "CV data still contains al-folio placeholder content."
Assert-NotContains "assets/json/resume.json" "Albert Einstein|Theoretical Physics|Quantum" "JSON resume still contains al-folio placeholder content."
Assert-NotContains "README.md" "^#\s+al-folio" "README still starts with upstream al-folio content."

Assert-NoFiles "_posts" "Demo blog posts should be removed."
Assert-NoFiles "_projects" "Demo project pages should be removed."

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
$unexpectedWorkflows = $workflowFiles | Where-Object { $_ -ne "deploy.yml" }
if ($unexpectedWorkflows.Count -gt 0) {
  throw "Unexpected upstream workflows remain: $($unexpectedWorkflows -join ', ')"
}

Write-Host "Site refresh validation passed."
