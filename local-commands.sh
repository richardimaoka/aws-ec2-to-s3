#!/bin/bash

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
INSTANCE_IDS=$(aws ec2 describe-instances --filter "Name=tag:aws:cloudformation:stack-name,Values=aws-ec2-to-s3" | jq 'Reservations[].Instances[].InstanceId')
# The above result is flattened array in multi-line output 
# although Reservations[] and Instances[] are nested arrays
# "i-0b852411111111111"
# "i-0b852422222222222"
# "i-0b852433333333333"

# Turn the multi-line result into a single line
INSTANCE_IDS=$($INSTANCE_IDS | paste -sd " ")

# Make sure all the EC2 instances in the Cloudformation stack are up and running
echo $INSTANCE_IDS
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_IDS

# Remote command to generate some results and copy the result file from EC2 to S3
aws ssm send-command \
  --instance-ids $INSTANCE_IDS \
  --document-name "AWS-RunPowerShellScript" \
  --parameters commands=["/home/ec2-user/aws-ec2-to-s3/remote-ec2-to-s3.sh"]

