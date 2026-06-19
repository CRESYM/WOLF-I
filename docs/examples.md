---
layout: page
title: "Examples"
description: "Reproducible, executable examples from the WOLF-I project: step-by-step multimachine linear models and eigenvalue computations, including Kundur's two-area four-generator system."
permalink: /examples/
---

<ul class="post-list">
  {%- assign examples = site.examples | sort: "title" -%}
  {%- for ex in examples -%}
    <li>
      <a href="{{ ex.url | relative_url }}">{{ ex.title }}</a>
      {%- if ex.summary %} &mdash; {{ ex.summary }}{% endif -%}
    </li>
  {%- else -%}
    <li><em>No examples published yet.</em></li>
  {%- endfor -%}
</ul>
