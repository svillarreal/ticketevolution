import knex from "knex";

let db;

export function initDb() {
  db = knex({
    client: "pg",
    connection: {
      host: process.env.PGHOST,
      user: process.env.PGUSER,
      password: process.env.PGPASSWORD,
      database: process.env.PGDATABASE,
      port: parseInt(process.env.PGPORT, 10),
    },
  });
}

export function getDb() {
  if (!db) {
    throw new Error("Database not initialized. Call initDb() first.");
  }
  return db;
}
