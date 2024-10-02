from netmiko import ConnectHandler

# Pedimos al usuario que ingrese los datos del router

# Definimos la clase Router
class Router:
    def __init__(self, device_type, host, username, password, port=22):
        # Constructor para inicializar los atributos del router
        self.device_type = device_type
        self.host = host
        self.username = username
        self.password = password
        self.port = port

    def conexion(self):
        # Crear el diccionario con las opciones de conexión
        router = {
            "device_type": self.device_type,
            "host": self.host,
            "username": self.username,
            "password": self.password,
            "port": self.port
        }
        # Realizar la conexión usando ConnectHandler
        self.net_connect = ConnectHandler(**router)
        print("Conexión completada")

    def comando(self, comando_2):
        # Enviar un comando al router
        salida = self.net_connect.send_command(comando_2)
        print(salida)


# Comprobación de ejecución en el script principal
if __name__ == "__main__":
    while True:
        router_pregunta=input("En qué router quieres ingresar algún comando. Exit para salir: ")
        if router_pregunta == "exit":
            break
        elif router_pregunta == "mikrotik":
        # Crear instancias de la clase Router para cada dispositivo
            mikrotik = Router("mikrotik_routeros", "10.10.10.103", "admin", "admin", 22)
            mikrotik.conexion() # Conectar a los routers
            mikrotik.comando("ip address print")    # Enviar comandos a los routers
        elif router_pregunta == "cisco": 
            cisco= Router("cisco_ios","10.10.10.101","admin","admin",22)
            cisco.conexion()
            cisco.comando("show ip interface brief")
        elif router_pregunta == "bird2":
            bird2=Router("linux","10.10.10.102","gns3","gns3",22)
            bird2.conexion()
            bird2.comando("ip a")
        elif router_pregunta == "juniper":
            juniper=Router("juniper","10.10.10.104","admin","admin1.",22)
            juniper.conexion()
            juniper.comando("show interfaces")

    
