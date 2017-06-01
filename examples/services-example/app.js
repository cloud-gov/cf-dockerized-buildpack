const express = require('express');
const cfenv = require('cfenv');
const Database = require('./database');
const bodyParser = require('body-parser');

const app = express();
const appEnv = cfenv.getAppEnv();
const port = process.env.PORT || appEnv.port;
const db = new Database('my-rds-instance');

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.get('/', (req, res) => {
  res.send('Hello World! I am running on port ' + port)
});

app.put('/items', (req, res, next) => {
  db.pool.query('INSERT INTO items(text) values($1)', [req.body.text])
  .then((results) => {
    db.pool.query('SELECT * FROM items ORDER BY id ASC')
    .then((results) => {
      return res.status(201).json(results.rows.pop());
    }).catch((err) => {
      return res.status(500).json({success: false, data: err});
    });
  }).catch((err) => {
    return res.status(500).json({success: false, data: err});
  });
});

app.get('/items/:id', (req, res) => {
  db.pool.query('SELECT * FROM items WHERE id=$1', [parseInt(req.params.id)])
  .then((results) => {
    if (results.rows.length > 0) {
      return res.json(results.rows.shift());
    }
    return res.status(404).json('Not found');
  }).catch((err) => {
    return res.status(500).json({success: false, data: err});
  });
});

app.listen(port, () => {
  db.init().then(() => {
    console.log('Example app listening on port ' + port)
  });
});
