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
Assert-Contains "_pages/about.md" "Assistant Professor, Department of Decisions, Operations and Technology" "Homepage employment should spell out the department name."
Assert-NotContains "_pages/about.md" "Assistant Professor,\s*DOT" "Homepage employment should not use the DOT abbreviation."
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
Assert-Contains "_layouts/about.liquid" "home-contact-card" "About layout should render the contact block as a dedicated card."
Assert-Contains "_layouts/about.liquid" "home-contact-line-primary" "About layout should distinguish the first contact card line."
Assert-Contains "_sass/_base.scss" "\.home-profile-hero" "Styles should define the homepage profile hero."
Assert-Contains "_sass/_base.scss" "\.home-contact-card" "Styles should define a dedicated homepage contact card."
Assert-Contains "_sass/_base.scss" "(?s)\.home-contact-card\s*\{[^}]*box-shadow:" "Homepage contact card should use a subtle card shadow."
Assert-Contains "_sass/_base.scss" "\.home-page\s+\{" "Styles should define homepage-specific typography and spacing."
Assert-Contains "_sass/_base.scss" "background-color:\s*#b8892f" "Homepage research cards should use the approved A2 gold accent line."
Assert-NotContains "_sass/_base.scss" "(?s)\.home-profile-intro\s*\{[^}]*border-left:" "Homepage bio intro should not keep the old left accent after contact panel redesign."
Assert-Contains "_sass/_base.scss" "row-gap:\s*1\.4rem" "Mobile homepage hero should keep spacing between intro and portrait."
Assert-Contains "_config.yml" "footer_fixed:\s*false" "Footer should not overlay homepage content."
Assert-Contains "_plugins/cache-bust.rb" "directory:\s*'_sass'" "CSS cache busting should hash the real Sass source directory."
Assert-NotContains "_config.yml" "permalink:\s*/news/:path/|announcements:" "Config should not publish or configure news."
Assert-Contains "_pages/about.md" "####\s*Research Interests" "Homepage should have an organized research interests section."
Assert-Contains "_pages/about.md" "My work connects operations management, network science, and AI-enabled analytics" "Homepage research description should explain the broader work agenda."
Assert-Contains "_pages/about.md" "Social network analytics and platform operations" "Homepage should organize the social network research theme."
Assert-Contains "_pages/about.md" "AI for operational decision-making" "Homepage should organize the AI research theme."
Assert-Contains "_pages/about.md" "deployable decision tools" "Homepage research cards should describe the practical aim of the work."
Assert-Contains "_pages/about.md" "home-research-themes" "Homepage should render research interests as compact full-width theme blocks."
Assert-Contains "_pages/about.md" "data-index=""01""" "Homepage research cards should use numbered A2-style tiles."
Assert-Contains "_pages/about.md" "home-research-tags" "Homepage research cards should include keyword tags."
Assert-Contains "_sass/_base.scss" "(?s)\.home-research-themes\s*\{[^}]*grid-template-columns:\s*minmax\(0,\s*1fr\)" "Homepage research cards should stack vertically."
Assert-NotContains "_sass/_base.scss" "(?s)\.home-research-themes\s*\{[^}]*grid-template-columns:\s*repeat\(2" "Homepage research cards should not use a two-column layout."
Assert-Contains "_sass/_base.scss" "content:\s*attr\(data-index\)" "Homepage research cards should render faint background numbers."
Assert-Contains "_sass/_base.scss" "home-research-tag" "Homepage should style research keyword tags."
Assert-Contains "_pages/about.md" "home-timeline-entry" "Homepage should render employment and education as polished timeline rows."
Assert-Contains "_sass/_base.scss" "(?s)\.home-timeline-entry\s*\{[^}]*border-top:\s*1px solid var\(--global-divider-color\)" "Homepage timeline entries should use quiet row dividers."
Assert-NotContains "_sass/_base.scss" "(?s)\.home-timeline-entry\s*\{[^}]*border-left:" "Homepage timeline entries should not use the old research-card accent."
Assert-Contains "_pages/about.md" "home-timeline-date" "Homepage timeline rows should render dates as compact pill labels."
Assert-Contains "_sass/_base.scss" "\.home-timeline-date" "Homepage timeline date pills should be styled explicitly."
Assert-NotContains "_pages/about.md" "<em>2024 - current</em>|<em>2019 - 2024</em>|<em>2018 - 2019</em>|<em>2014 - 2018</em>" "Homepage timeline should not use the older italic date treatment."
Assert-Contains "_pages/about.md" "####\s*Employment" "Homepage should include employment."
Assert-Contains "_pages/about.md" "2024-current" "Homepage employment should include the current CUHK appointment dates."
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
Assert-Contains ".github/workflows/preview.yml" "_plugins/\*\*" "Preview workflow should rebuild after plugin changes."
Assert-Contains ".github/workflows/preview.yml" "--baseurl /preview/site-refresh" "Preview workflow should build with the preview baseurl."
Assert-Contains ".github/workflows/preview.yml" "target-folder:\s*preview/site-refresh" "Preview workflow should deploy into the gh-pages preview folder."
Assert-Contains ".github/workflows/preview.yml" "clean:\s*false" "Preview workflow should not clean the live gh-pages root."
Assert-NotContains ".github/workflows/deploy.yml" "(?m)^\s*pull_request:" "Deploy workflow should not run on pull requests; preview.yml handles refresh-branch builds."
Assert-Contains ".github/workflows/deploy.yml" "\*\*/\*\.scss|_sass/\*\*" "Deploy workflow should rebuild after style-only changes."
Assert-Contains ".github/workflows/deploy.yml" "_plugins/\*\*" "Deploy workflow should rebuild after plugin changes."

Write-Host "Site refresh validation passed."
