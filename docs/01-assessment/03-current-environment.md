# Current Environment Assessment (AS-IS)

---

## Document Information

| Campo | Valor |
|--------|-------|
| Documento | Current Environment Assessment |
| Código | AS-IS-003 |
| Proyecto | Enterprise VMware to AWS Modernization Platform |
| Caso de Negocio | Distrito Miami |
| Fase | Assessment |
| Estado | En desarrollo |

---

# 1. Objetivo

Este documento describe la infraestructura tecnológica existente antes del proceso de migración hacia Amazon Web Services (AWS).

Su propósito es documentar el estado actual (AS-IS) de la plataforma, identificar sus componentes principales y establecer una línea base que servirá como referencia durante todas las fases posteriores del proyecto.

---

# 2. Alcance

Este documento considera los siguientes componentes:

- Plataforma de virtualización.
- Infraestructura de servidores.
- Aplicaciones.
- Base de datos.
- Red.
- Servicios.
- Comunicación entre componentes.
- Limitaciones actuales.

No considera aún la arquitectura objetivo (TO-BE), la cual será desarrollada en fases posteriores.

---

# 3. Descripción General

La plataforma Distrito Miami opera inicialmente sobre una infraestructura virtualizada basada en VMware Workstation.

Para representar un escenario empresarial, la solución se encuentra segmentada en servidores independientes, permitiendo aislar responsabilidades y simular una arquitectura utilizada habitualmente en organizaciones medianas y grandes.

Esta infraestructura constituye el punto de partida para el proceso de migración y posterior modernización hacia AWS.

---

# 4. Arquitectura AS-IS

```text
                           VMware Workstation

                   Virtual Network (192.168.100.0/24)

      ┌───────────────────────────────────────────────────────────────┐
      │                                                               │
      │   DM-WEB-01        DM-API-01        DM-DB-01                  │
      │   Frontend         Backend          PostgreSQL                │
      │                                                               │
      │   DM-MON-01        DM-BASTION-01                              │
      │   Monitoring       SSH Administration                         │
      │                                                               │
      └───────────────────────────────────────────────────────────────┘
```

---

# 5. Componentes de Infraestructura

| Servidor | Función | Sistema Operativo |
|----------|----------|------------------|
| DM-WEB-01 | Frontend Web | Ubuntu Server LTS |
| DM-API-01 | Backend / API | Ubuntu Server LTS |
| DM-DB-01 | Base de Datos | Ubuntu Server LTS |
| DM-MON-01 | Monitoreo | Ubuntu Server LTS |
| DM-BASTION-01 | Administración | Ubuntu Server LTS |

---

# 6. Recursos de Hardware

| Servidor | vCPU | RAM | Disco |
|----------|-----:|----:|------:|
| DM-WEB-01 | 1 | 1 GB | 8 GB |
| DM-API-01 | 1 | 2 GB | 10 GB |
| DM-DB-01 | 1 | 2 GB | 12 GB |
| DM-MON-01 | 1 | 2 GB | 10 GB |
| DM-BASTION-01 | 1 | 512 MB | 6 GB |

---

# 7. Distribución de Servicios

## DM-WEB-01

### Responsabilidades

- Servidor Web.
- Nginx.
- Frontend de Distrito Miami.
- Comunicación con la API.

---

## DM-API-01

### Responsabilidades

- Docker.
- Node.js.
- API REST.
- Lógica de negocio.
- Integración con Flow.
- Comunicación con PostgreSQL.

---

## DM-DB-01

### Responsabilidades

- PostgreSQL.
- Persistencia de datos.
- Usuarios.
- Productos.
- Pedidos.
- Inventario.

---

## DM-MON-01

### Responsabilidades

- Prometheus.
- Grafana.
- Monitoreo de infraestructura.
- Métricas del laboratorio.

---

## DM-BASTION-01

### Responsabilidades

- Administración remota.
- Acceso SSH.
- Punto centralizado de administración.

---

# 8. Flujo de Comunicación

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

# 9. Plataforma de Virtualización

| Característica | Valor |
|---------------|-------|
| Plataforma | VMware Workstation |
| Tipo | On-Premise |
| Virtualización | Hosted Hypervisor |
| Red | Virtual LAN |
| Administración | Local |

---

# 10. Sistema Operativo

Todos los servidores utilizarán:

- Ubuntu Server LTS

La administración se realizará mediante:

- SSH
- Consola VMware

---

# 11. Limitaciones Identificadas

Durante el Assessment se identifican las siguientes limitaciones técnicas:

- Ausencia de Alta Disponibilidad.
- Servidor Web único.
- Servidor Backend único.
- Base de datos sin redundancia.
- Ausencia de Balanceador de Carga.
- No existe Auto Scaling.
- Backups manuales.
- No existe Infraestructura como Código.
- No existe CI/CD.
- Monitoreo limitado al entorno local.
- Dependencia de un único host físico.

Estas limitaciones justifican la necesidad de modernizar la plataforma hacia una arquitectura cloud nativa.

---

# 12. Riesgos Operacionales

Los principales riesgos del entorno actual son:

| Riesgo | Impacto |
|---------|----------|
| Falla del host VMware | Interrupción completa del servicio |
| Caída del servidor PostgreSQL | Pérdida de disponibilidad del sistema |
| Incremento de tráfico | Saturación del servidor web |
| Crecimiento del negocio | Escalabilidad limitada |
| Errores humanos | Recuperación manual |

---

# 13. Oportunidades de Modernización

La arquitectura actual podrá evolucionar hacia AWS incorporando:

- Amazon VPC.
- Application Load Balancer.
- Auto Scaling.
- Amazon RDS PostgreSQL.
- Amazon S3.
- Amazon CloudFront.
- AWS Lambda.
- Amazon EventBridge.
- Amazon CloudWatch.
- Terraform.
- GitHub Actions.
- Plataforma Data Lake.

---

# 14. Conclusiones

La infraestructura actual cumple adecuadamente como entorno de laboratorio para representar un escenario empresarial de origen.

Sin embargo, presenta limitaciones significativas en disponibilidad, escalabilidad, automatización y observabilidad.

Estas limitaciones serán abordadas durante el proceso de migración y modernización mediante la adopción de servicios administrados de Amazon Web Services.

---

# Próximo Documento

➡ **04-server-inventory.md**

En este documento se realizará el inventario detallado de todos los servidores del entorno actual, incluyendo características técnicas, funciones, servicios instalados y dependencias.