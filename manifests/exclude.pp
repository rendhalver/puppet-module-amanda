define amanda::exclude ($ensure) {
  include amanda::params

	file_line {"${name}":
		ensure => present,
		path   => "${amanda::params::configs_directory}/exclude.list",
		line   => "${name}",
	}

}

