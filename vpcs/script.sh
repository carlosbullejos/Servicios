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

# Crear Dockerfile con el contenido necesario
cat > Dockerfile <<EOF
FROM debian:latest

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    proftpd \
    s3fs \
    fuse \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configuración del FTP
RUN echo 'PassivePorts 1100 1101' >> /etc/proftpd/proftpd.conf
RUN echo 'DefaultRoot ~' >> /etc/proftpd/proftpd.conf
EXPOSE 20 21 1100 1101

# Crear usuario FTP
RUN useradd -m -s /bin/bash carlos && echo 'carlos:carlos' | chpasswd

# Crear carpeta para montar el bucket S3
RUN mkdir -p /ftp-s3

# Configurar FTP para usar la carpeta montada en S3
RUN ln -s /ftp-s3 /home/carlos/ftp-storage

# Comando de arranque de ProFTPD
CMD ["proftpd", "--nodaemon"]
EOF

# Construcción del contenedor Docker
sudo docker build -t myproftpd /home/docker

# Ejecutar el contenedor Docker pasando las credenciales de AWS como variables de entorno
sudo docker run -d -p 20:20 -p 21:21 -p 1100:1100 -p 1101:1101 \
    -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
    -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
    -e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
    myproftpd


