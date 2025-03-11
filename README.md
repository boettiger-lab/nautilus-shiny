# nautilus-shiny

Shiny deployment for on Kubernetes (Nautilus)


This assumes the you already have a fully dockerized version of the shiny app, e.g. [boettiger-lab/inat-ranges](https://github.com/boettiger-lab/inat-ranges).  Have the Docker image pre-built and published to GitHub Container registry (as in that example), or via the [Nautilus GitLab](https://nationalresearchplatform.org/documentation/userdocs/development/gitlab/) and its container registry.

## Deployment

Deploying on Kubernetes involves three components: a `pod` specifying the environment (Docker image, environmental variables, computational resources), an `ingress` specifying the external URL (and handling https secure config), and a `service` connecting the two.  See the [Nautilus docs](https://nationalresearchplatform.org/documentation/userdocs/running/ingress/).

- Edit `pod.yaml` with the image, names/tags, and optionally resource and environmental variables. If secret variables are needed, create the secret first:

```bash
kubectl create secret generic aws-secret-access-key \
 --from-literal=AWS_SECRET_ACCESS_KEY=<MY-SECRET-KEY>
```

- Edit the `ingress.yaml` to specify the host URL and match to the service name.  (Port number here should match spec.ports.port in service file.)

- Edit the `service.yaml` to match the names of pod.  Note the spec.ports.targetPort section should match the port exposed in the Dockerfile for the app.

Bring up all components (from [up.sh](up.sh)):

```bash
kubectl apply -f service.yaml -n biodiversity
kubectl apply -f ingress.yaml -n biodiversity
kubectl apply -f pod.yaml -n biodiversity
```

Apps need to request permission to stay up for more than 24 hours.

