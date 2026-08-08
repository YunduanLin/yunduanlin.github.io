---
layout: page
permalink: /research/
title: Research
description: Research themes and publications in societal operations management, social networks, platform operations, optimization, and analytics.
nav: true
nav_order: 1
---

<div class="research-page" markdown="1">

<div class="research-overview">
  <div class="research-kicker">Research Agenda</div>
  <p>My research develops models, algorithms, and empirical tools for operational decisions in connected systems. I am motivated by settings where people, platforms, firms, and infrastructure interact through networks, and where better decision models can improve performance, resilience, and social value.</p>
</div>

<div class="research-theme-grid">
  <section class="research-theme-card" data-index="01">
    <h4>Platform Operations and Network Diffusion</h4>
    <p>I study how online platforms can design promotion, recommendation, and allocation policies when user behavior is shaped by social influence and feedback loops. This work develops approximation and optimization methods for diffusion processes on social networks, including settings where adoption can reverse over time.</p>
  </section>

  <section class="research-theme-card" data-index="02">
    <h4>AI, Optimization, and Applied Operational Systems</h4>
    <p>My methodological toolkit includes optimization, approximation algorithms, network and graph theory, stochastic simulation, machine learning, and empirical analytics. I use these tools to build deployable decision models for platforms, supply chains, healthcare, transportation, and other societal systems.</p>
  </section>
</div>

<section class="publication-section publication-section-journal" markdown="1">

#### Journal Publications
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
