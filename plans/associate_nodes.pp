plan pevm::associate_nodes(
  String $master = 'master',
  TargetSpec $agents,
) {
  run_task(bootstrap::linux, $agents, "install puppet-agent on agent nodes", {master => $master.get_target.host})

  $certnames = $agents.get_targets.map |$agent| { $agent.host }
  run_task(pevm::sign_certs, $master, "sign agent certificates", {certnames => $certnames})

  run_task(pevm::run_agent, $agents, "run puppet on agents to setup pxp-agent")
}
