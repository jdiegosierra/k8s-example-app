import { assertEquals } from "jsr:@std/assert";
import { assertSpyCalls, spy } from "jsr:@std/testing/mock";
import { UserService } from "../services/userService.ts";


interface UserRow {
  date_of_birth: string;
}

class MockClient {
  async queryObject(query: string): Promise<{ rows: UserRow[] }> {
    return { rows: [] };
  }
}

Deno.test("UserService - createOrUpdateUser", async (t) => {
  await t.step("should create user with valid data", async () => {
    const mockClient = new MockClient();
    const querySpy = spy(mockClient, "queryObject");
    const userService = new UserService(mockClient as any);
    const user = {
      username: "testuser",
      dateOfBirth: "1990-01-01"
    };
    
    await userService.createOrUpdateUser(user);
    
    assertSpyCalls(querySpy, 1);
    assertEquals(
      querySpy.calls[0].args[0],
      `INSERT INTO users (username, date_of_birth) VALUES ($1, $2)`
    );
  });

  await t.step("should throw error for invalid username", async () => {
    const mockClient = new MockClient();
    const userService = new UserService(mockClient as any);
    const user = {
      username: "user123",
      dateOfBirth: "1990-01-01"
    };
    
    try {
      await userService.createOrUpdateUser(user);
      throw new Error("Should have thrown an error");
    } catch (error: unknown) {
      if (error instanceof Error) {
        assertEquals(error.message, "Username can only contain letters.");
      } else {
        throw new Error("Expected an Error instance");
      }
    }
  });

  await t.step("should throw error for future date", async () => {
    const mockClient = new MockClient();
    const userService = new UserService(mockClient as any);
    const futureDate = new Date();
    futureDate.setFullYear(futureDate.getFullYear() + 1);
    const futureDateStr = futureDate.toISOString().split("T")[0];
    const user = {
      username: "validuser",
      dateOfBirth: futureDateStr
    };
    
    try {
      await userService.createOrUpdateUser(user);
      throw new Error("Should have thrown an error");
    } catch (error: unknown) {
      if (error instanceof Error) {
        assertEquals(error.message, "Date must be in YYYY-MM-DD format and must be before today.");
      } else {
        throw new Error("Expected an Error instance");
      }
    }
  });
});

Deno.test("UserService - getUserBirthdayMessage", async (t) => {
  await t.step("should throw error for invalid username", async () => {
    const mockClient = new MockClient();
    const userService = new UserService(mockClient as any);
    
    try {
      await userService.getUserBirthdayMessage("user123");
      throw new Error("Should have thrown an error");
    } catch (error: unknown) {
      if (error instanceof Error) {
        assertEquals(error.message, "Username can only contain letters.");
      } else {
        throw new Error("Expected an Error instance");
      }
    }
  });

  await t.step("should throw error for non-existent user", async () => {
    const mockClient = new MockClient();
    const userService = new UserService(mockClient as any);
    
    try {
      await userService.getUserBirthdayMessage("nonexistent");
      throw new Error("Should have thrown an error");
    } catch (error: unknown) {
      if (error instanceof Error) {
        assertEquals(error.message, "User not found.");
      } else {
        throw new Error("Expected an Error instance");
      }
    }
  });

  await t.step("should return birthday message for today", async () => {
    const mockClient = new MockClient();
    const today = new Date();
    const todayStr = today.toISOString().split("T")[0];
    mockClient.queryObject = async () => ({ rows: [{ date_of_birth: todayStr }] });
    const userService = new UserService(mockClient as any);

    const message = await userService.getUserBirthdayMessage("testuser");
    assertEquals(message, "Hello, testuser! Happy birthday!");
  });

  await t.step("should return days until birthday", async () => {
    const mockClient = new MockClient();
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const tomorrowStr = tomorrow.toISOString().split("T")[0];
    mockClient.queryObject = async () => ({ rows: [{ date_of_birth: tomorrowStr }] });
    const userService = new UserService(mockClient as any);

    const message = await userService.getUserBirthdayMessage("testuser");
    assertEquals(message, "Hello, testuser! Your birthday is in 1 day(s)");
  });
});