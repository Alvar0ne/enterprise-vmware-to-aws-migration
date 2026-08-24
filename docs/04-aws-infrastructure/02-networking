# Networking AWS — VPC, Subnets y Enrutamiento

## 1. Objetivo

El objetivo de esta fase fue implementar mediante **Terraform** la capa de networking sobre la cual se desplegarán los diferentes componentes de la plataforma en AWS.

La arquitectura fue diseñada utilizando una **VPC distribuida entre dos Availability Zones**, separando recursos públicos y privados mediante diferentes subnets.

La estructura implementada permite que:

- El Application Load Balancer pueda recibir tráfico desde Internet.
- Las instancias EC2 de aplicación permanezcan en subnets privadas.
- Las instancias privadas puedan iniciar conexiones hacia Internet mediante un NAT Gateway.
- La base de datos permanezca aislada de Internet.
- La aplicación pueda distribuirse entre múltiples Availability Zones.
- La infraestructura quede preparada para alta disponibilidad y Auto Scaling.

La arquitectura base implementada es:

```text
                        INTERNET
                            │
                            ▼
                    Internet Gateway
                            │
                            ▼
                  ┌───────────────────┐
                  │    VPC 10.0.0.0/16
                  │
        ┌─────────┴─────────┐
        │                   │
   us-east-1a          us-east-1b
        │                   │
   Public Subnet        Public Subnet
        │                   │
   Private Subnet       Private Subnet
        │                   │
        └─────────┬─────────┘
                  │
             NAT Gateway
```

---

## 2. Diseño de la VPC

Se creó una **Virtual Private Cloud (VPC)** dedicada para la infraestructura del proyecto.

El bloque de direccionamiento utilizado es:

```text
10.0.0.0/16
```

La VPC representa la red privada principal dentro de AWS y proporciona el espacio de direccionamiento desde el cual posteriormente se crean las diferentes subnets.

Conceptualmente:

```text
VPC
10.0.0.0/16
│
├── Subnets públicas
│
└── Subnets privadas
```

El uso de un bloque `/16` proporciona un espacio suficientemente amplio para dividir posteriormente la red en múltiples subnets `/24`.

La VPC fue creada y administrada mediante Terraform.

Ejemplo conceptual:

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true
}
```

Terraform mantiene este recurso dentro de su State, permitiendo detectar y administrar futuros cambios.

### Evidencia — VPC creada

Agregar una captura desde:

```text
AWS Console
→ VPC
→ Sus VPC
```

La captura debe mostrar principalmente:

- Nombre de la VPC.
- Estado `Available`.
- CIDR `10.0.0.0/16`.

No es necesario mostrar información de otras VPC existentes en la cuenta.

Nombre sugerido:

```text
images/01-vpc-created.png
```

Markdown:

```markdown
![VPC principal creada mediante Terraform](images/01-vpc-created.png)
```

---

## 3. Diseño Multi-AZ

La infraestructura fue distribuida entre dos Availability Zones:

```text
us-east-1a
us-east-1b
```

La distribución permite evitar que todos los componentes dependan de una única zona física.

La arquitectura queda organizada de la siguiente manera:

```text
VPC 10.0.0.0/16
│
├── us-east-1a
│   ├── Public Subnet A
│   └── Private Subnet A
│
└── us-east-1b
    ├── Public Subnet B
    └── Private Subnet B
```

Esta distribución será utilizada posteriormente por componentes como:

- Application Load Balancer.
- Auto Scaling Group.
- Instancias EC2.
- Amazon RDS.
- Otros servicios que requieran distribución Multi-AZ.

El diseño Multi-AZ proporciona la base de networking necesaria para implementar **alta disponibilidad**.

---

## 4. Subnets públicas

Se crearon dos subnets públicas, una en cada Availability Zone.

Conceptualmente:

```text
VPC 10.0.0.0/16
│
├── Public A
│   └── us-east-1a
│
└── Public B
    └── us-east-1b
