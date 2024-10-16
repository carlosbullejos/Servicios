import tftpy
import threading

class Tftp():
    def __init__(self,ip,puerto,directorio):
        self.ip=ip
        self.puerto=puerto
        self.directorio=directorio
        
    def asignar_directorio(self):
        self.servidor=tftpy.TftpServer(self.directorio)
        
    def escuchar(self):
        self.servidor.listen(self.ip,self.puerto)
        
if __name__ == "__main__":
    servidor_tftp=Tftp('0.0.0.0',69,'ftpy/server')
    servidor_tftp.asignar_directorio()
    
    servidor_segundoplano=threading.Thread(target=servidor_tftp.escuchar)
    servidor_segundoplano.daemon=True
    servidor_segundoplano.start()
    
    while True:
      parar=input("Escribe parar para parar el servidor tftp: ")
      if parar == "parar":
          break