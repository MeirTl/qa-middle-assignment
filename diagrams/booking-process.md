# Booking Creation and Cancellation Process

The diagram describes the booking flow from the user's perspective. It includes the main successful path and exception paths for an unavailable room and a failed payment.

```mermaid
flowchart TD
    START([Start])

    subgraph User
        U1[Search for a room]
        U2[Select room and dates]
        U3[Enter guest and payment details]
        U4[Review confirmed booking]
        U5{Cancel booking?}
        U6[Request cancellation]
        U7[Select another room or dates]
        U8[Retry payment or stop]
    end

    subgraph Frontend
        F1[Display available rooms]
        F2[Submit booking request]
        F3[Show room unavailable message]
        F4[Show payment failure]
        F5[Show booking confirmation]
        F6[Submit cancellation request]
        F7[Show cancellation confirmation]
    end

    subgraph Backend
        B1[Check room availability]
        G1{Room available?}
        B2[Create booking with pending status]
        B3[Process payment]
        G2{Payment successful?}
        B4[Set booking status to confirmed]
        B5[Send confirmation email]
        B6[Cancel pending booking and release room]
        B7[Set booking status to cancelled]
        B8[Release room]
        B9[Send cancellation email]
    end

    END1([Booking remains confirmed])
    END2([Booking cancelled])
    END3([Process stopped])

    START --> U1
    U1 --> F1
    F1 --> U2
    U2 --> U3
    U3 --> F2
    F2 --> B1
    B1 --> G1

    G1 -- No --> F3
    F3 --> U7
    U7 --> U1

    G1 -- Yes --> B2
    B2 --> B3
    B3 --> G2

    G2 -- No --> B6
    B6 --> F4
    F4 --> U8
    U8 --> END3

    G2 -- Yes --> B4
    B4 --> B5
    B5 --> F5
    F5 --> U4
    U4 --> U5

    U5 -- No --> END1
    U5 -- Yes --> U6
    U6 --> F6
    F6 --> B7
    B7 --> B8
    B8 --> B9
    B9 --> F7
    F7 --> END2
```

## Covered paths

1. **Happy path:** the room is available, payment succeeds, and the booking becomes confirmed.
2. **Exception 1:** the selected room is unavailable, so the user returns to the search.
3. **Exception 2:** payment fails, so the pending booking is cancelled and the room is released.
4. **Cancellation path:** the user cancels a confirmed booking, after which the room is released and a notification is sent.
