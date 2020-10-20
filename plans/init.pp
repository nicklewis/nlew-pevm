# @summary
#   Installs PE on a vmpooler VM
#
# @param version The version of Puppet Enterprise to install
# @param password The console admin user password
# @param agents How many agents, if any, to provision and connect
plan pevm(
  String $version = 'latest',
  String $password = lookup('console_password'),
  Integer $agents = 0,
) {
  $master = get_target('master')
  $platform = 'centos-7-x86_64'

  run_task('pevm::install', $master, "install PE", password => $password)

  run_task(pevm::run_agent, $master, "run puppet on the master to finish the setup")

  # XXX This should be a task
  run_command("echo ${password} | /opt/puppetlabs/bin/puppet-access login admin --lifetime 7d", $master, "create RBAC token")

  if $agents > 0 {
    run_plan(pevm::addnodes, master => $master, platform => $platform, count => $agents)
  }

  out::message("Finished installing Puppet Enterprise on a ${platform} host: ${master}")
}
