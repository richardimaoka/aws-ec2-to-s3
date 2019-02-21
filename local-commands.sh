#!/bin/bash

# Any subsequent(*) commands which fail will cause the shell script to exit immediately
set -e

# Create the Cloudformation stack from the local template `ec2-to-s3.cf.yml`
aws cloudformation create-stack \
  --stack-name aws-ec2-to-s3 \
  --template-body file://ec2-to-s3.cf.yml \
  --capabilities CAPABILITY_NAMED_IAM
# This produces output like below:  
# {
#   "StackId": "arn:aws:cloudformation:ap-northeast-1:795483015259:stack/aws-ec2-to-s3/e02c0f30-35d9-11e9-943d-0aa3c9b7e68c"
# }

echo "Waiting until the Cloudformation stack is CREATE_COMPLETE"
aws cloudformation wait stack-create-complete --stack-name aws-ec2-to-s3

# Get list of EC2 instance IDs
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=tag:aws:cloudformation:stack-name,Values=aws-ec2-to-s3" "Name=instance-state-name,Values=running" --output text --query "Reservations[*].Instances[*].InstanceId")
# The above result is flattened array in multi-line output 
#   i-0b852411111111111
#   i-0b852422222222222
#   i-0b852433333333333

# Turn the multi-line result into a single line
INSTANCE_IDS=$(echo $INSTANCE_IDS | paste -sd " ")

# Make sure all the EC2 instances in the Cloudformation stack are up and running
echo "Waiting until the following EC2 instances are OK: $INSTANCE_IDS"
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_IDS

echo "Run the remote command to crate a result file and copy it from EC2 to S3"
aws ssm send-command \
  --instance-ids $INSTANCE_IDS \
  --document-name "AWS-RunShellScript" \
  --parameters commands=["/home/ec2-user/aws-ec2-to-s3/remote-ec2-to-s3.sh"]  

# Go to the following page and check the command status:
# https://console.aws.amazon.com/ec2/v2/home?#Commands:sort=CommandId