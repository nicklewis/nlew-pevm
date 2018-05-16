# Installs PE on a vmpooler VM
plan pevm(
  String $version = '2018.1',
  String $password = 'istrator',
  Integer $agents = 0
) {
  $platform = 'centos-7-x86_64'

  $master = floaty::get($platform)

  # XXX This should all be one task and/or plan
  run_command("curl -skL getpe.delivery.puppetlabs.net/latest/${version}/el-7-x86_64 | tar xf -", $master, "download the PE VM")
  run_command("cd puppet-enterprise-* && sed -e 's/.*console_admin_password.*/\"console_admin_password\": \"${password}\"/' conf.d/pe.conf > conf.d/custom-pe.conf", $master, "update console admin password")
  run_command("cd puppet-enterprise-* && ./puppet-enterprise-installer -c conf.d/custom-pe.conf", $master, "install PE on the master")

  run_task(pevm::run_agent, $master, "run puppet on the master to finish the setup")

  # XXX This should be a task
  run_command("echo ${password} | /opt/puppetlabs/bin/puppet-access login admin --lifetime 7d", $master, "create RBAC token")

  if $agents > 0 {
    run_plan(pevm::addnodes, master => $master, platform => $platform, count => $agents)
  }

  notice "Finished installing Puppet Enterprise ${version}.x on a ${platform} host: ${master}"

  return $master
}
