# Seguridad AWS — Security Groups y Segmentación entre Capas

## 1. Objetivo

El objetivo de esta fase fue implementar los controles de seguridad de red necesarios para restringir la comunicación entre los diferentes componentes de la arquitectura AWS.

La estrategia se basa en separar las principales capas de la plataforma mediante **Security Groups independientes**, permitiendo únicamente las comunicaciones necesarias para el funcionamiento de la aplicación.

El modelo implementado sigue el siguiente flujo:

```text
Internet
   │
   │ HTTP / HTTPS
   ▼
ALB Security Group
   │
   │ TCP :3000
   ▼
APP Security Group
   │
   │ PostgreSQL :5432
   ▼
RDS Security Group
```

De esta manera, cada componente acepta tráfico únicamente desde la capa que necesita comunicarse con él.

Los principales objetivos fueron:

- Reducir la superficie de exposición.
- Evitar acceso directo desde Internet hacia las instancias EC2.
- Evitar exposición pública de PostgreSQL.
- Separar los controles de seguridad por capa.
- Aplicar el principio de mínimo privilegio.
- Utilizar referencias entre Security Groups en lugar de depender de direcciones IP.
- Administrar las reglas mediante Terraform.

---

## 2. Modelo de seguridad por capas

La aplicación se divide en tres capas principales:

```text
CAPA PÚBLICA
Application Load Balancer
        │
        ▼
CAPA DE APLICACIÓN
EC2 + Auto Scaling Group
        │
        ▼
CAPA DE DATOS
Amazon RDS PostgreSQL
```

Cada capa dispone de su propio Security Group.

| Security Group | Protege | Tráfico principal permitido |
|---|---|---|
| `ALB-SG` | Application Load Balancer | HTTP/HTTPS desde Internet |
| `APP-SG` | Instancias EC2 | Puerto 3000 desde `ALB-SG` |
| `RDS-SG` | Amazon RDS PostgreSQL | Puerto 5432 desde `APP-SG` |

Esto evita utilizar un único Security Group con reglas excesivamente amplias para toda la plataforma.

---

## 3. Security Groups

Los **Security Groups** funcionan como firewalls virtuales asociados a recursos AWS.

Permiten controlar:

- Tráfico entrante (`ingress`).
- Tráfico saliente (`egress`).
- Protocolos.
- Puertos.
- Origen o destino permitido.

En este proyecto los Security Groups fueron definidos mediante Terraform.

Conceptualmente:

```text
Terraform
    │
    ▼
security.tf
    │
    ▼
AWS Security Groups
    │
    ├── ALB-SG
    ├── APP-SG
    └── RDS-SG
```

Esto permite que las reglas de seguridad formen parte de la infraestructura versionada del proyecto.

---

## 4. Security Group del Application Load Balancer

El primer Security Group protege el **Application Load Balancer**.

El ALB representa el punto de entrada de las solicitudes provenientes desde Internet.

```text
Internet
   │
   │ HTTP
   │ :80
   ▼
┌───────────────┐
│    ALB-SG     │
│               │
│      ALB      │
└───────────────┘
```

Durante la implementación inicial se habilitó tráfico HTTP para permitir las pruebas de funcionamiento de la arquitectura.

Conceptualmente:

```text
Source:   0.0.0.0/0
Protocol: TCP
Port:     80
```

Posteriormente, la arquitectura puede evolucionar hacia HTTPS mediante AWS Certificate Manager y un listener TLS en el Application Load Balancer.

El ALB es el componente diseñado para recibir tráfico público.

Las instancias EC2 de aplicación permanecen detrás de este componente.

### Evidencia — Security Group del ALB

Agregar una captura desde:

```text
AWS Console
→ EC2
→ Security Groups
→ ALB Security Group
→ Inbound rules
```

La captura debe permitir visualizar principalmente:

```text
HTTP
TCP
80
0.0.0.0/0
```

Nombre sugerido:

```text
images/01-alb-security-group.png
```

Markdown:

```markdown
![Reglas de entrada del Security Group del Application Load Balancer](images/01-alb-security-group.png)
```

---

## 5. Security Group de la aplicación

Las instancias EC2 ejecutan la aplicación contenerizada mediante Docker.

La aplicación escucha internamente en:

```text
TCP :3000
```

Sin embargo, este puerto **no se expone directamente a Internet**.

El tráfico hacia el puerto `3000` debe provenir del Application Load Balancer.

```text
Internet
   │
   ▼
ALB
   │
   │ TCP :3000
   ▼
APP-SG
   │
   ▼
EC2
   │
   ▼
Docker
   │
   ▼
Next.js :3000
```

