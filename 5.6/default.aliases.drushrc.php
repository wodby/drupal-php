<?php

$aliases[isset($_SERVER['PHP_SITENAME']) ? $_SERVER['PHP_SITENAME'] : 'dev'] = array(
  'root' => '/var/www/html/' . (isset($_SERVER['PHP_DOCROOT']) ? $_SERVER['PHP_DOCROOT'] : ''),
  'uri' => isset($_SERVER['PHP_HOSTNAME']) ? $_SERVER['PHP_HOSTNAME'] : 'localhost:8000',
);
