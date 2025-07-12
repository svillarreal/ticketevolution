<template>
  <div class="greetings">
    <h1 class="green">Ticket Evolution - By Santiago Villarreal</h1>

    <section style="margin-bottom: 2rem">
      <h2>Create Event</h2>
      <form @submit.prevent="createEvent">
        <label>
          Name:
          <input v-model="event.name" required />
        </label>
        <label>
          Price:
          <input v-model="event.price" required />
        </label>
        <label>
          Date:
          <input v-model="event.eventDate" required />
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
        <label>
          Quantity:
          <input v-model="order.totalTickets" required />
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
          {{ e.name }} (ID: {{ e.id }}) — Available: {{ e.totalTickets - e.soldTickets }}
        </li>
      </ul>
      <p v-else>No events loaded.</p>
    </section>

    <section>
      <h2>All Orders</h2>
      <button @click="loadOrders">Load Orders</button>
      <ul v-if="orders.length">
        <li v-for="o in orders" :key="o.id">
          Order {{ o.id }}: User {{ o.userId }} → Event {{ o.eventId }} @
          {{ new Date(o.createdAt).toLocaleString() }}
        </li>
      </ul>
      <p v-else>No orders loaded.</p>
    </section>
  </div>
</template>

<script setup>
import { ref } from "vue";

const event = ref({ name: "", totalTickets: 0 });
const order = ref({ userId: "", eventId: "", totalTickets: "" });

const events = ref([]);
const orders = ref([]);

const eventResult = ref("");
const orderResult = ref("");

const createEvent = async () => {
  eventResult.value = "Sending…";
  const res = await fetch("/api/event", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(event.value),
  });
  eventResult.value = await res.text();
};

const createOrder = async () => {
  orderResult.value = "Sending…";
  const res = await fetch("/api/order", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(order.value),
  });
  orderResult.value = await res.text();
};

const loadEvents = async () => {
  events.value = [];
  try {

    const myHeaders = new Headers();
    myHeaders.append("Content-Type", "application/json");

    const raw = JSON.stringify({});

    const requestOptions = {
      method: "POST",
      headers: myHeaders,
      body: raw,
      redirect: "follow"
    };

    const res = await fetch("/api/event/find", requestOptions);
    events.value = await res.json();
  } catch (err) {
    console.error(err);
  }
};

const loadOrders = async () => {
  orders.value = [];
  try {
    const myHeaders = new Headers();
    myHeaders.append("Content-Type", "application/json");

    const raw = JSON.stringify({});

    const requestOptions = {
      method: "POST",
      headers: myHeaders,
      body: raw,
      redirect: "follow"
    };

    const res = await fetch("/api/order/find", requestOptions);
    orders.value = await res.json();
  } catch (err) {
    console.error(err);
  }
};
</script>


<style scoped>
h1 {
  font-weight: 500;
  font-size: 2.6rem;
  position: relative;
  top: -10px;
}

h3 {
  font-size: 1.2rem;
}

.greetings h1,
.greetings h3 {
  text-align: center;
}

@media (min-width: 1024px) {

  .greetings h1,
  .greetings h3 {
    text-align: left;
  }
}
</style>
