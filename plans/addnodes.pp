# Provisions and installs the agent on a set of nodes
plan pevm::addnodes(
  String $master = 'master',
  String $platform = 'centos-7-x86_64',
  Integer[1] $count = 2,
) {
  $agents = floaty::get($platform, $count)

  run_plan(pevm::associate_nodes, {master => $master, agents => $agents})

  $agents
}
