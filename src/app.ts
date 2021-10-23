require('dotenv').config();
require('express-async-errors');

import express from 'express';
import rateLimit from 'express-rate-limit';
import apicache from 'apicache';

import { errorHandler } from './middleware/error-handler';
import { getOneCall } from './service/open-weather';

const app = express();
const PORT = 9000;

app.set('trust proxy', true);
app.set('x-powered-by', false);

// caching
const cache = apicache.middleware;
app.use(cache('5 minutes'));

// rate limiting
const limiter = rateLimit({
    message: undefined,
    windowMs: 10 * 60 * 1000, // 10 Mins
    max: 20
});
app.use(limiter);

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