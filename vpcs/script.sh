#!/bin/bash

# Actualizar e instalar Docker
sudo apt-get update
sudo apt-get install -y ca-certificates curl

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
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configurar ProFTPD para permitir conexiones pasivas
RUN echo 'PassivePorts 1100 1101' >> /etc/proftpd/proftpd.conf
RUN echo 'DefaultRoot ~' >> /etc/proftpd/proftpd.conf
EXPOSE 20 21 1100 1101

# Crear usuario FTP
RUN useradd -m -s /bin/bash carlos && echo 'carlos:carlos' | chpasswd

# Directorio FTP en contenedor
VOLUME /ftp

# Comando de arranque de ProFTPD
CMD ["proftpd", "--nodaemon"]
EOF

# Construir y ejecutar el contenedor Docker FTP
sudo docker build -t myproftpd .
sudo docker run -d -p 20:20 -p 21:21 -p 1100:1100 -p 1101:1101 -v /home/ubuntu/ftp:/ftp myproftpd

# Configuración de sincronización con S3
sudo apt-get install -y awscli

# Crear directorio para sincronizar con S3
mkdir -p /home/ubuntu/ftp-s3

# Sincronizar el bucket S3 con el directorio de la instancia
aws s3 sync s3://my-ftp-storage-bucket /home/ubuntu/ftp-s3

# Configurar tareas cron para sincronización automática
(crontab -l 2>/dev/null; echo "*/5 * * * * aws s3 sync /home/ubuntu/ftp-s3 s3://my-ftp-storage-bucket") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * aws s3 sync s3://my-ftp-storage-bucket /home/ubuntu/ftp-s3") | crontab -
