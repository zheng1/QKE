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

echo "*************************"
echo "update sshd config"
echo "*************************"

sed -i 's/TCPKeepAlive yes/TCPKeepAlive no/g' /etc/ssh/sshd_config
if ! grep "ClientAliveInterval" /etc/ssh/sshd_config >/dev/null
then
    echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config
fi
if ! grep "ClientAliveCountMax" /etc/ssh/sshd_config >/dev/null
then
    echo "ClientAliveCountMax 720" >> /etc/ssh/sshd_config
fi

systemctl restart ssh