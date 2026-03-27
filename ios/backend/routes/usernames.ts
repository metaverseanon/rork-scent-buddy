import { Hono } from "hono";

const usernameRouter = new Hono();

const takenUsernames = new Set<string>();

usernameRouter.get("/check", async (c) => {
  const username = c.req.query("username")?.trim().toLowerCase();

  if (!username) {
    return c.json({ available: false, error: "Username is required" }, 400);
  }

  if (username.length < 3) {
    return c.json({ available: false, error: "Username must be at least 3 characters" }, 400);
  }

  if (username.length > 20) {
    return c.json({ available: false, error: "Username must be 20 characters or less" }, 400);
  }

  const validPattern = /^[a-z0-9._]+$/;
  if (!validPattern.test(username)) {
    return c.json({ available: false, error: "Only letters, numbers, dots, and underscores allowed" }, 400);
  }

  const isAvailable = !takenUsernames.has(username);
  return c.json({ available: isAvailable, username });
});

usernameRouter.post("/register", async (c) => {
  const body = await c.req.json();
  const username = body.username?.trim().toLowerCase();

  if (!username) {
    return c.json({ success: false, error: "Username is required" }, 400);
  }

  if (username.length < 3 || username.length > 20) {
    return c.json({ success: false, error: "Username must be 3-20 characters" }, 400);
  }

  const validPattern = /^[a-z0-9._]+$/;
  if (!validPattern.test(username)) {
    return c.json({ success: false, error: "Only letters, numbers, dots, and underscores allowed" }, 400);
  }

  if (takenUsernames.has(username)) {
    return c.json({ success: false, error: "Username is already taken" }, 409);
  }

  takenUsernames.add(username);
  return c.json({ success: true, username });
});

usernameRouter.post("/release", async (c) => {
  const body = await c.req.json();
  const username = body.username?.trim().toLowerCase();

  if (username) {
    takenUsernames.delete(username);
  }

  return c.json({ success: true });
});

export { usernameRouter };
