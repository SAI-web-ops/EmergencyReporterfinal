import { Router } from 'express';
import { z } from 'zod';
import { requireAuth } from '../middleware/auth.js';
import db from '../database/index.js';

const router = Router();

const messageSchema = z.object({
  incidentId: z.string().min(1),
  senderId: z.string().min(1),
  senderRole: z.string().min(1),
  text: z.string().min(1),
  sentAt: z.string().datetime().optional().default(new Date().toISOString()),
});

// Get chat history for an incident
router.get('/:incidentId/messages', requireAuth, (req, res) => {
  const { incidentId } = req.params;
  
  const messages = db.prepare(`
    SELECT cm.*, u.name as sender_name
    FROM chat_messages cm
    LEFT JOIN users u ON cm.sender_id = u.id
    WHERE cm.incident_id = ?
    ORDER BY cm.sent_at ASC
  `).all(incidentId);
  
  res.json({ data: messages });
});

// Socket.IO event handlers
export function registerChatSocket(io: any) {
io.on('connection', (socket: any) => {
  console.log('A user connected to chat socket');

  socket.on('joinIncidentChat', (incidentId: string) => {
    socket.join(incidentId);
    console.log(`User joined chat for incident ${incidentId}`);
  });

  socket.on('sendMessage', async (msg: z.infer<typeof messageSchema>) => {
    const parsed = messageSchema.safeParse(msg);
    if (!parsed.success) {
      console.error('Invalid chat message received:', parsed.error);
      return;
    }
    
    const { incidentId, senderId, senderRole, text, sentAt } = parsed.data;

    try {
      const messageId = `msg-${Date.now()}-${Math.random().toString(36).slice(2)}`;
      
      db.prepare(`
        INSERT INTO chat_messages (id, incident_id, sender_id, sender_role, text, sent_at)
        VALUES (?, ?, ?, ?, ?, ?)
      `).run(messageId, incidentId, senderId, senderRole, text, sentAt);

      const newMessage = {
        id: messageId,
        senderId,
        senderRole,
        text,
        sentAt,
        incidentId
      };

      io.to(incidentId).emit('receiveMessage', newMessage);
      console.log(`Message from ${senderId} in incident ${incidentId}: ${text}`);
    } catch (error) {
      console.error('Error saving chat message:', error);
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected from chat socket');
  });
});
}

export default router;