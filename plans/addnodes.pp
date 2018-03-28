plan pevm::addnodes(
  String $master,
  String $platform = 'centos-7-x86_64',
  Integer[1] $count = 2,
) {
  $agents = floaty::get($platform, $count)

  run_task(puppet::install, $agents, {master => $master})

  run_task(puppet::sign_certs, $master, {certnames => $agents})

  run_task(puppet::agent, $agents)

  $agents
}
