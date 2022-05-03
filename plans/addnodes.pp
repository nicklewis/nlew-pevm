plan pevm::addnodes(
  String $master = 'master',
  String $platform = 'centos-7-x86_64',
  Integer[1] $count = 2,
) {
  $agents = floaty::get($platform, $count)

  run_task(bootstrap::linux, $agents, "install puppet-agent on agent nodes", {master => $master})

  run_task(pevm::sign_certs, $master, "sign agent certificates", {certnames => $agents})

  run_task(pevm::run_agent, $agents, "run puppet on agents to setup pxp-agent")

  $agents
}
