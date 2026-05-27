import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as express from 'express';
import * as path from 'path';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api');

  app.enableCors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  });

  app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

  await app.listen(3000);
  console.log('Backend running at http://localhost:3000/api');
}

bootstrap();