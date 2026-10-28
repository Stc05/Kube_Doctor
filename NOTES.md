
## Aide-mémoire des commandes

### Terminal macOS
- `cd dossier` : se déplacer dans un dossier (`cd ~` pour revenir au dossier personnel)
- `mkdir -p dossier` : créer un dossier, sans erreur s'il existe déjà
- `ls` / `ls -a` : lister les fichiers ; `-a` affiche aussi les fichiers cachés
- `ls -l fichier` : afficher les détails d'un fichier, dont la flèche d'un lien symbolique
- `cat fichier` : afficher le contenu d'un fichier
- `cat > fichier << 'FIN' … FIN` : écrire un texte de plusieurs lignes dans un fichier (`>>` pour ajouter à la fin)
- `open -e fichier` : ouvrir un fichier dans TextEdit
- `which programme` : indiquer quel programme sera lancé et où il se trouve
- `echo $PATH | tr ':' '\n'` : afficher les dossiers où macOS cherche les programmes
- `source ~/.zshrc` : recharger la configuration du terminal
- `hash -r` : vider la mémoire du terminal sur l'emplacement des programmes
- `brew install outil` : installer un outil avec Homebrew

### Docker
- `docker info` : vérifier que Docker tourne, voir ses CPU et sa mémoire
- `docker ps` : lister les conteneurs en marche (dont les nœuds k3d)
- `docker stop nom` / `docker start nom` : arrêter ou relancer un conteneur sans perdre ses données

### k3d
- `k3d version` : afficher la version de k3d et de k3s
- `k3d cluster create nom --agents 1` : créer un cluster avec 1 server et 1 agent
- `k3d cluster delete nom` : supprimer complètement un cluster
- `k3d cluster stop nom` / `k3d cluster start nom` : mettre en pause ou rallumer le cluster

### kubectl : configuration
- `kubectl version --client` : version de kubectl, sans contacter de cluster
- `kubectl config current-context` : savoir à quel cluster kubectl parle
- `kubectl config get-contexts` : lister tous les clusters connus
- `kubectl config use-context nom` : basculer vers un autre cluster

### kubectl : observer
- `kubectl get nodes` : lister les nœuds et leur état
- `kubectl get pods` : lister les pods, leur état et leurs redémarrages
- `kubectl get pods -w` : suivre les changements en direct (Ctrl + C pour sortir)
- `kubectl get … -o wide` : ajouter des colonnes (nœud d'un pod, IP d'un nœud)
- `kubectl get deployments` / `services` / `replicasets` : lister un type d'objet
- `kubectl get all` : lister pods, Services, Deployments et ReplicaSets d'un coup
- `kubectl get deployment nom -o yaml` : afficher la fiche complète stockée dans le cluster
- `kubectl describe pod -l app=nom` : fiche détaillée d'un pod, avec Last State et Events
- `kubectl logs deployment/nom --tail=30` : les dernières lignes écrites par le programme
- `kubectl top pod -l app=nom` : consommation réelle de CPU et de mémoire

### kubectl : agir
- `kubectl apply -f fichier.yaml` : envoyer l'état voulu au cluster
- `kubectl delete -f fichier.yaml` : supprimer tout ce qu'un fichier avait créé
- `kubectl port-forward deployment/frontend 8080:8080` : tunnel entre le Mac et un pod (port Mac : port pod)
- `kubectl delete pod -l app=nom` : supprimer un pod (le Deployment en recrée un)
- `kubectl delete deployment nom` : arrêter vraiment un service
- `kubectl scale deployment nom --replicas=3` : changer le nombre de copies
- `kubectl set resources deployment nom --limits=memory=256Mi` : modifier la limite de mémoire

### Git
- `git clone adresse` : télécharger un dépôt (`--depth 1` pour la dernière version seulement)
- `git add .` : préparer les fichiers modifiés
- `git commit -m "message"` : créer un enregistrement
- `git push` : envoyer sur GitHub

### Helm
- `helm version --short` : vérifier que Helm est installé

## Jour 3 : Azure, Terraform et AKS

