import { Router } from 'express';
import { z } from 'zod';
import { requireAuth } from '../middleware/auth.js';
import db from '../database/index.js';

const router = Router();

const registerDeviceSchema = z.object({
  token: z.string().min(1),
  platform: z.enum(['ios', 'android', 'web']).default('web'),
});

router.post('/register-device', requireAuth, (req, res) => {
  const parsed = registerDeviceSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: parsed.error.flatten() });

  const { token, platform } = parsed.data;
  const userId = req.user!.sub;

  try {
    // Remove existing token for this user if it exists
    db.prepare('DELETE FROM device_tokens WHERE user_id = ? AND token = ?').run(userId, token);
    
    // Insert new token
    const tokenId = `token-${Date.now()}-${Math.random().toString(36).slice(2)}`;
    db.prepare(`
      INSERT INTO device_tokens (id, user_id, token, platform)
      VALUES (?, ?, ?, ?)
    `).run(tokenId, userId, token, platform);
    
    console.log(`[Notifications] Device token registered for user ${userId}: ${token}`);
    res.status(200).json({ message: 'Device token registered successfully' });
  } catch (error) {
    console.error('Error registering device token:', error);
    res.status(500).json({ error: 'token_registration_failed' });
  }
});

// Send notification to specific user
router.post('/send', requireAuth, (req, res) => {
  const { userId, title, body, type, data } = req.body;
  
  if (!userId || !title || !body) {
    return res.status(400).json({ error: 'missing_required_fields' });
  }
  
  try {
    // Get user's device tokens
    const tokens = db.prepare(`
      SELECT token, platform FROM device_tokens 
      WHERE user_id = ?
    `).all(userId) as { token: string; platform: string }[];
    
    if (tokens.length === 0) {
      return res.status(404).json({ error: 'no_device_tokens_found' });
    }
    
    // In a real application, this would integrate with FCM, Twilio, SendGrid, etc.
    console.log(`[Notifications] Sending ${type || 'general'} notification to user ${userId}:`);
    console.log(`  Title: ${title}`);
    console.log(`  Body: ${body}`);
    console.log(`  Tokens: ${tokens.map(t => t.token).join(', ')}`);
    console.log(`  Data:`, data);
    
    // Simulate notification sending
    tokens.forEach(({ token, platform }) => {
      console.log(`  -> Sending to ${platform} token: ${token.substring(0, 20)}...`);
    });
    
    res.status(200).json({ 
      message: 'Notification sent successfully',
      tokensCount: tokens.length 
    });
  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({ error: 'notification_send_failed' });
  }
});

// Send panic alert notification to dispatchers
router.post('/panic-alert', requireAuth, (req, res) => {
  const { latitude, longitude, address, userId } = req.body;
  
  try {
    // Store panic alert
    const alertId = `panic-${Date.now()}-${Math.random().toString(36).slice(2)}`;
    db.prepare(`
      INSERT INTO panic_alerts (id, user_id, latitude, longitude, address)
      VALUES (?, ?, ?, ?, ?)
    `).run(alertId, userId, latitude, longitude, address || '');
    
    // Get all dispatcher device tokens
    const dispatcherTokens = db.prepare(`
      SELECT dt.token, dt.platform, u.name
      FROM device_tokens dt
      JOIN users u ON dt.user_id = u.id
      WHERE u.role = 'dispatcher' AND u.is_active = 1
    `).all() as { token: string; platform: string; name: string }[];
    
    console.log(`[Panic Alert] Alert ${alertId} triggered by user ${userId}`);
    console.log(`[Panic Alert] Notifying ${dispatcherTokens.length} dispatchers`);
    
    dispatcherTokens.forEach(({ token, platform, name }) => {
      console.log(`[Panic Alert] -> Sending to dispatcher ${name} (${platform}): ${token.substring(0, 20)}...`);
    });
    
    res.status(200).json({ 
      message: 'Panic alert sent to dispatchers',
      alertId,
      dispatchersNotified: dispatcherTokens.length 
    });
  } catch (error) {
    console.error('Error sending panic alert:', error);
    res.status(500).json({ error: 'panic_alert_failed' });
  }
});

export default router;