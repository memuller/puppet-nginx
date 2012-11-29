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

	file { '/etc/nginx/globals/php.conf':
		ensure => present,
		content => template('nginx/php.conf.erb')
	}

	file { '/etc/nginx/globals/php-simple.conf':
		ensure => present,
		content => template('nginx/php-simple.conf.erb')
	}

	file { '/etc/nginx/globals/restrictions.conf':
		ensure => present,
		content => template('nginx/restrictions.conf.erb')
	}

	file { '/etc/nginx/globals/wordpress-mu.conf':
		ensure => present,
		content => template('nginx/wordpress-mu.conf.erb')
	}

}