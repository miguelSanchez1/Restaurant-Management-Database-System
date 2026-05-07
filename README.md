# 🍽️ Restaurant Management Database System

> A cloud-deployed PostgreSQL backend that runs the front-of-house: customers, reservations, tables, menu, orders, and payments — all wired up with triggers, views, and demo queries.

![Postgres](https://img.shields.io/badge/database-PostgreSQL-336791?logo=postgresql&logoColor=white)
![Supabase](https://img.shields.io/badge/cloud-Supabase-3ECF8E?logo=supabase&logoColor=white)
![Status](https://img.shields.io/badge/status-Phase%202%20%E2%80%94%20Live-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)

https://th.bing.com/th/id/OIP.wFhiiyNCcouL5OGgrOtY5wHaE8?w=278&h=185&c=7&r=0&o=7&dpr=1.3&pid=1.7&rm=3
 
CPSC 332 — Final Project, Phase 2: Implementation & Presentation

---

## 🧭 Quick navigation

You are here: `/` (root repo guide)

- 📐 **Schema:** [`001_init.sql`](./001_init.sql)
- 🌱 **Seed data:** [`002_seed_data.sql`](./002_seed_data.sql)
- ⚡ **Triggers:** [`003_triggers.sql`](./003_triggers.sql)
- 👁️ **Views:** [`004_views.sql`](./004_views.sql)
- 🔍 **Example queries (READ / UPDATE / DELETE):** [`005_queries.sql`](./005_queries.sql)
- 📊 **ER diagram:** *paste your dbdiagram.io link here*
- 🎥 **Cloud demo recording:** *paste your video link here*
- 🛝 **Live database:** Supabase (PostgreSQL, free tier)

---

## 🧠 What this repo is (and isn't)

- ✅ A live record of how a small restaurant could run its operations — bookings, dine-in & takeout orders, payments, and reporting — driven entirely from SQL.
- ✅ A teaching project showing version-controlled migrations, seed data, triggers, views, and CRUD queries deployed to a real cloud database.
- ❌ Not a turnkey clone-and-run app. There is no front-end here; everything is the database layer. To use it elsewhere, fork it, point at your own Supabase (or any Postgres) instance, and run the migrations in order.
- ❌ Not a production system. Sample data is intentionally small and human-readable so the queries return meaningful results during the demo.

Commits double as a changelog — browse history for design rationale behind each table and trigger.

---

## 🗂️ Repo layout

```
Restaurant-Management-Database-System/
├── 001_init.sql        # CREATE TABLEs, PK/FK, CHECK constraints, indexes
├── 002_seed_data.sql   # INSERT statements for every table
├── 003_triggers.sql    # Business-rule automation (totals, capacity, payment status)
├── 004_views.sql       # Reporting views for dashboards
├── 005_queries.sql     # READ / UPDATE / DELETE examples (CRUD demo)
└── README.md           # You are here
```

> Migration files are numbered so they run **in order** — `001` first, `005` last. Don't skip ahead; later files depend on earlier ones.

---

## 🛠️ Platform

- **Database:** PostgreSQL (cloud-hosted on **Supabase**, free tier)
- **Schema designed in:** [dbdiagram.io](https://dbdiagram.io/home)
- **Migrations:** plain `.sql` files, version-controlled here on GitHub
- **Demo:** screen recording of the SQL Editor running each migration in order

---

## 🧱 Database schema at a glance

Eight core tables, all linked by foreign keys:

| Table | What it stores |
|---|---|
| 👤 `customer` | Diners — name, phone, email, signup time |
| 🧑‍🍳 `staff` | Employees and their role (Manager / Server / Host / Cashier) |
| 🍽️ `restaurant_table` | Physical tables, seating capacity, current status |
| 📋 `menu_item` | Dishes & drinks with category, price, availability |
| 📅 `reservation` | Bookings linking customer → table → host |
| 🧾 `customer_order` | Dine-in or takeout orders, with running total |
| 🥘 `order_item` | Line items inside each order (quantity × unit price) |
| 💳 `payment` | One payment row per order — Cash / Card / Mobile |

Indexes are defined on the columns we filter on most (reservation time, order status, payment status) so the dashboard views stay snappy.

---

## ⭐ Featured examples to start with

Want to see the interesting parts first? Jump to these:

- 🔁 **Auto-calculated line totals** → `fn_set_order_item_total` in [`003_triggers.sql`](./003_triggers.sql) — quantity × unit price is computed automatically on insert/update so order totals can never drift.
- 💰 **Order total stays in sync** → `fn_refresh_order_total` rolls up `order_item.line_total` into `customer_order.total_amount` whenever items are added, edited, or removed.
- 🚫 **No overbooking** → `fn_check_reservation_capacity` rejects reservations whose `party_size` exceeds the table's `seating_capacity` *before* the row is saved.
- ✅ **Payments mark orders paid** → `fn_mark_order_paid` flips `customer_order.order_status` to `Paid` the moment a payment row is marked Paid, so the host stand and the kitchen always agree.
- 📊 **Reporting views** → see [`004_views.sql`](./004_views.sql):
  - `vw_reservation_schedule` — today's bookings, ordered by time
  - `vw_order_summary` — orders with customer + server + total
  - `vw_payment_summary` — payments with customer + method
  - `vw_table_status` — which tables are free / reserved / occupied right now
  - `vw_sales_by_menu_item` — best- and worst-selling dishes
- 🧪 **CRUD examples** → [`005_queries.sql`](./005_queries.sql) covers the assignment minimums (3 READ, 6 UPDATE, 6 DELETE), each with a `BEGIN; … ROLLBACK;` block so you can re-run the demo without touching seed data.

---

## 🎬 Demo evidence

The cloud demo recording walks through, in this order:

1. ▶️ Running `001_init.sql` — schema is created from scratch
2. ▶️ Running `002_seed_data.sql` — every table populated with believable data
3. ▶️ Running `003_triggers.sql` and `004_views.sql` — automation + reporting layer
4. ▶️ Running `005_queries.sql` — READ joins, UPDATE round-trips, DELETE with dependency cleanup
5. ▶️ Spot-checking the views in the Supabase Table Editor

📽️ **Watch the demo:** *paste link here*
📐 **dbdiagram link:** *paste link here*

---

## 👥 Contributors

This was a team effort — every member contributed commits to the repo:

- **Miguel Sanchez**
- **Joseph Villacorte**
- **Kakeru Minamikawa**

See [GitHub Contributors](../../graphs/contributors) for the commit history.

---

## 📄 License

MIT — feel free to fork, learn from, and adapt for your own coursework.

---

