#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker


mkdir -p /home/docker
cd /home/docker

touch Dockerfile

echo "FROM debian:latest" >> Dockerfile
echo "RUN apt-get update && apt-get install -y proftpd" >> Dockerfile
echo "RUN echo 'PassivePorts 1100 1101' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "RUN echo 'DefaultRoot ~' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "RUN echo 'MasqueradeAddress 54.159.37.114' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "EXPOSE 20 21 1100 1101" >> Dockerfile
echo "RUN useradd -m -s /bin/bash carlos && echo 'carlos:carlos' | chpasswd" >> Dockerfile
echo 'CMD ["proftpd", "--nodaemon"]' >> Dockerfile

sudo docker build -t myproftpd .
sudo docker run -d -p 20:20 -p 21:21 -p 1100:1100 -p 1101:1101 myproftpd

