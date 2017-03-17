<?php

$site = {{ getenv "DRUPAL_SITE" "default" }};

{{ $hosts := split (getenv "WODBY_HOSTS") "/" }}
{{ range $hosts }}
$sites['{{ . }}'] = $site;
{{ end }}
