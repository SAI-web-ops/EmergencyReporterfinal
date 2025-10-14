import Database from 'better-sqlite3';
import path from 'path';
import fs from 'fs';

const dbPath = path.join(process.cwd(), 'data', 'emergency.db');
const dir = path.dirname(dbPath);
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
}
const db = new Database(dbPath);

// Enable foreign keys
db.pragma('foreign_keys = ON');

// Create tables
db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('citizen', 'dispatcher', 'responder')),
    name TEXT,
    phone TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,
    is_active BOOLEAN DEFAULT 1
  );

  CREATE TABLE IF NOT EXISTS incidents (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'reported',
    priority TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    address TEXT NOT NULL,
    timestamp DATETIME NOT NULL,
    media_urls TEXT, -- JSON array
    is_anonymous BOOLEAN DEFAULT 0,
    reporter_id TEXT REFERENCES users(id),
    assigned_unit TEXT REFERENCES users(id),
    notes TEXT,
    points_awarded INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS points_transactions (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id),
    points INTEGER NOT NULL,
    description TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('earned', 'redeemed', 'bonus', 'penalty')),
    incident_id TEXT REFERENCES incidents(id),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS responders (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id),
    name TEXT NOT NULL,
    latitude REAL,
    longitude REAL,
    available BOOLEAN DEFAULT 1,
    last_location_update DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS chat_messages (
    id TEXT PRIMARY KEY,
    incident_id TEXT NOT NULL REFERENCES incidents(id),
    sender_id TEXT NOT NULL REFERENCES users(id),
    sender_role TEXT NOT NULL,
    text TEXT NOT NULL,
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS rewards_catalog (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    points_required INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS device_tokens (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id),
    token TEXT NOT NULL,
    platform TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, token)
  );

  CREATE TABLE IF NOT EXISTS panic_alerts (
    id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES users(id),
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    address TEXT,
    triggered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'active'
  );
`);

// Insert default data
const insertDefaultData = () => {
  // Default rewards
  const rewards = [
    { id: 'store-10', title: 'Local Store 10% Discount', description: '10% off at participating local stores', points_required: 50 },
    { id: 'medical-priority', title: 'Medical Center Priority Access', description: 'Priority access to medical services', points_required: 100 },
    { id: 'workshop-access', title: 'Safety Workshop Access', description: 'Free access to community safety workshops', points_required: 75 },
    { id: 'ngo-donation', title: 'NGO Donation', description: 'Donate points to community safety programs', points_required: 25 },
  ];

  const insertReward = db.prepare(`
    INSERT OR IGNORE INTO rewards_catalog (id, title, description, points_required)
    VALUES (?, ?, ?, ?)
  `);

  rewards.forEach(reward => {
    insertReward.run(reward.id, reward.title, reward.description, reward.points_required);
  });

  // Sample dispatcher and responder accounts
  const insertUser = db.prepare(`
    INSERT OR IGNORE INTO users (id, email, password_hash, role, name, phone)
    VALUES (?, ?, ?, ?, ?, ?)
  `);

  // Sample dispatcher
  insertUser.run('dispatcher-001', 'dispatcher@emergency.gov', '$2b$10$example_hash_dispatcher', 'dispatcher', 'Sarah Johnson', '+1-555-0101');
  
  // Sample responders
  insertUser.run('responder-001', 'responder1@emergency.gov', '$2b$10$example_hash_responder1', 'responder', 'Mike Rodriguez', '+1-555-0102');
  insertUser.run('responder-002', 'responder2@emergency.gov', '$2b$10$example_hash_responder2', 'responder', 'Lisa Chen', '+1-555-0103');

  // Sample responder locations
  const insertResponder = db.prepare(`
    INSERT OR IGNORE INTO responders (id, user_id, name, latitude, longitude, available)
    VALUES (?, ?, ?, ?, ?, ?)
  `);

  insertResponder.run('resp-001', 'responder-001', 'Mike Rodriguez', 40.7128, -74.0060, 1);
  insertResponder.run('resp-002', 'responder-002', 'Lisa Chen', 40.7589, -73.9851, 1);
};

insertDefaultData();

export default db;
