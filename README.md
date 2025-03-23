# nautilus-shiny

Shiny deployment for on Kubernetes (Nautilus)


This assumes the you already have a fully dockerized version of the shiny app.  A complete example is provided in the [app](/app) dir here, adjust as needed.  Have the Docker image pre-built and published to GitHub Container registry (as in this demo repo -- merely copy the `.github` folder).   Alternately, you can have the image build via the [Nautilus GitLab](https://nationalresearchplatform.org/documentation/userdocs/development/gitlab/) and deployed to its container registry.

## Deployment

Deploying on Kubernetes involves three components: a `deployment` specifying the environment (Docker image, environmental variables, computational resources), an `ingress` specifying the external URL (and handling https secure config), and a `service` connecting the two.  See the [Nautilus docs](https://nationalresearchplatform.org/documentation/userdocs/running/ingress/).

- Edit `deployment.yaml` to point to your desired Docker `image`. Optionally rename the k8s-app (`shiny-app`), and optionally set resource and environmental variables. 
- Edit the `ingress.yaml` to specify the host URL (e.g. if your namespace is `eco4cast`, I recommend `shiny-eco4cast.nrp-nautilus.io`.  The `nrp-natuilus.io` part is needed, and the prefix to it should not have `.`.  I recommen using the namespace in the prefix to avoid collisions; the `shiny-` part is just a suggestion.)
- Edit the `service.yaml` to match the names of pod.  Note the spec.ports.targetPort section should match the port exposed in the Dockerfile for the app. 

Bring up all components (from [up.sh](up.sh)), modifying to your namespace:

```bash
kubectl apply -f service.yaml -n biodiversity
kubectl apply -f ingress.yaml -n biodiversity
kubectl apply -f deployment.yaml -n biodiversity
```

It may take a few minutes for the deployment to spin up a pod serving the app.  Check the status with `kubectl get pods`, `kubectl describe pod shiny-deployment-xxxx` (replace `xxxx` with the suffix shown by `get pods`) etc.  The deployment will stay up for up 2 weeks before being auto-culled.  You can refresh the deployment as needed. Delete the existing depoyment with `down.sh` recipe (you will first need to adjust the namespace and containers appropriately.)
