#!/bin/bash

SECONDS=0

set -e -x

# Needed so that the aptitude/apt-get operations will not be interactive
export DEBIAN_FRONTEND=noninteractive

apt-get clean all && apt-get update -q 2
apt-get install -y apt-transport-https ca-certificates awscli curl ntp

# Install Python 2 and related packages
sudo apt install python2 python2-dev python2-minimal -y

# Set Python 2 as the default version
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1
sudo update-alternatives --set python /usr/bin/python2

aws --region=us-east-1 s3 cp s3://mgdevops/static/dev-ssh-pub-keys.txt /tmp/dev-ssh-pub-keys.txt
cat /tmp/dev-ssh-pub-keys.txt | sudo tee -a /home/ubuntu/.ssh/authorized_keys

aws --region=us-east-1 ec2 create-tags --resources `ec2metadata --instance-id` --tags Key="Name",Value="logs.staging.use1.ecs.aws.mtro.co" Key="Hostname",Value="logs" Key="Domain",Value="staging.use1.ecs.aws.mtro.co" Key="PublicDomain",Value="staging.use1.ecs.mtro.co" Key="ForceDNSUpdate",Value="YES" 

aws --region=us-east-1 s3 cp s3://mgdevops/scripts/ec2_prepare_ecs_instance.sh /tmp/ec2_prepare_ecs_instance.sh

bash /tmp/ec2_prepare_ecs_instance.sh metroleads-logs

duration=$SECONDS
MSG="Launched spot instance [`hostname -f`] successfully in $(($duration / 60)) minutes and $(($duration % 60)) secs" 
ALERT_CHANNEL_URL="https://hooks.slack.com/services/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" 

curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$MSG"'"}' "$ALERT_CHANNEL_URL" 

echo "262144" | sudo tee /proc/sys/vm/max_map_count

aws --region=us-east-1 s3 cp s3://mgdevops/scripts/spot_termination_slack_notifier.sh /tmp/spot_termination_slack_notifier.sh
chmod +x /tmp/spot_termination_slack_notifier.sh
nohup /tmp/spot_termination_slack_notifier.sh > /dev/null 2>&1 &