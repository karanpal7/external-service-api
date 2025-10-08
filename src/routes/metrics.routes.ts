import { Router } from 'express';
import { client } from '../middleware/metrics';

const router = Router();

router.get('/', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

export default router;
