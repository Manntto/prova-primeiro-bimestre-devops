#!/bin/bash
set -euo pipefail

# ─── Atualiza o sistema e instala Node.js 20 ──────────────────────────────────
dnf update -y
dnf install -y nodejs git

# ─── Cria diretório da aplicação ──────────────────────────────────────────────
mkdir -p /opt/api-reservas
cd /opt/api-reservas

# ─── Cria o package.json ──────────────────────────────────────────────────────
cat > package.json << 'PKGJSON'
{
  "name": "api-reservas",
  "version": "1.0.0",
  "main": "src/index.js",
  "scripts": { "start": "node src/index.js" },
  "dependencies": {
    "dotenv": "16.4.5",
    "express": "4.19.2",
    "pg": "8.12.0"
  }
}
PKGJSON

npm install --omit=dev

# ─── Cria o .env com variáveis passadas pelo Terraform ───────────────────────
cat > .env << ENVFILE
PORT=${api_port}
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
ENVFILE

# ─── Cria a estrutura da aplicação ───────────────────────────────────────────
mkdir -p src

cat > src/db.js << 'DBJS'
const { Pool } = require('pg');
const pool = new Pool({
  host:     process.env.DB_HOST,
  port:     parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});
async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS reservas (
      id      SERIAL PRIMARY KEY,
      cliente VARCHAR(255) NOT NULL,
      data    DATE         NOT NULL,
      status  VARCHAR(50)  NOT NULL DEFAULT 'pendente'
    );
  `);
}
module.exports = { pool, initDb };
DBJS

cat > src/index.js << 'INDEXJS'
require('dotenv').config();
const express = require('express');
const { pool, initDb } = require('./db');
const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.json());

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.post('/reservas', async (req, res) => {
  const { cliente, data, status } = req.body;
  if (!cliente || !data) return res.status(400).json({ erro: 'cliente e data são obrigatórios.' });
  try {
    const r = await pool.query('INSERT INTO reservas (cliente,data,status) VALUES ($1,$2,$3) RETURNING *', [cliente, data, status||'pendente']);
    res.status(201).json(r.rows[0]);
  } catch(e) { res.status(500).json({ erro: e.message }); }
});

app.get('/reservas', async (req, res) => {
  try { res.json((await pool.query('SELECT * FROM reservas ORDER BY id')).rows); }
  catch(e) { res.status(500).json({ erro: e.message }); }
});

app.get('/reservas/:id', async (req, res) => {
  try {
    const r = await pool.query('SELECT * FROM reservas WHERE id=$1', [req.params.id]);
    if (!r.rows.length) return res.status(404).json({ erro: 'Reserva não encontrada.' });
    res.json(r.rows[0]);
  } catch(e) { res.status(500).json({ erro: e.message }); }
});

app.put('/reservas/:id', async (req, res) => {
  const { cliente, data, status } = req.body;
  try {
    const cur = await pool.query('SELECT * FROM reservas WHERE id=$1', [req.params.id]);
    if (!cur.rows.length) return res.status(404).json({ erro: 'Reserva não encontrada.' });
    const o = cur.rows[0];
    const r = await pool.query('UPDATE reservas SET cliente=$1,data=$2,status=$3 WHERE id=$4 RETURNING *',
      [cliente??o.cliente, data??o.data, status??o.status, req.params.id]);
    res.json(r.rows[0]);
  } catch(e) { res.status(500).json({ erro: e.message }); }
});

app.delete('/reservas/:id', async (req, res) => {
  try {
    const r = await pool.query('DELETE FROM reservas WHERE id=$1 RETURNING *', [req.params.id]);
    if (!r.rows.length) return res.status(404).json({ erro: 'Reserva não encontrada.' });
    res.json({ mensagem: 'Removida.', reserva: r.rows[0] });
  } catch(e) { res.status(500).json({ erro: e.message }); }
});

app.listen(PORT, async () => {
  console.log('API rodando na porta ' + PORT);
  try { await initDb(); } catch(e) { console.error('initDb error:', e.message); }
});
INDEXJS

# ─── Cria serviço systemd para a API ─────────────────────────────────────────
cat > /etc/systemd/system/api-reservas.service << 'SERVICE'
[Unit]
Description=API de Reservas TechNova
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/api-reservas
ExecStart=/usr/bin/node src/index.js
Restart=always
RestartSec=5
EnvironmentFile=/opt/api-reservas/.env

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable api-reservas
systemctl start api-reservas
