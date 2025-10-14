import { Router } from 'express';
import { z } from 'zod';
import { requireAuth, requireRole } from '../middleware/auth.js';
import db from '../database/index.js';

const router = Router();

const incidentSchema = z.object({
  id: z.string(),
  type: z.string(),
  status: z.string(),
  priority: z.string(),
  title: z.string().min(1),
  description: z.string().min(1),
  latitude: z.number(),
  longitude: z.number(),
  address: z.string(),
  timestamp: z.string(),
  mediaUrls: z.array(z.string()).optional().default([]),
  isAnonymous: z.boolean().optional().default(false),
  reporterId: z.string().optional().nullable(),
  assignedUnit: z.string().optional().nullable(),
  notes: z.string().optional().nullable(),
  pointsAwarded: z.number().int().optional().default(0),
});

// SSE endpoint for real-time incident updates
router.get('/stream', requireAuth, requireRole('dispatcher'), (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  // Send initial data
  const incidents = db.prepare(`
    SELECT i.*, u.name as reporter_name, u.email as reporter_email
    FROM incidents i
    LEFT JOIN users u ON i.reporter_id = u.id
    ORDER BY i.created_at DESC
  `).all();
  
  res.write(`data: ${JSON.stringify({ type: 'snapshot', incidents })}\n\n`);

  req.on('close', () => {
    console.log('SSE client disconnected');
  });
});

function broadcastIncidentUpdate(req: any, incident: any) {
  try {
    const io = req.app?.get('io');
    io?.emit('incidentUpdate', incident);
  } catch {}
}

router.get('/', requireAuth, (_req, res) => {
  const incidents = db.prepare(`
    SELECT i.*, u.name as reporter_name, u.email as reporter_email
    FROM incidents i
    LEFT JOIN users u ON i.reporter_id = u.id
    ORDER BY i.created_at DESC
  `).all();
  
  res.json({ data: incidents });
});