Esto significa que una solicitud normal debe recorrer:

```text
Usuario
   ↓
ALB
   ↓
EC2
```

y no:

```text
Usuario
   ↓
EC2 :3000
```

Las instancias permanecen protegidas detrás del balanceador.

---

## 6. Referencia ALB-SG → APP-SG

Una de las decisiones de seguridad más importantes fue **no permitir el puerto 3000 utilizando un rango público de direcciones IP**.

En su lugar, la regla utiliza como origen el Security Group del ALB.

Conceptualmente:

```text
APP-SG

Inbound
────────────────────────

TCP :3000

Source:
ALB-SG
```

Esto representa:

```text
ALB-SG
   │
   │ permitido :3000
   ▼
APP-SG
```

Por lo tanto, el permiso está asociado a la identidad lógica del componente que origina el tráfico y no a una dirección IP específica.

Esto resulta especialmente importante debido al uso de:

```text
Auto Scaling Group
```

Las instancias EC2 pueden:

- Crearse.
- Eliminarse.
- Reemplazarse.
- Cambiar su dirección IP privada.

La política de seguridad no depende de esas direcciones.

Mientras las nuevas instancias pertenezcan al Security Group correspondiente, la arquitectura mantiene el mismo modelo de comunicación.

### Evidencia — Regla ALB → APP

Agregar una captura de las reglas inbound de `APP-SG`.

La evidencia debería mostrar:

```text
Port:   3000
Source: ALB Security Group
```

Lo importante es que el origen aparezca como **Security Group** y no como:

```text
0.0.0.0/0
```

Nombre sugerido:

```text
images/02-app-security-group.png
```

Markdown:

```markdown
![Acceso a la aplicación restringido al Security Group del ALB](images/02-app-security-group.png)
```

> Esta es una de las evidencias más importantes de esta sección, porque demuestra que las instancias EC2 no tienen el puerto de aplicación abierto indiscriminadamente hacia Internet.

---

## 7. Security Group de Amazon RDS

La base de datos PostgreSQL utiliza:

```text
TCP :5432
```

La base de datos no necesita recibir conexiones desde Internet.

Únicamente las instancias pertenecientes a la capa de aplicación necesitan establecer conexiones hacia PostgreSQL.

El modelo implementado es:

```text
APP-SG
   │
   │ PostgreSQL
   │ TCP :5432
   ▼
RDS-SG
   │
   ▼
Amazon RDS
PostgreSQL
```

Por lo tanto, el Security Group de RDS restringe el acceso al puerto `5432` utilizando como origen el Security Group de la aplicación.

---

## 8. Referencia APP-SG → RDS-SG

Al igual que en la capa anterior, no se utilizan direcciones IP individuales de las instancias EC2.

La regla se basa en una referencia entre Security Groups:

```text
RDS-SG

Inbound
──────────────────────

TCP :5432

Source:
APP-SG
```

El resultado es:

```text
EC2 #1 ──┐
         │
EC2 #2 ──┼── APP-SG ── :5432 ──► RDS-SG
         │
EC2 #N ──┘
```

Si el Auto Scaling Group crea una nueva instancia:

```text
Nueva EC2
    │
    ▼
APP-SG
    │
    ▼
Acceso permitido a RDS
```

No es necesario modificar manualmente la regla de PostgreSQL para incorporar la nueva dirección IP.

### Evidencia — Regla APP → RDS

Agregar una captura desde:

```text
AWS Console
→ EC2
→ Security Groups
→ RDS Security Group
→ Inbound rules
```

Debe observarse:

```text
PostgreSQL
TCP
5432
Source: APP-SG
```

Nombre sugerido:

```text
images/03-rds-security-group.png
```

Markdown:

```markdown
![Acceso PostgreSQL restringido al Security Group de aplicación](images/03-rds-security-group.png)
```

---

## 9. Principio de mínimo privilegio

La arquitectura fue diseñada siguiendo el principio de **Least Privilege**.

Cada componente recibe únicamente los permisos de red necesarios para cumplir su función.

En lugar de:

```text
Internet
   │
   ├──► ALB
   ├──► EC2 :3000
   └──► RDS :5432
```

se implementa:

```text
Internet
   │
   │ :80
   ▼
ALB-SG
   │
   │ :3000
   ▼
APP-SG
   │
   │ :5432
   ▼
RDS-SG
```

Esto reduce significativamente la superficie de exposición.

### Matriz de comunicación

