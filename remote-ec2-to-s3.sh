#!/bin/bash

# command to create a file to copy
# for the purpose of the demo, this remote-gen-text.sh is super simple
cd "$(dirname "$0")"
./remote-gen-text.sh

# On Amazon Linux, AWS CLI is already installed
# Note that an instance profiler setup is needed to execute AWS CLI on EC2
aws s3 mv results.txt s3://samplebucket-richardimaoka-sample-sample/sample-folder/

