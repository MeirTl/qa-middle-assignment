# Booking Creation Sequence Diagram

```mermaid
sequenceDiagram
    actor User
    participant Frontend
    participant API
    participant Database
    participant PaymentService as Payment Service
    participant EmailService as Email Service

    User->>Frontend: Select room, dates and enter details
    Frontend->>API: POST /bookings
    API->>Database: Check room availability
    Database-->>API: Availability result

    alt Room is unavailable
        API-->>Frontend: 409 Conflict
        Frontend-->>User: Show room unavailable message
    else Room is available
        API->>Database: Create booking with pending status
        Database-->>API: Return booking ID

        API->>PaymentService: Authorize payment

        alt Payment fails
            PaymentService-->>API: Payment rejected
            API->>Database: Set status to cancelled
            API-->>Frontend: 402 Payment Required
            Frontend-->>User: Show payment failure
        else Payment succeeds
            PaymentService-->>API: Payment confirmed
            API->>Database: Set status to confirmed
            Database-->>API: Booking updated

            API->>EmailService: Send booking confirmation
            EmailService-->>API: Notification accepted

            API-->>Frontend: 201 Created with booking details
            Frontend-->>User: Show booking confirmation
        end
    end
```

## Main verification points

* The API checks availability before creating a booking.
* A booking is initially created with `pending` status.
* The status changes to `confirmed` only after successful payment.
* Failed payments do not leave an active booking.
* The confirmation email is sent only after the database update succeeds.
* Error responses are returned to the frontend without exposing internal implementation details.