```

Estas subnets están destinadas principalmente a componentes que necesitan conectividad directa con Internet.

En la arquitectura del proyecto serán utilizadas por el **Application Load Balancer**.

El ALB podrá recibir solicitudes desde Internet y posteriormente enviarlas hacia las instancias de aplicación ubicadas en las subnets privadas.

```text
Internet
   │
   ▼
Internet Gateway
   │
   ▼
Public Subnets
   │
   ▼
Application Load Balancer
```

Las instancias de aplicación no necesitan estar expuestas directamente.

---

## 5. Subnets privadas

También se crearon dos subnets privadas, distribuidas entre las mismas Availability Zones.

```text
VPC
│
├── Private A
│   └── us-east-1a
│
└── Private B
    └── us-east-1b
```

Estas redes son utilizadas para componentes que no deben aceptar conexiones directas desde Internet.

Entre ellos:

```text
EC2 Application
Amazon RDS
```

La arquitectura separa por lo tanto la entrada pública de la capa de aplicación.

```text
Internet
   │
   ▼
Public Subnets
   │
   ▼
ALB
   │
   ▼
Private Subnets
   │
   ├── EC2
   └── RDS
```

Este diseño reduce la superficie de exposición de la infraestructura.

---

## 6. Distribución de subnets entre Availability Zones

La distribución implementada permite que cada zona disponga de infraestructura pública y privada.

```text
                  VPC 10.0.0.0/16
                         │
           ┌─────────────┴─────────────┐
           │                           │
      us-east-1a                  us-east-1b
           │                           │
      Public A                    Public B
           │                           │
      Private A                   Private B
```

Esta estructura permite posteriormente distribuir las instancias del Auto Scaling Group entre ambas zonas.

Si una instancia falla, otra instancia ubicada en una zona diferente puede continuar proporcionando el servicio.

### Evidencia — Subnets Multi-AZ

Agregar una captura desde:

```text
AWS Console
→ VPC
→ Subnets
```

La captura debería permitir identificar:

- Las cuatro subnets.
- La VPC asociada.
- Sus CIDR.
- `us-east-1a`.
- `us-east-1b`.

Esta evidencia es especialmente importante porque demuestra visualmente la distribución Multi-AZ.

Nombre sugerido:

```text
images/02-subnets-multi-az.png
```

Markdown:

```markdown
![Distribución de subnets públicas y privadas entre dos Availability Zones](images/02-subnets-multi-az.png)
```

---

## 7. Internet Gateway

Para proporcionar conectividad entre la VPC e Internet se creó un **Internet Gateway (IGW)**.

Conceptualmente:

```text
Internet
   │
   ▼
Internet Gateway
   │
   ▼
VPC
```

El Internet Gateway fue asociado a la VPC mediante Terraform.

Sin embargo, la existencia de un Internet Gateway por sí sola no convierte automáticamente una subnet en pública.

También es necesario que la tabla de rutas correspondiente contenga una ruta hacia el IGW.

---

## 8. Route Table pública

Las subnets públicas están asociadas a una tabla de rutas que contiene una ruta por defecto hacia el Internet Gateway.

Conceptualmente:

```text
Public Subnet
      │
      ▼
Public Route Table
      │
      │ 0.0.0.0/0
      ▼
Internet Gateway
      │
      ▼
Internet
```

La ruta:

```text
0.0.0.0/0 → Internet Gateway
```

indica que el tráfico cuyo destino no corresponde a una ruta más específica puede dirigirse hacia Internet.

Esto permite que los recursos diseñados para ser públicos puedan utilizar el Internet Gateway como punto de entrada y salida.

### Evidencia — Route Table pública

Agregar una captura desde:

```text
AWS Console
→ VPC
→ Route Tables
→ Public Route Table
→ Routes
```

La evidencia debe mostrar:

```text
Destination      Target

