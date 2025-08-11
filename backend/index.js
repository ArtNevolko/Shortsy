import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { AccessToken } from 'livekit-server-sdk';

const app = express();
app.use(cors());

const {
	LIVEKIT_URL,
	LIVEKIT_API_KEY,
	LIVEKIT_API_SECRET,
	PORT = 8787,
} = process.env;

app.get('/livekit/token', (req, res) => {
	const identity = req.query.identity || `user-${Date.now()}`;
	const roomName = req.query.room || 'shortsy_global';
	const canPublish = req.query.publish === '1';

	if (!LIVEKIT_URL || !LIVEKIT_API_KEY || !LIVEKIT_API_SECRET) {
		return res.status(500).json({ error: 'LiveKit env not configured' });
	}

	try {
		const at = new AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET, {
			identity: String(identity),
			ttl: 60 * 60, // 1h
		});
		at.addGrant({
			room: roomName,
			roomJoin: true,
			canPublish,
			canSubscribe: true,
		});
		const token = at.toJwt();
		return res.json({ token, url: LIVEKIT_URL });
	} catch (e) {
		console.error(e);
		return res.status(500).json({ error: 'token_error' });
	}
});

app.get('/', (_, res) => res.send('Shortsy backend OK'));

app.listen(PORT, () => {
	console.log(`Shortsy backend listening on http://localhost:${PORT}`);
});
