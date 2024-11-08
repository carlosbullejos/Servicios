#!/bin/bash

# Actualizar e instalar Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo apt-get install -y cron
sudo apt-get install -y rsync

# Instalar llaves y repositorio de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker y sus componentes
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Iniciar Docker y configurarlo para iniciar al arranque
sudo systemctl start docker
sudo systemctl enable docker
sudo mkdir -p /home/admin/ftp-temp
sudo mkdir -p /home/admin/ftp
echo "* * * * * rsync -av /home/admin/ftp-temp/* /home/admin/ftp/" >> /etc/crontab
sudo service cron restart
sudo echo "s3fs#my-ftp-storage-bucket /home/admin/ftp/ fuse    allow_other,use_cache=/tmp,url=https://s3.amazonaws.com 0 0" >> /etc/fstab
sudo systemctl daemon-reload
sudo mount -a

# Crear directorio de trabajo para Dockerfile
mkdir -p /home/docker
cd /home/docker

# Crear Dockerfile para el contenedor FTP
cat > Dockerfile <<EOF
FROM debian:latest

# Instalar ProFTPD y dependencias
RUN apt-get update && apt-get install -y \
    proftpd \
    ca-certificates \
    cron \
    rsync \
    nano \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configurar ProFTPD para permitir conexiones pasivas
RUN echo "* * * * * rsync -av /home/carlos/* /tmp/" >> /etc/crontab
RUN echo 'PassivePorts 1100 1101' >> /etc/proftpd/proftpd.conf
RUN echo 'DefaultRoot ~' >> /etc/proftpd/proftpd.conf
EXPOSE 20 21 1100 1101
CMD ["cron", "-f"]
# Crear usuario FTP
RUN useradd -m -s /bin/bash carlos && echo 'carlos:carlos' | chpasswd
RUN service cron restart 
# Directorio FTP en contenedor
VOLUME /ftp

# Comando de arranque de ProFTPD
CMD ["proftpd", "--nodaemon"]
EOF

# Construir y ejecutar el contenedor Docker FTP
sudo docker build -t myproftpd .
sudo docker run -d -p 20:20 -p 21:21 -p 1100:1100 -p 1101:1101 -v /home/admin/ftp-temp:/tmp myproftpd

# Configuración de sincronización con S3
sudo apt-get install -y awscli

