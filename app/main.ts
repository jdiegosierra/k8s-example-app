import { Application, Router } from "https://deno.land/x/oak/mod.ts";
import { initializeDatabase, client } from "./config/database.ts";
import { UserController } from "./controllers/userController.ts";

await initializeDatabase();

const userController = new UserController(client);

const router = new Router();
router
   .get("/hello", (ctx) => userController.getHello(ctx))
   .put("/hello/:username", (ctx) => userController.updateUser(ctx))
   .get("/hello/:username", (ctx) => userController.getUserBirthday(ctx));

const app = new Application();
app.use(router.routes());
app.use(router.allowedMethods());

console.log("Server running");
await app.listen({ port: Deno.env.get("PORT")}); 