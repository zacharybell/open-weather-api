import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { getOneCall } from './service/open-weather';

exports.handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const response = await getOneCall(event.queryStringParameters);

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(response.data),
  };
};
