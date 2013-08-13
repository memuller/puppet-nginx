define nginx::vhost (
	$ensure = 'present',
	$root = "/var/www/${name}", 
	$priority = '50',
	$file = $name,
	$server_name = $name,
	$index = 'index.html',
	$template = 'nginx/vhost.erb',
	$type = ['php'],
	$extra = '',
	$www = false,
	$alternative = false

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

	if $alternative {
		file { "/etc/nginx/sites-available/${priority}-${alternative}.conf":
			ensure 	=> $file_ensure,
			content => "
				server { 
					server_name ${alternative} ; 
					rewrite ^ \$scheme://${file}\$uri permanent ; 
				}",
			require => File["/etc/nginx/sites-enabled/${priority}-${file}.conf"],
			notify 	=> Service['nginx'],
		}

		file { "/etc/nginx/sites-enabled/${priority}-www.${file}.conf":
			ensure 	=> $link_ensure,
			target 	=> "/etc/nginx/sites-available/${priority}-${alternative}.conf",
			require => Package['nginx'],
		}
	}

	if $www {
		file { "/etc/nginx/sites-available/${priority}-www.${file}.conf":
			ensure 	=> $file_ensure,
			content => "
				server { 
					server_name www.${file} ; 
					rewrite ^ \$scheme://${file}\$uri permanent ; 
				}",
			require => File["/etc/nginx/sites-enabled/${priority}-www.${file}.conf"],
			notify 	=> Service['nginx'],
		}

		file { "/etc/nginx/sites-enabled/${priority}-www.${file}.conf":
			ensure 	=> $link_ensure,
			target 	=> "/etc/nginx/sites-available/${priority}-www.${file}.conf",
			require => Package['nginx'],
		}		
	}
}