router.post('/', requireAuth, (req, res) => {
  const parsed = incidentSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }
  
  const incident = parsed.data;
  const mediaUrlsJson = JSON.stringify(incident.mediaUrls);
  
  try {
    db.prepare(`
      INSERT INTO incidents (
        id, type, status, priority, title, description, latitude, longitude, 
        address, timestamp, media_urls, is_anonymous, reporter_id, 
        assigned_unit, notes, points_awarded
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      incident.id, incident.type, incident.status, incident.priority,
      incident.title, incident.description, incident.latitude, incident.longitude,
      incident.address, incident.timestamp, mediaUrlsJson, incident.isAnonymous,
      incident.reporterId, incident.assignedUnit, incident.notes, incident.pointsAwarded
    );
    
    // Award points for incident report
    if (incident.reporterId && incident.pointsAwarded > 0) {
      db.prepare(`
        INSERT INTO points_transactions (id, user_id, points, description, type, incident_id)
        VALUES (?, ?, ?, ?, ?, ?)
      `).run(
        `tx-${Date.now()}-${Math.random().toString(36).slice(2)}`,
        incident.reporterId,
        incident.pointsAwarded,
        `Points for reporting ${incident.type} incident`,
        'earned',
        incident.id
      );
    }
    
    broadcastIncidentUpdate(req, incident);
    res.status(201).json({ data: incident });
  } catch (error) {
    console.error('Error creating incident:', error);
    res.status(500).json({ error: 'incident_creation_failed' });
  }
});

router.get('/:id', requireAuth, (req, res) => {
  const incident = db.prepare(`
    SELECT i.*, u.name as reporter_name, u.email as reporter_email
    FROM incidents i
    LEFT JOIN users u ON i.reporter_id = u.id
    WHERE i.id = ?
  `).get(req.params.id);
  
  if (!incident) return res.status(404).json({ error: 'incident_not_found' });
  
  // Parse media URLs
  (incident as any).mediaUrls = JSON.parse((incident as any).media_urls || '[]');
  delete (incident as any).media_urls;
  
  res.json({ data: incident });
});

router.patch('/:id/status', requireAuth, requireRole('dispatcher', 'responder'), (req, res) => {
  const { status } = req.body as { status?: string };
  const incidentId = req.params.id;
  
  if (!status) return res.status(400).json({ error: 'status_required' });
  
  try {
    const result = db.prepare(`
      UPDATE incidents 
      SET status = ?, updated_at = CURRENT_TIMESTAMP 
      WHERE id = ?
    `).run(status, incidentId);
    
    if (result.changes === 0) {
      return res.status(404).json({ error: 'incident_not_found' });
    }
    
    const updatedIncident = db.prepare('SELECT * FROM incidents WHERE id = ?').get(incidentId);
    broadcastIncidentUpdate(req, updatedIncident);
    
    res.json({ data: updatedIncident });
  } catch (error) {
    console.error('Error updating incident status:', error);
    res.status(500).json({ error: 'status_update_failed' });
  }
});

// Assign responder to incident
router.post('/:id/assign', requireAuth, requireRole('dispatcher'), (req, res) => {
  const { responderId } = req.body as { responderId?: string };
  const incidentId = req.params.id;
  
  if (!responderId) return res.status(400).json({ error: 'responder_id_required' });
  
  try {
    // Check if responder exists and is available
    const responder = db.prepare(`
      SELECT r.*, u.name, u.email 
      FROM responders r 
      JOIN users u ON r.user_id = u.id 
      WHERE r.id = ? AND r.available = 1
    `).get(responderId);
    
    if (!responder) {
      return res.status(404).json({ error: 'responder_not_found_or_unavailable' });
    }
    
    const result = db.prepare(`
      UPDATE incidents 
      SET assigned_unit = ?, status = 'in_progress', updated_at = CURRENT_TIMESTAMP 
      WHERE id = ?
    `).run(responderId, incidentId);
    
    if (result.changes === 0) {
      return res.status(404).json({ error: 'incident_not_found' });
    }
    
    const updatedIncident = db.prepare('SELECT * FROM incidents WHERE id = ?').get(incidentId);
    broadcastIncidentUpdate(req, updatedIncident);
    
    res.json({ data: updatedIncident });
  } catch (error) {
    console.error('Error assigning responder:', error);
    res.status(500).json({ error: 'assignment_failed' });
  }
});

// Get available responders
router.get('/responders', requireAuth, requireRole('dispatcher'), (_req, res) => {
  const responders = db.prepare(`
    SELECT r.*, u.name, u.email, u.phone
    FROM responders r
    JOIN users u ON r.user_id = u.id
    WHERE r.available = 1 AND u.is_active = 1
    ORDER BY r.name
  `).all();
  
  res.json({ data: responders });
});

// Register/update responder location
router.post('/responders/location', requireAuth, requireRole('dispatcher', 'responder'), (req, res) => {
  const { id, latitude, longitude, available } = req.body as any;
  
  if (!id || typeof latitude !== 'number' || typeof longitude !== 'number') {
    return res.status(400).json({ error: 'invalid_payload' });
  }
  
  try {
    // Update responder location
    const result = db.prepare(`
      UPDATE responders 
      SET latitude = ?, longitude = ?, available = ?, last_location_update = CURRENT_TIMESTAMP 
      WHERE id = ?
    `).run(latitude, longitude, available !== false, id);
    
    if (result.changes === 0) {
      return res.status(404).json({ error: 'responder_not_found' });
    }
    
    const updatedResponder = db.prepare(`
      SELECT r.*, u.name, u.email 
      FROM responders r 
      JOIN users u ON r.user_id = u.id 
      WHERE r.id = ?
    `).get(id);
    
    res.json({ data: updatedResponder });
  } catch (error) {
    console.error('Error updating responder location:', error);
    res.status(500).json({ error: 'location_update_failed' });
  }
});

export default router;