# Terraform Foundation — Infrastructure as Code

## 1. Objetivo

El objetivo de esta fase fue establecer **Terraform como herramienta de Infrastructure as Code (IaC)** para construir y administrar la infraestructura AWS utilizada durante la modernización de la plataforma.

En lugar de crear manualmente los recursos desde AWS Management Console, la infraestructura fue definida mediante archivos de configuración versionables.

El flujo general implementado es:

```text
Código Terraform
       │
       ▼
Terraform
       │
       ▼
AWS Provider
       │
       ▼
AWS API
       │
       ▼
Infraestructura AWS
```

Este enfoque permite que la arquitectura pueda ser creada, modificada y reproducida de manera controlada.

---

## 2. ¿Por qué Infrastructure as Code?

En una infraestructura creada exclusivamente mediante interfaces gráficas, gran parte de la configuración depende de acciones manuales realizadas por los administradores.

Esto puede generar:

- Diferencias entre ambientes.
- Configuraciones difíciles de reproducir.
- Errores humanos.
- Falta de trazabilidad.
- Dificultad para reconstruir infraestructura.
- Cambios realizados sin control de versiones.

Para evitar estas limitaciones, el proyecto adopta **Infrastructure as Code**.

Con IaC, la infraestructura pasa a ser representada mediante archivos declarativos.

```text
Infraestructura manual
        │
        ▼
Configuraciones realizadas desde consola


Infrastructure as Code
        │
        ▼
Configuración declarada en código
        │
        ▼
Infraestructura reproducible
```

---

## 3. Selección de Terraform

Para implementar Infrastructure as Code se seleccionó **Terraform**.

Terraform permite declarar el estado deseado de la infraestructura utilizando archivos escritos en **HashiCorp Configuration Language (HCL)**.

En este proyecto Terraform es responsable de administrar progresivamente componentes como:

- VPC.
- Subnets.
- Internet Gateway.
- NAT Gateway.
- Elastic IP.
- Route Tables.
- Security Groups.
- IAM Roles.
- Instance Profiles.
- Launch Templates.
- Auto Scaling Groups.
- Application Load Balancer.
- Target Groups.
- Amazon ECR.
- Amazon RDS.
- Infraestructura de conectividad híbrida.

La incorporación de nuevos servicios se realiza progresivamente a medida que avanza la modernización.

---

## 4. Integración Terraform con AWS

Terraform no se conecta directamente a cada recurso individual.

La comunicación se realiza mediante el **AWS Provider**.

```text
Archivos .tf
     │
     ▼
Terraform
     │
     ▼
AWS Provider
     │
     ▼
AWS API
     │
     ▼
Recursos AWS
```

El AWS Provider permite que Terraform pueda crear, consultar, modificar y eliminar recursos dentro de la cuenta AWS autorizada.

---

## 5. Configuración del Provider

El proyecto utiliza el provider oficial de AWS para Terraform.

Ejemplo conceptual:

```hcl
provider "aws" {
  region = var.aws_region
}
```

La región utilizada para el laboratorio es:

```text
us-east-1
```

La región se administra mediante variables para evitar repetir valores directamente dentro de los diferentes recursos.

---

## 6. Autenticación con AWS

Antes de permitir que Terraform administrara recursos fue necesario configurar acceso válido hacia AWS.

La autenticación fue validada inicialmente utilizando AWS CLI.

Ejemplo de validación:

```bash
aws sts get-caller-identity
```

Este comando permitió verificar que las credenciales configuradas correspondían a una identidad AWS válida antes de ejecutar Terraform.

El flujo utilizado es:

```text
Equipo local
     │
     ├── AWS CLI
     │
     └── Terraform
             │
             ▼
        Credenciales AWS
             │
             ▼
           AWS API
```

> Las credenciales de acceso no forman parte del código Terraform ni deben almacenarse dentro del repositorio Git.

---

## 7. Estructura del código Terraform

El código fue separado en diferentes archivos según la responsabilidad de cada componente.

La estructura evoluciona junto con el proyecto y mantiene una separación lógica entre networking, seguridad, cómputo, balanceo y servicios adicionales.

<p align="center">
  <img src="../images/19-terracarpet.png" alt="terra" width="400">
</p>

Esta separación no representa módulos independientes, sino una organización lógica del mismo root module de Terraform.

Terraform procesa conjuntamente los archivos `.tf` existentes dentro del directorio de trabajo.

---

## 8. `provider.tf`

El archivo `provider.tf` contiene la configuración relacionada con Terraform y los providers utilizados por el proyecto.

Su responsabilidad principal es establecer cómo Terraform interactúa con AWS.

