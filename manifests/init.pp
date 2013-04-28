class nginx (
		$ensure = 'present',
		$default_vhost = false,
	) {

	$running = $ensure ? {
		absent => 'stopped',
		default => 'running',
	}

	$default_vhost_ensure = $default_vhost ? {
		true => 'link',
		default => 'absent',
	}

	package { 'nginx':
		ensure => $ensure,
	}

	service { 'nginx':
		ensure => $running,
		require => Package['nginx'],
	}

	file { '/etc/nginx/sites-enabled/default':
		ensure => $default_vhost_ensure,
		target => '/etc/nginx/sites-available/default',
		notify => Service['nginx'],
	}

	file { '/etc/nginx/conf.d/php.conf':
		ensure => present,
		content => template('nginx/upstream-php.conf.erb'),
		notify => Service['nginx']
	}

	file { '/etc/nginx/globals':
		ensure => directory
	}
	# PHP upstream.
	file { '/etc/nginx/globals/php.conf':
		ensure => present,
		content => template('nginx/php.conf.erb')
	}

	# Simple PHP app; redirects all non-found requests to index.php .
	file { '/etc/nginx/globals/php-simple.conf':
		ensure => present,
		content => template('nginx/php-simple.conf.erb')
	}

	# Wordpress, installed w/ separate directories for wp-content and wordpress.
	file { '/etc/nginx/globals/wordpress-subdirectory.conf':
		ensure => present,
		content => template('nginx/wordpress-subdirectory.conf.erb')
	}

	# Wordpress MU.
	file { '/etc/nginx/globals/wordpress-mu.conf':
		ensure => present,
		content => template('nginx/wordpress-mu.conf.erb')
	}

	# GZIP.
	file { '/etc/nginx/globals/gzip.conf':
		ensure => present,
		content => template('nginx/gzip.conf.erb')
	}

	# No-transform header (disencourages mobile carries from transforming content).
	file { '/etc/nginx/globals/no-transform.conf':
		ensure => present,
		content => template('nginx/no-transform.conf.erb')
	}

	# File access restrictions (robots, favicon, hidden files, source files)
	file { '/etc/nginx/globals/restrictions.conf':
		ensure => present,
		content => template('nginx/restrictions.conf.erb')
	}

	#== Cache handlers.
	# Media (image/video/document) handler.
	file { '/etc/nginx/globals/cache-media.conf':
		ensure => present,
		content => template('nginx/cache-media.conf.erb')
	}
	# Javascript and CSS handlers.
	file { '/etc/nginx/globals/cache-app.conf':
		ensure => present,
		content => template('nginx/cache-app.conf.erb')
	}
	# Web documents (HTML/Manifest) handlers.
	file { '/etc/nginx/globals/cache-html.conf':
		ensure => present,
		content => template('nginx/cache-html.conf.erb')
	}
	# Cache-busting using filenames (file.20120212.css => file.css?20120212)
	file { '/etc/nginx/globals/cache-buster.conf':
		ensure => present,
		content => template('nginx/cache-buster.conf.erb')
	}
	# Caches file descriptors.
	file { '/etc/nginx/globals/cache-file-descriptors.conf':
		ensure => present,
		content => template('nginx/cache-file-descriptors.conf.erb')
	}

}