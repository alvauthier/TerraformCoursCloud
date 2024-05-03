Projet Terraform

Remplir le fichier terraform.tfvars avec le nom d'utilisateur de votre choix et mot de passe.
Votre mot de passe doit respecter les conditions choisies par Azzure, à savoir qu'il doit avoir 12 caractères minimum, au moins 1 majusucule, 1 minuscule et 1 chiffre.
Ils seront utilisés comme nom d'utilisateur pour la machine virtuelle et comme mot de passe pour vous y connecter.

Faire la commande terraform init à la racine du projet.

Faire ensuite un terraform plan toujours à la racine.

Faire un terraform apply, vérifier les modifications qui seront apportées et les accepter.

L'adresse IP de la machine s'affichera dans le terminal. Vous pourrez accéder ensuite au site depuis votre navigateur.


Dans les 2 fichiers .env, back.env et front.env, des variables d'environnements seront rajoutés par Terraform.
En effet, c'est pour permettre d'ajouter correctement l'adresse IP dont on a besoin dans ces fichiers, adresse générée automatiquement et donc ajoutée automatiquement.

Si vous souhaitez relancer le apply de Terraform, pour n'importe quelle raison, il faudra donc supprimer les variables de ces fichiers.

Pour back.env, il faut supprimer DOMAIN_NAME, URL et URL_SITE_CLIENT.
Pour front.env, il faut supprimer VITE_URL, VITE_DOMAIN_NAME et VITE_URL_SITE_CLIENT.

Pour s'assurer du bon fonctionnement du programme, pour que celui-ci ajoute à coup sûr correctement les variables, merci de bien laisser quelques lignes vides sous les variables d'environnements qui ne sont pas à supprimer.

