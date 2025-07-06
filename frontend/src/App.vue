<template>
  <div style="max-width: 600px; margin: auto; padding: 2rem">
    <h1>Ticket Evolution - By Santiago Villarreal</h1>

    <section style="margin-bottom: 2rem">
      <h2>Create Event</h2>
      <form @submit.prevent="createEvent">
        <label>
          Event ID:
          <input v-model="event.id" required />
        </label>
        <label>
          Name:
          <input v-model="event.name" required />
        </label>
        <label>
          Total Tickets:
          <input v-model.number="event.totalTickets" type="number" required />
        </label>
        <button type="submit">Create Event</button>
      </form>
      <p v-if="eventResult">{{ eventResult }}</p>
    </section>

    <section style="margin-bottom: 2rem">
      <h2>Create Order</h2>
      <form @submit.prevent="createOrder">
        <label>
          User ID:
          <input v-model="order.userId" required />
        </label>
        <label>
          Event ID:
          <input v-model="order.eventId" required />
        </label>
        <button type="submit">Create Order</button>
      </form>
      <p v-if="orderResult">{{ orderResult }}</p>
    </section>

    <section style="margin-bottom: 2rem">
      <h2>All Events</h2>
      <button @click="loadEvents">Load Events</button>
      <ul v-if="events.length">
        <li v-for="e in events" :key="e.id">
          {{ e.name }} (ID: {{ e.id }}) — Available: {{ e.available }}
        </li>
      </ul>
      <p v-else>No events loaded.</p>
    </section>

    <section>
      <h2>All Orders</h2>
      <button @click="loadOrders">Load Orders</button>
      <ul v-if="orders.length">
        <li v-for="o in orders" :key="o.id">
          Order {{ o.id }}: User {{ o.user_id }} → Event {{ o.event_id }} @
          {{ new Date(o.created_at).toLocaleString() }}
        </li>
      </ul>
      <p v-else>No orders loaded.</p>
    </section>
  </div>
</template>

<script setup>
import { ref } from "vue";

const event = ref({ id: "", name: "", totalTickets: 0 });
const order = ref({ userId: "", eventId: "" });

const events = ref([]);
const orders = ref([]);

const eventResult = ref("");
const orderResult = ref("");

const createEvent = async () => {
  eventResult.value = "Sending…";
  const res = await fetch("/api/events", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(event.value),
  });
  eventResult.value = await res.text();
};

const createOrder = async () => {
  orderResult.value = "Sending…";
  const res = await fetch("/api/orders", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(order.value),
  });
  orderResult.value = await res.text();
};

const loadEvents = async () => {
  events.value = [];
  try {
    const res = await fetch("/api/events");
    events.value = await res.json();
  } catch (err) {
    console.error(err);
  }
};

const loadOrders = async () => {
  orders.value = [];
  try {
    const res = await fetch("/api/orders");
    orders.value = await res.json();
  } catch (err) {
    console.error(err);
  }
};
</script>

<style>
label {
  display: block;
  margin-top: 0.5rem;
}
input {
  width: 100%;
  padding: 0.25rem;
  margin-bottom: 0.5rem;
}
button {
  margin-top: 0.5rem;
}
ul {
  margin-top: 0.5rem;
  padding-left: 1rem;
}
li {
  margin-bottom: 0.25rem;
}
</style>
