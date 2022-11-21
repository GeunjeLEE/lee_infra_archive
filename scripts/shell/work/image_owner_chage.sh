#!/bin/bash

export OS_AUTH_URL=http://[ip]:35357/v2.0
export OS_USERNAME=[]
export OS_PASSWORD=[]
export OS_PROJECT_ID=[]
export OS_REGION_NAME=[]
export LC_ALL=en_US.UTF-8
export PYTHONIOENCODING=UTF-8

Imageid=$1
Ownerid=$2
Mindisk=$3
Date=`date "+%Y%m%d %H:%M:%S"`
Log=/var/log/image-owner-chenge/image-owner-chenge.log

##### function #####
function api_v {
    case $1 in
        1) export OS_IMAGE_API_VERSION=1;;
        2) export OS_IMAGE_API_VERSION=2;;
    esac
}

function abort {
    case $1 in
        show)         echo $Date resultCode:12001 Imageid:$Imageid Ownerid:$Ownerid ERROR:Image check failed. $Error;;
        owner)        echo $Date resultCode:12002 Imageid:$Imageid Ownerid:$Ownerid ERROR:Owner ID change failed. $Error;;
        ownercheck)   echo $Date resultCode:12003 Imageid:$Imageid Ownerid:$Ownerid ERROR:Owner ID change check failed. $Error;;
        tag)          echo $Date resultCode:12004 Imageid:$Imageid Ownerid:$Ownerid ERROR:Image tag change failed. $Error;;
        tagcheck)     echo $Date resultCode:12005 Imageid:$Imageid Ownerid:$Ownerid ERROR:Image tag chenge check failed. $Error;;
        mindisk)      echo $Date resultCode:12006 Imageid:$Imageid Ownerid:$Ownerid ERROR:Mindisk add failed. $Error;;
        mindiskcheck) echo $Date resultCode:12007 Imageid:$Imageid Ownerid:$Ownerid ERROR:Mindisk add check failed. $Error;;
    esac | tee -a $Log
    exit 1
}

function image_check {
    Error=$(api_v 2; glance image-show $Imageid 2>&1 > /dev/null) || abort show
}

function owner_id_change {
    Error=$(api_v 1; openstack image set --owner $Ownerid --property owner_id=$Ownerid --property description='' $Imageid 2>&1 > /dev/null) || abort owner
}

function owner_id_change_check {
    Error=$(api_v 2; bash -e -o pipefail -c "glance image-show $Imageid | grep -w owner_id | grep -w $Ownerid" 2>&1 > /dev/null) || abort ownercheck
}

function tag_change {
    if [ "$(api_v 2; glance image-show $Imageid | grep -e '_CLOUD_TYPE_EXT_CG')" ]; 
    then
        Error=$(api_v 2; glance image-tag-delete $Imageid _CLOUD_TYPE_EXT_CG 2>&1 > /dev/null) || abort tag
        Error=$(api_v 2; glance image-tag-update $Imageid _CLOUD_TYPE_NORMAL 2>&1 > /dev/null) || abort tag
    else
        Error=$(api_v 2; glance image-tag-update $Imageid _AVAILABLE_ 2>&1 > /dev/null) || abort tag
        Error=$(api_v 2; glance image-tag-update $Imageid _CLOUD_TYPE_NORMAL 2>&1 > /dev/null) || abort tag
    fi
}

function tag_check {
    Error=$(api_v 2; bash -e -o pipefail -c "glance image-show $Imageid | grep -w tags | grep -v _CLOUD_TYPE_EXT_CG | grep -w _CLOUD_TYPE_NORMAL" 2>&1 > /dev/null) || abort tagcheck
}

function mindisk_add {
    if [ $Mindisk ];
    then
        Error=$(api_v 2; glance image-update --min-disk $Mindisk $Imageid 2>&1 > /dev/null) || abort mindisk
    fi
}

function mindisk_check {
    if [ $Mindisk ];
    then
        Error=$(api_v 2; bash -e -o pipefail -c "glance image-show $Imageid | grep -w min_disk | grep -w $Mindisk" 2>&1 > /dev/null) || abort mindiskcheck
    fi
}


##### main #####
image_check
owner_id_change
owner_id_change_check
tag_change
tag_check
mindisk_add
mindisk_check

echo "$Date Success. Imageid:$Imageid Ownerid:$Ownerid" | tee -a $Log