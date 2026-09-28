const { Pool } = require('pg');

const pool = new Pool({
  host:     process.env.DB_HOST     || 'localhost',
  port:     parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME     || 'reservas',
  user:     process.env.DB_USER     || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

/**
 * Inicializa a tabela de reservas se ela ainda não existir.
 */
async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS reservas (
      id     SERIAL PRIMARY KEY,
      cliente VARCHAR(255) NOT NULL,
      data    DATE         NOT NULL,
      status  VARCHAR(50)  NOT NULL DEFAULT 'pendente'
    );
  `);
  console.log('Banco de dados inicializado.');
}

module.exports = { pool, initDb };
