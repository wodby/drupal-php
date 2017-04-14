<?php
/**
 * @file
 * Wodby environment configuration for Drupal 7.
 */

$wodby['files_dir'] = '{{ getenv "WODBY_DIR_FILES" }}';
$wodby['base_url'] = '{{ getenv "WODBY_HOST_PRIMARY" "" }}';

$wodby['site'] = '{{ getenv "DRUPAL_SITE" }}';
$wodby['hash_salt'] = '{{ getenv "DRUPAL_HASH_SALT" "" }}';

$wodby['db']['host'] = '{{ getenv "DB_HOST" "" }}';
$wodby['db']['name'] = '{{ getenv "DB_NAME" "" }}';
$wodby['db']['username'] = '{{ getenv "DB_USER" "" }}';
$wodby['db']['password'] = '{{ getenv "DB_PASSWORD" "" }}';
$wodby['db']['driver'] = '{{ getenv "DB_DRIVER" "mysql" }}';

$wodby['varnish']['host'] = '{{ getenv "VARNISH_HOST" "" }}';
$wodby['varnish']['terminal_port'] = '{{ getenv "VARNISH_SERVICE_PORT_6082" "6082" }}';
$wodby['varnish']['secret'] = '{{ getenv "VARNISH_SECRET" "" }}';
$wodby['varnish']['version'] = '{{ getenv "VARNISH_VERSION" "4" }}';

$wodby['redis']['host'] = '{{ getenv "REDIS_HOST" "" }}';
$wodby['redis']['port'] = '{{ getenv "REDIS_SERVICE_PORT" "6379" }}';
$wodby['redis']['password'] = '{{ getenv "REDIS_PASSWORD" "" }}';

if (isset($_SERVER['HTTP_X_REAL_IP'])) {
  $_SERVER['REMOTE_ADDR'] = $_SERVER['HTTP_X_REAL_IP'];
}

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
  $_SERVER['HTTPS'] = 'on';
}

if (!isset($base_url) && !empty($wodby['base_url'])) {
  $base_url = $wodby['base_url'];
}

if (!isset($update_free_access)) {
  $update_free_access = FALSE;
}

if (empty($drupal_hash_salt)) {
  $drupal_hash_salt = $wodby['hash_salt'];
}

if (!isset($conf['404_fast_html'])) {
  $conf['404_fast_paths_exclude'] = '/\/(?:styles)\//';
  $conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
  $conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';
}

if (!isset($databases['default']['default'])) {
  $databases['default']['default'] = array();
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

$conf['file_public_path'] = "sites/{$wodby['site']}/files";
$conf['file_private_path'] = $wodby['files_dir'] . '/private';
$conf['file_temporary_path'] = '/tmp';

$contrib_path = is_dir('sites/all/modules/contrib') ? 'sites/all/modules/contrib' : 'sites/all/modules';

if (!defined('MAINTENANCE_MODE') || MAINTENANCE_MODE != 'install') {
  if (!empty($wodby['varnish']['host']) && file_exists("$contrib_path/varnish")) {
    $conf['varnish_version'] = $wodby['varnish']['version'];
    $conf['varnish_control_terminal'] = $wodby['varnish']['host'] . ':' . $wodby['varnish']['terminal_port'];
    $conf['varnish_control_key'] = $wodby['varnish']['secret'];
  }

  if (!empty($wodby['redis']['host']) && file_exists("$contrib_path/redis")) {
    $conf['redis_client_host'] = $wodby['redis']['host'];
    $conf['redis_client_port'] = $wodby['redis']['port'];
    $conf['redis_client_password'] = $wodby['redis']['password'];
    $conf['redis_client_base'] = 0;
    $conf['redis_client_interface'] = 'PhpRedis';
    $conf['cache_backends'][] = "$contrib_path/redis/redis.autoload.inc";
    $conf['cache_default_class'] = 'Redis_Cache';
    $conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
    $conf['lock_inc'] = "$contrib_path/redis/redis.lock.inc";
    $conf['path_inc'] = "$contrib_path/redis/redis.path.inc";
  }
}