#!/bin/bash

# This resource and associated terraform code is temporary. It should be removed during review.

cd /home/ubuntu/sp3
if [ $? -ne 0 ]
then
    echo 'Unable cd into sp3 directory.'
    exit 1
fi

sudo apt remove openjdk-8-jre-headless -y
if [ $? -ne 0 ]
then
    echo 'Unable to uninstall openjdk-8-jre-headless'
    exit 1
fi

wget https://github.com/nextflow-io/nextflow/releases/download/v22.04.0/nextflow-22.04.0-all
if [ $? -ne 0 ]
then
    echo 'Unable to download nextflow-22.04.0.'
    exit 1
fi

sudo mv nextflow-22.04.0-all /usr/bin/nextflow
sudo chmod a+x /usr/bin/nextflow