<?php
/**
 * @file
 * Wodby environment configuration for Drupal 8.
 */

{{ $hosts := split (getenv "WODBY_HOSTS" "" ) "/" }}{{ range $hosts }}
$wodby['hosts'][] = '{{ . }}';
{{ end }}

$wodby['files_dir'] = '{{ getenv "WODBY_DIR_FILES" }}';
$wodby['site'] = '{{ getenv "DRUPAL_SITE" }}';
$wodby['hash_salt'] = '{{ getenv "DRUPAL_HASH_SALT" "" }}';
$wodby['sync_salt'] = '{{ getenv "DRUPAL_FILES_SYNC_SALT" "" }}';

$wodby['db']['host'] = '{{ getenv "DB_HOST" "" }}';
$wodby['db']['name'] = '{{ getenv "DB_NAME" "" }}';
$wodby['db']['username'] = '{{ getenv "DB_USER" "" }}';
$wodby['db']['password'] = '{{ getenv "DB_PASSWORD" "" }}';
$wodby['db']['driver'] = '{{ getenv "DB_DRIVER" "mysql" }}';

$wodby['redis']['host'] = '{{ getenv "REDIS_HOST" "" }}';
$wodby['redis']['port'] = '{{ getenv "REDIS_SERVICE_PORT" "6379" }}';
$wodby['redis']['password'] = '{{ getenv "REDIS_PASSWORD" "" }}';

if (isset($_SERVER['HTTP_X_REAL_IP'])) {
  $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_REAL_IP'];
}

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
  $_SERVER['HTTPS'] = 'on';
}

if (empty($settings['container_yamls'])) {
  $settings['container_yamls'][] = "sites/{$wodby['site']}/services.yml";
}

if (!array_key_exists('update_free_access', $settings)) {
  $settings['update_free_access'] = FALSE;
}

if (empty($settings['hash_salt'])) {
  $settings['hash_salt'] = $wodby['hash_salt'];
}

if (!array_key_exists('file_scan_ignore_directories', $settings)) {
  $settings['file_scan_ignore_directories'] = [
    'node_modules',
    'bower_components',
  ];
}

if (!empty($wodby['db']['host'])) {
  if (!isset($databases['default']['default'])) {
    $databases['default']['default'] = [];
  }

  $databases['default']['default'] = array_merge(
    $databases['default']['default'],
    [
      'host' => $wodby['db']['host'],
      'database' => $wodby['db']['name'],
      'username' => $wodby['db']['username'],
      'password' => $wodby['db']['password'],
      'driver' => $wodby['db']['driver'],
    ]
  );
}

$settings['file_public_path'] = "sites/{$wodby['site']}/files";
$settings['file_private_path'] = $wodby['files_dir'] . '/private';
$settings['file_temporary_path'] = '/tmp';

$config_directories['sync'] = $wodby['files_dir'] . '/config/sync_' . $wodby['sync_salt'];

if (!empty($wodby['hosts'])) {
  foreach ($wodby['hosts'] as $host) {
    $settings['trusted_host_patterns'][] = '^' . str_replace('.', '\.', $host) . '$';
  }
}

if (!defined('MAINTENANCE_MODE') || MAINTENANCE_MODE != 'install') {
  $site_mods_dir = "sites/{$wodby['site']}/modules";
  $contrib_path = is_dir('modules/contrib') ? 'modules/contrib' : 'modules';
  $contrib_path_site = is_dir("$site_mods_dir/contrib") ? "$site_mods_dir/contrib" : $site_mods_dir;

  $redis_module_path = NULL;

  if (file_exists("$contrib_path/redis")) {
    $redis_module_path = "$contrib_path/redis";
  } elseif (file_exists("$contrib_path_site/redis")) {
    $redis_module_path = "$contrib_path_site/redis";
  }

  if (!empty($wodby['redis']['host']) && $redis_module_path) {
    $settings['redis.connection']['host'] = $wodby['redis']['host'];
    $settings['redis.connection']['port'] = $wodby['redis']['port'];
    $settings['redis.connection']['password'] = $wodby['redis']['password'];
    $settings['redis.connection']['base'] = 0;
    $settings['redis.connection']['interface'] = 'PhpRedis';
    $settings['cache']['default'] = 'cache.backend.redis';
    $settings['cache']['bins']['bootstrap'] = 'cache.backend.chainedfast';
    $settings['cache']['bins']['discovery'] = 'cache.backend.chainedfast';
    $settings['cache']['bins']['config'] = 'cache.backend.chainedfast';

    $settings['container_yamls'][] = "$redis_module_path/example.services.yml";
  }
}
