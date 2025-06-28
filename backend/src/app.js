import express from "express";
import { loadConfig } from "./config.js";
import { initDb, getDb } from "./db.js";

const app = express();
app.use(express.json());

app.get("/api/health", (_req, res) => {
  return res.status(200).json({ status: "ok" });
});

app.post("/api/events", async (req, res) => {
  const { id, name, totalTickets } = req.body;
  if (!id || !name || !totalTickets) {
    return res.status(400).send("Missing required fields");
  }

  try {
    await getDb()("events").insert({
      id,
      name,
      available: totalTickets,
    });
    res.status(201).send("Event created");
  } catch (err) {
    res.status(400).send(err.message);
  }
});

app.post("/api/orders", async (req, res) => {
  const { userId, eventId } = req.body;
  if (!userId || !eventId) {
    return res.status(400).send("Missing userId or eventId");
  }

  try {
    await getDb().transaction(async (trx) => {
      const event = await trx("events")
        .where({ id: eventId })
        .forUpdate()
        .first();
      if (!event) throw new Error("Event not found");
      if (event.available < 1) throw new Error("Sold out");

      await trx("events")
        .where({ id: eventId })
        .update({ available: event.available - 1 });
      await trx("orders").insert({ user_id: userId, event_id: eventId });
    });

    res.status(201).send("Order confirmed");
  } catch (err) {
    res.status(400).send(err.message);
  }
});

app.get("/api/events", async (_req, res) => {
  try {
    const events = await getDb()("events").select("id", "name", "available");
    res.json(events);
  } catch (err) {
    console.error(err);
    res.status(500).send(err.message);
  }
});

app.get("/api/orders", async (req, res) => {
  try {
    const { eventId, userId } = req.query;
    const qb = getDb()("orders").select(
      "id",
      "user_id",
      "event_id",
      "created_at"
    );
    const orders = await qb;
    res.json(orders);
  } catch (err) {
    console.error(err);
    res.status(500).send(err.message);
  }
});

loadConfig()
  .then(() => {
    initDb();
    app.listen(3000, () => console.log("Server running on port 3000"));
  })
  .catch((err) => {
    console.error("Startup failed:", err);
    process.exit(1);
  });