Conceptualmente:

```text
provider.tf
     │
     ▼
AWS Provider
     │
     ▼
AWS
```

---

## 9. `variables.tf`

El archivo `variables.tf` contiene valores configurables utilizados por diferentes componentes.

Las variables permiten evitar valores repetidos o hardcodeados innecesariamente.

Por ejemplo:

```hcl
variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}
```

Conceptualmente:

```text
Variable
   │
   ├── Región
   ├── Nombre proyecto
   ├── CIDR
   └── otros parámetros
           │
           ▼
        Recursos
```

Esto facilita modificar determinados parámetros sin alterar múltiples bloques de infraestructura.

---

## 10. Resources

Los bloques `resource` representan infraestructura que Terraform debe administrar.

Ejemplo conceptual:

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}
```

En este caso:

```text
aws_vpc
   │
   ▼
Terraform
   │
   ▼
VPC real en AWS
```

Terraform mantiene la relación entre la declaración del recurso y el recurso existente en AWS mediante su estado.

---

## 11. Data Sources

No toda la información utilizada por Terraform necesita ser creada por Terraform.

Los bloques `data` permiten consultar información existente.

En el proyecto se utilizó este mecanismo, por ejemplo, para localizar dinámicamente una AMI de Ubuntu adecuada para las instancias EC2.

Conceptualmente:

```text
Terraform
    │
    │ consulta
    ▼
AWS
    │
    ▼
AMI disponible
    │
    ▼
Launch Template
```

Esto evita depender innecesariamente de determinados identificadores escritos manualmente dentro del código.

---

## 12. Outputs

Los `output` permiten mostrar información relevante después de ejecutar Terraform.

Ejemplos de información que puede resultar útil:

- VPC ID.
- IDs de subnets.
- Security Group IDs.
- AMI seleccionada.
- DNS del Application Load Balancer.
- Identificadores de recursos creados.

Ejemplo conceptual:

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

Después de ejecutar Terraform:

```text
Terraform
    │
    ▼
Infraestructura creada
    │
    ▼
Outputs
    │
    └── Información relevante
```

Los outputs no crean recursos adicionales.

Su función es exponer información producida o conocida por Terraform.

---

## 13. Terraform State

Terraform necesita conocer la relación entre el código declarado y la infraestructura que administra.

Para ello utiliza el **Terraform State**.

Conceptualmente:

```text
Código Terraform
       │
       ▼
Terraform State
       │
       ▼
Infraestructura AWS
```

El estado permite que Terraform determine qué recursos ya existen y qué modificaciones son necesarias.

Por ejemplo:

```text
Código actual
      │
      ▼
Terraform compara
      │
      ├── State
      │
      └── Infraestructura
              │
              ▼
           PLAN
```

El archivo de estado puede contener información sensible y específica del entorno.

<p align="center">
  <img src="../images/20-statelist.png" alt="terra" width="400">
</p>

Por esta razón:

> `terraform.tfstate` no debe publicarse en el repositorio GitHub.

Para este laboratorio el estado se administra localmente. En un escenario empresarial se evaluaría un backend remoto con mecanismos adecuados de protección y colaboración.

---

## 14. `.gitignore`

Para evitar publicar archivos que no deben almacenarse en Git se utiliza `.gitignore`.

Entre los elementos que deben excluirse se encuentran archivos de estado y otros artefactos locales de Terraform.



<p align="center">
  <img src="../images/21-gitignore.png" alt="terra" width="500">
</p>

También deben mantenerse fuera del repositorio archivos que contengan credenciales, secretos o valores sensibles.

---

## 15. Flujo de trabajo utilizado

Durante la implementación se utilizó el siguiente ciclo de trabajo:

```text
terraform init
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
terraform apply
```

Cada etapa cumple una función diferente antes de modificar la infraestructura.

---

## 16. `terraform init`

El primer paso consiste en inicializar el directorio de Terraform.

```bash
terraform init
```

Durante este proceso Terraform prepara el directorio de trabajo e instala los providers requeridos por la configuración.

```text
Código Terraform
      │
      ▼
terraform init
      │
      ▼
Provider AWS disponible
```

Este comando fue ejecutado inicialmente al preparar el directorio `terraform/`.

---

## 17. `terraform fmt`

Antes de validar los archivos se utiliza:

```bash
terraform fmt
```

Este comando normaliza el formato del código HCL.

Su objetivo es mantener una estructura consistente y legible entre los diferentes archivos del proyecto.

---

## 18. `terraform validate`

Después se valida la configuración mediante:

```bash
terraform validate
```

Terraform comprueba que la configuración sea sintácticamente válida y consistente.

```text
Archivos .tf
     │
     ▼
