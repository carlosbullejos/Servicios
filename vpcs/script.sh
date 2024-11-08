 user_data = <<-EOF
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
    cat << 'EOT' > /home/admin/proftp/Dockerfile
    FROM debian:latest
    RUN apt-get update && apt-get install -y proftpd
    RUN echo "PassivePorts 1100 1101" >> /etc/proftpd/proftpd.conf
    RUN adduser --disabled-password --gecos "" carlos
    RUN echo "carlos:carlos" | chpasswd
    CMD ["proftpd", "--nodaemon"]
    EXPOSE 20 21 1100 1101
    EOT

    # Crear archivo de credenciales de AWS
    sudo mkdir -p ~/.aws
    cat > ~/.aws/credentials <<-AWS_CREDENTIALS
    [default]
    aws_access_key_id=ASIAVI3F4JOOGPW6TDQL
    aws_secret_access_key=N6p2Al1K5c36suvmwHrCf6whEkAm21wdNckMUkTk
    aws_session_token=IQoJb3JpZ2luX2VjENT//////////wEaCXVzLXdlc3QtMiJHMEUCIQDvWyw+uSw2fNcf/9IUeK1vmDADmuTrh21qBgCdTgFv9gIgfzcS2UYN/CU8jH5E0Tnlaa8m6W52BjDja6m4tCQgX8cqtwIIXRAAGgwzNjI2MDE1MzIzMTYiDC02J32FJb6eA5JYuCqUAtRMI97WrcTAK6oJ/cNtPWPL1+TJM1a4BxwfhAKlbHwn1Eq9bh6EEaokym2tf7u7ZDw3cZLfZWRSnNXe5EhivWY3Z8ZL/eCiI63CSC6iR88vZH1xMKy8fxPXh1cCxKctEpNRhJKnDTE4uFRn3SbyICod7rMdP5rkoA1E4UnK06hlwiFtlqHKqRPpcvg3BxueOxae04ATjC9WiM0o+RUK2cOtrhfiawPDz3fZFpQdAsqtL7zOZ02ppA+0HQArmzhAfBxLBsz7Z/tCic7iymyu2ihK4QpCi2fr1/frMTep+C9asfrxuCeqKkjjj/I62YHgRcrvcNEo5hw6Yo4YD/E+zHdfjpg9rj7GaLBzAYC4wcB/1hBmVzCK8Le5BjqdAdC3HvQ+3jNf8zL2R+JC08AKV7zwK0V7U3JzyphS4jypvlVXoDpjWPBm6gbGsWftzisNuvO6PlG6gV6uyEwzixc3hiJeRNYWK9EARC6duLtsHDEaKNbUOyMNjJHd4uK1GGacqmW8n0adgJRgRi/TD5DO8ffDexGaumXQOH9LoE08M93eE4N+/49shug4e4KyKcLVzqumBVE8vXiXNvA=
    AWS_CREDENTIALS
    # Crear directorio del bucket de S3
    sudo mkdir -p /home/admin/carpeta_bucket
    sudo chmod 755 /home/admin/carpeta_bucket
    
    # Montar el bucket S3
    sudo s3fs my-ftp-storage-bucket /home/admin/carpeta_bucket -o allow_other
    
    # Construir y ejecutar el contenedor Docker
    cd /home/admin/proftp
    sudo docker build -t proftp .
    sudo docker run -d --name proftp -p 21:21 -p 20:20 -p 1100-1100:1101-1101 -v /home/admin/carpeta_bucket:/home/carlos proftp
  EOF
}
