require('dotenv').config();
require('express-async-errors');

import express from 'express';
import { errorHandler } from './middleware/error-handler';
import { getOneCall } from './service/open-weather';

const app = express();
const PORT = 9000;

app.get('/weather', async (req, res) => {
    const weather = await getOneCall(req.query);
    res.send(weather.data);
});

app.all('*', function(req, res){
    res.status(404).send();
});

app.use(errorHandler);

app.listen(PORT, () => {
    console.log(`Listening at port ${PORT}`);
});