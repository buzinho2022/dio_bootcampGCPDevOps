#!/bin/bash
# add repository ansible epel
sudo yum install epel-release -y
echo "start instalation ansible"
sudo yum install ansible -y

sudo cat <<EOF | sudo tee > /etc/hosts
10.0.2.2 control-node
10.0.2.3 app01
10.0.2.4 db01
EOF

