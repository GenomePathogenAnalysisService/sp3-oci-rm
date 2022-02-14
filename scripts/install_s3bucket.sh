#!/bin/bash

# Pull the s3 bucket secrets from Vault

mkdir -p /data/inputs/s3

if [ $? -ne 0 ]
then
    echo 'Failed to create /data/inputs/s3 directory.'
    exit 1
fi

oci secrets secret-bundle get \
 --raw-output \
 --auth instance_principal \
 --secret-id ${Gpas_dev_ox_ac_uk_s3_secret_id} \
 --query "data.\"secret-bundle-content\".content" | base64 --decode > /home/ubuntu/.passwd-s3fs-oracle-test

chmod 600 /home/ubuntu/.passwd-s3fs-oracle-test

if [ ! -f .passwd-s3fs-oracle-test ] 
then
    echo 'Failed to create s3 file for bucket mount.'
    exit 1
fi

# mount the s3 bucket(s)

cd /home/ubuntu/catsgo/

. /home/ubuntu/env/bin/activate 

python3 oracle_buckets.py go --bucket-names ${Gpas_dev_ox_ac_uk_s3_bucket_names}
