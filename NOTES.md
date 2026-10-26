
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
