class nginx (
		$ensure = 'present',
		$default_vhost = false,
		$user = 'www-data',
		$group = 'www-data',
		$worker_processes = 'auto',
		$client_max_body_size = '200M',
		$server_names_hash_bucket_size = 64
	) {

	$running = $ensure ? {
		absent => 'stopped',
		default => 'running',
	}

	$default_vhost_ensure = $default_vhost ? {
		true => 'link',
		default => 'absent',
	}

	File {
		ensure => present,
		notify => Service['nginx']
	}

	package { 'nginx':
		ensure => $ensure
	}

	service { 'nginx':
		ensure => $running,
		require => Package['nginx']
	}

	file { '/etc/nginx/nginx.conf':
		content => template('nginx/nginx.conf.erb')
	}

	file { '/etc/nginx/sites-enabled/default':
		ensure => $default_vhost_ensure,
		target => '/etc/nginx/sites-available/default'
	}

	file { '/etc/nginx/conf.d/php.conf':
		content => template('nginx/upstream-php.conf.erb')
	}

	file { '/etc/nginx/globals':
		ensure => directory
	}
	# PHP upstream.
	file { '/etc/nginx/globals/php.conf':
		content => template('nginx/php.conf.erb')
	}

	# Simple PHP app; redirects all non-found requests to index.php .
	file { '/etc/nginx/globals/php-simple.conf':
		content => template('nginx/php-simple.conf.erb')
	}

	# Wordpress, installed w/ separate directories for wp-content and wordpress.
	file { '/etc/nginx/globals/wordpress-subdirectory.conf':
		content => template('nginx/wordpress-subdirectory.conf.erb')
	}

	# Wordpress MU.
	file { '/etc/nginx/globals/wordpress-mu.conf':
		content => template('nginx/wordpress-mu.conf.erb')
	}
	file { '/etc/nginx/globals/wordpress-ms-files.conf':
		content => template('nginx/wordpress-ms-files.conf.erb')
	}
	# Wordpress Total Cache minify rewrite rules.
	file { '/etc/nginx/globals/wordpress-w3tc-minify.conf':
		content => template('nginx/wordpress-w3tc-minify.conf.erb')
	}

	# GZIP.
	file { '/etc/nginx/globals/gzip.conf':
		content => template('nginx/gzip.conf.erb')
	}

	# No-transform header (disencourages mobile carries from transforming content).
	file { '/etc/nginx/globals/no-transform.conf':
		content => template('nginx/no-transform.conf.erb')
	}

	# File access restrictions (robots, favicon, hidden files, source files)
	file { '/etc/nginx/globals/restrictions.conf':
		content => template('nginx/restrictions.conf.erb')
	}

	#== Cache handlers.
	# Media (image/video/document) handler.
	file { '/etc/nginx/globals/cache-media.conf':
		content => template('nginx/cache-media.conf.erb')
	}
	# Javascript and CSS handlers.
	file { '/etc/nginx/globals/cache-app.conf':
		content => template('nginx/cache-app.conf.erb')
	}
	# Web documents (HTML/Manifest) handlers.
	file { '/etc/nginx/globals/cache-html.conf':
		content => template('nginx/cache-html.conf.erb')
	}
	# Cache-busting using filenames (file.20120212.css => file.css?20120212)
	file { '/etc/nginx/globals/cache-buster.conf':
		content => template('nginx/cache-buster.conf.erb')
	}
	# Caches file descriptors.
	file { '/etc/nginx/globals/cache-file-descriptors.conf':
		content => template('nginx/cache-file-descriptors.conf.erb')
	}

}