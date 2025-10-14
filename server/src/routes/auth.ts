import { Router } from 'express';
import { z } from 'zod';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import db from '../database/index.js';

const router = Router();

const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  role: z.enum(['citizen', 'dispatcher', 'responder']).optional().default('citizen'),
  name: z.string().optional(),
  phone: z.string().optional(),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

function signAccessToken(user: any) {
  const secret = process.env.JWT_SECRET || 'dev-secret';
  return jwt.sign({ sub: user.id, role: user.role }, secret, { expiresIn: '15m' });
}

function signRefreshToken(user: any) {
  const secret = process.env.JWT_REFRESH_SECRET || 'dev-refresh';
  return jwt.sign({ sub: user.id }, secret, { expiresIn: '7d' });
}

router.post('/signup', async (req, res) => {
  const parsed = signupSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  
  const { email, password, role, name, phone } = parsed.data;
  
  // Check if user exists
  const existingUser = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
  if (existingUser) {
    return res.status(400).json({ error: 'email_exists' });
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const userId = `user-${Date.now()}-${Math.random().toString(36).slice(2)}`;
  
  try {
    db.prepare(`
      INSERT INTO users (id, email, password_hash, role, name, phone)
      VALUES (?, ?, ?, ?, ?, ?)
    `).run(userId, email, passwordHash, role, name || '', phone || '');
    
    const user = { id: userId, email, role, name, phone };
    const accessToken = signAccessToken(user);
    const refreshToken = signRefreshToken(user);
    
    res.status(201).json({ 
      data: { 
        user: { id: user.id, email: user.email, role: user.role, name: user.name, phone: user.phone }, 
        accessToken, 
        refreshToken 
      } 
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ error: 'signup_failed' });
  }
});

router.post('/login', async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  
  const { email, password } = parsed.data;
  
  const user = db.prepare('SELECT * FROM users WHERE email = ? AND is_active = 1').get(email) as any;
  if (!user) {
    return res.status(401).json({ error: 'invalid_credentials' });
  }
  
  const isValidPassword = await bcrypt.compare(password, user.password_hash);
  if (!isValidPassword) {
    return res.status(401).json({ error: 'invalid_credentials' });
  }
  
  // Update last login
  db.prepare('UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?').run(user.id);
  
  const accessToken = signAccessToken(user);
  const refreshToken = signRefreshToken(user);
  
  res.json({ 
    data: { 
      user: { id: user.id, email: user.email, role: user.role, name: user.name, phone: user.phone }, 
      accessToken, 
      refreshToken 
    } 
  });
});

router.post('/refresh', (req, res) => {
  const token = (req.body?.refreshToken as string | undefined) || '';
  if (!token) return res.status(400).json({ error: 'refresh_token_required' });
  
  try {
    const payload = jwt.verify(token, process.env.JWT_REFRESH_SECRET || 'dev-refresh') as any;
    const user = db.prepare('SELECT * FROM users WHERE id = ? AND is_active = 1').get(payload.sub) as any;
    
    if (!user) return res.status(401).json({ error: 'invalid_token' });
    
    const accessToken = signAccessToken(user);
    res.json({ data: { accessToken } });
  } catch {
    return res.status(401).json({ error: 'invalid_token' });
  }
});

export type JwtUser = { sub: string; role: string };
export default router;


