import { Hono } from "hono";
import { cors } from "hono/cors";
import { trendingRouter } from "./routes/trending";
import { usernameRouter } from "./routes/usernames";

const app = new Hono();

app.use("*", cors());

app.get("/", (c) => {
  return c.json({ status: "ok", message: "ScentBuddy API is running" });
});

app.route("/trending", trendingRouter);
app.route("/usernames", usernameRouter);

export default app;
