from pysnmp.hlapi import getCmd, SnmpEngine, UdpTransportTarget, ContextData, ObjectType, ObjectIdentity, CommunityData

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
    