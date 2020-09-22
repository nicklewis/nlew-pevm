#!/usr/bin/env bash

set -e

if [ "latest" = "${PT_version?}" ]; then
  version=$(curl -q https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/master/ci-ready/LATEST)
else
  version="${PT_version?}"
fi

curl -skL "https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/master/ci-ready/puppet-enterprise-${version?}-el-7-x86_64.tar" | tar xf -
cd puppet-enterprise-*
sed -e "s/.*console_admin_password.*/\"console_admin_password\": \"${PT_password?}\"/" conf.d/pe.conf > conf.d/custom-pe.conf
./puppet-enterprise-installer -c conf.d/custom-pe.conf
