# PF-Ocaml - Virtual Filesystem

## Description du Projet

**PF-Ocaml** est un système de fichiers virtuel implémenté en **OCaml**. Ce projet académique simule un système de fichiers en mémoire avec une interface REPL (Read-Eval-Print Loop) interactive en ligne de commande. 

### Objectif
L'objectif de ce projet est de :
- Implémenter une structure de données représentant un arborescence de fichiers et répertoires
- Développer une interface utilisateur interactive permettant de naviguer et manipuler le système de fichiers
- Mettre en pratique les concepts de programmation fonctionnelle en OCaml (récursivité, types algébriques, immuabilité)

### Fonctionnalités Principales
- ✅ Système de fichiers hiérarchique avec répertoires et fichiers
- ✅ Navigation interactive via REPL
- ✅ Structure de données mutuellement récursive pour représenter l'arborescence
- ✅ Gestion des chemins (path) et noms de fichiers

---

## Structure du Projet

```
Projet_DJEUTCHEU_DEGBOEVI/
├── main.ml              # Point d'entrée principal du programme
├── filesystem.ml        # Implémentation du système de fichiers
├── filesystem.mli       # Interface/signature du module filesystem
├── repl.ml              # Boucle interactive (Read-Eval-Print Loop)
├── commands.ml          # Implémentation des commandes disponibles
├── dune                 # Configuration de build dune
├── dune-project         # Configuration du projet dune
└── _build/              # Répertoire de build (généré automatiquement)
    └── default/         # Artefacts compilés
```

### Description des Modules

| Fichier | Description |
|---------|-------------|
| `filesystem.mli` | Définit les types et l'interface publique : `name`, `path`, `file`, `directory`, `filesystem` |
| `filesystem.ml` | Implémente la logique du système de fichiers et les fonctions utilitaires |
| `repl.ml` | Gère la boucle interactive, affiche le prompt et traite les entrées utilisateur |
| `commands.ml` | Contient les implémentations des commandes disponibles (ex: fonction `existe`) |
| `main.ml` | Point d'entrée qui initialise le système de fichiers et lance la REPL |

---

## Installation et Configuration

### Prérequis
- **OCaml** (version 4.14 ou supérieure)
- **Dune** (système de build pour OCaml)
- Un terminal compatible (PowerShell, Bash, etc.)

### Installation

1. Clonez le repository :
```bash
git clone https://gitlab.univ-nantes.fr/E25D505L/pf-ocaml.git
cd pf-ocaml
```

2. Naviguez dans le répertoire du projet :
```bash
cd Projet_DJEUTCHEU_DEGBOEVI
```

3. Compilez le projet avec Dune :
```bash
dune build
```

---

## Utilisation

### Lancer le programme

```bash
dune exec ./main.exe
```

Vous verrez apparaître un prompt interactif :
```
/> 
```

### Commandes Disponibles

Une fois dans la REPL, vous pouvez utiliser les commandes suivantes :

- **`quit` ou `exit`** : Quitter le programme
- *D'autres commandes à implémenter selon les spécifications du projet*

### Exemple d'Utilisation

```bash
$ dune exec ./main.exe
/> exit
Exit
```

---

## Commandes Git Essentielles

### Configuration initiale
```bash
# Configurer votre identité Git (si ce n'est pas déjà fait)
git config --global user.name "Votre Nom"
git config --global user.email "votre.email@example.com"
```

### Clonage et synchronisation
```bash
# Cloner le repository
git clone https://gitlab.univ-nantes.fr/E25D505L/pf-ocaml.git

# Récupérer les dernières modifications du serveur
git fetch origin

# Fusionner les modifications (depuis origin/main)
git pull origin main

# Mettre à jour vers la branche main et récupérer les changements
git checkout main
git pull
```

### Gestion des branches
```bash
# Créer une nouvelle branche pour vos modifications
git checkout -b nom-de-la-branche

# Lister les branches locales
git branch

# Lister toutes les branches (locales + distantes)
git branch -a

# Basculer vers une autre branche
git checkout nom-de-la-branche

# Supprimer une branche locale
git branch -d nom-de-la-branche
```

### Validation des modifications
```bash
# Voir le statut des fichiers modifiés
git status

# Ajouter des fichiers au staging
git add nom-du-fichier
git add .                    # Ajouter tous les fichiers

# Vérifier les différences avant de valider
git diff                     # Changements non stagés
git diff --staged            # Changements stagés

# Valider avec un message descriptif
git commit -m "Description des changements"

# Valider en modifiant le message (si oubli)
git commit --amend
```

### Envoi et récupération
```bash
# Envoyer vos modifications vers le serveur
git push origin nom-de-la-branche

# Envoyer vers la branche main (après avoir basculé dessus)
git push origin main

# Forcer l'envoi (à utiliser avec prudence)
git push -uf origin main

# Récupérer et fusionner automatiquement
git pull origin main
```

### Fusion (Merge) et Requêtes de fusion
```bash
# Fusionner une branche dans la branche courante
git merge nom-de-la-branche

# Annuler une fusion en cas de conflit
git merge --abort

# Résoudre les conflits manuellement, puis :
git add .
git commit -m "Résolution des conflits"
```

### Historique et consultation
```bash
# Voir l'historique des commits
git log

# Voir l'historique de manière compacte
git log --oneline

# Voir les changements d'un commit spécifique
git show <hash-du-commit>

# Voir qui a modifié chaque ligne d'un fichier
git blame nom-du-fichier
```

### Annulation de modifications
```bash
# Annuler les modifications d'un fichier non stagé
git checkout -- nom-du-fichier

# Retirer un fichier du staging
git reset HEAD nom-du-fichier

# Annuler le dernier commit (garder les modifications)
git reset --soft HEAD~1

# Annuler le dernier commit (perdre les modifications)
git reset --hard HEAD~1
```

### Workflow typique pour ce projet GitLab

```bash
# 1. Mettre à jour votre branche locale
git pull origin main

# 2. Créer une branche pour votre fonctionnalité
git checkout -b feature/nom-de-la-feature

# 3. Faire vos modifications
# ... éditer les fichiers ...

# 4. Valider vos changements
git add .
git commit -m "Ajout de la fonctionnalité XYZ"

# 5. Envoyer votre branche
git push origin feature/nom-de-la-feature

# 6. Créer une merge request (Pull Request) sur GitLab
#    -> Via l'interface web du projet

# 7. Une fois fusionné, récupérer les changements
git checkout main
git pull origin main
```

---

## Auteurs

- DJEUTCHEU
- DEGBOEVI

## Licence

Projet académique - Université de Nantes
