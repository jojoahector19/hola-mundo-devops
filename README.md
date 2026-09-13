# Hola Mundo DevOps - PoC CI/CD local con Kubernetes, ArgoCD y Tekton

PoC 100% software libre, pensado para correr **localmente en Ubuntu** (sin nube),
usando k3d (Kubernetes en Docker). Todo el stack cabe sobradamente en una
maquina de 128GB de RAM.

## Arquitectura (3 proyectos independientes, mismo repo)

```
hola-mundo-devops/
├── database/   -> PostgreSQL (o SQL Server si prefieres, ver docs/ARCHITECTURE.md)
├── backend/    -> Web API en Node.js/Express
├── frontend/   -> Frontend en JavaScript plano (facil de migrar a Angular)
├── k8s/        -> Recursos compartidos (namespace)
├── argocd/     -> Applications de ArgoCD (CD / GitOps)
├── tekton/     -> Pipelines, Tasks y PipelineRuns (CI)
└── scripts/    -> Scripts de instalacion y bootstrap
```

Cada carpeta (`database/`, `backend/`, `frontend/`) es un proyecto
independiente con su propio Dockerfile y manifiestos k8s, pero viven en el
mismo repositorio Git (monorepo), tal como pediste.

## Que hace la aplicacion

- El frontend llama a `GET /api/hello` en el backend.
- El backend inserta una fila en la tabla `visits` de Postgres (con el campo
  `environment` = `develop` o `release`, segun la variable de entorno
  `ENVIRONMENT` del Deployment) y responde con el total de visitas.
- El frontend muestra "Hola Mundo", el numero de visitas y el ambiente.

## Stack usado (todo software libre / gratis)

| Componente        | Herramienta                          |
|-------------------|---------------------------------------|
| Cluster K8s local | k3d (k3s dentro de Docker)            |
| CD / GitOps       | ArgoCD                                |
| CI / Pipelines    | Tekton Pipelines                      |
| Base de datos     | PostgreSQL 16                         |
| Backend           | Node.js + Express + pg                |
| Frontend          | HTML/JS + Nginx                       |
| Registro imagenes | Registro Docker local (k3d-registry)  |

No se necesita GCP para nada de esto. Si mas adelante quieres llevarlo a la
nube, el mismo YAML de k8s sirve para GKE (Google Kubernetes Engine) - solo
cambiarias el registro de imagenes a Artifact Registry y el cluster a GKE
Autopilot (opcion mas economica de GCP).

## Pasos para correrlo en tu Ubuntu

### 1. Sube este repo a GitHub (o GitLab)
Tekton y ArgoCD necesitan un repo Git real para funcionar en modo GitOps.
Reemplaza `jojoahector19` en `argocd/*.yaml` y `tekton/pipelinerun-*.yaml` por
tu usuario/repositorio real.

```bash
cd hola-mundo-devops
git init
git add .
git commit -m "poc inicial"
git branch -M main
git remote add origin https://github.com/jojoahector19/hola-mundo-devops.git
git push -u origin main
```

### 2. Instala prerequisitos
```bash
cd scripts
./00-prereqs.sh
```
Instala: Docker, kubectl, k3d, Tekton CLI (tkn) y ArgoCD CLI.

### 3. Crea el cluster local + registro de imagenes
```bash
./01-create-cluster.sh
```

### 4. Instala ArgoCD
```bash
./02-install-argocd.sh
```
Guarda el password que imprime. Para ver la UI:
```bash
kubectl port-forward svc/argocd-server -n argocd 8081:443
# abre https://localhost:8081  usuario: admin
```

### 5. Instala Tekton
```bash
./03-install-tekton.sh
```

### 6. Registra las Applications de ArgoCD (una por proyecto)
```bash
./04-bootstrap-argocd-apps.sh
```
ArgoCD empezara a sincronizar `database/k8s`, `backend/k8s` y
`frontend/k8s` automaticamente desde tu repo Git.

### 7. Ejecuta el pipeline de Tekton (build + push + actualizar manifest)
```bash
./05-run-pipeline.sh
tkn pipelinerun logs --last -f -n hola-mundo
```
El pipeline: clona el repo -> construye la imagen con Kaniko -> la sube al
registro local -> actualiza el tag en el `deployment.yaml` y hace push ->
ArgoCD detecta el cambio en Git y despliega automaticamente (GitOps real).

### 8. Prueba la aplicacion
```bash
curl http://localhost:8080/api/hello
# o abre http://localhost:8080 en el navegador
```

## Cambiar entre "develop" y "release"

Edita `backend/k8s/configmap.yaml`, cambia `ENVIRONMENT: "develop"` a
`"release"`, haz commit y push. ArgoCD (self-heal automatico) redepliega el
ConfigMap y desde ese momento cada fila nueva en `visits` quedara marcada
como `release`.

Para un caso mas real, se recomienda usar **Kustomize overlays**
(`overlays/develop` y `overlays/release`) o dos ArgoCD Applications
apuntando a dos branches distintas. Se explica en `docs/ARCHITECTURE.md`.

## Frontend en Angular (opcional)

Se entrega en JavaScript plano para simplificar el PoC, pero es igual de
valido usar Angular:
```bash
npm install -g @angular/cli
ng new frontend --directory frontend/src --routing=false --style=css
```
Solo tendrias que ajustar el Dockerfile del frontend a un build multi-stage
(`ng build` -> copiar `dist/` a Nginx) y mantener el mismo `nginx.conf` con
el proxy `/api/`.
