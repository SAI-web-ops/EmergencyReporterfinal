import { Router } from 'express';
import { z } from 'zod';

const router = Router();

const panicSchema = z.object({
  latitude: z.number(),
  longitude: z.number(),
  address: z.string().optional(),
  triggeredAt: z.string().optional(),
});

// Simple in-memory log of panic alerts
const panicLog: any[] = [];

router.post('/panic', (req, res) => {
  const parsed = panicSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }
  const alert = {
    id: Date.now().toString(),
    ...parsed.data,
    triggeredAt: parsed.data.triggeredAt || new Date().toISOString(),
  };
  panicLog.unshift(alert);

  // TODO: Integrate with SMS/email/push, dispatcher console, etc.

  res.status(201).json({ data: alert });
});

router.get('/panic', (_req, res) => {
  res.json({ data: panicLog });
});

export default router;


