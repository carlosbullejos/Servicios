from netmiko import ConnectHandler
class Router:
    def __init__(self, device_type, host, username, password, port=22):
        self.device_type = device_type
        self.host = host
        self.username = username
        self.password = password
        self.port = port

    def conexion(self):
        router = {
            "device_type": self.device_type,
            "host": self.host,
            "username": self.username,
            "password": self.password,
            "port": self.port
        }
        self.net_connect = ConnectHandler(**router)
        print(f"Conexión completada con el router {self.host}")

    def comando(self, comando_2):
        salida = self.net_connect.send_command(comando_2)
        print(salida)

    def enviar_comandos(self, archivo_comandos):
        with open(archivo_comandos, 'r') as file:
            comandos = file.read().splitlines()
        salida = self.net_connect.send_config_set(comandos)
        print(salida)


if __name__ == "__main__":
    while True:
        router_pregunta = input("En qué router quieres ingresar algún comando. Exit para salir: ").lower()
        if router_pregunta == "exit":
            break
                                                                                                #MIKROTIK
        elif router_pregunta == "mikrotik":
            mikrotik = Router("mikrotik_routeros", "10.10.11.2", "admin", "admin", 22)
            mikrotik.conexion()
            mikrotik.enviar_comandos("comandos_mikrotik.txt") 
            
        elif router_pregunta == "cisco":
                                                                                                #CISCO
            cisco = Router("cisco_ios", "10.10.10.101", "admin", "admin", 22)
            cisco.conexion()
            cisco.enviar_comandos("comandos_cisco.txt")
        
        elif router_pregunta == "cisco2":
                                                                                                #CISCO
            cisco = Router("cisco_ios", "10.10.13.2", "admin", "admin", 22)
            cisco.conexion()
            cisco.enviar_comandos("comandos_cisco2.txt")
            
        elif router_pregunta == "cisco3":
                                                                                                #CISCO
            cisco = Router("cisco_ios", "10.10.14.2", "admin", "admin", 22)
            cisco.conexion()
            cisco.enviar_comandos("comandos_cisco3.txt")
            
        elif router_pregunta == "cisco4":
                                                                                                #CISCO
            cisco = Router("cisco_ios", "10.10.15.2", "admin", "admin", 22)
            cisco.conexion()
            cisco.enviar_comandos("comandos_cisco4.txt")
            
        elif router_pregunta == "bird2":
                                                                                                #BIRD2
            bird2 = Router("linux", "10.10.16.2", "gns3", "gns3", 22)
            bird2.conexion()
            bird2.enviar_comandos("comandos_bird2.txt")
        elif router_pregunta == "juniper":
                                                                                                #JUNIPER
            juniper = Router("juniper", "10.10.12.2", "admin", "admin1.", 22)
            juniper.conexion()
            juniper.enviar_comandos("comandos_juniper.txt")
        else:
            print("Router no reconocido. Intenta con mikrotik, cisco, bird2 o juniper.")
