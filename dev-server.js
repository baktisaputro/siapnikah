require('dotenv').config();
const path = require('path');
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve berkas statis dari folder proyek
app.use(express.static(path.join(__dirname)));

app.listen(PORT, () => {
    console.log(`LMS Nikah berjalan di http://localhost:${PORT}`);
});
