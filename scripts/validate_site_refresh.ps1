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
Assert-Contains "_pages/about.md" "Good morning, and in case I don't see you, good afternoon, good evening, and good night!" "Homepage should use the previous subtitle from master."
Assert-NotContains "_pages/about.md" "subtitle:\s*Assistant Professor, CUHK Business School" "Homepage subtitle should not repeat the job title."
Assert-Contains "_pages/about.md" "profile_layout:\s*hero" "Homepage should use the profile hero layout."
Assert-Contains "_pages/about.md" "home_intro:" "Homepage should keep the short bio in the profile hero."
Assert-Contains "_pages/about.md" "home_contact:" "Homepage should keep contact information in the left profile hero column."
Assert-Contains "_pages/about.md" "Assistant Professor" "Homepage should use the current Assistant Professor title."
Assert-Contains "_pages/about.md" "CUHK Business School" "Homepage should identify CUHK Business School."
Assert-Contains "_pages/about.md" "Department of Decisions, Operations and Technology" "Homepage should identify the current department."
Assert-NotContains "_pages/about.md" "will be joining|fifth-year Ph\.D\. candidate" "Homepage still contains stale career-stage language."
Assert-NotContains "_pages/about.md" "I received my Ph\.D\. and M\.S\." "Homepage intro should not lead with education history."
Assert-Contains "_pages/about.md" "news:\s*false" "Homepage should not render the news section."
Assert-NotContains "_pages/about.md" "selected_papers:\s*true" "Homepage should not render selected publications."
Assert-NotContains "_pages/about.md" "/publications/|/cv/|CV\.pdf" "Homepage should not link to removed publications or CV pages."
Assert-NotContains "_pages/about.md" "<div class=""clearfix""></div>" "Homepage should not force research content below the profile image."
Assert-NotContains "_layouts/about.liquid" "/news/" "About layout should not contain a dormant news section link."
Assert-NotContains "_layouts/about.liquid" "selected publications|selected_papers" "About layout should not render the selected publications block."
Assert-Contains "_layouts/about.liquid" "home-page" "About layout should expose a homepage-specific styling hook."
Assert-Contains "_layouts/about.liquid" "home-profile-hero" "About layout should support the homepage profile hero."
Assert-Contains "_sass/_base.scss" "\.home-profile-hero" "Styles should define the homepage profile hero."
Assert-Contains "_sass/_base.scss" "\.home-page\s+\{" "Styles should define homepage-specific typography and spacing."
Assert-Contains "_sass/_base.scss" "border-left:\s*3px solid var\(--global-theme-color\)" "Homepage should use restrained accent lines."
Assert-Contains "_sass/_base.scss" "row-gap:\s*1\.4rem" "Mobile homepage hero should keep spacing between intro and portrait."
Assert-Contains "_config.yml" "footer_fixed:\s*false" "Footer should not overlay homepage content."
Assert-NotContains "_config.yml" "permalink:\s*/news/:path/|announcements:" "Config should not publish or configure news."
Assert-Contains "_pages/about.md" "####\s*Research Interests" "Homepage should have an organized research interests section."
Assert-Contains "_pages/about.md" "Social network analytics and platform operations" "Homepage should organize the social network research theme."
Assert-Contains "_pages/about.md" "AI for operational decision-making" "Homepage should organize the AI research theme."
Assert-Contains "_pages/about.md" "home-research-themes" "Homepage should render research interests as compact full-width theme blocks."
Assert-Contains "_pages/about.md" "home-timeline-entry" "Homepage should render employment and education as polished timeline rows."
Assert-Contains "_pages/about.md" "####\s*Employment" "Homepage should include employment."
Assert-Contains "_pages/about.md" "2024 - current" "Homepage employment should include the current CUHK appointment dates."
Assert-Contains "_pages/about.md" "####\s*Education" "Homepage should include education."
Assert-Contains "_pages/about.md" "University of California, Berkeley" "Homepage education should include Berkeley."
Assert-Contains "_pages/about.md" "Tsinghua University" "Homepage education should include Tsinghua."

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
Assert-Contains ".github/workflows/preview.yml" "\*\*/\*\.scss|_sass/\*\*" "Preview workflow should rebuild after style-only changes."
Assert-Contains ".github/workflows/preview.yml" "--baseurl /preview/site-refresh" "Preview workflow should build with the preview baseurl."
Assert-Contains ".github/workflows/preview.yml" "target-folder:\s*preview/site-refresh" "Preview workflow should deploy into the gh-pages preview folder."
Assert-Contains ".github/workflows/preview.yml" "clean:\s*false" "Preview workflow should not clean the live gh-pages root."
Assert-NotContains ".github/workflows/deploy.yml" "(?m)^\s*pull_request:" "Deploy workflow should not run on pull requests; preview.yml handles refresh-branch builds."

Write-Host "Site refresh validation passed."
