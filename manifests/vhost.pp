define nginx::vhost (
	$ensure = 'present',
	$root = "/var/www/${name}", 
	$priority = '50',
	$file = $name,
	$server_name = $name,
	$index = 'index.html',
	$template = 'nginx/vhost.erb',
	$type = ['php']
) {
	include nginx

	$link_ensure = $ensure ? {
		'present' => 'link',
		default => 'absent',
	}

	$file_ensure = $ensure ? {
		'present' => 'file',
		default => 'absent',
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

	file { '/etc/nginx/globals/restrictions.conf':
		ensure => present,
		content => template('nginx/restrictions.conf.erb')
	}

	file { '/etc/nginx/globals/wordpress-mu.conf':
		ensure => present,
		content => template('nginx/wordpress-mu.conf.erb')
	}

	file { "/etc/nginx/sites-available/${priority}-${file}.conf":
		ensure 	=> $file_ensure,
		content => template($template),
		require => File["/etc/nginx/sites-enabled/${priority}-${file}.conf"],
		notify 	=> Service['nginx'],
	}

	file { "/etc/nginx/sites-enabled/${priority}-${file}.conf":
		ensure 	=> $link_ensure,
		target 	=> "/etc/nginx/sites-available/${priority}-${file}.conf",
		require => Package['nginx'],
	}
}