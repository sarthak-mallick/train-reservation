# Train Reservation System
## Create users, tables, grants, initial data
1. (ADMIN) Run Create_Users.sql to create users and assign roles
2. (CRS_ADMIN) Run DDL.sql to create schema tables
3. (CRS_ADMIN) Run Grant_Permissions.sql to allow roles access to certain tables
4. (CRS_DATA) Run DML.sql to fill all tables with initial data
5. (CRS_ADMIN) Open Create_Packages.sql and run to create all packages and views

## Standard Workflow
```
┌─────────────────────────────────────────────────────────────────────────┐
│                        TRAIN RESERVATION WORKFLOW                        │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐
│   CRS_OPERATIONS     │  Train Setup & Management
└──────────────────────┘
         │
         ├─► 1. Create Train
         │   PKG_TRAIN.add_train()
         │   ↓
         │   Train ID: 1, TR001: New York → Boston
         │
         ├─► 2. Schedule Train
         │   PKG_TRAIN.add_train_to_schedule(train_id=1, sch_id=1-7)
         │   ↓
         │   Train operates: Mon-Sun
         └─────────────────────────────────────────────────────┐
                                                                │
                                                                ▼
                                              ┌──────────────────────────┐
                                              │      CRS_AGENT           │  Passenger & Booking
                                              └──────────────────────────┘
                                                       │
                                                       ├─► 3. Register Passenger
                                                       │   PKG_PASSENGER.register_passenger()
                                                       │   ↓
                                                       │   Passenger ID: 100, John Doe
                                                       │
                                                       ├─► 4. Book Ticket
                                                       │   PKG_BOOKING.book_ticket(passenger_id=100, train_id=1, ...)
                                                       │   ↓
                                                       │   Booking ID: 500, Status: CONFIRMED
                                                       │
                                                       └─► 5. Cancel Ticket (Optional)
                                                           PKG_BOOKING.cancel_ticket(booking_id=500)
                                                           ↓
                                                           ┌─────────────────────────────────────┐
                                                           │ Automatic Waitlist Promotion        │
                                                           │ • Find waitlist position 1          │
                                                           │ • Promote to CONFIRMED              │
                                                           │ • Reorder positions 2-5 → 1-4       │
                                                           └─────────────────────────────────────┘
```
## Key Business Rules

- 📅 Book up to **7 days** in advance
- 🎫 **40 seats** per class (FC/ECON)
- ⏳ **5 waitlist** positions per class
- 🚫 No cancellation/modification on **day of travel**
- 🔄 Automatic **waitlist promotion** on cancellation
- ⛔ **No duplicate** bookings per passenger per train/date

## Packages

### PKG_VALIDATION
Validates all booking requests, checks seat availability, enforces business rules (7-day window, no duplicates, 40 seats + 5 waitlist limits).

### PKG_BOOKING
Handles ticket booking and cancellation with automatic waitlist promotion and reordering.

### PKG_PASSENGER
Manages passenger registration, updates contact information, and searches passengers by email, phone, or ID.

### PKG_TRAIN
Creates and updates trains, manages day-of-week schedules, and handles train cancellations.

## Users and Roles

| User | Role | Role Description |
|------|------|------------------|
| **crs_admin** | Schema Owner | Owns all database objects (tables, packages, views) |
| **crs_data** | Data Admin | Loads and maintains data (full DML on tables) |
| **crs_agent** | Booking Agent | Book/cancel/modify tickets, register passengers |
| **crs_operations** | Train Operations | Create/update trains, manage schedules, cancel trains |
| **crs_reports** | Analytics | Read-only access to all tables and views for reporting |

## Package Access by Role

| Package | crs_agent_role | crs_operations_role | crs_report_role |
|---------|----------------|---------------------|-----------------|
| PKG_VALIDATION | ✅ EXECUTE | ✅ EXECUTE | ❌ None |
| PKG_BOOKING | ✅ EXECUTE | ❌ None | ❌ None |
| PKG_PASSENGER | ✅ EXECUTE | ❌ None | ❌ None |
| PKG_TRAIN | ❌ None | ✅ EXECUTE | ❌ None |
