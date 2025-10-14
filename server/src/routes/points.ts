import { Router } from 'express';
import { z } from 'zod';
import { requireAuth } from '../middleware/auth.js';
import db from '../database/index.js';

const router = Router();

const addSchema = z.object({
  points: z.number().int().positive(),
  description: z.string().min(1),
  type: z.enum(['earned', 'redeemed', 'bonus', 'penalty']).optional().default('earned'),
});

router.get('/', requireAuth, (req, res) => {
  const userId = req.user!.sub;
  
  // Get user's total points
  const totalResult = db.prepare(`
    SELECT COALESCE(SUM(points), 0) as totalPoints 
    FROM points_transactions 
    WHERE user_id = ?
  `).get(userId) as { totalPoints: number };
  
  // Get transaction history
  const transactions = db.prepare(`
    SELECT pt.*, i.title as incident_title
    FROM points_transactions pt
    LEFT JOIN incidents i ON pt.incident_id = i.id
    WHERE pt.user_id = ?
    ORDER BY pt.created_at DESC
    LIMIT 50
  `).all(userId);
  
  res.json({ 
    data: { 
      totalPoints: totalResult.totalPoints, 
      transactions 
    } 
  });
});

router.post('/add', requireAuth, (req, res) => {
  const parsed = addSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });
  
  const { points, description, type } = parsed.data;
  const userId = req.user!.sub;
  
  try {
    const transactionId = `tx-${Date.now()}-${Math.random().toString(36).slice(2)}`;
    
    db.prepare(`
      INSERT INTO points_transactions (id, user_id, points, description, type)
      VALUES (?, ?, ?, ?, ?)
    `).run(transactionId, userId, points, description, type);
    
    // Get updated total
    const totalResult = db.prepare(`
      SELECT COALESCE(SUM(points), 0) as totalPoints 
      FROM points_transactions 
      WHERE user_id = ?
    `).get(userId) as { totalPoints: number };
    
    const transaction = {
      id: transactionId,
      points,
      description,
      type,
      timestamp: new Date().toISOString(),
    };
    
    res.status(201).json({ 
      data: { 
        totalPoints: totalResult.totalPoints, 
        transaction 
      } 
    });
  } catch (error) {
    console.error('Error adding points:', error);
    res.status(500).json({ error: 'points_add_failed' });
  }
});

router.post('/redeem', requireAuth, (req, res) => {
  const { points, description } = req.body as { points?: number; description?: string };
  const userId = req.user!.sub;
  
  if (!points || points <= 0) {
    return res.status(400).json({ error: 'invalid_points_amount' });
  }
  
  if (!description) {
    return res.status(400).json({ error: 'description_required' });
  }
  
  try {
    // Check if user has enough points
    const totalResult = db.prepare(`
      SELECT COALESCE(SUM(points), 0) as totalPoints 
      FROM points_transactions 
      WHERE user_id = ?
    `).get(userId) as { totalPoints: number };
    
    if (totalResult.totalPoints < points) {
      return res.status(400).json({ error: 'insufficient_points' });
    }
    
    const transactionId = `tx-${Date.now()}-${Math.random().toString(36).slice(2)}`;
    
    db.prepare(`
      INSERT INTO points_transactions (id, user_id, points, description, type)
      VALUES (?, ?, ?, ?, ?)
    `).run(transactionId, userId, -points, description, 'redeemed');
    
    // Get updated total
    const newTotalResult = db.prepare(`
      SELECT COALESCE(SUM(points), 0) as totalPoints 
      FROM points_transactions 
      WHERE user_id = ?
    `).get(userId) as { totalPoints: number };
    
    const transaction = {
      id: transactionId,
      points: -points,
      description,
      type: 'redeemed',
      timestamp: new Date().toISOString(),
    };
    
    res.status(201).json({ 
      data: { 
        totalPoints: newTotalResult.totalPoints, 
        transaction 
      } 
    });
  } catch (error) {
    console.error('Error redeeming points:', error);
    res.status(500).json({ error: 'points_redeem_failed' });
  }
});

// Get available rewards catalog
router.get('/rewards', requireAuth, (_req, res) => {
  const rewards = db.prepare(`
    SELECT * FROM rewards_catalog 
    WHERE is_active = 1 
    ORDER BY points_required ASC
  `).all();
  
  res.json({ data: rewards });
});

// Redeem a specific reward
router.post('/rewards/:rewardId/redeem', requireAuth, (req, res) => {
  const { rewardId } = req.params;
  const userId = req.user!.sub;
  
  try {
    // Get reward details
    const reward = db.prepare(`
      SELECT * FROM rewards_catalog 
      WHERE id = ? AND is_active = 1
    `).get(rewardId) as any;
    
    if (!reward) {
      return res.status(404).json({ error: 'reward_not_found' });
    }
    
    // Check if user has enough points
    const totalResult = db.prepare(`
      SELECT COALESCE(SUM(points), 0) as totalPoints 
      FROM points_transactions 
      WHERE user_id = ?
    `).get(userId) as { totalPoints: number };
    
    if (totalResult.totalPoints < reward.points_required) {
      return res.status(400).json({ error: 'insufficient_points' });
    }
    
    // Create redemption transaction
    const transactionId = `tx-${Date.now()}-${Math.random().toString(36).slice(2)}`;
    
    db.prepare(`
      INSERT INTO points_transactions (id, user_id, points, description, type)
      VALUES (?, ?, ?, ?, ?)
    `).run(
      transactionId, 
      userId, 
      -reward.points_required, 
      `Redeemed: ${reward.title}`, 
      'redeemed'
    );
    
    // Get updated total
    const newTotalResult = db.prepare(`
      SELECT COALESCE(SUM(points), 0) as totalPoints 
      FROM points_transactions 
      WHERE user_id = ?
    `).get(userId) as { totalPoints: number };
    
    res.json({ 
      data: { 
        totalPoints: newTotalResult.totalPoints,
        reward,
        redemptionCode: `REDEEM-${transactionId.slice(-8).toUpperCase()}`
      } 
    });
  } catch (error) {
    console.error('Error redeeming reward:', error);
    res.status(500).json({ error: 'reward_redemption_failed' });
  }
});

export default router;