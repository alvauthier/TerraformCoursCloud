# Projet Terraform

## Configuration initiale

1. Remplissez le fichier `terraform.tfvars` avec le nom d'utilisateur de votre choix et le mot de passe. Votre mot de passe doit respecter les conditions choisies par Azure, à savoir qu'il doit avoir 12 caractères minimum, au moins 1 majuscule, 1 minuscule et 1 chiffre. Ils seront utilisés comme nom d'utilisateur pour la machine virtuelle et comme mot de passe pour vous y connecter.

2. Exécutez la commande `terraform init` à la racine du projet.

3. Exécutez ensuite un `terraform plan` toujours à la racine.

4. Exécutez un `terraform apply`, vérifiez les modifications qui seront apportées et les accepter.

L'adresse IP de la machine s'affichera dans le terminal. Vous pourrez accéder ensuite au site depuis votre navigateur.

## Variables d'environnement

Dans les fichiers `.env`, `back.env` et `front.env`, des variables d'environnement seront ajoutées par Terraform. Cela permet d'ajouter correctement l'adresse IP dont on a besoin dans ces fichiers, adresse générée automatiquement et donc ajoutée automatiquement.

Si vous souhaitez relancer le `apply` de Terraform, pour n'importe quelle raison, il faudra donc supprimer les variables de ces fichiers.

Pour `back.env`, il faut supprimer `DOMAIN_NAME`, `URL` et `URL_SITE_CLIENT`.
Pour `front.env`, il faut supprimer `VITE_URL`, `VITE_DOMAIN_NAME` et `VITE_URL_SITE_CLIENT`.

## Note importante

Pour s'assurer du bon fonctionnement du programme, pour que celui-ci ajoute à coup sûr correctement les variables d'environnement, merci de bien laisser quelques lignes vides sous les variables qui ne sont pas à supprimer.