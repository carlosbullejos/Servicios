from pysnmp.hlapi import getCmd, SnmpEngine, UdpTransportTarget, ContextData, ObjectType, ObjectIdentity, CommunityData
from netmiko import ConnectHandler

cisco_881 = {
    'device_type': 'cisco_ios',
    'host':   '10.10.10.101',
    'username': 'admin',
    'password': 'admin',
    'port' : 22,          # optional, defaults to 22
    'secret': '',     # optional, defaults to ''
}
net_connect = ConnectHandler(**cisco_881)
output = net_connect.send_command('show ip int brief')
print(output)


ip=['10.10.10.101','10.10.10.102','10.10.10.103','10.10.10.104']
comunidad=['china','camerun','canada','chile']

routers=dict(zip(ip,comunidad))

for ips,comunidades in routers.items():
        varip=input("Introduce la IP del router: ")
        varcomunidad=input("Introduce el nombre de la comunidad: ")
        if varip == ips and varcomunidad == comunidades:
            iterator = getCmd(
                SnmpEngine(),
                CommunityData(comunidades, mpModel=0), # En vez de public va el nombre de la comunidad que se le de al router.
                UdpTransportTarget((ips, 161)),
                ContextData(),
                ObjectType(ObjectIdentity('.1.3.6.1.2.1.1.1.0'))
            )#buscar el OID del router.

            errorIndication, errorStatus, errorIndex, varBinds = next(iterator)

        if errorIndication:
                print(errorIndication)

        elif errorStatus:
                print('%s at %s' % (errorStatus.prettyPrint(),
                                    errorIndex and varBinds[int(errorIndex) - 1][0] or '?'))

        else:
                for varBind in varBinds:
                    print(' = '.join([x.prettyPrint() for x in varBind]))