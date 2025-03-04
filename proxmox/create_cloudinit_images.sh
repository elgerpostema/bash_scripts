#!/bin/bash

cd  /mnt/iso/template/iso/

wget --continue "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
wget --continue "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
wget --continue "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
wget --continue "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"

#remove the vms
for NUMMER in 1804 2004 2204 2404 ;
do
	qm stop ${NUMMER}
	qm set ${NUMMER} --delete scsi0
	qm set ${NUMMER} --delete ide2
	qm destroy ${NUMMER}
done

# create a new VM with VirtIO SCSI controller
qm create 1804 --memory 2048 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --description "Ubuntu Server 18.04 LTS (Bionic Beaver)" --name "bionic-server-cloudimg-amd64"
sleep 5
qm create 2004 --memory 2048 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --description "Ubuntu Server 20.04 LTS (Focal Fossa)" --name "focal-server-cloudimg-amd64"
sleep 5
qm create 2204 --memory 2048 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --description "Ubuntu Server 22.04 LTS (Jammy Jellyfish)" --name "jammy-server-cloudimg-amd64"
sleep 5
qm create 2404 --memory 2048 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --description "Ubuntu Server 24.04 LTS (Noble Numbat)" --name "noble-server-cloudimg-amd64"

# import the downloaded disk to the local-lvm storage, attaching it as a SCSI drive
qm set 1804 --scsi0 zfs_pool_10:0,import-from=/mnt/iso/template/iso/bionic-server-cloudimg-amd64.img
sleep 5
qm set 2004 --scsi0 zfs_pool_10:0,import-from=/mnt/iso/template/iso/focal-server-cloudimg-amd64.img
sleep 5
qm set 2204 --scsi0 zfs_pool_10:0,import-from=/mnt/iso/template/iso/jammy-server-cloudimg-amd64.img
sleep 5
qm set 2404 --scsi0 zfs_pool_10:0,import-from=/mnt/iso/template/iso/noble-server-cloudimg-amd64.img

for NUMMER in 1804 2004 2204 2404 ;
do
	qm set ${NUMMER} --ide2 zfs_pool_10:cloudinit
	qm set ${NUMMER} --boot order=scsi0
	qm set ${NUMMER} --serial0 socket --vga serial0
	qm set ${NUMMER} --sshkey ~/.ssh/authorized_keys
	qm template ${NUMMER}
done
