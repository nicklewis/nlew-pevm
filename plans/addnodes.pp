plan pevm::addnodes(
  String $master,
  String $platform = 'centos-7-x86_64',
  Integer[1] $count = 2,
) {
  $agents = floaty::get($platform, $count)

  run_task(pevm::install_agent, $agents, {master => $master})

  run_task(pevm::sign_certs, $master, {certnames => $agents})

  run_task(pevm::run_agent, $agents)

  $agents
}
