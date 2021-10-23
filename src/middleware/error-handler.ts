import { Request, Response, NextFunction } from 'express';
import { AxiosError } from 'axios';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if ("isAxiosError" in err) {
    const axiosError = err as AxiosError;
    return res.status(axiosError.response?.status || 500).send();
  }

  return res.status(500).send();
};