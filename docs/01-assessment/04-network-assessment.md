# Network Assessment

---

## Document Information

| Campo | Valor |
|--------|-------|
| Documento | Network Assessment |
| Código | AS-IS-004 |
| Proyecto | Enterprise VMware to AWS Modernization Platform |
| Caso de Negocio | Distrito Miami |
| Fase | Assessment |
| Estado | En desarrollo |

---

# 1. Objetivo

Este documento describe el diseño de red del entorno actual (AS-IS) utilizado como infraestructura de origen para el proceso de migración hacia Amazon Web Services (AWS).

El objetivo es definir la topología de red, el direccionamiento IP, la comunicación entre servidores y las reglas necesarias para garantizar la conectividad de la plataforma.

---

# 2. Alcance

Este documento incluye:

- Topología de red.
- Segmentación.
- Direccionamiento IP.
- Hostnames.
- Comunicación entre servidores.
- Puertos utilizados.
- Flujo de red.
- Reglas de firewall.

---

# 3. Topología de Red

La plataforma opera sobre una red privada virtual implementada en VMware Workstation.

Todos los servidores pertenecen al mismo segmento de red y se comunican mediante una Virtual LAN.

```text
                           VMware Workstation

                   Virtual Network (LAN)

                          192.168.100.0/24

       -----------------------------------------------------------

       DM-WEB-01

       DM-API-01

       DM-DB-01

       DM-MON-01

       DM-BASTION-01

       -----------------------------------------------------------
```

---

# 4. Esquema de Direccionamiento

| Servidor | Hostname | Dirección IP |
|----------|----------|--------------|
| Web | DM-WEB-01 | 192.168.100.10 |
| API | DM-API-01 | 192.168.100.20 |
| Database | DM-DB-01 | 192.168.100.30 |
| Monitoring | DM-MON-01 | 192.168.100.40 |
| Bastion | DM-BASTION-01 | 192.168.100.50 |

---

# 5. Segmento de Red

| Parámetro | Valor |
|-----------|-------|
| Red | 192.168.100.0/24 |
| Gateway | 192.168.100.1 |
| Máscara | 255.255.255.0 |
| Tipo | LAN Privada |
| DHCP | No |
| Asignación IP | Estática |

---

# 6. Nombres DNS

Para facilitar la administración del laboratorio se utilizarán los siguientes nombres lógicos:

| Servicio | Nombre |
|-----------|--------|
| Web | web.distritomiami.local |
| API | api.distritomiami.local |
| Database | db.distritomiami.local |
| Monitoring | monitor.distritomiami.local |
| Bastion | bastion.distritomiami.local |

---

# 7. Flujo de Comunicación

```text
Cliente

↓

DM-WEB-01

↓

DM-API-01

↓

DM-DB-01

↓

Flow

↓

Amazon S3
```

---

# 8. Comunicación entre Componentes

| Origen | Destino | Servicio |
|---------|----------|-----------|
| Cliente | DM-WEB-01 | HTTP / HTTPS |
| DM-WEB-01 | DM-API-01 | API REST |
| DM-API-01 | DM-DB-01 | PostgreSQL |
| DM-API-01 | Flow | API HTTPS |
| DM-API-01 | Amazon S3 | Upload de imágenes |
| Administrador | DM-BASTION-01 | SSH |
| DM-MON-01 | Todos los servidores | Monitoreo |

---

# 9. Puertos Utilizados

| Puerto | Protocolo | Servicio |
|---------|-----------|----------|
| 22 | TCP | SSH |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 3000 | TCP | API Node.js |
| 5432 | TCP | PostgreSQL |
| 3001 | TCP | Grafana |
| 9090 | TCP | Prometheus |

---

# 10. Reglas de Firewall

El laboratorio aplicará el principio de mínimo privilegio.

Las comunicaciones permitidas serán únicamente las necesarias para el funcionamiento de la plataforma.

| Origen | Destino | Puerto |
|---------|----------|--------|
| Cliente | DM-WEB-01 | 80,443 |
| DM-WEB-01 | DM-API-01 | 3000 |
| DM-API-01 | DM-DB-01 | 5432 |
| Administrador | DM-BASTION-01 | 22 |
| DM-BASTION-01 | Todos | 22 |
| DM-MON-01 | Todos | 9090,3001 |

---

# 11. Riesgos Identificados

Se identifican los siguientes riesgos en la infraestructura actual:

- Un único segmento de red.
- No existe segmentación por capas.
- No existen VLANs.
- No existe firewall perimetral.
- No existen listas de control de acceso.
- Dependencia de un único host físico.
- Acceso administrativo centralizado únicamente mediante SSH.

Estos riesgos serán mitigados durante la modernización de la plataforma hacia AWS.

---

# 12. Evolución hacia AWS

La arquitectura de red será transformada durante la fase de modernización.

| Infraestructura Actual | Arquitectura AWS |
|-------------------------|------------------|
| Virtual LAN | Amazon VPC |
| Segmento 192.168.100.0/24 | CIDR VPC |
| Red única | Public y Private Subnets |
| SSH | Bastion Host / AWS Systems Manager |
| Firewall Local | Security Groups + NACL |
| Host VMware | Multi Availability Zone |

---

# 13. Conclusiones

La topología actual proporciona un entorno adecuado para representar una infraestructura empresarial simplificada.

Sin embargo, presenta limitaciones importantes en disponibilidad, seguridad y segmentación de red.

La arquitectura objetivo en AWS resolverá estas limitaciones mediante el uso de Amazon VPC, subredes públicas y privadas, Security Groups, Network ACLs y servicios administrados.

---

# Próximo Documento

➡ **05-server-inventory.md**

Este documento detallará cada servidor del laboratorio, incluyendo su configuración técnica, funciones, recursos, servicios instalados y dependencias.