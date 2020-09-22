# @summary
#   Installs PE on a vmpooler VM
#
# @param version The version of Puppet Enterprise to install
# @param password The console admin user password
# @param master The hostname of the server to use as the PE master
# @param agents How many agents, if any, to provision and connect
plan pevm(
  String $version = 'latest',
  String $password = 'istrator',
  TargetSpec $master = undef,
  Integer $agents = 0,
) {
  $platform = 'centos-7-x86_64'

  if $master {
    $master_target = $master.get_target
  } else {
    $master_target = floaty::get($platform).get_target
    run_command("floaty modify ${master_target} --tags '{\"pevm\": \"master\"}'", localhost)
  }

  run_task('pevm::install', $master_target, "install PE on the master", password => $password)

  run_task(pevm::run_agent, $master_target, "run puppet on the master to finish the setup")

  # XXX This should be a task
  run_command("echo ${password} | /opt/puppetlabs/bin/puppet-access login admin --lifetime 7d", $master_target, "create RBAC token")

  if $agents > 0 {
    run_plan(pevm::addnodes, master => $master_target, platform => $platform, count => $agents)
  }

  out::message("Finished installing Puppet Enterprise on a ${platform} host: ${master}")

  return $master_target
}
