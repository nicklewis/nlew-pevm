#!/usr/bin/env bash

set -e

if [ "latest" = "${PT_version?}" ]; then
  version=$(curl -q https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/main/ci-ready/LATEST)
else
  version="${PT_version?}"
fi

curl -skL "https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/main/ci-ready/puppet-enterprise-${version?}-el-7-x86_64.tar" | tar xf -
cd puppet-enterprise-*
sed -e "s/.*console_admin_password.*/\"console_admin_password\": \"${PT_password?}\"/" conf.d/pe.conf > conf.d/custom-pe.conf
if [ "true" = "${PT_code_manager?}" ]; then
  sed -i -e '/^}$/d' conf.d/custom-pe.conf
  cat <<CONFIG >> conf.d/custom-pe.conf
  "puppet_enterprise::profile::master::code_manager_auto_configure": true
  "puppet_enterprise::profile::master::r10k_remote": "${PT_control_repo?}"
  "puppet_enterprise::profile::master::r10k_private_key": "/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa"
}
CONFIG
fi

./puppet-enterprise-installer -c conf.d/custom-pe.conf
