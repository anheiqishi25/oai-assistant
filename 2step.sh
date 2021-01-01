sudo groupadd docker
sudo gpasswd -a $xxx docker
sudo gpasswd -a $USER docker
newgrp docker
