<?php

$site = {{ getenv "DRUPAL_SITE" "default" }};

{{ range jsonArray (getenv "WODBY_HOSTS") }}
$sites['{{ . }}'] = $site;
{{ end }}
