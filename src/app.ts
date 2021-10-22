import express from 'express';

const app = express();

app.get('/openweather', (req, res) => {
    res.send('HELLO WORLD');
});

app.listen(9000, () => {
    console.log('start');
});