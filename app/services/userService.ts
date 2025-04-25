import { User } from "../types/user.ts";
import { isValidUsername, isValidDate } from "../utils/validators.ts";
import { Client } from "https://deno.land/x/postgres@v0.17.0/mod.ts";

export class UserService {
  private client: Client;

  constructor(client: Client) {
    this.client = client;
  }

  async createOrUpdateUser(user: User): Promise<void> {
    if (!isValidUsername(user.username)) {
      throw new Error("Username can only contain letters.");
    }
    if (!isValidDate(user.dateOfBirth)) {
      throw new Error("Date must be in YYYY-MM-DD format and must be before today.");
    }

    await this.client.queryObject(
      `INSERT INTO users (username, date_of_birth) VALUES ($1, $2)`,
      [user.username, user.dateOfBirth]
    );
  }

  async getUserBirthdayMessage(username: string): Promise<string> {
    if (!isValidUsername(username)) {
      throw new Error("Username can only contain letters.");
    }

    const result = await this.client.queryObject<{ date_of_birth: string }>(
      `SELECT date_of_birth FROM users WHERE username = $1`,
      [username]
    );

    if (result.rows.length === 0) {
      throw new Error("User not found.");
    }

    const dob = new Date(result.rows[0].date_of_birth);
    const today = new Date();
    const todayStr = today.toISOString().split("T")[0];
    const birthThisYear = new Date(
      `${today.getFullYear()}-${String(dob.getMonth() + 1).padStart(2, '0')}-${String(dob.getDate()).padStart(2, '0')}`
    );

    let daysDiff: number;
    if (birthThisYear.getTime() >= new Date(todayStr).getTime()) {
      daysDiff = Math.ceil((birthThisYear.getTime() - new Date(todayStr).getTime()) / (1000 * 60 * 60 * 24));
    } else {
      const nextBirthday = new Date(
        `${today.getFullYear() + 1}-${String(dob.getMonth() + 1).padStart(2, '0')}-${String(dob.getDate()).padStart(2, '0')}`
      );
      daysDiff = Math.ceil((nextBirthday.getTime() - new Date(todayStr).getTime()) / (1000 * 60 * 60 * 24));
    }

    return daysDiff === 0
      ? `Hello, ${username}! Happy birthday!`
      : `Hello, ${username}! Your birthday is in ${daysDiff} day(s)`;
  }
} 