terraform validate
     │
     ├── Error → corregir configuración
     │
     └── Success → continuar
```

---

## 19. `terraform plan`

Antes de modificar AWS se genera un plan:

```bash
terraform plan
```

Esta etapa es especialmente importante porque permite revisar qué operaciones pretende ejecutar Terraform.

Por ejemplo:

```text
+ create
~ update
- destroy
```

Un resultado como:

```text
Plan: 3 to add, 1 to change, 0 to destroy.
```

indica que Terraform pretende:

- Crear 3 recursos.
- Modificar 1 recurso existente.
- No destruir recursos.

El plan permite revisar las modificaciones antes de ejecutarlas.

---

## 20. `terraform apply`

Después de revisar el plan se aplican los cambios:

```bash
terraform apply
```

Terraform utiliza la configuración declarada para realizar las operaciones necesarias mediante las APIs de AWS.

```text
terraform apply
       │
       ▼
AWS Provider
       │
       ▼
AWS API
       │
       ▼
Crear / modificar recursos
```

Al finalizar correctamente:

```text
Apply complete!
```

La infraestructura declarada pasa a formar parte del estado administrado por Terraform.

---

## 21. Flujo de cambios de infraestructura

A partir de este punto, las modificaciones de infraestructura siguen el mismo procedimiento.

```text
Modificar código .tf
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
AWS actualizado
```

Esto permite evitar realizar cambios directamente en AWS sin que dichos cambios queden representados en el código.

---

## 22. Principio de infraestructura reproducible

Uno de los objetivos principales de utilizar Terraform es que la infraestructura no dependa exclusivamente de configuraciones realizadas manualmente.

El código pasa a representar la definición de la plataforma.

```text
Repositorio
    │
    ▼
Terraform
    │
    ▼
Infraestructura AWS
```

Esto proporciona una base para:

- Reproducibilidad.
- Automatización.
- Auditoría.
- Control de versiones.
- Recuperación.
- Evolución de la arquitectura.

---

## 23. Separación entre infraestructura y aplicación

Terraform administra principalmente la infraestructura AWS.

La aplicación sigue un ciclo independiente basado en GitHub, Docker y Amazon ECR.

```text
INFRAESTRUCTURA

Terraform
    │
    ▼
AWS Provider
    │
    ▼
VPC / ALB / ASG / EC2 / RDS / etc.


APLICACIÓN

GitHub
    │
    ▼
Docker Build
    │
    ▼
Amazon ECR
    │
    ▼
EC2
```

Esta separación permite modificar infraestructura y aplicación mediante ciclos de vida diferentes.

---

## 24. Resultado de la implementación

Terraform quedó establecido como la base de **Infrastructure as Code** del proyecto.

A partir de esta configuración se comenzó a construir progresivamente la infraestructura AWS necesaria para la modernización.

La implementación permitió establecer:

- Provider AWS.
- Variables reutilizables.
- Resources.
- Data Sources.
- Outputs.
- Terraform State.
- Exclusión de archivos sensibles mediante `.gitignore`.
- Flujo `init → fmt → validate → plan → apply`.
- Infraestructura versionable.
- Base para automatizar la creación de recursos AWS.

La siguiente fase documenta la implementación del **networking AWS**, incluyendo VPC, subnets Multi-AZ, Internet Gateway, NAT Gateway y tablas de enrutamiento.

---

# Evidencias







## Evidencia 6 — Terraform State

Ejecutar:

```bash
terraform state list
```

Agregar una captura donde aparezcan diferentes recursos administrados por Terraform.

Por ejemplo:

```text
aws_vpc.main
aws_subnet.public_a
aws_subnet.public_b
aws_security_group.alb
aws_lb.main
aws_autoscaling_group.app
...
```

Esta es una de las **mejores evidencias de esta sección**, porque demuestra que Terraform realmente administra la infraestructura y no es simplemente código almacenado en el repositorio.

Nombre sugerido:

```text
images/06-terraform-state.png
```

Markdown:

```markdown
![Recursos administrados mediante Terraform State](images/06-terraform-state.png)
```

---

## Evidencia 7 — `.gitignore`

Agregar una captura de Visual Studio Code mostrando que los archivos de estado y artefactos locales están excluidos del repositorio.

Por ejemplo:

```gitignore
*.tfstate
*.tfstate.*
.terraform/
*.tfplan
```

Nombre sugerido:

```text
images/07-terraform-gitignore.png
```

Markdown:

```markdown
![Protección de archivos locales de Terraform](images/07-terraform-gitignore.png)
```