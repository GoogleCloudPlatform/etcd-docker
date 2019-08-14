#!/bin/bash
#
# Copyright 2019 Google LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Check if Root password is provided
if [[ ! -z "${ETCD_ROOT_PASSWORD}" ]]; then
    echo "==> Enabling etcd authentication..."
    # Starting etcd daemon
    etcd > /dev/null 2>&1 &
    ETCD_PID=$!
    while ! etcdctl member list &>/dev/null; do sleep 1; done
    # Creating root user and setting password
    echo "${ETCD_ROOT_PASSWORD}" | etcdctl user add root
    # Enabling Authentication
    etcdctl auth enable
    # Revoking quest role if exists
    etcdctl -u root:"${ETCD_ROOT_PASSWORD}" role revoke guest -path '/*' --readwrite
    # Killing etcd daemon
    kill "${ETCD_PID}"
else
    echo "ETCD_ROOT_PASSWORD is required"
    exit 1
fi

exec "$@"