| Origen | Destino | Puerto | Permitido |
|---|---|---:|:---:|
| Internet | ALB | 80 | Sí |
| Internet | EC2 App | 3000 | No |
| Internet | RDS | 5432 | No |
| ALB-SG | APP-SG | 3000 | Sí |
| APP-SG | RDS-SG | 5432 | Sí |
| ALB-SG | RDS-SG | 5432 | No |

La comunicación sigue una secuencia controlada entre las diferentes capas.

---

## 10. Seguridad y Auto Scaling

El uso de referencias entre Security Groups también facilita el funcionamiento del Auto Scaling Group.

Las instancias EC2 no son consideradas servidores permanentes.

Pueden ser reemplazadas automáticamente.

```text
ASG
 │
 ├── EC2-A
 ├── EC2-B
 │
 └── Nueva EC2
        │
        ▼
      APP-SG
```

La nueva instancia hereda el modelo de seguridad definido para la aplicación.

Esto evita reglas basadas en:

```text
10.0.x.x
10.0.x.x
10.0.x.x
```

que tendrían que actualizarse cada vez que cambien las instancias.

El modelo se basa en:

```text
Security Group
      │
      ▼
Identidad lógica de la capa
```

---

## 11. Security Groups Stateful

Los Security Groups de AWS son **stateful**.

Esto significa que cuando una conexión está permitida en una dirección, el tráfico de respuesta asociado puede regresar sin necesidad de crear una regla independiente para ese flujo de respuesta.

Por ejemplo:

```text
ALB
 │
 │ solicitud :3000
 ▼
EC2
 │
 │ respuesta
 ▼
ALB
```

Si la conexión inicial está permitida por las reglas correspondientes, el tráfico de respuesta es reconocido como parte de la misma conexión.

Esta característica simplifica la administración de reglas respecto de un firewall completamente stateless.

---

## 12. Tráfico de salida

Además de las reglas de entrada, los Security Groups también permiten administrar reglas de salida (`egress`).

Las instancias de aplicación necesitan iniciar determinadas conexiones.

Por ejemplo:

```text
EC2
 │
 ├──► Amazon ECR
 ├──► servicios AWS
 ├──► repositorios de paquetes
 └──► Internet mediante NAT Gateway
```

El flujo de networking es:

```text
EC2 privada
     │
     ▼
Security Group
     │
     ▼
Private Route Table
     │
     ▼
NAT Gateway
     │
     ▼
Internet Gateway
```

Las reglas de Security Group y las Route Tables cumplen funciones diferentes:

```text
Security Group
      │
      └── ¿Está permitido el tráfico?

Route Table
      │
      └── ¿Hacia dónde debe enviarse?
```

Ambos mecanismos trabajan conjuntamente.

---

## 13. Security Groups vs Network ACL

La arquitectura también contempla controles a nivel de subnet mediante **Network ACL (NACL)**.

La diferencia conceptual es:

```text
Security Group
      │
      ▼
Protección a nivel de recurso
      │
      └── Stateful


Network ACL
      │
      ▼
Protección a nivel de subnet
      │
      └── Stateless
```

En este proyecto los Security Groups constituyen el principal mecanismo para controlar las comunicaciones entre las capas de la aplicación.

Las NACL proporcionan una capa adicional de control a nivel de subnet.

Esto permite aplicar una estrategia de **defensa en profundidad**, utilizando controles en diferentes niveles de la arquitectura.

---

## 14. Comparación con el entorno VMware

En el entorno on-premises, parte de la protección de los servidores se implementó utilizando firewall a nivel del sistema operativo mediante UFW.

Conceptualmente:

```text
VMware

Servidor
   │
   ▼
Ubuntu
   │
   ▼
UFW
   │
   ▼
Servicio
```

En AWS se incorpora una capa adicional de seguridad administrada desde la infraestructura:

```text
AWS

VPC
 │
 ▼
Security Group
 │
 ▼
EC2
 │
 ▼
Sistema operativo
 │
 ▼
Aplicación
```

Esto permite controlar el tráfico antes de que llegue a la interfaz de red del recurso.

El firewall del sistema operativo puede seguir utilizándose cuando los requerimientos lo justifiquen, pero los Security Groups proporcionan el control principal a nivel de infraestructura AWS.

---

## 15. Seguridad declarada mediante Terraform

Los Security Groups y sus reglas fueron definidos mediante Terraform.

Conceptualmente:

```text
security.tf
    │
    ▼
Terraform
    │
    ▼
AWS Provider
    │
    ▼
Security Groups
```

Esto significa que las relaciones:

```text
Internet → ALB
ALB-SG   → APP-SG
APP-SG   → RDS-SG
```

quedan representadas mediante código.

