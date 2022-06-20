#!/bin/bash

# Prerequisites
# apply TkgServiceConfiguration for additionalTrustedCAs (Harbor)
# Create tkc with 60gb storage for workers
# kubectl create clusterrolebinding default-tkg-admin-privileged-binding --clusterrole=psp:vmware-system-privileged --group=system:authenticated
# Download Carvel imgpkg. Version 0.12.0 or higher is required. https://network.tanzu.vmware.com/products/imgpkg/
#      mv imgpkg-linux-amd64-0.29.0 imgpkg
#      chmod +x imgpkg
#      sudo cp imgpkg /usr/bin
#
# Download and install the Tanzu CLI. https://network.tanzu.vmware.com/products/tanzu-application-platform/#/releases/1095326/file_groups/8255
#      mkdir $HOME/tanzu
#      tar -xvf tanzu-framework-linux-amd64.tar -C $HOME/tanzu
#      export TANZU_CLI_NO_INIT=true
#      cd $HOME/tanzu
#      export VERSION=v0.11.4 
#      sudo install cli/core/$VERSION/tanzu-core-linux_amd64 /usr/local/bin/tanzu
#      tanzu version
#      tanzu plugin install --local cli all
#      tanzu plugin list
#
# Install Carvel kapp controller and secret gen controller on your cluster.
#    kapp deploy -a kc -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml
#    kapp deploy -a sg -f https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/latest/download/release.yml
#
# Download the kp CLI for your operating system from the Tanzu Build Service page on Tanzu Network. See the kp CLI help text.
#      mv kp-linux-0.5.0 kp
#      chmod +x kp
#      sudo cp kp /usr/bin
#
#  Install Docker


##################
# Edit Variables #
##################

export INSTALL_REGISTRY_HOSTNAME=harbor1.wizards.lab
export INSTALL_REPOSITORY=harbor1.wizards.lab/tbs/build-service
export INSTALL_REGISTRY_USERNAME=admin
export INSTALL_REGISTRY_PASSWORD=Harbor12345
export TBS_VERSION=1.5.2

export REGISTRY_CERT_PATH=/etc/docker/certs.d/${INSTALL_REGISTRY_HOSTNAME}/ca.crt

export TANZU_CLI_NO_INIT=true
export CLI_VERSION=v0.11.4

export STORAGECLASS=tanzu-nfs01-policy

export INSTALL_DIR=$HOME/TBS
####################
# End of Variables #
####################


kubectl create clusterrolebinding default-tkg-admin-privileged-binding --clusterrole=psp:vmware-system-privileged --group=system:authenticated


curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --batch --yes
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
apt-cache madison docker-ce



cp imgpkg-linux-amd64-0.29.0 imgpkg
chmod +x imgpkg
sudo cp imgpkg /usr/bin

cp kp-linux-0.5.0 kp
chmod +x kp
sudo cp kp /usr/bin

mkdir $HOME/tanzu
tar -xvf tanzu-framework-linux-amd64.tar -C $HOME/tanzu

cd $HOME/tanzu
 
sudo install cli/core/$CLI_VERSION/tanzu-core-linux_amd64 /usr/local/bin/tanzu
tanzu version
tanzu plugin install --local cli all
tanzu plugin list


cd $INSTALL_DIR
kapp deploy -a kc -f  https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml --yes
kapp deploy -a sg -f  https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/latest/download/release.yml --yes


########################################################
# Replace the ca_cert_data with the REGISTRY_CERT_PATH #
########################################################

