#!/bin/bash                                                                                                                                                                                                        

# Create a CentOS 7 VM on a KVM host
#
# Use this script on the local KVM host
# The only required parameter in --name=HOSTNAME to give the VM this hostname
#
# Elger Postema
# sept 2015

# some options still need to be made variable, for now I set them here:
#
# the network bridge to connect to
BRIDGE="br0"

# @TODO : add the KICKSTARTOPTIONS as an option
# configure the netork
IP=1.2.3.4
NETMASK=255.255.255.0
GATEWAY=1.2.3.1
NAMESERVER1=1.2.3.2
NAMESERVER2=1.2.3.3
KICKSTARTOPTIONS="network ip=$IP::$GATEWAY:$NETMASK:$NAME:eth0:none nameserver=$NAMESERVER1 nameserver=$NAMESERVER2 bootdev=eth0"
#KICKSTARTOPTIONS="--bootproto=dhcp --hostname $NAME --device=eth0"

# @TODO : add the REPOSITORY as an option
# where are the installation files
REPOSITORY=http://some.repo.url/centos/7/os/x86_64

# where to find the kickstart file
if [ "$KICKSTART" = "" ]
then
    KICKSTART="ftp://user:pass@some.repo.url/minimalcentos7.ks"
fi

# Now process the parameters given on the commandline
for i in "$@"
do
case $i in
    -n=*|--name=*)
    NAME="${i#*=}"
    ;;

    -d=*|--disk=*)
    DISK="${i#*=}"
    ;;

    -s=*|--size=*)
    SIZE="${i#*=}"
    ;;

    -f|--force)
    FORCE="YES"
    ;;

    -k|--kickstart=*)
    KICKSTART="${i#*=}"
    ;;

    -h|--help)
    HELP="YES"
    ;;

    *)
            # unknown option
    ;;
esac
done

me=`basename "$0"`

EXITWITHERROR=false

if [ "$NAME" = "" ] || [ "$HELP" = "YES" ]
then
  echo "Usage : $me -n|--name=<vpsname> [-d|--disk=<path to qcow file>] [-s|--size=<disksize>] [-k|--kickstart=<url of kickstart file>] [-f|--force]"
  exit 1
fi

# The hostname and the name for the VPS
NAME=${NAME}

# The qcow2 image for the VPS
if [ "$DISK" = "" ]
then
    DISK=/var/lib/libvirt/images/$NAME.img
fi

# If the VPS was still running from a previous attempt, stop and remove it.
$(virsh domid $NAME 2>1 > /dev/null )
EXISTS=$?
if [ "$EXISTS" -eq 0 ] && [ "$FORCE" = "YES" ]
then
  virsh destroy $NAME
  virsh undefine $NAME
fi

if [ "$EXISTS" -eq 0 ] && [ "$FORCE" != "YES" ]
then
  echo "ERROR: $NAME already exists, not doing anything right now."
  echo "You might want to use the --force Luke."
  exit 1
fi

# remove the disk from a previous attempt
if [ -f "$DISK" ] && [ ${FORCE} = "YES" ]
then
  rm $DISK
fi

if [ -f $DISK ]
then
  echo "ERROR: $DISK already exists, quitting"
  echo "You might want to use the --force Luke."
  exit 2
fi

if [ "$SIZE" = "" ]
then
  SIZE=8G
fi

# create a new disk
qemu-img create -f qcow2 $DISK $SIZE
QCOWDISK=" --disk path=$DISK,format=qcow2,device=disk,bus=virtio,cache=writethrough"

# start the installation
#
# one known issue is that the CentOS7 installer will use the DNS name that belongs to the IP
# and not the given name.
#
# TODO : allow the creation of swap
#        --disk path=$SWAP,format=qcow2,device=disk,bus=virtio,cache=writeback
echo "name: $NAME"
echo "disk: $QCOWDISK"
echo "repo: $REPOSITORY"
echo "kickstart: $KICKSTART"
echo "options: $KICKSTARTOPTIONS"

virt-install --hvm --name $NAME --ram=1024 \
$QCOWDISK \
--network bridge:$BRIDGE,model=virtio \
--vcpus=2,maxvcpus=3 \
--os-variant=centos7.0 \
--location=$REPOSITORY \
--graphics vnc \
--keymap=en-us \
--extra-args "ks=$KICKSTART $KICKSTARTOPTIONS servername=$NAME"


#--accelerate --vnc \
#--os-type=linux --os-variant generic26 \
