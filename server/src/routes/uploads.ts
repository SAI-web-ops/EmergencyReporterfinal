import { Router, Request, Response } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { encryptFileAtPath, getKeyFromEnv, sha256OfFile, decryptFileToStream } from '../services/crypto.js';
import { requireAuth, requireRole } from '../middleware/auth.js';

const router = Router();

const uploadsDir = path.resolve(process.cwd(), 'uploads');
const encDir = path.join(uploadsDir, 'enc');
const backupsDir = path.join(uploadsDir, 'backups');
for (const d of [uploadsDir, encDir, backupsDir]) {
  if (!fs.existsSync(d)) fs.mkdirSync(d, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req: any, _file: any, cb: any) => cb(null, uploadsDir),
  filename: (_req: any, file: any, cb: any) => {
    const ext = path.extname(file.originalname) || '';
    const name = `${Date.now()}-${Math.random().toString(36).slice(2)}${ext}`;
    cb(null, name);
  },
});

const upload = multer({ storage });

router.post('/', upload.single('file'), async (req: Request, res: Response) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'file_required' });

    const clearPath = req.file.path;
    const hash = await sha256OfFile(clearPath);

    // Encrypt
    const encName = `${req.file.filename}.enc`;
    const encPath = path.join(encDir, encName);
    const key = getKeyFromEnv();
    const { iv, authTag } = await encryptFileAtPath(clearPath, encPath, key);

    // Backup copy (simple demo backup)
    const backupPath = path.join(backupsDir, encName);
    fs.copyFileSync(encPath, backupPath);

    // Remove clear file
    fs.unlinkSync(clearPath);

    const url = `/uploads/enc/${encName}`;
    const evidence = {
      url,
      filename: encName,
      sha256: hash,
      iv,
      authTag,
      uploadedAt: new Date().toISOString(),
    };

    // Write sidecar metadata for decrypt endpoint
    const metaPath = path.join(encDir, encName.replace(/\.enc$/, '.meta.json'));
    fs.writeFileSync(metaPath, JSON.stringify({ iv, authTag }), { encoding: 'utf8' });

    res.status(201).json({ data: evidence });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'upload_failed' });
  }
});

router.get('/list', (_req: Request, res: Response) => {
  const list = fs.readdirSync(encDir)
    .filter((n) => n.endsWith('.enc'))
    .map((filename) => ({ filename, url: `/uploads/enc/${filename}` }));
  res.json({ data: list });
});

// Stream decrypt to authorized roles only
router.get('/decrypt/:filename', requireAuth, requireRole('dispatcher', 'responder'), (req: Request, res: Response) => {
  const filename = req.params.filename;
  if (!filename.endsWith('.enc')) return res.status(400).json({ error: 'invalid_filename' });
  const encPath = path.join(encDir, filename);
  if (!fs.existsSync(encPath)) return res.status(404).json({ error: 'not_found' });

  // In a full system, metadata would store IV/authTag per file. For demo, infer namesidecar.
  const sidecar = filename.replace(/\.enc$/, '.meta.json');
  const metaPath = path.join(encDir, sidecar);
  if (!fs.existsSync(metaPath)) return res.status(400).json({ error: 'missing_metadata' });
  const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8')) as { iv: string; authTag: string };

  const key = getKeyFromEnv();
  res.setHeader('Content-Type', 'application/octet-stream');
  res.setHeader('Content-Disposition', `attachment; filename="${filename.replace(/\.enc$/, '')}"`);
  const stream = decryptFileToStream(encPath, key, meta.iv, meta.authTag);
  stream.on('error', () => res.status(500).end());
  stream.pipe(res);
});

export default router;
