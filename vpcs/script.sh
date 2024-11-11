#!/bin/bash
# Actualizar el repositorio e instalar Docker y s3fs
sudo apt-get update
sudo apt-get install -y docker.io
sudo apt-get install -y s3fs

# Iniciar servicio Docker
sudo systemctl start docker
sudo systemctl enable docker

# Crear Dockerfile para ProFTP
mkdir -p /home/admin/proftp
echo 'FROM debian:latest

# Instalar paquetes necesarios para ProFTP y LDAP
RUN apt-get update && apt-get install -y proftpd proftpd-mod-ldap ldap-utils

# Configurar puertos pasivos de ProFTP
RUN echo "PassivePorts 1100 1101" >> /etc/proftpd/proftpd.conf

# Crear el usuario de FTP
RUN adduser --disabled-password --gecos "" carlos
RUN echo "carlos:carlos" | chpasswd

# Copiar el archivo de configuración de ProFTP
COPY proftpd.conf /etc/proftpd/proftpd.conf

# Establecer el comando para ejecutar ProFTP
CMD ["proftpd", "--nodaemon"]

# Exponer puertos FTP
EXPOSE 20 21 1100 1101' > /home/admin/proftp/Dockerfile

# Crear archivo de configuración de ProFTP con LDAP
cat <<EOF > /home/admin/proftp/proftpd.conf
<IfModule mod_ldap.c>
  LDAPServer "ldap://$LDAP_SERVER_IP"
  LDAPBaseDN "dc=example,dc=com"
  LDAPBindDN "cn=admin,dc=example,dc=com"
  LDAPPassword "password"
  LDAPUserFilter "(&(objectClass=inetOrgPerson)(uid=%u))"
  LDAPGroupFilter "(&(objectClass=posixGroup)(memberUid=%u))"
  LDAPUserNameAttribute "uid"
  LDAPGroupNameAttribute "cn"
  LDAPLogLevel 0
</IfModule>

PassivePorts 1100 1101
EOF

# Crear archivo de credenciales de AWS
cd /home/admin
sudo mkdir .aws
sudo echo "[default]
aws_access_key_id=ASIAVI3F4JOOAKCTPNQX
aws_secret_access_key=AkXdYrcYQQTp3v9abM0h6XoMBGqx7r5nxXRqxcM7
aws_session_token=IQoJb3JpZ2luX2VjEPv//////////wEaCXVzLXdlc3QtMiJGMEQCIFptqN0KcWBcJw3Gyx5pj7D8XP/oYo/3khBYBcgA69zAAiADL4IUP0fhoDfWHsgXHUvp8WQd18kpypEje6CmXujv/CrAAgiE//////////8BEAAaDDM2MjYwMTUzMjMxNiIM0dFrvJstNPXcxglDKpQC86Q1h/lT7D5uWhvw1/xNRKOCwrErLzRWSkI0M9JRaLoyoDWogbv9yclFBLM59JTt8/UNN8ilN8CQuy2OQaPIWsyr1Ye2mZOzKZ7vzSaSoFIuL+CaDIpKN9rLbrCgIMvJpegMWq3zyxBtjV4PC8BL5/AnC3QOMZ1U68UlN1TtmFl7uYxA/ROBIoWc6MboAdIRMYoNQGfi/Y7TG1XguOpz70lNsm8ntZ7TEQAP9AU9XX1e0M1m/B5wA/9lg7yyL3QdTGDO8+cQ9azGDASIow+dsiiomtf6KyoEGptIOHnBwX27u/qpL0bpRokI9ZSd9tUG5PQ+uTuOQW+zeVMl8mmBAIXl6+eyFGH+/qY6Gx+KRC3RtBumMPjDwLkGOp4BnN/oiBTbMO4wGHUKHZx3K7ArPYPqOQx1MLOJ+WBSGEdu0Vlbr9ALdMU/WCBErlJ0R6Qf8RVv6wZz89UGU6gIm+kthp1n50q3M0lBk381GXwwbL71vDI3oQE58WfyUnhnvVz+AT4+CaCdnf7byiNw81HpwsIVtpPmhkGWUuho4nwvDPBsi99VXsYm1lRwFI4h17XLsNILBZlA9Pd9wzo=" > .aws/credentials
sudo mkdir -p /home/admin/carpeta_bucket
sudo chmod 755 /home/admin/carpeta_bucket
sudo mkdir -p /root/.aws
sudo cp /home/admin/.aws/credentials /root/.aws/credentials

# Montar el bucket S3
sudo s3fs my-ftp-storage-bucket /home/admin/carpeta_bucket -o allow_other

# Construir y ejecutar el contenedor Docker con LDAP y configuración de ProFTP
cd /home/admin/proftp
sudo docker build -t proftp .
sudo docker run -d --name proftp -p 21:21 -p 20:20 -p 1100:1100 -p 1101:1101 -v /home/admin/carpeta_bucket:/home/carlos proftp