10.0.0.0/16      local
0.0.0.0/0        igw-...
```

Nombre sugerido:

```text
images/03-public-route-table.png
```

Markdown:

```markdown
![Tabla de rutas pública con salida mediante Internet Gateway](images/03-public-route-table.png)
```

---

## 9. Elastic IP

Para proporcionar una dirección IPv4 pública estable al NAT Gateway se creó una **Elastic IP (EIP)**.

Conceptualmente:

```text
Elastic IP
    │
    ▼
NAT Gateway
```

La Elastic IP proporciona la dirección pública utilizada por el NAT Gateway cuando los recursos privados necesitan iniciar comunicaciones hacia Internet.

La EIP también fue declarada y administrada mediante Terraform.

---

## 10. NAT Gateway

Las instancias ubicadas en las subnets privadas pueden necesitar iniciar conexiones hacia Internet.

Por ejemplo:

- Descargar paquetes.
- Obtener actualizaciones.
- Acceder a servicios externos.
- Descargar componentes durante procesos de bootstrap.

Sin embargo, no queremos proporcionarles una ruta directa mediante Internet Gateway.

Para resolver esta necesidad se implementó un **NAT Gateway**.

```text
Private EC2
    │
    ▼
Private Route Table
    │
    ▼
NAT Gateway
    │
    ▼
Internet Gateway
    │
    ▼
Internet
```

El NAT Gateway se encuentra ubicado en una **subnet pública** y utiliza una Elastic IP.

Esto permite que las instancias privadas puedan **iniciar conexiones hacia Internet**, sin convertirlas en servidores directamente accesibles desde Internet.

---

## 11. Decisión de utilizar un único NAT Gateway

En una arquitectura empresarial de alta disponibilidad completa podría desplegarse un NAT Gateway por Availability Zone.

Conceptualmente:

```text
us-east-1a                  us-east-1b

Private A                   Private B
    │                           │
    ▼                           ▼
NAT GW A                    NAT GW B
```

Sin embargo, para este laboratorio se decidió utilizar **un único NAT Gateway**.

La razón principal es optimizar costos mientras se mantiene el objetivo técnico del proyecto.

La arquitectura utilizada es:

```text
Private A ─────┐
               │
               ▼
           NAT Gateway
               ▲
               │
Private B ─────┘
```

Esta decisión implica un compromiso entre:

```text
Costo
  vs.
Alta disponibilidad completa del NAT
```

Para un ambiente productivo crítico se evaluaría desplegar un NAT Gateway por Availability Zone para evitar dependencia de una única zona y reducir tráfico cross-AZ innecesario.

> Esta es una decisión consciente de diseño del laboratorio y no una limitación desconocida de la arquitectura.

---

## 12. Route Table privada

Las subnets privadas utilizan una tabla de rutas diferente a las subnets públicas.

La ruta por defecto se dirige hacia el NAT Gateway.

```text
Private Subnet
      │
      ▼
Private Route Table
      │
      │ 0.0.0.0/0
      ▼
NAT Gateway
```

La diferencia fundamental es:

```text
PUBLIC ROUTE TABLE

0.0.0.0/0
     │
     ▼
Internet Gateway


PRIVATE ROUTE TABLE

0.0.0.0/0
     │
     ▼
NAT Gateway
```

De esta manera, las instancias privadas pueden iniciar tráfico hacia Internet pero no reciben tráfico entrante iniciado directamente desde Internet mediante el NAT Gateway.

### Evidencia — Route Table privada

Agregar una captura desde:

```text
AWS Console
→ VPC
→ Route Tables
→ Private Route Table
→ Routes
```

La captura debe mostrar principalmente:

```text
Destination      Target

10.0.0.0/16      local
0.0.0.0/0        nat-...
```

Nombre sugerido:

```text
images/04-private-route-table.png
```

Markdown:

```markdown
![Tabla de rutas privada con salida mediante NAT Gateway](images/04-private-route-table.png)
```

---

## 13. Asociaciones de Route Tables

La creación de las tablas de rutas no es suficiente.

Cada subnet debe estar asociada con la tabla correspondiente.

La configuración implementada sigue el siguiente modelo:

```text
Public A ──────┐
               ├── Public Route Table ──► IGW
