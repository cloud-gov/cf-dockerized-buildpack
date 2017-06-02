const Pool = require('pg').Pool;
const cfenv = require('cfenv');
const url = require('url');
const appEnv = cfenv.getAppEnv();

class Database {

  constructor(service) {
    const uri = process.env.DATABASE_URL || appEnv.getServiceCreds(service).uri;
    const params = url.parse(uri);
    const auth = params.auth.split(':');
    const config = {
      user: auth[0],
      password: auth[1],
      host: params.hostname,
      port: params.port,
      database: params.pathname.split('/')[1],
      max: 10,
      idleTimeoutMillis: 1000
    };
    this.pool = new Pool(config);
    this.pool.on('error', function(err, client) {
      // if a client is idle in the pool
      // and receives an error - for example when your PostgreSQL server restarts
      // the pool will catch the error & let you handle it here
      console.log(err);
    });
  }

  init() {
    return this.pool.query(
      'CREATE TABLE IF NOT EXISTS items(id SERIAL PRIMARY KEY, text VARCHAR(40) not null)'
    ).catch((err) => {
      console.log(err);
    });
  }

}

module.exports = Database;