cat > tbs-values.yaml <<-EOF
kp_default_repository: ${INSTALL_REPOSITORY}/
kp_default_repository_username: ${INSTALL_REGISTRY_USERNAME}
kp_default_repository_password: ${INSTALL_REGISTRY_PASSWORD}
pull_from_kp_default_repo: true
ca_cert_data: |
  -----BEGIN CERTIFICATE-----
  MIIHZTCCBU2gAwIBAgITGwAAAA+j3miU5bcjIAAAAAAADzANBgkqhkiG9w0BAQsF
  ADBKMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxFzAVBgoJkiaJk/IsZAEZFgdXaXph
  cmRzMRgwFgYDVQQDEw9XaXphcmRzLVJvb3QtQ0EwHhcNMjIwMzE1MTkwNTMzWhcN
  MjQwMzE0MTkwNTMzWjBIMQswCQYDVQQGEwJDSDEbMBkGA1UEChMSRXhhbXBsZSBV
  bml2ZXJzaXR5MRwwGgYDVQQDExNoYXJib3IxLndpemFyZHMubGFiMIICIjANBgkq
  hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA0/9r5S51D2B/yjdJ4bd0Qm+0nIoCX6K5
  FcZMOeBgNJhy7VLhq9nwXNMx3fYzwMrcMj3rdbcRfwGTsbHu5DgJNc87DtXEjrRB
  6VwWY6c6fMe4LeTZ53S9v+cUn/Xexmz8bSAf/ZGwi3hJOW6yqSFHr/E16G+C1H++
  Y9m25j/CnfGzK5UbB5fEQbvtLVpdeDIPgIsGaIxYjimpqwF47CJcvLgLMKBoVRiX
  8lPJWUgQHq53jwCCL2HZvH2Vjrqw/bKwcQTwK45jneiI/fRpd8R+Ijok+7anKEt4
  TO4XDDH7yTLU5QEqYiSI3mxsaITzicnUMwELail8QAA5zMnCrXSieJbQx7ISAF7H
  HvRJK2cYfVUj6sBd2lw97PDDMdDi8/P/yPzDQkOGJ3e57z1UG1HoVnnlN/iBel1t
  OJFHFMqZap3ylZkB0+MWnJ6NleOmLlphkt5wh4XcwS+0OM+HDAyOykz2PTr31z93
  86LOuhvEAoVjXBukcT+TuY6ZFVJBERFeY6n9OABpM/MzJJRW/Lsz/98OPeLO2biJ
  NWfSumQ/3EHVVdN8Ibs66UrcU6pXn3/nJtgcNJk5rZ/LPTekqf8U8hje+z5XuFA7
  2GQiqZW/Lz9mRvlk5R5etdOaaqfGKb9fwExDNGesBXtc6M+TEsAcIExIRdQ+4t/3
  VoC2y2zIhiMCAwEAAaOCAkQwggJAMB4GA1UdEQQXMBWCE2hhcmJvcjEud2l6YXJk
  cy5sYWIwHQYDVR0OBBYEFJI53MikUPnUuJF934FSfn+/p9TYMB8GA1UdIwQYMBaA
  FFnjLxKmJIQp7d/mS4gB+RkKXP6jMIHPBgNVHR8EgccwgcQwgcGggb6ggbuGgbhs
  ZGFwOi8vL0NOPVdpemFyZHMtUm9vdC1DQSxDTj1XaXotREMxLENOPUNEUCxDTj1Q
  dWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0
  aW9uLERDPVdpemFyZHMsREM9bG9jYWw/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlz
  dD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIHDBggrBgEF
  BQcBAQSBtjCBszCBsAYIKwYBBQUHMAKGgaNsZGFwOi8vL0NOPVdpemFyZHMtUm9v
  dC1DQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2Vydmlj
  ZXMsQ049Q29uZmlndXJhdGlvbixEQz1XaXphcmRzLERDPWxvY2FsP2NBQ2VydGlm
  aWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MCEG
  CSsGAQQBgjcUAgQUHhIAVwBlAGIAUwBlAHIAdgBlAHIwDgYDVR0PAQH/BAQDAgWg
  MBMGA1UdJQQMMAoGCCsGAQUFBwMBMA0GCSqGSIb3DQEBCwUAA4ICAQAS3/Uh/zX6
  KXYxnZrFubOrTyd+cZRp5VR/DM9bzvCcukydDP+pMXrYPprtjnyerQQ13NAGEmnR
  SzmC1RpjyI3YPVJiKEBfeyqqtD8C5L9KgApQg7FXmyGOtBYcNIA+GaD2Rd7oVdtX
  87ECbhp8vM+vIy661twcNQqUaR7No5dtT4uncrFYpS/7DNLEUPcak+XiGRA7dd9D
  NXo4DG34ldpOKK/wfRs1CQkEA6+y7z23pmMjofXyBjJ9X9PopxrPCqmaLaDPmufY
  hGLHCrl7DYWvHYeGBPWnrjWoJGHyX7Ncpv7KN1I2SqLQCuhlWizaV0ul5R6N6589
  QW6CSQuEwVRqAT+VyrjJbmXa6nh1Mv/EaQSR37HGu36dZs8UT0/f+OZ0+NVx0XZm
  v4fkjwUeSUPrTtuIfvTFKxm4cRwT8vTiY45T4x2QiBWqtYeEyj5ZL/oBbXcI9jMw
  HX+pW4A7NRkE+5poeEaGMJt10LWzcTJlhSIrnUlUwQ0CXaJ7FoKiV05CeN+DqZ1D
  p8W+Jq6dmKSzFuCKoJXaBc2oMbTNyMFWoGdZOSqrOaUO1EnRVhT+tnp1CAAq/bzn
  Rkvn2CPAcHtqAx9nE1E3fDPxia9QzB0TPFCiANFzLniLDZaAb+mmUnrZ5Rr8XrNk
  6cqVK3opfDxEBglqLWuw88vBNc37yIqW0g==
  -----END CERTIFICATE-----


