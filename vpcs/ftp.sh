#!/bin/bash

# Actualizar el sistema
sudo apt-get update

# Instalar dependencias necesarias para Docker
sudo apt-get install -y ca-certificates curl

# Agregar la clave GPG de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Agregar el repositorio de Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar los índices de paquetes e instalar Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Instalar s3fs
sudo apt update
sudo apt install s3fs -y

# Configurar credenciales de AWS
sudo mkdir -p ~/.aws
sudo cat > ~/.aws/credentials <<EOF
[default]
[default]
aws_access_key_id=ASIAVI3F4JOOEAPBVMPI
aws_secret_access_key=5PoG294ByVa27RY5buvzxzfA6qouc6b2ZMxEQrbz
aws_session_token=IQoJb3JpZ2luX2VjEOz//////////wEaCXVzLXdlc3QtMiJIMEYCIQDjWiKbr0X+DLgYWC6szcGluxd+Wd5vbMUs3NYlKeJ9EwIhANWBuikb56/47mqygWmR1Z5tl5j2LElVcYmVk9k4f7mgKsACCJX//////////wEQABoMMzYyNjAxNTMyMzE2IgyaCpuKix6xLNeIh/YqlAKcJFXg+LybHTjtyFDjtVBJbiEJGPK6LJZYtrbOWmQsxxeHcUC3k9Ova6fnTDfQ3gHSDy7Mm7lcoWNAayXacDZy/SmBn2Hoe0NJrXAUotReq0+0mUf3BUEMVUjtbmq2J676kuhTFqftejBRW2NuBVgeCXXtZvkb1wDFHZqKFZTkRSeFt+sLKX3YZgoVs+lPR5xA+ExGwnOU+HELw1jxpxtisNF3/FZVM/EkYRtExY/RcMIkBvCLVfNSc69l35A5I1jSiKcwwMCe09VDcmtmzDRmr1al3iwUuum8/hp/Am5MshOpfXli9DyRtlJeSEJRAsmO4grNyARCBAg5UxTKZrlfgelGbYdNNOSi4BVqHdo8t8yWebAw+d6tugY6nAFrFdzBXnOnCxFCB4IK8MJMffA5OkJWmeIgF2Ab1/xfDCFzy7e7tLtyx9tMVvbIkRkfuWAn1nGXMIi1RsyyXiksZHNbIu6A1I+EaBQL22CHE8/BVda8E0QW0jMa97Yyhz8eitSWQGnTBMKamK+GedTyLwQkaP8HIvOwLhuGIanC6uGp6cnr1+V8ZmMFBVIDTxUvIV6OT62CXfvw71A=
EOF
sudo apt install cron -y
# Crear directorio para el FTP
sudo mkdir -p /home/admin/ftp
sudo mkdir /mnt/bucket-s3
sudo chmod 777 /mnt/bucket-s3

# Habilitar cron para que se inicie automáticamente en el arranque
sudo systemctl enable cron

#!/bin/bash

# Asegurarse de que cron está instalado y en ejecución
sudo apt update
sudo apt install cron -y

#!/bin/bash

# Asegurarse de que cron está instalado y en ejecución
sudo apt update
sudo apt install cron -y
sudo apt install rsync -y
# Iniciar el servicio de cron si no está en ejecución
sudo systemctl start cron
sudo systemctl enable cron

# Añadir el cron job automáticamente si no existe

(crontab -l 2>/dev/null; echo "* * * * * rsync -av /home/admin/ftp/ /mnt/bucket-s3/") | crontab -


# Montar el bucket S3 en el directorio del FTP
sudo s3fs my-ftp-storage-bucket /mnt/bucket-s3 -o allow_other


# Crear directorio para el Dockerfile
mkdir -p /home/docker
cd /home/docker

# Crear el Dockerfile
cat > Dockerfile <<EOF
FROM debian:latest

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y proftpd openssl nano proftpd-mod-crypto proftpd-mod-ldap ldap-utils

# Instalar el módulo de criptografía de ProFTPD
RUN apt-get update && apt-get install -y proftpd-mod-crypto && apt-get install proftpd-mod-ldap -y
RUN useradd -m -s /bin/bash carlos && echo 'carlos:carlos' | chpasswd
RUN mkdir -p /home/admin/ftp && chown -R carlos:carlos /home/admin && chmod -R 777 /home/admin && chmod -R 777 /home/

# Generar el certificado SSL/TLS para ProFTPD
RUN openssl req -x509 -newkey rsa:2048 -sha256 -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.crt -nodes -days 365 \
    -subj "/C=ES/ST=España/L=Granada/O=carlos/OU=carlos/CN=ftp.carlos.com"

# Eliminar el bloque de cuotas anterior de /etc/proftpd/proftpd.conf
RUN sed -i '/<IfModule mod_quotatab.c>/,/<\/IfModule>/d' /etc/proftpd/proftpd.conf

