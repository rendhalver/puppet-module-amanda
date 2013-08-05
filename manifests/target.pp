# You can define $amanda_client_backupserver,
# with the fqdn of the backaupserver, to export
# the targets to a specfic server, otherwise they 
# will be exported with 'amanda_target_default', 
# which will be imported on _every_ amanda 
# backupserver.
#
# Setting the dumptype to absent, will ensure 
# that the target is not included in the backup.

define amanda::target(
  $ensure = present,
  $hostname = $fqdn,
	$config = $amanda::client::config,
  $dir_path = $title,
  $dumptype = $amanda::client::dumptype,
  $server = $amanda::client::server,
) {
  include amanda::params
	include concat::setup
	$disklist = "$amanda::params::configs_directory/$config/disklist"

	@@concat::fragment{"amanda_disklist_${server}_${fqdn}_${title}":
		ensure	=> $ensure,
		target	=> $disklist,
		content	=> "$hostname   $title   $dumptype\n",
		order	=> 30,
		tag		=> "amanda_target_${server}",
	}

}
