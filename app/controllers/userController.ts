import { Context } from "https://deno.land/x/oak/mod.ts";
import { UserService } from "../services/userService.ts";
import { UserResponse, ErrorResponse } from "../types/user.ts";
import { Client } from "https://deno.land/x/postgres/mod.ts";

export class UserController {
  private userService: UserService;

  constructor(client: Client) {
    this.userService = new UserService(client);
  }

  async updateUser(ctx: Context) {
    try {
      const { username } = ctx.params;
      const { dateOfBirth } = await ctx.request.body.json();

      await this.userService.createOrUpdateUser({ username, dateOfBirth });
      
      ctx.response.status = 204;
    } catch (error) {
      console.error(error);
      ctx.response.status = error.message.includes("not found") ? 404 : 400;
      ctx.response.body = { error: error.message } as ErrorResponse;
    }
  }

  async getUserBirthday(ctx: Context) {
    try {
      const { username } = ctx.params;
      const message = await this.userService.getUserBirthdayMessage(username);
      ctx.response.status = 200;
      ctx.response.body = { message } as UserResponse;
    } catch (error) {
      ctx.response.status = error.message.includes("not found") ? 404 : 400;
      ctx.response.body = { error: error.message } as ErrorResponse;
    }
  }

  async getHello(ctx: Context) {
    ctx.response.status = 200;
    ctx.response.body = { message: "Hello, World!" } as UserResponse;
  }
} 