Public B ──────┘


Private A ─────┐
               ├── Private Route Table ─► NAT Gateway
Private B ─────┘
```

Estas asociaciones también son declaradas mediante Terraform.

Esto evita tener que configurar manualmente cada subnet desde AWS Management Console.

---

## 14. Diferencia entre subnet pública y privada

Una subnet no es pública simplemente por llamarse `public`.

La diferencia está determinada principalmente por su **routing**.

### Subnet pública

```text
Subnet
  │
  ▼
Route Table
  │
  ▼
0.0.0.0/0 → Internet Gateway
```

### Subnet privada

```text
Subnet
  │
  ▼
Route Table
  │
  ▼
0.0.0.0/0 → NAT Gateway
```

En nuestra arquitectura:

| Componente | Subnet |
|---|---|
| Application Load Balancer | Pública |
| EC2 Application | Privada |
| Amazon RDS | Privada |
| NAT Gateway | Pública |

Esta separación permite exponer únicamente los componentes que realmente necesitan recibir tráfico desde Internet.

---

## 15. Flujo de tráfico entrante

El tráfico de usuarios seguirá el siguiente recorrido:

```text
Usuario
   │
   ▼
Internet
   │
   ▼
Internet Gateway
   │
   ▼
Application Load Balancer
   │
   ▼
EC2 privadas
```

El usuario no establece una conexión directa con las instancias EC2.

El punto de entrada público es el Application Load Balancer.

---

## 16. Flujo de salida desde las instancias privadas

Cuando una instancia privada necesita iniciar una conexión hacia Internet, el recorrido es diferente.

```text
EC2 privada
    │
    ▼
Private Route Table
    │
    ▼
NAT Gateway
    │
    ▼
Internet Gateway
    │
    ▼
Internet
```

El NAT Gateway permite la salida sin requerir que las instancias tengan una dirección IPv4 pública.

Esto mantiene separada la capa de aplicación del acceso público directo.

---

## 17. Comunicación interna dentro de la VPC

Los componentes también necesitan comunicarse internamente.

Por ejemplo:

```text
ALB
 │
 ▼
EC2
 │
 ▼
RDS
```

El tráfico interno entre recursos de la VPC utiliza direccionamiento privado.

Esto evita que la comunicación entre capas de la aplicación necesite atravesar Internet.

Posteriormente, los **Security Groups** determinan específicamente qué comunicaciones están permitidas entre estos componentes.

La arquitectura combina por lo tanto:

```text
Networking
     +
Routing
     +
Security Groups
```

para controlar la comunicación entre las diferentes capas.

---

## 18. Arquitectura de networking implementada

La arquitectura base puede representarse de la siguiente manera:

```text
                              INTERNET
                                  │
                                  ▼
                         Internet Gateway
                                  │
                                  ▼
                       VPC 10.0.0.0/16
                                  │
             ┌────────────────────┴────────────────────┐
             │                                         │
        us-east-1a                                us-east-1b
             │                                         │
      ┌──────┴──────┐                           ┌──────┴──────┐
      │             │                           │             │
   Public A      Private A                   Public B      Private B
      │             │                           │             │
      │             │                           │             │
      └──── ALB ────┼───────────────────────────┘             │
                    │                                         │
                  EC2                                       EC2
                    │                                         │
                    └────────────────┬────────────────────────┘
                                     │
                                     ▼
                                    RDS


Private Subnets
       │
       ▼
Private Route Table
       │
       ▼
NAT Gateway
       │
       ▼
Internet Gateway
       │
       ▼
