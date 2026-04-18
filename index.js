import express from 'express';
import {createServer} from 'node:http';
import {Server} from 'socket.io';
import dotenv from 'dotenv';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { time } from 'node:console';


dotenv.config(); // charge le fichier .env à la racine
const __dirname = dirname(fileURLToPath(import.meta.url));

const app = express();
const server = createServer(app,);
const io = new Server(server);

app.use(express.json())

const api_key = process.env.API_KEY;

app.get('/', (req,res,next) => {
  const key = req.headers["api-key"];

  if(api_key===key){
    res.status(200).json({ message: "Clé valide, accès autorisé !" });
    next()
  }
  else{
    res.status(403).json({ error: "Clé API invalide" });
  }

})

io.on("connection", (socket) => {
  console.log("Un client est connecté :", socket.id);
});


app.get('/style.css', (req,res) => {
  res.sendFile(join(__dirname + '/style.css'))
})

app.get('/myd.png', (req,res) => {
  res.sendFile(join(__dirname + '/myd.png'))
})
app.get('/monitoring', (req, res) => {
  res.sendFile(join(__dirname + '/dashboard.html'));

  
});




app.post('/', (req,res) => {
   
    const data = req.body
    console.log(data)
    io.emit("espace_total", data.HDD.espace_total);
    io.emit("espace_libre", data.HDD.espace_libre);
    io.emit("espace_utiliser", data.HDD.espace_utiliser);
    io.emit("pourcentage_disk", data.HDD.pourentage_disk);
    io.emit("pourcentage_cpu", data.CPU.pourcentage_cpu);
    io.emit("modele", data.CPU.modele);
    io.emit("frequence", data.CPU.frequence);
    io.emit("ram_total", data.RAM.ram_total);
    io.emit("type", data.RAM.type);
    io.emit("ram_percent", data.RAM.ram_percent);
    io.emit("uptime", data.TIME.uptime);
    io.emit("boot-time", data.TIME.boot_time);
    res.status(200).json({status : "ok"});
})

server.listen(3000, () => {
    console.log("server en marche à l'adresse http://localhost:3000")
})