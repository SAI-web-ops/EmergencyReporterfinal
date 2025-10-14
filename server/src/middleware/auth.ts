import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export type Roles = 'citizen' | 'dispatcher' | 'responder';

declare global {
  namespace Express {
    interface Request {
      user?: { sub: string; role: Roles };
    }
  }
}

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const h = req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : '';
  if (!token) return res.status(401).json({ error: 'unauthorized' });
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET || 'dev-secret') as any;
    req.user = { sub: payload.sub, role: payload.role };
    return next();
  } catch {
    return res.status(401).json({ error: 'unauthorized' });
  }
}

export function requireRole(...roles: Roles[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = req.user;
    if (!user || !user.role || !roles.includes(user.role)) {
      return res.status(403).json({ error: 'forbidden' });
    }
    next();
  };
}


