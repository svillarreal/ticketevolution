alias k=kubectl
alias kaf="kubectl apply -f"

kaf bootstrap.yaml

helm repo add bitnami-labs https://bitnami-labs.github.io/sealed-secrets/ 
helm install ticketevol-sealed-secrets bitnami-labs/sealed-secrets --version 2.17.3 

# The following step is not automated yet, the secret name is harcoded, check how to make it generic (variable)
k get secret sealed-secrets-key49k6n -n default \                                                                                                    
  -o jsonpath="{.data.tls\.crt}" \
  | base64 -d  \
  > pub-cert.pem

# Sounds like that the following pg-sealed-secret.yaml file should be commited and pushed to git, so that it reflects the new encrypted values
kubeseal --cert=pub-cert.pem --format=yaml < pg-secret.yml > pg-sealed-secret.yaml --controller-name ticketevol-sealed-secrets --controller-namespace default 

kaf pg-sealed-secret.yaml

# The file pg_config.yaml is not commited in git and has the following structure:
## auth:
##  database: ticketevolutiondb
##  username: ticketevolutionapp
##  password: yT8-...
##  postgresPassword: bK3...
# Maybe it can be generated automatically? So we don't depend on manual steps
helm template ticketevolution-pg oci://registry-1.docker.io/bitnamicharts/postgresql -n ticketevol -f pg_config.yaml > pg.yaml

kaf pg.yaml 

# This step requires actually to get the EKS Load Balancer IAM Role ARN, so TODO can get this value with AWS CLI maybe?
kaf serviceaccount.yaml

helm repo add eks https://aws.github.io/eks-charts

# clusterName can maybe be an tf output
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \        
  --set clusterName=ticketevolution-eks-dev \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

kaf deployment-be.yaml
kaf services.yaml
kaf loadbalancer.yaml
