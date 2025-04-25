import { Client } from "https://deno.land/x/postgres/mod.ts";


const client = new Client({
  user: Deno.env.get("DB_USER"),
  // user: "postgres",
  password: Deno.env.get("DB_PASSWORD"),
  // password: "jAefjZZBsF6fDlKLd2W6SyMfFWmmZOjISEZi8xU4njnOyqXRXYi0f595NAOlhQ0R",
  database: Deno.env.get("DB_NAME"),
  // database: "postgres",
  hostname: Deno.env.get("DB_HOST"),
  // hostname: "cluster-rw.default.svc.cluster.local",
  port: Deno.env.get("DB_PORT")
  // port: 5432
});

export async function initializeDatabase() {
  await client.connect();
  await client.queryObject(`
    CREATE TABLE IF NOT EXISTS users (
      username TEXT PRIMARY KEY,
      date_of_birth DATE NOT NULL
    );
  `);
}

export { client }; 