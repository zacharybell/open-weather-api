require('dotenv').config();

import express from 'express';
import { getOneCall } from './service/open-weather';

const app = express();

app.get('/weather', async (req, res, next) => {
    try {
        const weather = await getOneCall(req.query);
        res.send(weather.data);
    } catch (error) {
        next(error);
    }
});

app.listen(9000, () => {
    console.log('start');
});