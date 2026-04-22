# 🖥️ Live Monitoring Dashboard - Architecture DevOps

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Express](https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white)
![API](https://img.shields.io/badge/API-REST-red?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-HTTPS_&_API_KEY-green?style=for-the-badge&logo=google-cloud)
![Real-Time](https://img.shields.io/badge/Real--Time-Socket.io-black?style=for-the-badge&logo=socketdotio)

---

## 📌 Présentation du Projet
Réalisé dans le cadre d'un projet étudiant, ce dashboard de monitoring système en temps réel permet de surveiller les ressources d'une machine (CPU, RAM, Disque). L'objectif est de mettre en œuvre un flux de données complet et sécurisé entre un agent collecteur et une interface web dynamique.

## 🏗️ Architecture du Système
L'application repose sur un modèle **Agent / Serveur / Client** :
* **L'Agent (Bash)** : Collecte les métriques système et les transmet en JSON via `POST`.
* **Le Serveur (Node.js)** : Centralise les données sous HTTPS, valide les accès via API Key et diffuse les métriques.
* **Le Client (Web)** : Affiche les données en temps réel sans rafraîchissement grâce aux WebSockets.

---

## 🚀 Configuration de l'environnement NodeJS

### 1. Préparation du système et Sécurité
Avant de commencer, assurez-vous que les outils de collecte de données sont installés sur votre machine Linux :
```bash
# Mise à jour des dépôts système
sudo apt update

# Installation de Node.js et du gestionnaire de paquets NPM
sudo apt install nodejs npm -y

# Vérification de l'installation (important pour les logs de projet)
node -v
npm -v

# Installation groupée des dépendances principales
npm install express socket.io dotenv

# Détail des modules installés :
- express   : Framework web pour gérer les routes API (GET/POST)
- socket.io : Communication temps réel Full-Duplex
- dotenv    : Gestion des variables d'environnement (API_KEY)

# Création Clé SSH et certificat SSL/TLS 
- mkdir keys
- cd keys
- openssl req -new -x509 -key private-key.pem -out cert.pem -days 365

# Clé API avec variables d'environnement

- echo "API_KEY=AbbéGrégoire_92i" > .env
```
---

---

## ⚙️ Fonctionnement et Flux de Données

### 🔄 Collection et Transfert
* **Extraction** : L'agent `agent.sh` isole les métriques via des outils comme `inxi`, `lscpu` (pour la fréquence CPU) et `sar`.
* **Formatage** : Les variables sont encapsulées dans un objet JSON structuré via **jq**.
* **Expédition** : Les données sont envoyées au serveur via une requête `POST` sécurisée par **curl** toutes les secondes.

### 🔑 Validation du Dashboard (Handshake)
* **Vérification API** : Au chargement de la page, une fonction `fetch` asynchrone envoie la clé API dans les headers (`api-key`).
* **Autorisation** : Le serveur compare cette clé avec le fichier `.env`. Si elle est valide, il autorise l'ouverture de la connexion WebSocket.

### 📡 Focus Technique : Socket.io (Temps Réel)
L'interactivité repose sur une communication **Full-Duplex** :
* **Serveur** : Agit comme un "Hub". Dès qu'une donnée arrive en `POST`, il la diffuse immédiatement (**Broadcast**) via `io.emit()`.
* **Client** : Reste en écoute constante. À chaque réception d'événement, il injecte les données dans le DOM (ID HTML) et met à jour les barres de progression dynamiquement via `style.css` (alerte rouge si > 80%).

---

## 🔒 Confidentialité (Git)
Les fichiers sensibles suivants sont exclus du dépôt via le `.gitignore` :
* Le fichier **`.env`** (Secret API).
* Le répertoire **`keys/`** (Certificats et Clés privées).
* Le dossier **`node_modules/`**.

---

## ⚡ Lancement du projet

1.  **Démarrer le serveur Node.js :**
    ```bash
    node serveur.js
    ```

2.  **Lancer l'agent de collecte :**
    ```bash
    chmod +x agent.sh
    ./agent.sh
    ```

**Accès sécurisé :** `https://localhost:3000/monitoring`
