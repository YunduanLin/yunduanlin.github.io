---
layout: page
permalink: /research/
title: Research
description: Research themes and publications in societal operations management, social networks, platform operations, optimization, and analytics.
nav: true
nav_order: 1
---

<div class="research-page" markdown="1">

<div class="research-focus-list" aria-label="Research focus areas">
  <span>Networks</span>
  <span>AI</span>
  <span>Optimization</span>
  <span>Analytics</span>
</div>

<p class="research-order-note">Research outputs are organized by type and ordered from newest to oldest within each section.</p>

<section class="grant-section" markdown="1">

#### Grants
{: .publication-section-title }

<div class="grant-list">
  <div class="grant-item">
    <div class="grant-title">"Harnessing the Power of Social Network Analytics for Enhanced Business Decision-Making"</div>
    <div class="grant-meta"><em>CUHK Improvement on Competitiveness in Hiring New Faculties Funding Scheme</em>, PI, <span class="grant-amount">HKD 1,307,270</span>, 2024.</div>
  </div>

  <div class="grant-item">
    <div class="grant-title">"Optimal Design of the Referral Program for Two-Sided Platforms"</div>
    <div class="grant-meta"><em>Hong Kong Research Grants Council, Early Career Scheme</em>, PI, <span class="grant-amount">HKD 454,062</span>, 2026-2028.</div>
  </div>
</div>
</section>

<section class="publication-section publication-section-journal" markdown="1">

#### Journal Publications & Manuscripts
{: .publication-section-title }

<div class="publications">

{% bibliography --group_by none --query @*[category=journal]* %}

</div>
</section>

<section class="publication-section publication-section-conference" markdown="1">

#### Refereed Conference Proceedings
{: .publication-section-title }

<div class="publications">

{% bibliography --group_by none --query @*[category=conference]* %}

</div>
</section>

<section class="publication-section publication-section-progress" markdown="1">

#### Work In Progress
{: .publication-section-title }

<div class="publications">

{% bibliography --group_by none --query @*[category=progress]* %}

</div>
</section>

</div>
