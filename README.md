CloudFormation
 - either by aws cli
 - or from AWS console

local-commands.sh
  - which executes `remote-gen-text.sh` and `remote-ec2-to-s3.sh` on EC2 remotely via [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html)
  - [official video resources](https://www.youtube.com/watch?v=zwS8lssaY_k&list=PLhr1KZpdzukeH5jKyYi55ef9tEWAllypB)


About file permissions in git repo, [look here](https://medium.com/@akash1233/change-file-permissions-when-working-with-git-repos-on-windows-ea22e34d5cee).

- TL;DR
  - `git ls-files --stage` to check
  - `git update-index --chmod=+x 'name-of-shell-script'` to update