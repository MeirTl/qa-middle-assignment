-- SQL dialect: PostgreSQL 14+
-- Schema:
-- Users(id, name, email, created_at)
-- Rooms(id, type, price_per_night)
-- Bookings(id, user_id, room_id, checkin, checkout, status, created_at)
-- status: 'pending' | 'confirmed' | 'cancelled'

-- QA check 1: Finds users without bookings to verify orphaned or inactive user records and empty-state behaviour.
SELECT
u.id,
u.name,
u.email,
u.created_at
FROM Users AS u
WHERE NOT EXISTS (
SELECT 1
FROM Bookings AS b
WHERE b.user_id = u.id
)
ORDER BY u.id;

-- QA check 2: Finds overlapping active bookings for the same room to detect double-booking and date-range validation defects.
SELECT
b1.room_id,
b1.id AS first_booking_id,
b1.checkin AS first_checkin,
b1.checkout AS first_checkout,
b1.status AS first_status,
b2.id AS second_booking_id,
b2.checkin AS second_checkin,
b2.checkout AS second_checkout,
b2.status AS second_status
FROM Bookings AS b1
JOIN Bookings AS b2
ON b1.room_id = b2.room_id
AND b1.id < b2.id
AND b1.checkin < b2.checkout
AND b2.checkin < b1.checkout
WHERE b1.status IN ('pending', 'confirmed')
AND b2.status IN ('pending', 'confirmed')
ORDER BY
b1.room_id,
b1.checkin,
b2.checkin;

-- QA check 3: Shows the three most frequently confirmed rooms created during the last 30 days for reporting and aggregation validation.
SELECT
r.id AS room_id,
r.type AS room_type,
COUNT(b.id) AS confirmed_booking_count
FROM Rooms AS r
JOIN Bookings AS b
ON b.room_id = r.id
WHERE b.status = 'confirmed'
AND b.created_at >= CURRENT_TIMESTAMP - INTERVAL '30 days'
GROUP BY
r.id,
r.type
ORDER BY
confirmed_booking_count DESC,
r.id
LIMIT 3;

-- QA check 4: Finds stale confirmed bookings whose check-in date has passed to verify lifecycle processing and missed status updates.
SELECT
b.id,
b.user_id,
b.room_id,
b.checkin,
b.checkout,
b.status,
b.created_at
FROM Bookings AS b
WHERE b.status = 'confirmed'
AND b.created_at < CURRENT_TIMESTAMP - INTERVAL '7 days'
AND b.checkin < CURRENT_DATE
ORDER BY
b.checkin,
b.created_at;

-- QA check 5: Counts confirmed bookings by room type to validate GROUP BY results and business-report totals.
SELECT
r.type AS room_type,
COUNT(b.id) AS confirmed_booking_count
FROM Rooms AS r
LEFT JOIN Bookings AS b
ON b.room_id = r.id
AND b.status = 'confirmed'
GROUP BY
r.type
ORDER BY
confirmed_booking_count DESC,
r.type;

