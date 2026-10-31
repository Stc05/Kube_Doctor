
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

## Jour 5 : sécurité, GitOps avec Argo CD et pipeline CI

### Gitleaks : chercher des secrets
- `brew install gitleaks` : installer l'outil
- `gitleaks git -v .` : analyser tout l'historique du dépôt (résultat : 9 commits, no leaks found)

### Trivy : failles et erreurs de configuration
- `brew install trivy` : installer l'outil
- `trivy image --severity HIGH,CRITICAL <image>` : failles connues (CVE) d'une image
- Résultat cartservice v0.10.7 : 2 failles OpenSSL HIGH (corrigées dans une version plus récente) ; risque faible (code concerné probablement non utilisé, service non exposé)
- `trivy config terraform/` : erreurs de configuration du Terraform (9 problèmes trouvés)
- `trivy config terraform/ --show-suppressed` : voir aussi les problèmes ignorés

### Tri des 9 problèmes du Terraform
- Corrigé : AZU-0042 (RBAC du cluster, faux positif, écrit explicitement)
- Corrigé : AZU-0041 (API du cluster restreinte à mon adresse IP avec authorized_ip_ranges)
- Reporté (semaine sécurité) : AZU-0013 (réseau du Key Vault), AZU-0043 (network policies)
- Assumé : AZU-0016 (purge du coffre, destroy quotidien), AZU-0040 (Azure Monitor, remplacé par Prometheus), AZU-0065 (cluster privé, compensé par la restriction IP), AZU-0066 (Azure Policy, Kyverno prévu), AZU-0067 (clés de chiffrement personnelles)
- Les exceptions sont listées dans `.trivyignore`, avec leur justification (registre des risques acceptés)

### Mon adresse IP
- `curl -4 -s ifconfig.me; echo` : adresse IPv4 publique (le -4 est nécessaire, sinon on peut obtenir une IPv6 refusée par AKS)
- La mettre dans terraform.tfvars : `authorized_ip = "x.x.x.x/32"`

