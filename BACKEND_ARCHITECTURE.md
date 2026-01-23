# Q-Less Backend Architecture Plan

## Technology Stack
- **Language**: Python 3.10+
- **Framework**: FastAPI (High performance, easy async support for WebSockets)
- **Database**: MongoDB (Flexible schema for products and cart sessions)
- **Real-time**: WebSocket (via FastAPI) for "Sync-Cart" functionality
- **Authentication**: JWT (JSON Web Tokens)
- **Payments**: UPI Integration mock / PhonePe / Paytm API (for India context) or Stripe

## Core Features & Endpoints
c
### 1. Authentication (`/auth`)
- `POST /register`: Sign up with mobile/email.
- `POST /login`: Get JWT token.
- `GET /me`: Get user profile.

### 2. Product Management (`/products`)
- `GET /products/{barcode}`: Fast lookup for scanned items.
- `GET /search?q={query}`: Search manually.
- **Optimization**: Use Redis cache for product lookups to ensure instant scan results.

### 3. Shopping Session (The "Cart") (`/session`)
- `POST /session/start`: Initialize a shopping trip (generates a `session_id`).
- `POST /session/join`: Family members join via QR code/Link (WebSocket connection).
- `POST /cart/add`: Add item to shared cart.
- `POST /cart/remove`: Remove item.
- `WS /ws/cart/{session_id}`: WebSocket endpoint for real-time updates across multiple devices.

### 4. Smart Budgeter Logic (Backend)
- Backend calculates total vs. user-set budget.
- Returns status flags: `SAFE` (Green), `WARNING` (Orange), `DANGER` (Red).

### 5. Checkout & Exit (`/checkout`)
- `POST /checkout/calculate`: Finalize totals, apply discounts/coupons.
- `POST /payment/initiate`: Start UPI transaction.
- `POST /payment/webhook`: Callback for payment success.
- `POST /exit-pass/generate`: Create a secure, time-limited QR token for the exit gate.

### 6. Rewards & History (`/user`)
- `GET /orders/history`: Fetch past purchases.
- `GET /rewards/balance`: Get current points.

## Data Models (MongoDB)

### User
```json
{
  "_id": "uuid",
  "name": "Shivam",
  "phone": "+919876543210",
  "reward_points": 1250,
  "history": ["order_id_1", "order_id_2"]
}
```

### Product
```json
{
  "_id": "ean_13_code",
  "name": "Maggi Noodles",
  "price": 12.00,
  "category": "Food",
  "images": ["url1"]
}
```

### ActiveSession (Cart)
```json
{
  "_id": "session_uuid",
  "host_user_id": "uuid",
  "participants": ["uuid1", "uuid2"],
  "items": [
    {"product_id": "ean_123", "qty": 2, "added_by": "uuid1"}
  ],
  "budget_limit": 2000,
  "status": "active" // or "completed"
}
```

## Recommended Folder Structure
```
backend/
├── app/
│   ├── main.py
│   ├── api/
│   │   ├── auth.py
│   │   ├── products.py
│   │   ├── cart.py
│   │   └── payment.py
│   ├── core/
│   │   ├── config.py
│   │   └── security.py
│   ├── models/
│   ├── services/
│   │   └── websocket_manager.py
│   └── websockets/
├── requirements.txt
└── Dockerfile
```
