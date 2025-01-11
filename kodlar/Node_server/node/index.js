// 1-cd ve path ile directorymizi ayarlarız
// 2-nmp init ile projemizi oluştururuz(package.json)(config file)(-y eklersek her şeye yes diyerek hızlıca oluşturur)
// 2.1- config içinde type module yaparak import kullanabiliriz(js yerine paketleri belirtmek için)
// 3-nmp i ile istediğimiz paketleri indiririz(express framework indirdik (npm i express))(ctrl+c ile exit)
// 3-1 server çalıştırırken nodemon(paketi indiririz("npm i -g" ile global)) index.js yaparsak, server kendi kendini değişlikte günceller
// 3-1 hata verirse (powershell Set-ExecutionPolicy RemoteSigned -Scope CurrentUser)
// 4-node index.js komutu ile çalıştırırız
// 5-autocomplete çalışması için bunu yüklüyoruz (npm install --save-dev @types/node)
// başka bi yerden node dosyaları alırsak
// npm install yazarak gerekli öğeleri indirebiliriz

// API'nin KENDİSİ

//Aynı ağ üserine bağlı olursa çalışması için şartlar
//- firewalldan tüm node dosylarına özel ve genel ağlara izin verilecek
//- kurallardan gelen kısmına kullanılan portlar girilecek

import express from "express";
import bodyParser from "body-parser";
import pg from "pg";
import { Server } from 'socket.io';
import cors from 'cors';
import OpenAI from 'openai';


const app = express();
const port = 3000;
const hostname = "localhost";
// wifi const hostname = "192.168.1.188";

// Socket.IO, HTTP sunucusu ile çalışır, bu nedenle Express ile kurduğumuz sunucuya socket.io entegre ediliyor.
const server = app.listen(port, hostname, () => {
    console.log(`API is running at http://${hostname}:${port}`);
});
// new Server(server) ile Socket.IO’yu başlattınız ve HTTP sunucusuna bağladık
const io = new Server(server);

// database
const db = new pg.Client({
    user: "postgres",
    host: "localhost",
    database: "data-server",
    password: "msaz1216",
    port: 5432,
});
db.connect();

// Middleware
// middleware(siteden gelen bilgilere erişmemizi sağlar)
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());

// Sunucuya bir istemci bağlandığında(flutter) bu olay tetiklenir. socket, bağlanan istemciyi temsil eder.
// Bu bölüm, istemcinin sunucuya bağlandığında tüm verileri almasını sağlar. Bağlantı sona erdiğinde ise "user disconnected" yazılır.
io.on('connection', async (socket) => {
    console.log('A user connected');

    try {
        // Veritabanındaki tüm verileri al ve yeni bağlanan kullanıcıya gönder
        const result = await db.query("SELECT * FROM sensor_data ORDER BY id ASC");
        let allData = result.rows;
        // Sunucu, veritabanından aldığı tüm verileri initial_data adında bir olayla bağlı olan istemcilere (Flutter'a ve web) gönderir.
        // io bağlı olan tüm kullancılara, socket (bağlı olan kullanıcılara spesifik)
        // kullancıılar bağlandığında onlara özel socket id atanır
        socket.emit('initial_data', allData);

        // İstemci bağlantısını kestiğinde bu olay tetiklenir ve sunucu bunu loglar.
        socket.on('disconnect', () => {
            console.log('User disconnected');
        });
    } catch (error) {
        console.error("Error fetching data on connection:", error);
    }
});


// show data on screen
app.get("/", (req, res) => {
    // console.log(data);
    res.send(`<p>Use /api to get the data</p><p>Use /data to post the data</p>`);
});

// GET all data
app.get("/api", async (req, res) => {
    try {
        const result = await db.query("SELECT * FROM sensor_data ORDER BY id ASC");
        let items = result.rows;
        console.log("data gönderildi");
        res.json(items);
    } catch (error) {
        console.log(error);
    }

});

// POST a new post
// Post yağıldığı anda gerekli yerlere socket ile emit yapılır
app.post("/data", async (req, res) => {
    const {
        device1: { deviceId: device1_deviceId, current: device1_current, power: device1_power },
        device2: { deviceId: device2_deviceId, current: device2_current, power: device2_power },
    } = req.body;

    try {
        const insertResult = await db.query(
            "INSERT INTO sensor_data (device1_deviceId, device1_current, device1_power, device2_deviceId, device2_current, device2_power, timestamp) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *",
            [device1_deviceId, device1_current, device1_power, device2_deviceId, device2_current, device2_power, new Date().toLocaleString('en-US', { timeZone: 'Europe/Istanbul' })
            ]
        );
        
        const insertedData = insertResult.rows[0];
        console.log("Data inserted into the database");

        // Yeni veriyi tüm bağlı kullanıcılara emit et
        io.emit('new_data', insertedData);

        // API post yapanın çağrısına cevap ver
        res.status(201).json(insertedData);
    } catch (err) {
        console.log(err);
        res.status(500).send("Error inserting data");
    }
});

app.get("/data", (req, res) => {
    res.send(`<p> Use in your app to post data to database</p>`);
});

app.post("/reset", async (req, res) => {
    try {
        // current_data tablosunu truncate ediyoruz
        await db.query("TRUNCATE TABLE sensor_data RESTART IDENTITY");
        const resetData = []
        io.emit('initial_data', resetData);
        console.log("Table truncated successfully");

        // API post yapanın çağrısına cevap veriyoruz
        res.status(200).send("Table truncated successfully");
    } catch (err) {
        console.log(err);
        res.status(500).send("Error truncating table");
    }
});
app.get("/reset", (req, res) => {
    res.send(`<p> Use in your app to reset all data in your database</p>`);
});

const openai = new OpenAI({
    apiKey: "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"
});

app.post('/ai', async (req, res) => {

    try {

        const result = await db.query("SELECT * FROM sensor_data ORDER BY id ASC");
        let items = result.rows;
        console.log("data gönderildi");

        const { message } = req.body; // Get user message from request body
        const chatCompletion = await openai.chat.completions.create({
            model: 'gpt-3.5-turbo',
            //In the first case, the items array is converted to a string, but it results in [object Object],[object Object], which is not useful for the AI. In the second case, 
            //using JSON.stringify provides a clear string representation of the array, allowing the AI to process and understand the input correctly.
            messages: [{ role: 'system', content: "Based on the collected current and power consumption data, answer user questions related to current, voltage, power, and energy usage. Provide fixed, straightforward information to make it easy for the user to understand. Focus on informative, clear, and concise responses: " + JSON.stringify(items) }, { role: 'user', content: message }],
        });
        console.log(chatCompletion);
        const aiMessage = chatCompletion.choices[0]?.message.content;
        res.json({ response: aiMessage });
    } catch (error) {
        console.error('backend:', error);
        res.status(500).send('backend error');
    }
});





