const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.PGHOST || 'postgres-service',
  port: process.env.PGPORT || 5432,
  user: process.env.PGUSER || 'holamundo_user',
  password: process.env.PGPASSWORD || 'change_me_123',
  database: process.env.PGDATABASE || 'holamundo',
});

module.exports = pool;
