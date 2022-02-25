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

deactivate 

# Run on_headnode_reboot.sh when headnode is rebooted
tee <<EOF /home/ubuntu/on_headnode_reboot.sh
#!/bin/bash
# Run this script to mount s3 bucket objects when headnode is rebooted and s3 bucket is empty

echo "Mount s3 bucket objects"
cd /home/ubuntu/catsgo/
. /home/ubuntu/env/bin/activate
python3 oracle_buckets.py go --bucket-names ${Gpas_dev_ox_ac_uk_s3_bucket_names}
deactivate
EOF

chmod 755 /home/ubuntu/on_headnode_reboot.sh

# Use cron to execute on_headnode_reboot.sh on reboot
cd /home/ubuntu/
crontab -l > on_headnode_reboot_cron
# On reboot, wait for 60 seconds before running on_headnode_reboot.sh
echo "@reboot sleep 60 && /home/ubuntu/on_headnode_reboot.sh \
      > /home/ubuntu/reboot-cron-output.txt 2>&1" >> on_headnode_reboot_cron
# Set up the cron
crontab on_headnode_reboot_cron
# Remove the temp cron file
rm on_headnode_reboot_cron

