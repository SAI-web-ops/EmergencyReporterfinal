import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';
import db from './database/index.js';
import incidentsRouter from './routes/incidents.js';
import pointsRouter from './routes/points.js';
import uploadsRouter from './routes/uploads.js';
import alertsRouter from './routes/alerts.js';
import authRouter from './routes/auth.js';
import notificationsRouter from './routes/notifications.js';
import chatRouter, { registerChatSocket } from './routes/chat.js';
import http from 'http';
import { Server as SocketIOServer } from 'socket.io';

dotenv.config();

const app = express();
const httpServer = http.createServer(app);
const io = new SocketIOServer(httpServer, { cors: { origin: (process.env.CORS_ORIGIN || '*').split(',') } });
app.set('io', io);
registerChatSocket(io);

app.use(express.json({ limit: '50mb' }));
app.use(cors({ origin: (process.env.CORS_ORIGIN || '*').split(',') }));

// Static serving for encrypted uploaded files
const uploadsPath = path.resolve(process.cwd(), 'uploads');
// Ensure required directories exist (uploads and data)
const dataDir = path.resolve(process.cwd(), 'data');
for (const dir of [uploadsPath, path.join(uploadsPath, 'enc'), path.join(uploadsPath, 'backups'), dataDir]) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}
app.use('/uploads/enc', express.static(path.join(uploadsPath, 'enc')));

// Simple static dashboard
const publicPath = path.resolve(process.cwd(), 'public');
app.use('/', express.static(publicPath));

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

app.use('/auth', authRouter);
app.use('/incidents', incidentsRouter);
app.use('/points', pointsRouter);
app.use('/uploads', uploadsRouter);
app.use('/alerts', alertsRouter);
app.use('/notifications', notificationsRouter);
app.use('/chat', chatRouter);

const port = process.env.PORT ? Number(process.env.PORT) : 4000;
httpServer.listen(port, () => {
  console.log(`[server] listening on port ${port}`);
});
