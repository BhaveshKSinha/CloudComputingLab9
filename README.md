# OpenFaaS on Minikube with Terraform and GitHub Actions

This repo is set up for:

- a `hello-world` OpenFaaS function in `function/`
- Terraform-driven deploy and destroy using `faas-cli`
- a GitHub Actions pipeline that builds the image on Linux and deploys from a self-hosted runner on the Minikube machine

## Important constraint

OpenFaaS Community Edition only allows **public images** when deploying through the gateway.

If you use Docker Hub, make sure `hello-world` is in a **public** repository, for example:

- `bhaveshksiiitk/hello-world:latest`

## What Terraform does

Terraform renders `function/hello-world.rendered.yml` from `function/hello-world.yml` during `apply` by replacing `__FUNCTION_IMAGE__` with the image passed in `TF_VAR_function_image`.

Then Terraform runs:

- `faas-cli deploy -f function/hello-world.rendered.yml`
- `faas-cli remove hello-world`

## Required GitHub secrets

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `OPENFAAS_PASSWORD`

## Runner requirement

The deploy and destroy jobs must run on a self-hosted runner on the same machine that has:

- Minikube
- `kubectl`
- `faas-cli`
- access to the OpenFaaS gateway

## Local run

### 1. Build and push the image

From WSL:

```bash
cd /mnt/c/Users/bhave/OneDrive/Documents/GitHub/CloudComputingLab9
faas-cli template store pull python3-http
sed "s|__FUNCTION_IMAGE__|bhaveshksiiitk/hello-world:latest|g" function/hello-world.yml > function/hello-world.rendered.yml
faas-cli build -f function/hello-world.rendered.yml
faas-cli push -f function/hello-world.rendered.yml
```

### 2. Make sure the Docker Hub repo is public

In Docker Hub, set the `hello-world` repository visibility to public.

### 3. Port-forward the gateway

From PowerShell:

```powershell
kubectl port-forward svc/gateway -n openfaas 8080:8080
```

### 4. Log in to OpenFaaS

From another PowerShell window:

```powershell
faas-cli login --username admin --password <OPENFAAS_PASSWORD> --gateway http://127.0.0.1:8080
```

### 5. Deploy with Terraform

```powershell
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve -var="function_image=bhaveshksiiitk/hello-world:latest" -var="release_id=manual-1"
```

### 6. Verify

```powershell
faas-cli list -g http://127.0.0.1:8080
echo "" | faas-cli invoke hello-world -g http://127.0.0.1:8080
kubectl get pods -n openfaas-fn
```

### 7. Monitor with Prometheus

```powershell
kubectl port-forward svc/prometheus -n openfaas 9090:9090
```

Open `http://localhost:9090` and query:

```text
gateway_function_invocation_total
```

### 8. Destroy

```powershell
terraform -chdir=terraform destroy -auto-approve -var="function_image=bhaveshksiiitk/hello-world:latest"
```

## GitHub Actions

Push to `main` or manually run the workflow with `deploy` to:

1. build and push the public Docker image on `ubuntu-latest`
2. port-forward and log in to OpenFaaS on the self-hosted runner
3. run `terraform apply`

Run the workflow with `destroy` to remove the function.
