#!/usr/bin/env bash
# Ubuntu 14.04 用

## Shell Opts ----------------------------------------------------------------
set -e -u -x


## Vars ----------------------------------------------------------------------

ROOT="$(cd $(dirname $0); pwd)"
export ANSIBLE_ROLE_FILE=${ANSIBLE_ROLE_FILE:-${ROOT}/../requirements.txt}


## Functions -----------------------------------------------------------------

# (None)


## Main ----------------------------------------------------------------------

user=`whoami`
if [ "$user" != "root" ]
then
    echo "Must be run as root. You are $user."
    exit 1
fi

# Install Ansible
apt-get install software-properties-common
apt-add-repository ppa:ansible/ansible
apt-get update
apt-get install ansible -y

# Install Roles
if [ -e $ANSIBLE_ROLE_FILE ]; then
  ansible-galaxy install -r $ANSIBLE_ROLE_FILE
fi
