# MongoDB Booking Data Design

I would store bookings in a dedicated `bookings` collection and use a hybrid model. The booking document would keep the booking-specific data embedded, while `userId` and `roomId` would be stored as references to the `users` and `rooms` collections. This avoids duplicating user and room data that can change independently, while keeping the booking payload self-contained for common reads.

Example fields:

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId",
  "roomId": "ObjectId",
  "status": "confirmed",
  "dates": {
    "checkin": "ISODate",
    "checkout": "ISODate"
  },
  "pricePerNight": 120,
  "totalPrice": 480,
  "createdAt": "ISODate",
  "updatedAt": "ISODate"
}
```

I would create compound indexes on `{ roomId: 1, "dates.checkin": 1, "dates.checkout": 1 }` to support availability and overlap checks, `{ userId: 1, createdAt: -1 }` for a user's booking history, and `{ status: 1, createdAt: -1 }` for operational queries and reports. A unique index could also be considered for an external booking reference.

During testing in MongoDB Compass or `mongosh`, I would validate field types, required fields, allowed status values, date order, references to existing users and rooms, and calculated totals. I would run queries for invalid records, for example bookings where `dates.checkout <= dates.checkin`, `totalPrice < 0`, or `status` is outside the allowed set. I would also test duplicate and overlapping bookings for the same room, verify index usage with `explain("executionStats")`, and compare API responses with the stored documents. Finally, I would check that create, update, cancellation, and deletion operations change only the expected fields and preserve audit timestamps.