# Configuración de ProFTPD
RUN echo "DefaultRoot /home/admin/ftp" >> /etc/proftpd/proftpd.conf && \
    echo "Include /etc/proftpd/modules.conf" >> /etc/proftpd/proftpd.conf && \
    echo "LoadModule mod_ldap.c" >> /etc/proftpd/modules.conf && \
    echo "Include /etc/proftpd/ldap.conf" >> /etc/proftpd/proftpd.conf && \
    echo "Include /etc/proftpd/tls.conf" >> /etc/proftpd/proftpd.conf && \
    echo "PassivePorts 1100 1101" >> /etc/proftpd/proftpd.conf && \
    echo "<IfModule mod_tls.c>" >> /etc/proftpd/tls.conf && \
    echo "  TLSEngine on" >> /etc/proftpd/tls.conf && \
    echo "  TLSLog /var/log/proftpd/tls.log" >> /etc/proftpd/tls.conf && \
    echo "  TLSProtocol SSLv23" >> /etc/proftpd/tls.conf && \
    echo "  TLSRSACertificateFile /etc/ssl/certs/proftpd.crt" >> /etc/proftpd/tls.conf && \
    echo "  TLSRSACertificateKeyFile /etc/ssl/private/proftpd.key" >> /etc/proftpd/tls.conf && \
    echo "</IfModule>" >> /etc/proftpd/tls.conf && \
    echo "<Anonymous /home/admin/ftp>" >> /etc/proftpd/proftpd.conf && \
    echo "  User ftp" >> /etc/proftpd/proftpd.conf && \
    echo "  Group nogroup" >> /etc/proftpd/proftpd.conf && \
    echo "  UserAlias anonymous ftp" >> /etc/proftpd/proftpd.conf && \
    echo "  RequireValidShell off" >> /etc/proftpd/proftpd.conf && \
    echo "  MaxClients 10" >> /etc/proftpd/proftpd.conf && \
    echo "  <Directory *>" >> /etc/proftpd/proftpd.conf && \
    echo "    <Limit WRITE>" >> /etc/proftpd/proftpd.conf && \
    echo "      DenyAll" >> /etc/proftpd/proftpd.conf && \
    echo "    </Limit>" >> /etc/proftpd/proftpd.conf && \
    echo "  </Directory>" >> /etc/proftpd/proftpd.conf && \
    echo "</Anonymous>" >> /etc/proftpd/proftpd.conf && \
    echo " LoadModule mod_tls.c" >> /etc/proftpd/modules.conf

# Añadir configuración de cuotas a /etc/proftpd/proftpd.conf
RUN echo "<IfModule mod_quotatab.c>" >> /etc/proftpd/proftpd.conf && \
    echo "QuotaEngine on" >> /etc/proftpd/proftpd.conf && \
    echo "QuotaLog /var/log/proftpd/quota.log" >> /etc/proftpd/proftpd.conf && \
    echo "<IfModule mod_quotatab_file.c>" >> /etc/proftpd/proftpd.conf && \
    echo "     QuotaLimitTable file:/etc/proftpd/ftpquota.limittab" >> /etc/proftpd/proftpd.conf && \
    echo "     QuotaTallyTable file:/etc/proftpd/ftpquota.tallytab" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf

RUN cd /etc/proftpd
# Comandos ftpquota para crear tablas y registros
RUN cd /etc/proftpd && ftpquota --create-table --type=limit --table-path=/etc/proftpd/ftpquota.limittab && \
    ftpquota --create-table --type=tally --table-path=/etc/proftpd/ftpquota.tallytab && \
    ftpquota --add-record --type=limit --name=carlos --quota-type=user --bytes-upload=20 --bytes-download=400 --units=Mb --files-upload=15 --files-download=50 --table-path=/etc/proftpd/ftpquota.limittab && \
    ftpquota --add-record --type=tally --name=carlos --quota-type=user

# Configuración de LDAP en /etc/proftpd/proftpd.conf
RUN echo "<IfModule mod_ldap.c>" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPLog /var/log/proftpd/ldap.log" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPAuthBinds on" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPServer ldap://10.1.1.100:389" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPBindDN \"cn=admin,dc=carlosftp,dc=com\" \"admin_password\"" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPUsers \"dc=carlosftp,dc=com\" \"(uid=%u)\"" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf

# Configuración de LDAP en /etc/proftpd/ldap.conf
RUN echo "<IfModule mod_ldap.c>" >> /etc/proftpd/ldap.conf && \
    echo "    # Dirección del servidor LDAP" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPServer 10.1.1.100" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPBindDN \"cn=admin,dc=carlosftp,dc=com\" \"admin_password\"" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPUsers ou=users,dc=carlosftp,dc=com (uid=%u)" >> /etc/proftpd/ldap.conf && \
    echo "    CreateHome on 755" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPGenerateHomedir on 755" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPForceGeneratedHomedir on 755" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPGenerateHomedirPrefix /home" >> /etc/proftpd/ldap.conf && \
    echo "</IfModule>" >> /etc/proftpd/ldap.conf

RUN echo "<Directory /home/admin/ftp>" >> /etc/proftpd/proftpd.conf && \
    echo "<Limit WRITE>" >> /etc/proftpd/proftpd.conf && \
    echo "  DenyUser daniel" >> /etc/proftpd/proftpd.conf && \
    echo "</Limit>" >> /etc/proftpd/proftpd.conf && \
    echo "</Directory>" >> /etc/proftpd/proftpd.conf 
# Exponer los puertos de FTP
EXPOSE 20 21 1100 1101

CMD ["sh", "-c", "chmod -R 777 /home/admin/ftp && proftpd --nodaemon"]


EOF

# Construir la imagen de Docker
docker build -t myproftpd .

# Ejecutar el contenedor
docker run -d --name proftpd -p 20:20 -p 21:21 -p 1100:1100 -p 1101:1101 -v /home/admin/ftp:/home/admin/ftp myproftpd


#echo "LoadModule mod_ctrls_admin.c" >> /etc/proftpd/modules.conf && \
