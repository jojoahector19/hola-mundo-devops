const express = require('express');
const pool = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

// 'develop' o 'release' - se define via variable de entorno en el Deployment/ConfigMap
const ENVIRONMENT = process.env.ENVIRONMENT || 'develop';

// Endpoint principal: registra la visita y devuelve el conteo total
app.get('/api/hello', async (req, res) => {
  try {
    await pool.query(
      'INSERT INTO visits (environment) VALUES ($1)',
      [ENVIRONMENT]
    );

    const result = await pool.query('SELECT COUNT(*)::int AS total FROM visits');
    const total = result.rows[0].total;

    res.json({
      message: 'Hola Mundo',
      visits: total,
      environment: ENVIRONMENT,
    });
  } catch (err) {
    console.error('Error en /api/hello:', err);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
});

// Health check para Kubernetes (liveness/readiness probes)
app.get('/health', (req, res) => {
  res.json({ status: 'ok', environment: ENVIRONMENT });
});

app.listen(PORT, () => {
  console.log(`Backend escuchando en el puerto ${PORT} (environment=${ENVIRONMENT})`);
});