### Installer les outils et se connecter
- `brew install azure-cli` : installer la commande `az`
- `brew tap hashicorp/tap` : ajouter le catalogue officiel de HashiCorp à Homebrew
- `brew install hashicorp/tap/terraform` : installer Terraform depuis ce catalogue
- `az login` : se connecter à Azure (choisir l'abonnement Azure for Students)
- `az account show --output table` : vérifier l'abonnement actif
- `az account set --subscription "Azure for Students"` : changer d'abonnement actif
- `az account show --query id --output tsv` : afficher l'identifiant de l'abonnement

### Activer les fournisseurs de ressources (une fois par abonnement)
- `az provider register --namespace Microsoft.Compute` : machines virtuelles (nœuds)
- `az provider register --namespace Microsoft.ContainerService` : AKS
- `az provider register --namespace Microsoft.ContainerRegistry` : registre d'images
- `az provider register --namespace Microsoft.Network` : réseau, répartiteur de charge
- `az provider show --namespace <nom> --output table` : vérifier l'état (Registered)
- `az provider list --output table | grep -i container` : retrouver des noms de fournisseurs

### Vérifier quotas, tailles et régions
- `az vm list-usage --location <région> --output table` : quotas de vCPU par famille
- `az vm list-usage --location <région> --output table | grep -v " 0$"` : seulement les quotas non nuls
- `az vm list-skus --location <région> --size <taille> --output table` : taille accessible ? (vide = interdite)
- `az vm list-skus --location <région> --size <taille> --all --output table` : voir la raison d'un blocage
- `az vm list-skus --location <région> --resource-type virtualMachines --output table | grep -E "_B2|_D2"` : petites tailles disponibles
- `az policy assignment list --output table` : règles imposées à l'abonnement
- `az policy assignment show --name sys.regionrestriction --query parameters --output json` : régions autorisées
- `az aks get-versions --location <région> --output table` : versions AKS proposées (garder celles en KubernetesOfficial)
- Règle : une taille est utilisable si la région est autorisée, si elle est disponible (restriction None ou seulement Zone) et si sa famille a du quota

### Terraform
- `terraform version` : vérifier l'installation
- `terraform init` : télécharger le provider (première fois, ou après changement de provider)
- `terraform fmt` : mettre les fichiers en forme
- `terraform validate` : vérifier le code, sans contacter Azure
- `terraform plan` : voir ce qui serait créé, modifié ou supprimé, sans rien faire
- `terraform apply` : appliquer (lire la ligne "X to add, Y to change, Z to destroy" avant de taper yes)
- `terraform destroy` : tout supprimer en fin de session
- `terraform state list` : voir les ressources gérées par Terraform

### Utiliser le cluster AKS
- `az aks get-credentials --resource-group rg-kube-doctor --name aks-kube-doctor --overwrite-existing` : connecter kubectl à AKS
- `az aks list --output table` : lister les clusters AKS
- `az group show --name rg-kube-doctor` : vérifier un groupe de ressources
- `az group list --output table` : lister les groupes de ressources
- `kubectl get service frontend-external -w` : attendre l'adresse IP publique de la boutique

### Routine quotidienne sur AKS
- `cd ~/projets/Kube_Doctor/terraform` puis `terraform apply`
- `az aks get-credentials --resource-group rg-kube-doctor --name aks-kube-doctor --overwrite-existing`
- travailler
- `terraform destroy` puis `kubectl config use-context k3d-kube-doctor`

## Jour 2 : Helm, Prometheus et Grafana (en local)

### Cluster local et contextes
- `k3d cluster start kube-doctor` : rallumer le cluster local
- `k3d cluster list` : lister les clusters k3d
- `kubectl config use-context k3d-kube-doctor` : basculer sur le cluster local
- `kubectl config get-contexts` : lister les contextes (étoile = actif)
- `kubectl get namespaces` : lister les namespaces
- `kubectl get pods -A` : les pods de tous les namespaces
- `kubectl api-resources` : types d'objets et leurs abréviations (svc, deploy, ns…)

### Explorer un chart
- `ls ~/projets/microservices-demo/helm-chart` : Chart.yaml, values.yaml, templates/
- `grep -n -A 12 "cartService:" values.yaml` : trouver un réglage dans les valeurs par défaut
- `grep -rn "cartService.resources" templates/` : voir où le réglage est utilisé
- `helm show values <chart>` : toutes les valeurs par défaut d'un chart
- `helm show chart <chart>` : la carte d'identité d'un chart (dont ses dépendances)
- `helm template <release> <chart> -f <fichier>` : afficher le YAML final sans rien installer

### Installer la boutique avec Helm
- `kubectl delete -f ~/projets/microservices-demo/release/kubernetes-manifests.yaml` : retirer l'installation kubectl du jour 1
- `helm install boutique ~/projets/microservices-demo/helm-chart -f ~/projets/Kube_Doctor/helm/boutique-values.yaml` : installer avec mes réglages
- `helm list` : voir les releases
- `kubectl get deployment cartservice -o jsonpath='{.spec.template.spec.containers[0].resources}'` : vérifier les ressources appliquées

### Installer le monitoring
- `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts` : ajouter le dépôt de charts
- `helm repo update` : mettre à jour la liste des charts
- `helm search repo kube-prometheus-stack` : trouver le chart et sa version
- `helm install monitoring prometheus-community/kube-prometheus-stack --version 92.14.0 --namespace monitoring --create-namespace` : installer Prometheus, Grafana, Alertmanager
- `kubectl get pods -n monitoring -w` : suivre le démarrage

### Accéder à Grafana
- `kubectl get secrets -n monitoring` : lister les Secrets
- `kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d; echo` : mot de passe admin
- `kubectl get svc -n monitoring` : Services et ports
- `kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80` : ouvrir http://localhost:3000 (identifiant admin)

### Premières requêtes PromQL (Grafana, menu Explore)
- `container_memory_working_set_bytes{namespace="default", container="server", pod=~"cartservice.*"} / 1024 / 1024` : mémoire réelle de cartservice en MiB
- `kube_pod_container_resource_limits{namespace="default", pod=~"cartservice.*", resource="memory"} / 1024 / 1024` : sa limite en MiB

### Diagnostic cartservice : les preuves
- En local, limite 128 MiB : 18 redémarrages (OOMKilled)
- Sur AKS, limite 128 MiB : 0 redémarrage
- En local, consommation mesurée par Prometheus : environ 142 MiB, au-dessus de 128
- Conclusion : l'émulation amd64 sur Mac arm64 augmente la consommation ; limite fixée à 256 MiB dans helm/boutique-values.yaml

## Jour 4 : registre d'images, Key Vault et permissions

### Préparer Azure
- `az account show --output table` : vérifier l'abonnement actif (Azure for Students)
- `az provider register --namespace Microsoft.KeyVault` : activer le service Key Vault (une fois par abonnement)
- `az provider show --namespace Microsoft.KeyVault --output table` : vérifier l'état (Registered)
- `az acr check-name --name acrkubedoctorstc05` : vérifier qu'un nom de registre est libre (unique dans tout Azure, minuscules et chiffres)

### Écrire et vérifier le Terraform
- `nano providers.tf` : bloc `features { key_vault { purge_soft_delete_on_destroy = true … } }` pour purger le coffre au destroy
- `nano main.tf` : ajouter le registre, l'accès AcrPull, le Key Vault et la permission
- `cat >> main.tf << 'EOF' … EOF` : ajouter des blocs à la fin d'un fichier sans rien effacer
- `grep -n '^resource\|^data' main.tf` : lister les blocs déclarés dans le fichier
- `terraform fmt` : mettre en forme
- `terraform validate` : vérifier le code
- `terraform plan` : vérifier la dernière ligne avant d'appliquer
- `terraform apply` : créer ou modifier (lire add / change / destroy avant de taper yes)
- `terraform state list` : voir les ressources réellement gérées par Terraform

### Tester le coffre
- `az keyvault secret set --vault-name kv-kubedoctor-stc05 --name test-secret --value "bonjour"` : ranger un secret (vault-name = le coffre, name = le secret)
- `az keyvault secret show --vault-name kv-kubedoctor-stc05 --name test-secret --query value --output tsv` : relire sa valeur
- `az keyvault list-deleted --output table` : voir les coffres supprimés mais encore en réserve

### Tester l'accès du cluster au registre
- `az aks get-credentials --resource-group rg-kube-doctor --name aks-kube-doctor --overwrite-existing` : connecter kubectl (Mac vers cluster)
- `az aks check-acr --resource-group rg-kube-doctor --name aks-kube-doctor --acr acrkubedoctorstc05.azurecr.io` : diagnostic cluster vers registre

### Terminer la session
- `terraform destroy` : tout supprimer (6 to destroy ; le bloc data n'est pas compté)
- `az group list --output table` : ne doit rester que NetworkWatcherRG (créé automatiquement par Azure)
- `kubectl config use-context k3d-kube-doctor` : revenir sur le cluster local

### Reste à faire (prochaine session)
- `terraform apply` puis `az aks get-credentials … --overwrite-existing`
- `helm install boutique ~/projets/microservices-demo/helm-chart -f ~/projets/Kube_Doctor/helm/boutique-values.yaml`
- `kubectl get service frontend-external -w` : attendre l'adresse IP publique
- optionnel : `helm install monitoring prometheus-community/kube-prometheus-stack --version 92.14.0 --namespace monitoring --create-namespace`
- `terraform destroy`

### Notions du jour
- Attribution de rôle (RBAC Azure) : qui (une identité), quel rôle, sur quoi (la portée)
- Moindre privilège : AcrPull pour le cluster (lire seulement), Key Vault Secrets Officer pour moi, chacun limité à une seule ressource
- Kubelet identity : l'identité des nœuds, celle qui télécharge les images (différente de l'identité du cluster)
- Bloc `data` : lire une information existante sans rien créer (ici mon identité et mon tenant)
- Tenant : l'annuaire d'identités de l'organisation (DVHE pour l'école)
- Key Vault : coffre à secrets ; suppression réversible 7 jours, purge activée pour le destroy quotidien
- ClusterIP vs LoadBalancer : Grafana reste interne (accès par port-forward), seule la boutique a une adresse publique

### Incident du jour
- Un apply a annoncé "0 added, 1 changed" au lieu de "3 to add" : les nouveaux blocs n'étaient pas enregistrés dans main.tf
- Diagnostic : `terraform state list` (3 ressources seulement) puis `grep` sur main.tf
- Le "1 changed" sur le cluster était une dérive : Azure remplit des réglages par défaut après la création
- Leçon : toujours lire la dernière ligne du plan avant de taper yes
