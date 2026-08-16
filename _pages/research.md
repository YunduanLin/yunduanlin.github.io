---
layout: page
permalink: /research/
title: Research
nav: true
nav_order: 1
---

<div class="research-page" markdown="1">

{% include paper_network.liquid %}

{% assign paper_network_js = '/assets/js/paper-network.js' | relative_url | bust_file_cache %}
<script defer src="{{ paper_network_js }}&v=feature-similarity-20260809"></script>

<p class="research-order-note">Papers are grouped by research stream and listed in reverse chronological order within each section. Labels indicate publication type/order (J=published journal, C=refereed conference, W=working paper/manuscript/work in progress).</p>

<section class="publication-section publication-section-stream publication-section-social" markdown="1">

#### Social Network Analytics and Platform Operations
{: .publication-section-title }

<div class="publications">

{% bibliography --group_by none --query @*[stream=social]* %}

</div>
</section>

<section class="publication-section publication-section-stream publication-section-aiops" markdown="1">

#### AI and Machine Learning for Operations
{: .publication-section-title }

<div class="publications">

{% bibliography --group_by none --query @*[stream=aiops]* %}

</div>
</section>

<section class="grant-section" markdown="1">

#### Grants
{: .publication-section-title }

<div class="grant-list">
  <div class="grant-item">
    <div class="grant-title">Harnessing the Power of Social Network Analytics for Enhanced Business Decision-Making</div>
    <div class="grant-meta"><em>CUHK Improvement on Competitiveness in Hiring New Faculties Funding Scheme</em>, <span class="grant-role">PI</span>, <span class="grant-amount">HKD 1,307,270</span>, 2024-2027.</div>
  </div>

  <div class="grant-item">
    <div class="grant-title">Optimal Design of the Referral Program for Two-Sided Platforms</div>
    <div class="grant-meta"><em>Hong Kong Research Grants Council, Early Career Scheme</em>, <span class="grant-role">PI</span>, <span class="grant-amount">HKD 454,062</span>, 2026-2028.</div>
  </div>
</div>
</section>

</div>
