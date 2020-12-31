sudo apt-get update
echo Y | sudo apt-get install apt-transport-https apt-utils openssh-server ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ $(lsb_release -cs) stable"
sudo apt-get update
echo Y | sudo apt-get install docker-ce docker-ce-cli containerd.io
