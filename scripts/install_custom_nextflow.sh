#!/bin/bash

cd /home/ubuntu/sp3
if [ $? -ne 0 ]
then
    echo 'Unable cd into sp3 directory.'
    exit 1
fi

oci artifacts generic artifact download --file /home/ubuntu/sp3/nextflow --auth instance_principal --artifact-id ocid1.genericartifact.oc1.uk-london-1.0.amaaaaaahe4ejdias3ay4msnugkxsxpvrp4se6tyw6vkvbcalf4f4bxp7dxq
if [ $? -ne 0 ]
then
    echo 'Unable to download nextflow.'
    exit 1
fi

sudo mv nextflow /usr/bin
sudo chmod a+x /usr/bin/nextflow