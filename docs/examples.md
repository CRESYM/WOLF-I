---
layout: page
title: "Examples"
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
