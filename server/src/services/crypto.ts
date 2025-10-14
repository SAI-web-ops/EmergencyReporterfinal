import crypto from 'crypto';
import fs from 'fs';

const ALGO = 'aes-256-gcm';

export function sha256OfFile(filePath: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const hash = crypto.createHash('sha256');
    const stream = fs.createReadStream(filePath);
    stream.on('data', (d) => hash.update(d));
    stream.on('error', reject);
    stream.on('end', () => resolve(hash.digest('hex')));
  });
}

export async function encryptFileAtPath(inputPath: string, outputPath: string, key: Buffer): Promise<{ iv: string; authTag: string }>{
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv(ALGO, key, iv);
  const input = fs.createReadStream(inputPath);
  const output = fs.createWriteStream(outputPath);

  await new Promise<void>((resolve, reject) => {
    input.pipe(cipher).pipe(output).on('finish', () => resolve()).on('error', reject);
  });

  const authTag = (cipher as any).getAuthTag?.() as Buffer | undefined;
  return { iv: iv.toString('hex'), authTag: authTag ? authTag.toString('hex') : '' };
}

export function decryptFileToStream(inputPath: string, key: Buffer, ivHex: string, authTagHex: string) {
  const iv = Buffer.from(ivHex, 'hex');
  const authTag = Buffer.from(authTagHex, 'hex');
  const decipher = crypto.createDecipheriv(ALGO, key, iv);
  (decipher as any).setAuthTag?.(authTag);
  const input = fs.createReadStream(inputPath);
  return input.pipe(decipher);
}

export function getKeyFromEnv(): Buffer {
  const hex = process.env.EVIDENCE_KEY;
  if (!hex) {
    // For demo; in prod, require key
    const tmp = crypto.createHash('sha256').update('dev-key').digest();
    return tmp;
  }
  return Buffer.from(hex, 'hex');
}