EOF




docker login registry.tanzu.vmware.com
docker login ${INSTALL_REGISTRY_HOSTNAME}

imgpkg copy -b registry.tanzu.vmware.com/build-service/package-repo:$TBS_VERSION --to-tar=/tmp/tanzu-build-service.tar --registry-ca-cert-path ${REGISTRY_CERT_PATH}

imgpkg copy --tar /tmp/tanzu-build-service.tar  --to-repo=${INSTALL_REPOSITORY}  --registry-ca-cert-path ${REGISTRY_CERT_PATH}
  
kubectl create ns tbs-install
kubectl apply -f ~/TBS/kapps-cm-config.yaml -n kapp-controller
kubectl delete pod -n kapp-controller --all
sleep 5
tanzu package repository add tbs-repository --url "${INSTALL_REPOSITORY}:${TBS_VERSION}" --namespace tbs-install
    
tanzu package repository get tbs-repository --namespace tbs-install

tanzu package install tbs -p buildservice.tanzu.vmware.com -v $TBS_VERSION -n tbs-install -f ~/TBS/tbs-values.yaml

export DEPENDENCIES_VERSION=100.0.312
imgpkg copy -y -b registry.tanzu.vmware.com/tbs-dependencies/full:"${DEPENDENCIES_VERSION}"  --to-tar=/tmp/tbs-dependencies.tar
imgpkg copy -y --tar=/tmp/tbs-dependencies.tar  --to-repo "${INSTALL_REPOSITORY}"
  
imgpkg pull -y -b "${INSTALL_REPOSITORY}:${DEPENDENCIES_VERSION}" -o /tmp/descriptor-bundle --registry-ca-cert-path ${REGISTRY_CERT_PATH}

kbld -f /tmp/descriptor-bundle/.imgpkg/images.yml  -f /tmp/descriptor-bundle/tanzu.descriptor.v1alpha3/descriptor-"${DEPENDENCIES_VERSION}".yaml  | kp import -f -
kubectl patch storageclass ${STORAGECLASS} -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


# kp secret create harbor1-creds --registry ${INSTALL_REGISTRY_HOSTNAME} --registry-user admin
# kp secret create my-git-ssh-cred --git git@github.com --git-ssh-key PATH-TO-GITHUB-PRIVATE-KEY
# kp secret create my-git-cred --git https://github.com --git-user GITHUB-USERNAME

#kp image create pacman-test3 --tag harbor1.wizards.lab/library/pac --git https://github.com/saintdle/pacman.git

# kp image create ddd --tag harbor1.wizards.lab/library/ddd --git https://github.com/egedsoft/devops-excercise.git --git-revision master


#kp image create my-image --tag ${INSTALL_REGISTRY_HOSTNAME}/tbs/test-app --git https://github.com/buildpacks/samples --sub-path ./apps/java-maven --wait
