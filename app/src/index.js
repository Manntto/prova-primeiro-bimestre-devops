require('dotenv').config();
const express = require('express');
const { pool, initDb } = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Verifica se uma string é uma data válida no formato YYYY-MM-DD.
 */
function isValidDate(value) {
  if (!value) return false;
  const date = new Date(value);
  return !isNaN(date.getTime());
}

// ─── Health Check ────────────────────────────────────────────────────────────

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ─── POST /reservas ──────────────────────────────────────────────────────────

app.post('/reservas', async (req, res) => {
  const { cliente, data, status } = req.body;

  if (!cliente || !data) {
    return res.status(400).json({ erro: 'Os campos "cliente" e "data" são obrigatórios.' });
  }

  if (!isValidDate(data)) {
    return res.status(400).json({ erro: 'O campo "data" deve ser uma data válida (ex: 2026-10-10).' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO reservas (cliente, data, status) VALUES ($1, $2, $3) RETURNING *',
      [cliente, data, status || 'pendente']
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: 'Erro ao criar reserva.' });
  }
});

// ─── GET /reservas ───────────────────────────────────────────────────────────

app.get('/reservas', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM reservas ORDER BY id ASC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: 'Erro ao listar reservas.' });
  }
});

// ─── GET /reservas/:id ───────────────────────────────────────────────────────

app.get('/reservas/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('SELECT * FROM reservas WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ erro: 'Reserva não encontrada.' });
    }

    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: 'Erro ao buscar reserva.' });
  }
});

// ─── PUT /reservas/:id ───────────────────────────────────────────────────────

app.put('/reservas/:id', async (req, res) => {
  const { id } = req.params;
  const { cliente, data, status } = req.body;

  if (!cliente && !data && !status) {
    return res.status(400).json({ erro: 'Informe ao menos um campo para atualizar.' });
  }

  if (data && !isValidDate(data)) {
    return res.status(400).json({ erro: 'O campo "data" deve ser uma data válida (ex: 2026-10-10).' });
  }

  try {
    const current = await pool.query('SELECT * FROM reservas WHERE id = $1', [id]);

    if (current.rows.length === 0) {
      return res.status(404).json({ erro: 'Reserva não encontrada.' });
    }

    const old = current.rows[0];
    const newCliente = cliente ?? old.cliente;
    const newData    = data    ?? old.data;
    const newStatus  = status  ?? old.status;

    const result = await pool.query(
      'UPDATE reservas SET cliente = $1, data = $2, status = $3 WHERE id = $4 RETURNING *',
      [newCliente, newData, newStatus, id]
    );

    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: 'Erro ao atualizar reserva.' });
  }
});

// ─── DELETE /reservas/:id ────────────────────────────────────────────────────

app.delete('/reservas/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM reservas WHERE id = $1 RETURNING *', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ erro: 'Reserva não encontrada.' });
    }

    res.status(200).json({ mensagem: 'Reserva removida com sucesso.', reserva: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ erro: 'Erro ao remover reserva.' });
  }
});

// ─── Inicialização ────────────────────────────────────────────────────────────

app.listen(PORT, async () => {
  console.log(`API de Reservas rodando na porta ${PORT}`);
  try {
    await initDb();
  } catch (err) {
    console.error('Erro ao inicializar banco:', err.message);
  }
});
