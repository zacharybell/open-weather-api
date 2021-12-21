import axios from 'axios';

const openApiClient = axios.create({
  baseURL: 'https://api.openweathermap.org/data/2.5',
  params: {
    appid: process.env.OPEN_WEATHER_API_KEY,
  },
});

export async function getOneCall(params: any) {
  return openApiClient.get('/onecall', { params });
}
