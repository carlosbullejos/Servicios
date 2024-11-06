#!/bin/bash
# Instalación de Docker en la instancia
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

# Crear Dockerfile para el contenedor FTP
mkdir -p /home/docker
cd /home/docker

touch Dockerfile

# Configuración del Dockerfile
echo "FROM debian:latest" >> Dockerfile

# Instalar dependencias necesarias
echo "RUN apt-get update && apt-get install -y \
    proftpd \
    s3fs \
    fuse \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*" >> Dockerfile

# Configuración del FTP
echo "RUN echo 'PassivePorts 1100 1101' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "RUN echo 'DefaultRoot ~' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "RUN echo 'MasqueradeAddress 54.159.37.114' >> /etc/proftpd/proftpd.conf" >> Dockerfile
echo "EXPOSE 20 21 1100 1101" >> Dockerfile

# Crear usuario FTP
echo "RUN useradd -m -s /bin/bash carlos && echo 'carlos:carlos' | chpasswd" >> Dockerfile

# Inyectar las credenciales de AWS usando las variables de entorno
# Esto asume que las credenciales se pasan como variables de entorno cuando el script se ejecuta
echo "RUN echo 'AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}' > /root/.passwd-s3fs && \
    echo 'AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}' >> /root/.passwd-s3fs && \
    chmod 600 /root/.passwd-s3fs" >> Dockerfile

# Crear carpeta para montar el bucket S3
echo "RUN mkdir -p /ftp-s3" >> Dockerfile

# Montar el bucket S3 como sistema de archivos
echo "RUN s3fs ftp-storage-bucket /ftp-s3 -o passwd_file=/root/.passwd-s3fs -o url=https://s3.amazonaws.com" >> Dockerfile

# Configurar FTP para usar la carpeta montada en S3
echo "RUN ln -s /ftp-s3 /home/carlos/ftp-storage" >> Dockerfile

# Comando de arranque de ProFTPD
echo 'CMD ["proftpd", "--nodaemon"]' >> Dockerfile

# Construcción y ejecución del contenedor
sudo docker build -t myproftpd /home/docker
sudo docker run -d -p 20:20 -p 21:21 -p 1100:1100 -p 1101:1101 myproftpd


