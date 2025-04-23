import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import { Client } from "jsr:@db/postgres";


const router = new Router();

console.log("INTENTO 6");

const client = new Client({
  user: "postgres",
  password: "O0hhpRDpff3bJdZjZ6Q1trgWD99TfMqIEJDwJ9YBeC9RG6RJEVTzhaWZ5Tjytlh1",
  database: "postgres",
  hostname: "cluster.default.svc.cluster.local",
  port: 5432,
  tls: {
    enforce: false,
    enable: false
  }
});

// Conectar y crear tabla si no existe
await client.connect();
await client.queryObject(`
  CREATE TABLE IF NOT EXISTS test (
    username TEXT PRIMARY KEY,
    date_of_birth DATE NOT NULL
  );
`);

// // Función para validar nombre de usuario
// function isValidUsername(username: string): boolean {
//   return /^[A-Za-z]+$/.test(username);
// }

// // Función para validar fecha y que sea anterior a hoy
// function isValidDate(dateString: string): boolean {
//   const date = new Date(dateString);
//   if (isNaN(date.getTime())) return false;
//   const today = new Date();
//   // Compara solo la parte de fecha sin hora
//   const todayStr = today.toISOString().split("T")[0];
//   return date < new Date(todayStr);
// }


// // API para crear/actualizar usuario
// router.put("/hello/:username", async (ctx) => {
//   const { username } = ctx.params;
//   const { dateOfBirth } = await ctx.request.body.json();

//   if (!username || !isValidUsername(username)) {
//     ctx.response.status = 400;
//     ctx.response.body = { error: "El nombre de usuario sólo puede contener letras." };
//     return;
//   }
//   if (!dateOfBirth || !isValidDate(dateOfBirth)) {
//     ctx.response.status = 400;
//     ctx.response.body = { error: "La fecha debe tener formato YYYY-MM-DD y ser anterior a hoy." };
//     return;
//   }

//   await client.queryObject(
//     `INSERT INTO users (username, date_of_birth) VALUES ('${username}', '${dateOfBirth}')
//     ON CONFLICT (username) DO UPDATE SET date_of_birth = EXCLUDED.date_of_birth`,
//     username,
//     dateOfBirth
//   );
//   ctx.response.status = 204;
// });

// // API para saludo según cumpleaños
// router.get("/hello/:username", async (ctx) => {
//   const { username } = ctx.params;

//   console.log("username", username);

//   if (!username || !isValidUsername(username)) {
//     ctx.response.status = 400;
//     ctx.response.body = { error: "El nombre de usuario sólo puede contener letras." };
//     return;
//   }
//   const result = await client.queryObject<{ date_of_birth: string }>
//   `SELECT date_of_birth FROM users WHERE username = ${username}`;

//   if (result.rows.length === 0) {
//     ctx.response.status = 404;
//     ctx.response.body = { error: "Usuario no encontrado." };
//     return;
//   }
//   const dob = new Date(result.rows[0].date_of_birth);
//   const today = new Date();
//   const todayStr = today.toISOString().split("T")[0];
//   const birthThisYear = new Date(`${today.getFullYear()}-${String(dob.getMonth()+1).padStart(2,'0')}-${String(dob.getDate()).padStart(2,'0')}`);

//   let daysDiff: number;
//   if (birthThisYear.getTime() >= new Date(todayStr).getTime()) {
//     daysDiff = Math.ceil((birthThisYear.getTime() - new Date(todayStr).getTime()) / (1000 * 60 * 60 * 24));
//   } else {
//     const nextBirthday = new Date(`${today.getFullYear()+1}-${String(dob.getMonth()+1).padStart(2,'0')}-${String(dob.getDate()).padStart(2,'0')}`);
//     daysDiff = Math.ceil((nextBirthday.getTime() - new Date(todayStr).getTime()) / (1000 * 60 * 60 * 24));
//   }

//   let message: string;
//   if (daysDiff === 0) {
//     message = `Hello, ${username}! Happy birthday!`;
//   } else {
//     message = `Hello, ${username}! Your birthday is in ${daysDiff} day(s)`;
//   }

//   ctx.response.status = 200;
//   ctx.response.body = { message };
// });

router.get("/hello", async (ctx) => {
  ctx.response.status = 200;
  ctx.response.body = { message: "Hello, World!" };
});

const app = new Application();
app.use(router.routes());
app.use(router.allowedMethods());

console.log("LELELEL http://localhost:8000");
await app.listen({ port: 8000 });
