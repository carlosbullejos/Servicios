from netmiko import ConnectHandler

cisco_881 = {
    'device_type': 'mikrotik_roufdafdateros',
    'host':   '10.10.10.103',
    'username': 'admin',
    'password': 'admin',
    'port' : 22,          # optional, defaults to 22
    'secret': '',     # optional, defaults to ''
}

net_connect = ConnectHandler(**cisco_881)
output = net_connect.send_command('ip address print')
print(output)