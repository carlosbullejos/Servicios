#!/bin/bash
# Actualiza el sistema e instala Docker y Docker Composeç
sleep 30
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Crea el directorio para los archivos de configuración
mkdir -p /home/admin/ldap

# Crea el archivo docker-compose.yml
cat << 'EOT' > /home/admin/ldap/Dockerfile

# Usar la imagen base de osixia/openldap
FROM osixia/openldap:1.5.0
# Copiar archivo LDIF para agregar usuarios y estructura


# Configurar variables de entorno para el dominio y la contraseña
ENV LDAP_ORGANISATION="Carlos FTP"
ENV LDAP_DOMAIN="carlosftp.com"
ENV LDAP_ADMIN_PASSWORD="admin_password"

# Configurar el contenedor para cargar el archivo LDIF al inicio


EOT

# Crea el archivo users.ldif
cat << 'EOF' > /home/admin/ldap/bootstrap.ldif

# Unidad organizativa para usuarios
dn: ou=users,dc=carlosftp,dc=com
objectClass: top
objectClass: organizationalUnit
ou: users

# Usuario: Daniel
dn: uid=daniel,ou=users,dc=carlosftp,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
cn: daniel
sn: Perez
uid: daniel
mail: daniel@carlosftp.com
userPassword: daniel
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/ftp/
loginShell: /bin/bash

# Usuario: Alejandro
dn: uid=alejandro,ou=users,dc=carlosftp,dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
cn: alejandro
sn: Garcia
uid: alejandro
mail: alejandro@carlosftp.com
userPassword: alejandro
uidNumber: 1002
gidNumber: 1002
homeDirectory: /home/ftp/
loginShell: /bin/bash

EOF

cd /home/admin/ldap
docker build -t myldap .

# Ejecutar el contenedor con registro en modo debug
docker run -d -p 389:389 -p 636:636 --name ldap myldap --loglevel debug

# Esperar unos segundos para que el servicio LDAP esté listo
sleep 10

# Copiar el archivo LDIF al contenedor
docker cp bootstrap.ldif ldap:/tmp

# Agregar la configuración desde el archivo LDIF
docker exec ldap ldapadd -x -D "cn=admin,dc=carlosftp,dc=com" -w admin_password -f /tmp/bootstrap.ldif

# Configurar contraseñas para los usuarios
docker exec ldap ldappasswd -x -D "cn=admin,dc=carlosftp,dc=com" -w admin_password -s "daniel" "uid=daniel,ou=users,dc=carlosftp,dc=com"
docker exec ldap ldappasswd -x -D "cn=admin,dc=carlosftp,dc=com" -w admin_password -s "alejandro" "uid=alejandro,ou=users,dc=carlosftp,dc=com"

# Reiniciar el contenedor
docker stop ldap
docker start ldap
