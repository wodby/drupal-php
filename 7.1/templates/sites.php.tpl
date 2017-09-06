<?php

$site = {{ getenv "DRUPAL_SITE" "default" }};

{{ if getenv "WODBY_HOSTS" }}{{ range jsonArray (getenv "WODBY_HOSTS") }}
$sites['{{ . }}'] = $site;
{{ end }}{{ end }}