Internet
```

Esta arquitectura proporciona la base para desplegar posteriormente las capas de cómputo, balanceo y base de datos.

### Evidencia — Arquitectura de networking

Agregar un diagrama visual utilizando iconos oficiales o representativos de AWS mostrando:

- VPC.
- `us-east-1a`.
- `us-east-1b`.
- Dos subnets públicas.
- Dos subnets privadas.
- Internet Gateway.
- NAT Gateway.
- Application Load Balancer.
- EC2 privadas.
- RDS privado.

Nombre sugerido:

```text
images/05-aws-network-architecture.png
```

Markdown:

```markdown
![Arquitectura de networking AWS Multi-AZ](images/05-aws-network-architecture.png)
```

> Esta debería ser la imagen principal de esta sección. Es más útil para un reclutador o arquitecto que varias capturas independientes de AWS Console.

---

## 19. Implementación mediante Terraform

Todos los componentes principales de networking fueron definidos mediante Terraform.

La configuración incluye recursos para:

```text
VPC
│
├── Subnets
├── Internet Gateway
├── Elastic IP
├── NAT Gateway
├── Route Tables
├── Routes
└── Route Table Associations
```

El flujo de implementación utilizado fue:

```text
Modificar networking.tf
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
        │
        ▼
Networking creado en AWS
```

Esto permite que la topología de red pueda reconstruirse a partir del código en lugar de depender exclusivamente de configuraciones realizadas manualmente.

### Evidencia — Recursos de networking administrados por Terraform

Se puede utilizar:

```bash
terraform state list
```

y capturar específicamente los recursos relacionados con networking.

Por ejemplo:

```text
aws_vpc.main
aws_subnet.public_a
aws_subnet.public_b
aws_subnet.private_a
aws_subnet.private_b
aws_internet_gateway.main
aws_eip.nat
aws_nat_gateway.main
aws_route_table.public
aws_route_table.private
...
```

Nombre sugerido:

```text
images/06-terraform-networking-state.png
```

Markdown:

```markdown
![Recursos de networking administrados mediante Terraform](images/06-terraform-networking-state.png)
```

Esta evidencia es opcional si `terraform state list` ya fue mostrado en `01-terraform-foundation.md`.

---

## 20. Decisiones de arquitectura

Las principales decisiones tomadas durante esta fase fueron:

### Separación público / privado

El Application Load Balancer se ubica en las subnets públicas mientras que las instancias de aplicación permanecen en subnets privadas.

### Distribución Multi-AZ

Las subnets se distribuyen entre `us-east-1a` y `us-east-1b`, proporcionando la base para alta disponibilidad.

### EC2 sin exposición directa

Las instancias de aplicación no necesitan direcciones IP públicas para recibir tráfico de usuarios.

### NAT Gateway para salida

Los recursos privados pueden iniciar conexiones hacia Internet mediante NAT sin convertirse en recursos públicamente accesibles.

### Un NAT Gateway para el laboratorio

Se utiliza un único NAT Gateway para reducir costos.

En producción se evaluaría un NAT Gateway por Availability Zone dependiendo de los requerimientos de disponibilidad y costo.

### Infraestructura administrada mediante Terraform

Los componentes de networking se encuentran declarados como código y administrados mediante Terraform.

---

## 21. Resultado de la implementación

La implementación de networking estableció la base sobre la cual se desplegarán los demás componentes de la arquitectura AWS.

Se implementaron:

- VPC `10.0.0.0/16`.
- Dos Availability Zones.
- Dos subnets públicas.
- Dos subnets privadas.
- Internet Gateway.
- Elastic IP.
- NAT Gateway.
- Public Route Table.
- Private Route Table.
- Rutas hacia IGW y NAT.
- Asociaciones entre subnets y Route Tables.
- Arquitectura preparada para ALB.
- Arquitectura preparada para Auto Scaling.
- Networking privado para EC2.
- Networking privado para Amazon RDS.
- Administración mediante Terraform.

El resultado proporciona una arquitectura segmentada y preparada para continuar con la implementación de controles de seguridad.

La siguiente fase documenta los **Security Groups y el modelo de comunicación ALB → APP → RDS**.