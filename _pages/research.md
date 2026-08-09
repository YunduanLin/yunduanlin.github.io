---
layout: page
permalink: /research/
title: Research
description: Research themes and publications in societal operations management, social networks, platform operations, AI, and analytics.
nav: true
nav_order: 1
---

<div class="research-page" markdown="1">

<p class="research-order-note">Papers are grouped by research stream and ordered from newest to oldest within each section. Labels indicate publication type/order (J=published journal, C=refereed conference, W=working paper/manuscript/work in progress); keyword chips mark recurring methods and domains.</p>

{% include paper_network.liquid %}

{% assign paper_network_js = '/assets/js/paper-network.js' | relative_url | bust_file_cache %}
<script defer src="{{ paper_network_js }}&v=feature-similarity-20260809"></script>

<section class="publication-section publication-section-stream publication-section-social" markdown="1">

#### Social Network Analytics & Platform Operations
{: .publication-section-title }

<p class="publication-section-lead">This stream studies how network connections, peer influence, learning, and platform interventions shape adoption, engagement, diffusion, and operational performance in connected markets.</p>

<div class="publications">

{% bibliography --group_by none --query @*[stream=social]* %}

</div>
</section>

<section class="publication-section publication-section-stream publication-section-aiops" markdown="1">

#### AI & Operational Analytics
{: .publication-section-title }

<p class="publication-section-lead">This stream develops AI, machine learning, simulation, and data-driven analytics for deployable decision support in service platforms, transportation, healthcare, and complex operational systems.</p>

<div class="publications">

{% bibliography --group_by none --query @*[stream=aiops]* %}

</div>
</section>

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

</div>
