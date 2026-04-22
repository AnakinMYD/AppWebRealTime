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
express   : Framework web pour gérer les routes API (GET/POST)
socket.io : Communication temps réel Full-Duplex
dotenv    : Gestion des variables d'environnement (API_KEY)

# Création Clé SSH et certificat SSL/TLS 
mkdir keys
cd keys
openssl req -new -x509 -key private-key.pem -out cert.pem -days 365

# Clé API avec variables d'environnement
echo "API_KEY=AbbéGrégoire_92i" > .env
```
---

---

## ⚙️ Fonctionnement et Flux de Données

### 🔄 Collection et Transfert
La donnée suit un cycle de vie automatisé pour garantir une surveillance précise :
* **Extraction** : L'agent `agent.sh` isole les métriques système via des commandes natives Linux (`df`, `sar`, `inxi`).
* **Formatage** : Les variables sont encapsulées dans un objet JSON structuré grâce à l'outil **jq**.
* **Expédition** : Les métriques sont envoyées au serveur Node.js via une requête `POST` (protocole HTTPS) toutes les secondes.

### 🔑 Validation du Dashboard (Handshake)
La sécurité de l'accès visuel est assurée au niveau du client :
* **Vérification API** : Au chargement de la page de monitoring, une fonction asynchrone `GetData()` effectue une requête `fetch` vers le serveur.
* **Header de sécurité** : Elle transmet la clé API via le header `api-key`. Si le serveur valide la clé, l'accès aux données et la connexion **Socket.io** sont autorisés.

### 🔗 Liaison entre les fichiers
Le projet est architecturé de manière modulaire :
* **`serveur.js`** : Cœur de l'application, il réceptionne le flux JSON envoyé par l'agent et le diffuse instantanément ("broadcast") vers les sockets connectés.
* **`dashboard.html`** : Écoute les événements Socket et injecte dynamiquement les valeurs dans les balises HTML via leurs identifiants (`id`).
* **`style.css`** : Gère l'aspect visuel et l'UX, incluant le passage automatique des barres de progression au **rouge** dès que le seuil de surcharge (**80%**) est atteint.

---

## 🔒 Sécurité et Confidentialité
Pour respecter les standards de développement professionnels, les fichiers sensibles suivants sont exclus du dépôt via le `.gitignore` :
* Le fichier **`.env`** (Secret API utilisé par le serveur).
* Le répertoire **`keys/`** (Certificats SSL et Clés privées).
* Le dossier **`node_modules/`** (Dépendances).

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
