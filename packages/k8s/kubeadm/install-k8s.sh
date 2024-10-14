#!/bin/bash
set -euxo pipefail

RELEASE=$1
DOWNLOAD_DIR=$2
ARCH=$3
cd "$DOWNLOAD_DIR"
sudo curl -L --remote-name-all https://dl.k8s.io/release/"${RELEASE}"/bin/linux/"${ARCH}"/{kubeadm,kubelet,kubectl}
sudo chmod +x {kubeadm,kubelet,kubectl}
cd -

sed "s:/usr/bin:${DOWNLOAD_DIR}:g" files/etc/systemd/system/kubelet.service | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
sed "s:/usr/bin:${DOWNLOAD_DIR}:g" files/etc/systemd/system/kubelet.service.d/10-kubeadm.conf | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
mkdir -p  /etc/default
cp files/etc/default/kubelet /etc/default
systemctl enable kubelet 
