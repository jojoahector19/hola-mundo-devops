# Arquitectura y decisiones

## Por que k3d en vez de minikube/kind
k3d es liviano, corre k3s (distribucion oficial ligera de Kubernetes) dentro
de contenedores Docker, soporta multi-nodo y trae soporte nativo de registro
local de imagenes, ideal para un PoC de CI/CD sin salir de tu maquina.

## Flujo GitOps completo
1. Desarrollador hace push de codigo (backend o frontend).
2. Tekton PipelineRun: git-clone -> build imagen (Kaniko, sin Docker-in-Docker)
   -> push al registro local -> actualiza el tag de imagen en el YAML del
   repo y hace commit/push.
3. ArgoCD detecta el cambio en Git (polling cada 3 min o webhook) y
   sincroniza el cluster automaticamente (`selfHeal: true`).

## Por que 3 Applications de ArgoCD separadas
Cada Application apunta a una carpeta distinta (`database/k8s`,
`backend/k8s`, `frontend/k8s`), permitiendo desplegar, versionar y hacer
rollback de cada componente de forma independiente, aunque vivan en el mismo
repositorio.

## Alternativa con SQL Server
Si prefieres SQL Server en vez de Postgres, reemplaza en
`database/k8s/deployment.yaml` la imagen por
`mcr.microsoft.com/mssql/server:2022-latest`, ajusta las variables de
entorno (`ACCEPT_EULA=Y`, `SA_PASSWORD=...`) y cambia el driver del backend
de `pg` a `mssql` (paquete npm `mssql`). La logica de negocio (tabla
`visits` con columna `environment`) es identica.

## Ambientes develop/release con Kustomize (recomendado a futuro)
```
backend/k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/
    ├── develop/kustomization.yaml   (patch ENVIRONMENT=develop)
    └── release/kustomization.yaml   (patch ENVIRONMENT=release)
```
Y en ArgoCD, dos Applications: una apuntando a `overlays/develop`, otra a
`overlays/release`.

## Migracion a GCP (opcional, mas economico)
- Cluster: **GKE Autopilot** (pagas solo por los pods que corren, no por
  nodos ociosos - la opcion mas barata de GKE).
- Registro de imagenes: **Artifact Registry** (capa gratuita generosa).
- Base de datos: Cloud SQL for PostgreSQL (tier `db-f1-micro`, el mas
  economico) o seguir con Postgres en el propio cluster para ahorrar del
  todo.
- ArgoCD y Tekton se instalan exactamente igual, solo cambia el `kubeconfig`
  al cluster de GKE.
