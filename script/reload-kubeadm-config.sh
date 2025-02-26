#!/usr/bin/env bash

# Copyright 2018 The KubeSphere Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
K8S_HOME=$(dirname "${SCRIPTPATH}")

source "${K8S_HOME}/script/common.sh"

if [ ${ENV_MASTER_COUNT} -gt 1 ]
then
    replace_kubeadm_config_lb_ip
fi
# Write kubelet configuration to file "/var/lib/kubelet/config.yaml"
# Write kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
kubeadm init phase kubelet-start --config  ${KUBEADM_CONFIG_PATH}

if [ "${HOST_ROLE}" == "master" ]
then
    # Write Static Pod manifest
    kubeadm init phase control-plane all --config ${KUBEADM_CONFIG_PATH}
    if [ "${HOST_SID}" == "1" ]
    then
        # storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
        retry kubeadm init phase upload-config kubeadm --config ${KUBEADM_CONFIG_PATH} --kubeconfig ${KUBECONFIG}
        # Creating a ConfigMap "kubelet-config-1.13" in namespace kube-system with the configuration for the kubelets in the cluster
        retry kubeadm init phase upload-config kubelet --config ${KUBEADM_CONFIG_PATH} --kubeconfig ${KUBECONFIG}
    fi
fi

# Reload config
systemctl daemon-reload
systemctl restart kubelet