### Installer Argo CD
- `helm repo add argo https://argoproj.github.io/argo-helm` : dépôt officiel (vérifier l'éditeur "argo", badge Official sur Artifact Hub)
- `helm repo update` puis `helm search repo argo/argo-cd` : trouver la version
- `helm install argocd argo/argo-cd --version 10.11.6 --namespace argocd --create-namespace` : installer
- Variante sans repo add : `helm install argocd argo-cd --repo https://argoproj.github.io/argo-helm --version 10.11.6 --namespace argocd --create-namespace`
- `kubectl get pods -n argocd` : 7 composants (server, repo-server, application-controller, redis, dex, applicationset, notifications)
- `helm get notes argocd -n argocd` : réafficher les instructions d'après installation

### Accéder à Argo CD
- `kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo` : mot de passe initial (identifiant admin)
- `kubectl port-forward -n argocd svc/argocd-server 8080:443` puis https://localhost:8080 (accepter l'avertissement : certificat auto-signé)
- Ordre correct : se connecter, changer le mot de passe, le noter, puis seulement `kubectl delete secret -n argocd argocd-initial-admin-secret`
- Mot de passe perdu : `kubectl patch secret -n argocd argocd-secret -p '{"data": {"admin.password": null, "admin.passwordMtime": null}}'` puis `kubectl rollout restart deployment -n argocd argocd-server`

### L'Application Argo CD (argocd/boutique.yaml)
- Quoi : le chart de Google (tag v0.10.7) + mes réglages (helm/boutique-values.yaml), avec deux sources et `ref: values`
- Où : ce cluster, namespace boutique (CreateNamespace=true)
- Comment : synchronisation automatique, prune et selfHeal
- `git ls-remote --tags <dépôt> | grep v0.10` : trouver une étiquette (attention au tri alphabétique, utiliser `sort -V -k2`)
- `kubectl apply -f argocd/boutique.yaml --dry-run=server` : vérifier sans créer
- `kubectl apply -f argocd/boutique.yaml` : le seul geste manuel, une fois par cluster
- `kubectl get applications -n argocd` : SYNC STATUS et HEALTH STATUS
- `kubectl get application boutique -n argocd -o jsonpath='{.status.conditions}'; echo` : lire les erreurs
- `kubectl annotate application boutique -n argocd argocd.argoproj.io/refresh=hard --overwrite` : forcer une relecture et vider le cache
- `kubectl logs -n argocd deployment/argocd-repo-server --tail=30` : journal du composant qui lit les dépôts
- `kubectl explain application.spec` et `kubectl api-resources | grep -i application` : retrouver la structure et l'apiVersion

### Tests GitOps
- Test 1 : modifier helm/boutique-values.yaml, git push, Argo CD applique tout seul (limite de cartservice passée à 300Mi)
- Test 2 : `kubectl set resources deployment cartservice -n boutique --limits=memory=200Mi` : annulé en quelques secondes par selfHeal
- Limite : `kubectl scale … --replicas=3` n'est pas annulé, car le chart ne déclare pas replicas ; le GitOps ne protège que ce qui est écrit dans Git
- `helm template boutique <chart> -f helm/boutique-values.yaml > /dev/null && echo "YAML valide"` : tester les réglages avant de pousser

### Pipeline GitHub Actions (.github/workflows/securite.yml)
- Déclenché à chaque push sur main et à chaque pull request
- Tâche 1 : Gitleaks sur tout l'historique (actions/checkout avec fetch-depth: 0)
- Tâche 2 : Trivy config sur terraform/, avec .trivyignore et exit-code 1 (sinon la tâche reste verte même en cas de problème)
- Versions figées des actions ; option plus sûre : figer par identifiant de commit
- `git ls-remote --tags https://github.com/aquasecurity/trivy-action | sort -V -k2 | tail -3` : dernière version d'une action
- Résultat : deux tâches vertes, artefact gitleaks-results.sarif (format standard des rapports de sécurité)
- À faire : mettre à jour actions/checkout (avertissement Node.js 20) et figer runs-on: ubuntu-24.04

### Session AKS (fin des jours 4 et 5)
- `terraform apply` puis `az aks get-credentials --resource-group rg-kube-doctor --name aks-kube-doctor --overwrite-existing`
- `helm install argocd …` (Argo CD doit être installé avant de lui donner l'Application)
- `kubectl apply -f argocd/boutique.yaml` : le même fichier qu'en local
- `kubectl get svc -n boutique frontend-external -w` : adresse publique de la boutique
- `terraform destroy` puis `kubectl config use-context k3d-kube-doctor`

### Incidents du jour
- Dépôt privé : Argo CD ne pouvait pas le lire (failed to get git client) ; corrigé en rendant le dépôt public
- Erreur de syntaxe YAML poussée dans Git : Argo CD a refusé de l'appliquer et gardé la dernière version valide ; diagnostic dans les conditions de l'Application, correction testée avec helm template
- Le premier déploiement avait réussi grâce au cache : le refresh hard a révélé le problème
- Mac à court de mémoire (pression orange, 12 Go pour Docker) : libérer en retirant le monitoring (`helm uninstall monitoring -n monitoring`)
- Faux chart sur Artifact Hub (QuenchWorks) : Verified Publisher ne veut pas dire officiel ; chercher le badge Official
- Adresse IPv6 refusée par AKS : utiliser `curl -4`

### Notions du jour
- GitOps : Git est la seule source de vérité ; Argo CD aligne le cluster sur Git
- CI / CD : GitHub Actions contrôle le code, Argo CD déploie la configuration
- Application : objet ajouté par Argo CD (CRD), qui répond à quoi, où, comment
- Helm installe les outils de la plateforme (Argo CD) ; Argo CD déploie les applications
- brew installe ce qui tourne sur mon Mac, Helm ce qui tourne dans le cluster, Terraform ce qui tourne dans Azure
- Chaîne d'approvisionnement : vérifier l'éditeur de chaque chart, image et action, et figer les versions

## Jour 6 : alertes et tableaux de bord

### Monitoring confié à Argo CD
- `helm uninstall monitoring -n monitoring` : retirer l'installation manuelle (les CRD restent, Helm ne les supprime jamais)
- helm/monitoring-values.yaml : rétention 2d ; `ruleSelectorNilUsesHelmValues: false` (et serviceMonitor, podMonitor) pour lire les règles de tous les namespaces ; kubeControllerManager, kubeScheduler, kubeProxy, kubeEtcd désactivés (regroupés dans k3s, sinon fausses alertes)
- `helm template monitoring prometheus-community/kube-prometheus-stack --version 92.14.0 -f helm/monitoring-values.yaml > /dev/null && echo "YAML valide"` : vérifier les réglages
- argocd/monitoring.yaml : source Helm (`chart:` au lieu de `path:`, version du chart en targetRevision), `releaseName: monitoring` pour garder les mêmes noms, `ServerSideApply=true` (CRD trop volumineuses sinon)
- `kubectl top nodes` : mémoire des nœuds (les deux nœuds k3d partagent la même VM Docker)
- `kubectl get svc kubernetes -n default` : l'API du cluster, joignable en interne à https://kubernetes.default.svc (règle : <service>.<namespace>.svc)

### Règles d'alerte (k8s/alertes/boutique.yaml, type PrometheusRule)
- ConteneurRedemarreEnBoucle (critical) : `increase(kube_pod_container_status_restarts_total{namespace="boutique"}[10m]) > 2`, for 1m
- ConteneurTueParManqueDeMemoire (critical) : dernier arrêt OOMKilled et redémarrages récents
- MemoireProcheDeLaLimite (warning) : mémoire / limite > 0.9 pendant 2m (alerte prédictive)
- PodNonPret (warning) : pod non prêt depuis 5m
- Une règle : expr (condition PromQL), for (durée minimale), labels.severity, annotations (message, {{ $labels.pod }} remplacé par la vraie valeur)
- États : Inactive, Pending (condition vraie, durée non atteinte), Firing
- argocd/alertes.yaml : Application qui applique tous les fichiers du dossier k8s/alertes
- `kubectl get prometheusrules -n monitoring` : vérifier que la règle existe

### Interfaces
- Prometheus : `kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090` puis http://localhost:9090/alerts
- Alertmanager : `kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager 9093:9093` puis http://localhost:9093
- Grafana : `kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d; echo` puis `kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80` (le mot de passe change à chaque réinstallation)
- Prometheus affiche toutes les règles ; Alertmanager ne reçoit que les alertes Firing
- Destinataire "null" : les alertes arrivent dans Alertmanager mais ne préviennent personne (à configurer plus tard, identifiants dans Key Vault)
- Watchdog : alerte toujours déclenchée exprès, preuve que la chaîne d'alertes fonctionne

### Fausses alertes et sourdines
- KubeDaemonSetRolloutStuck et 2 x KubePodNotReady : une seule cause, Traefik occupe le port 80 sur k3d, les pods svclb-frontend-external restent en Pending (même cause que frontend-external <pending> et l'Application boutique en Progressing)
- Tempête d'alertes : une cause, plusieurs alertes ; remonter à la cause commune (le rôle de l'agent IA)
- Sourdine 1 : `namespace="kube-system"` et `pod=~"svclb-frontend-external.*"`, 7d, commentaire justifié
- Sourdine 2 : `namespace="kube-system"` et `daemonset=~"svclb-frontend-external.*"`
- Une bonne sourdine : précise (jamais un namespace entier), limitée dans le temps, justifiée ; vérifier avec Preview Alerts
- Les conditions d'une sourdine s'additionnent (pas de "ou") : deux familles d'alertes = deux sourdines
- Les sourdines agissent sur Alertmanager, pas sur Prometheus

### Test de panne
- Limite de cartservice à 128Mi dans Git : OOMKilled (code 137), 3 redémarrages en 8 minutes
- ConteneurRedemarreEnBoucle et ConteneurTueParManqueDeMemoire en Firing ; MemoireProcheDeLaLimite reste en Pending (le conteneur meurt avant 2 minutes : limite de la règle)
- Alertes du chart en plus : KubePodNotReady et CPUThrottlingHigh (le manque de mémoire fait tourner le ramasse-miettes, donc le CPU)
- Retour à 300Mi dans Git : les alertes se résolvent
- Cycle complet : panne, détection, diagnostic, correction dans Git, résolution confirmée

### Tableau de bord Grafana (k8s/dashboards/boutique.yaml)
- Panneau 1 : `max by (pod) (container_memory_working_set_bytes{namespace="boutique", container="server", pod=~"cartservice.*"}) / 1024 / 1024` et la limite (kube_pod_container_resource_limits), légende `Consommation {{pod}}`
- Panneau 2 : `sum by (container) (increase(kube_pod_container_status_restarts_total{namespace="boutique"}[10m]))`
- Panneau 3 : `sum by (pod) (rate(container_cpu_usage_seconds_total{namespace="boutique", container!=""}[5m]))` (en cœurs)
- Panneau 4 (Stat) : `count(ALERTS{alertstate="firing", namespace="boutique"}) or vector(0)`
- `max by (pod)` : regrouper les séries (chaque redémarrage crée un nouveau label id)
- Méthode : créer dans l'interface, exporter en JSON format Classic (pas V2 resource), emballer dans un ConfigMap
- `kubectl create configmap dashboard-boutique -n monitoring --from-file=kube-doctor-boutique.json="<fichier>" --dry-run=client -o yaml > /tmp/boutique.yaml`
- `kubectl label --local -f /tmp/boutique.yaml grafana_dashboard=1 -o yaml > k8s/dashboards/boutique.yaml` (jamais rediriger vers le fichier qu'on lit : il serait vidé avant la lecture)
- `grep -n "grafana_dashboard" k8s/dashboards/boutique.yaml` : vérifier l'étiquette (metadata est à la fin du fichier, kubectl trie les champs)
- `kubectl get configmap -n monitoring -l grafana_dashboard=1` et `--show-labels` : vérifier dans le cluster
- argocd/dashboards.yaml : Application du dossier k8s/dashboards
- Supprimer le tableau de bord manuel avant (même identifiant)

### Incidents du jour
- ConfigMap sans étiquette : Grafana l'ignore sans erreur ; les étiquettes relient les objets entre eux
- Export Grafana au format v2 (apiVersion dashboard.grafana.app/v2) : non compris par le chargement par ConfigMap ; réexporter en Classic
- L'export YAML de Grafana n'est pas un objet Kubernetes utilisable ici (type Dashboard inconnu du cluster)
- Modification de boutique-values.yaml oubliée (non poussée) : toujours vérifier git status

### État du cluster
- 4 Applications : boutique, monitoring, alertes, dashboards
- Tout est décrit dans Git, sauf Argo CD lui-même (installé avec Helm)

## Jour 7 : tests de charge et montée en charge automatique

### Prérequis du HPA
- `kubectl top pods -n boutique` : le metrics-server fonctionne (installé d'office avec k3s)
- `kubectl get deployment frontend -n boutique -o jsonpath='{.spec.template.spec.containers[0].resources}'; echo` : le frontend réserve 100m de CPU (limite 200m)
- Le HPA raisonne en pourcentage de la réservation (requests) : sans réservation, pas de calcul possible
- Aucun champ replicas dans le chart pour le frontend : le HPA peut changer le nombre de copies sans qu'Argo CD le contredise

### Unités
- CPU en millicœurs : 1000m = 1 cœur, 100m = 0,1 cœur
- Mémoire en Mi (mébioctets)
- Plafond de mémoire dépassé : le conteneur est tué (OOMKilled)
- Plafond de CPU atteint : le conteneur est ralenti (throttled), pas tué

### Le HPA (k8s/autoscaling/frontend-hpa.yaml)
- Type HorizontalPodAutoscaler, apiVersion autoscaling/v2 (intégré à Kubernetes)
- scaleTargetRef : le Deployment frontend
- minReplicas 1, maxReplicas 4 (le maximum protège le cluster et le quota)
- Cible : 50 % de CPU moyen par rapport à la réservation
- behavior.scaleDown.stabilizationWindowSeconds: 60 (5 minutes par défaut) : attendre avant de retirer des copies
- Par défaut, la montée est immédiate (pas de délai) ; la descente est prudente
- argocd/autoscaling.yaml : Application du dossier k8s/autoscaling, destination namespace boutique
- `kubectl get hpa -n boutique` : TARGETS (utilisation / cible) et REPLICAS ; `<unknown>` pendant la première minute
- `kubectl get hpa -n boutique -w` : suivre en direct
- `kubectl describe hpa frontend -n boutique` : Behavior, Conditions et historique des décisions dans Events
- ScalingLimited à True : le maximum est atteint (relever le maximum ou chercher un problème)

### Test de charge avec k6
- `brew install k6` : outil en ligne de commande, scénario écrit en JavaScript
- tests/charge/boutique.js : montée à 20 visiteurs en 1 min, palier de 3 min, descente en 1 min
- thresholds : p(95) < 1000 ms et moins de 1 % d'erreurs
- Chaque visiteur : page d'accueil, page produit au hasard, vérification du code 200, pause d'une seconde
- L'adresse vient de la variable BASE_URL (`__ENV.BASE_URL`), avec une valeur par défaut
- `kubectl port-forward -n boutique svc/frontend 8081:80` : tunnel vers la boutique
- `k6 run -e BASE_URL=http://localhost:8081 tests/charge/boutique.js` : lancer le test
- Sur AKS : même scénario avec `-e BASE_URL=http://<adresse publique>`
- Limite en local : le tunnel port-forward peut devenir le goulot d'étranglement

### Résultats du test
- 8 440 requêtes en 5 minutes (28 par seconde), 0 % d'erreurs, 100 % de checks réussis
- Médiane 21 ms, moyenne 73 ms, p95 277 ms, max 1,09 s : quelques requêtes lentes tirent la moyenne vers le haut ; on regarde les centiles, pas la moyenne
- HPA : 1 → 2 → 3 copies pendant la charge, puis 3 → 2 → 1 après (jamais 4 : 3 suffisaient)
- Les requêtes lentes : pendant la montée, avant que les nouvelles copies soient prêtes (délai de réaction du HPA)
- Avertissement FailedGetScale Unauthorized : au redémarrage du cluster k3d, sans gravité

### Tableau de bord : panneau des copies
- `kube_horizontalpodautoscaler_status_desired_replicas{namespace="boutique", horizontalpodautoscaler="frontend"}` : copies voulues par le HPA
- `kube_deployment_status_replicas_available{namespace="boutique", deployment="frontend"}` : copies prêtes
- L'écart entre les deux courbes : le délai de démarrage des nouvelles copies
- Tableau de bord géré par Git : pas de Save dans Grafana ; Export as JSON (Classic), régénérer le ConfigMap, git push
- `ls -t ~/Downloads/*.json | head -1` : le fichier téléchargé le plus récent
- `head -c 200 <fichier>` : vérifier le format (ne pas commencer par "apiVersion")

### Reste à faire
- Refaire le test de charge sur AKS, avec l'adresse publique (sans le goulot du tunnel)
- Mettre en place App of Apps (une seule Application à appliquer sur un nouveau cluster)

### État du cluster
- 5 Applications : boutique, monitoring, alertes, dashboards, autoscaling
