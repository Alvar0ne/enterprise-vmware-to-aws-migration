# Enterprise VMware to AWS Modernization Platform

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazonaws&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-4169E1?logo=postgresql&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-Backend-339933?logo=node.js&logoColor=white)

### Migración y modernización empresarial End-to-End | VMware • AWS • DevOps • Serverless • Data Platform

---

## 📖 Descripción del proyecto

Este proyecto documenta la migración y modernización de una plataforma de comercio electrónico empresarial, utilizando **Distrito Miami** como caso de negocio.

El objetivo es diseñar, implementar y documentar una estrategia completa para evolucionar desde una infraestructura basada en VMware hacia una arquitectura moderna en AWS, aplicando buenas prácticas de arquitectura cloud, seguridad, alta disponibilidad, automatización e Infrastructure as Code.

La estrategia principal corresponde a una **replatformización y modernización**, en lugar de realizar únicamente un rehost 1:1 de las máquinas virtuales existentes.

> **Nota:** Este repositorio utiliza una versión sanitizada de una aplicación real. No contiene credenciales de producción, información de clientes ni datos comerciales confidenciales.

---

# 🎯 Objetivos del proyecto

El proyecto busca demostrar experiencia práctica en:

- Administración de infraestructura VMware
- Arquitectura AWS
- Networking empresarial
- Migración y modernización cloud
- Infrastructure as Code con Terraform
- Docker y contenedores
- CI/CD con GitHub Actions
- Alta disponibilidad y Auto Scaling
- Seguridad cloud
- Observabilidad y monitoreo
- Arquitecturas orientadas a eventos
- Data Engineering y Business Intelligence

---

# 🏗 Arquitectura

## Infraestructura de origen — VMware

El entorno de origen está compuesto por máquinas virtuales Ubuntu que representan las principales capas de una plataforma empresarial:

- Frontend / Reverse Proxy
- Aplicación Next.js + Docker
- PostgreSQL
- Prometheus + Grafana
- Bastion + GitHub Actions Runner

## Arquitectura objetivo — AWS

La plataforma se está modernizando utilizando servicios administrados y capacidades nativas de AWS.

Principales componentes:

- Amazon VPC con arquitectura Multi-AZ
- Subnets públicas y privadas
- Internet Gateway y NAT Gateway
- Security Groups
- Amazon EC2
- Launch Templates
- Auto Scaling Groups
- Application Load Balancer
- Amazon RDS PostgreSQL
- Amazon S3
- Amazon CloudWatch
- IAM
- Terraform
- GitHub Actions

---

# 🚀 Estado del proyecto

| Etapa | Estado |
|---|---|
| Laboratorio VMware | ✅ Completado |
| Aplicación + PostgreSQL en VMware | ✅ Completado |
| Dockerización de la aplicación | ✅ Completado |
| Monitoreo Prometheus / Grafana | ✅ Completado |
| CI/CD inicial con GitHub Actions | ✅ Completado |
| Networking AWS con Terraform | ✅ Completado |
| Security Groups | ✅ Completado |
| Launch Template + Auto Scaling | ✅ Completado |
| Application Load Balancer | ✅ Completado |
| Despliegue automático de la aplicación en EC2 | 🟡 En progreso |
| Amazon RDS PostgreSQL | ⏳ Pendiente |
| Observabilidad AWS | ⏳ Pendiente |
| Serverless / Event-Driven | ⏳ Pendiente |
| Data Platform / Analytics | ⏳ Pendiente |

---

# 🔄 Estrategia de migración

La arquitectura no replica directamente las máquinas virtuales VMware en AWS.

Se utiliza una estrategia de **replatform / modernization**, reemplazando componentes tradicionales por servicios y patrones cloud-native cuando corresponde.

Para la base de datos PostgreSQL se contempla una estrategia empresarial mediante **AWS Database Migration Service (DMS)** utilizando Full Load + Change Data Capture (CDC), permitiendo realizar posteriormente un cutover controlado hacia Amazon RDS PostgreSQL.

AWS Application Migration Service (MGN) queda considerado como alternativa para workloads que requieran una estrategia de **rehost / lift-and-shift**.

---

# ⚙️ Infrastructure as Code

La infraestructura AWS se construye utilizando **Terraform**, permitiendo que la arquitectura sea:

- Reproducible
- Versionable
- Auditable
- Automatizable
- Consistente entre ambientes

El código Terraform se encuentra dentro del directorio:

```text
terraform/
```

---

# 🔄 DevOps

El proyecto incorpora prácticas DevOps utilizando:

- Git
- GitHub
- GitHub Actions
- Docker
- Terraform

El objetivo final es automatizar tanto la infraestructura como el ciclo de construcción y despliegue de la aplicación.

---

# ⚡ Próximas etapas

La evolución de la plataforma contempla:

- Amazon RDS PostgreSQL
- AWS DMS
- Amazon ECR
- CloudWatch y SNS
- ACM / HTTPS
- Route 53
- Políticas de Auto Scaling
- AWS Lambda
- Amazon EventBridge
- Amazon SQS + DLQ
- Data Lake en Amazon S3
- AWS Glue
- Amazon Athena
- Power BI

---

# 📚 Documentación

Los detalles técnicos, decisiones de arquitectura, configuraciones, procedimientos, evidencias y diagramas se mantienen separados del README principal dentro de la documentación del proyecto.

El repositorio contempla documentación para:

- Arquitectura
- Infraestructura VMware
- Terraform
- Networking
- Seguridad
- Estrategia de migración
- DevOps y CI/CD
- Base de datos
- Observabilidad
- Serverless
- Data Platform
- Diagramas
- Decisiones de arquitectura

---

# 📁 Estructura del repositorio

```text
enterprise-vmware-to-aws-migration/
│
├── docs/
├── terraform/
├── docker/
├── app/
├── diagrams/
├── scripts/
├── .github/
│   └── workflows/
└── README.md
```

---

# 🎯 Resultado esperado

Al finalizar, el proyecto demostrará de forma práctica un proceso completo de migración y modernización empresarial desde VMware hacia AWS, incluyendo infraestructura, automatización, seguridad, alta disponibilidad, DevOps, observabilidad y servicios de datos.

---

# 👨‍💻 Autor

**Álvaro Ponce**

Ingeniero Civil en Computación

**Cloud | AWS | Infraestructura | DevOps | Data Engineering**