La seguridad forma así parte de la infraestructura reproducible del proyecto.

Un cambio de reglas puede seguir el mismo proceso utilizado para el resto de la infraestructura:

```text
Modificar security.tf
        │
        ▼
terraform fmt
        │
        ▼
terraform validate
        │
        ▼
terraform plan
        │
        ▼
Revisión
        │
        ▼
terraform apply
```

Esto proporciona trazabilidad sobre las modificaciones realizadas.

---

## 16. Evidencia mediante Terraform

Para demostrar que los Security Groups forman parte del estado administrado por Terraform puede utilizarse:

```bash
terraform state list
```

y localizar los recursos correspondientes.

Otra opción es utilizar:

```bash
terraform state show <recurso-security-group>
```

para visualizar la configuración administrada de un Security Group específico.

Esta evidencia es opcional si ya se documentó ampliamente el State en la sección de Terraform Foundation.

---

## 17. Arquitectura de seguridad implementada

El resultado final de esta capa puede representarse de la siguiente manera:

```text
                           INTERNET
                              │
                              │ TCP :80
                              ▼
                    ┌───────────────────┐
                    │      ALB-SG       │
                    │                   │
                    │       ALB         │
                    └─────────┬─────────┘
                              │
                              │ TCP :3000
                              │ Source: ALB-SG
                              ▼
                    ┌───────────────────┐
                    │      APP-SG       │
                    │                   │
                    │    EC2 / ASG      │
                    └─────────┬─────────┘
                              │
                              │ TCP :5432
                              │ Source: APP-SG
                              ▼
                    ┌───────────────────┐
                    │      RDS-SG       │
                    │                   │
                    │  RDS PostgreSQL   │
                    └───────────────────┘
```

La arquitectura establece una cadena de confianza explícita:

```text
Internet
   ↓
ALB
   ↓
Application
   ↓
Database
```

Ninguna capa posterior necesita estar expuesta directamente a Internet.

### Evidencia — Diagrama de seguridad

Crear una imagen utilizando los componentes AWS correspondientes y mostrando únicamente:

```text
Internet
   │ :80
   ▼
ALB
[ALB-SG]
   │ :3000
   ▼
EC2 / ASG
[APP-SG]
   │ :5432
   ▼
RDS PostgreSQL
[RDS-SG]
```

Nombre sugerido:

```text
images/04-security-groups-architecture.png
```

Markdown:

```markdown
![Arquitectura de seguridad entre las capas ALB, aplicación y base de datos](images/04-security-groups-architecture.png)
```

> Esta sería la imagen principal de `03-security.md`, porque permite comprender inmediatamente la segmentación y los puertos permitidos.

---

## 18. Decisiones de seguridad

Las principales decisiones adoptadas durante esta fase fueron:

### Security Groups separados por capa

Se evita utilizar un único grupo de seguridad compartido por toda la infraestructura.

### ALB como único punto de entrada público

Las solicitudes de los usuarios ingresan mediante el Application Load Balancer.

### Puerto 3000 restringido

El puerto de la aplicación solamente acepta tráfico proveniente del Security Group del ALB.

### PostgreSQL no expuesto a Internet

El puerto `5432` solamente acepta conexiones desde el Security Group de aplicación.

### Referencias entre Security Groups

Las reglas no dependen de las direcciones IP dinámicas de las instancias EC2.

### Compatibilidad con Auto Scaling

Las nuevas instancias reciben automáticamente el modelo de seguridad correspondiente al asociarse con `APP-SG`.

### Infrastructure as Code

Las reglas se administran mediante Terraform y pueden ser revisadas antes de aplicarse.

---

## 19. Resultado de la implementación

La implementación estableció un modelo de seguridad segmentado entre las diferentes capas de la plataforma.

Se implementaron:

- Security Group dedicado al Application Load Balancer.
- Security Group dedicado a las instancias de aplicación.
- Security Group dedicado a Amazon RDS.
- Acceso público restringido al punto de entrada.
- Comunicación `ALB-SG → APP-SG` mediante TCP `3000`.
- Comunicación `APP-SG → RDS-SG` mediante TCP `5432`.
- Referencias entre Security Groups.
- Separación entre networking, routing y controles de acceso.
- Base para aplicar el principio de mínimo privilegio.
- Seguridad administrada mediante Terraform.

El resultado evita que las instancias de aplicación y la base de datos necesiten exposición directa a Internet.

La siguiente fase documenta la implementación de **cómputo y Auto Scaling**, incluyendo la selección dinámica de la AMI Ubuntu, Launch Template, User Data, Docker y distribución de instancias EC2 entre múltiples Availability Zones.