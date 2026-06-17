---
layout: page
title: "Examples"
permalink: /examples/
---

Worked, executable examples. Each one is generated from the code in its
`projects/<name>/` folder, so the results shown are produced by the code itself.
Development-diary posts link to the relevant example below.

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
