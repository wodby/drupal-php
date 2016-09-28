<?php

$aliases[isset($_SERVER['PHP_SITE_NAME']) ? $_SERVER['PHP_SITE_NAME'] : 'dev'] = array(
  'root' => '/var/www/html/' . (isset($_SERVER['PHP_DOCROOT']) ? $_SERVER['PHP_DOCROOT'] : ''),
  'uri' => isset($_SERVER['PHP_HOST_NAME']) ? $_SERVER['PHP_HOST_NAME'] : 'localhost:8000',
);
