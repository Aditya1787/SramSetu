# Technical Requirements Document (TRD) — SRAM SETU

## 1. System Architecture Overview

```
                         +-----------------------------------+
                         |       Flutter Client Application  |
                         |   (Customer, Technician, Admin)   |
                         +-----------------+-----------------+
                                           |
                                  HTTPS / WSS (Realtime)
                                           |
                                           v
                         +-----------------------------------+
                         |       Supabase Backend Platform   |
                         +-----------------+-----------------+
                                           |
     +-------------------+-----------------+-------------------+-------------------+
     |                   |                 |                   |                   |
     v                   v                 v                   v                   v
+----+---------+   +-----+--------+  +-----+--------+   +------+-------+   +-------+------+
| Supabase     |   | PostgreSQL   |  | Supabase     |   | Supabase     |   | Supabase     |
| Auth         |   | Database     |  | Storage      |   | Realtime     |   | Edge Funcs   |
+--------------+   +--------------+  +--------------+   +--------------+   +-------+------+
                                                                                   |
                                                        +--------------------------+--------------------------+
                                                        |                          |                          |
                                                        v                          v                          v
                                              +---------+--------+       +---------+--------+       +---------+--------+
                                              | Firebase Cloud   |       | Payment Gateway  |       | Google Maps      |
                                              | Messaging (FCM)  |       | (Razorpay/UPI)   |       | Distance Matrix  |
                                              +------------------+       +------------------+       +------------------+
```

---

## 2. Technology Stack

| Layer | Component | Technology / Library |
| :--- | :--- | :--- |
| **Frontend** | Cross-Platform Framework | Flutter (Dart SDK 3.x+) |
| **State Management** | Application State | Flutter Riverpod (`flutter_riverpod`, `riverpod_annotation`) |
| **Routing** | Declarative Navigation | `go_router` |
| **Networking & BaaS** | Supabase Client | `supabase_flutter` (Auth, PostgREST, Realtime, Storage) |
| **Data Models** | Serialization & Immutability | `freezed_annotation`, `json_annotation`, `build_runner` |
| **Backend & DB** | Relational Database | Supabase Managed PostgreSQL |
| **Serverless Logic** | Business Logic Edge | Supabase Edge Functions (Deno / TypeScript) |
| **Realtime Engine** | WebSocket Broadcasting | Supabase Realtime (Postgres Changes & Broadcast Channels) |
| **File Storage** | Blob Storage & Documents | Supabase Storage Buckets (Public for avatars/services, Private for ID docs) |
| **Push Notifications** | Device Notifications | Firebase Cloud Messaging (FCM) + `flutter_local_notifications` |
| **Maps & Geolocation** | Maps & Reverse Geocoding | `google_maps_flutter`, `geolocator`, `geocoding` |

---

## 3. Database Schema (PostgreSQL DDL)

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES TABLE
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    email TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL CHECK (role IN ('customer', 'technician', 'admin')) DEFAULT 'customer',
    fcm_token TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. SERVICE CATEGORIES TABLE
CREATE TABLE public.service_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    icon_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. SERVICES TABLE
CREATE TABLE public.services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES public.service_categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    base_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. SERVICE PROBLEMS TABLE
CREATE TABLE public.service_problems (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    estimated_duration_mins INT DEFAULT 60,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. MATERIALS TABLE
CREATE TABLE public.materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    unit TEXT NOT NULL DEFAULT 'piece',
    current_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    is_active BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. SERVICE PRICING TABLE
CREATE TABLE public.service_pricing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    problem_id UUID UNIQUE NOT NULL REFERENCES public.service_problems(id) ON DELETE CASCADE,
    material_cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    labour_cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    visit_charge DECIMAL(10, 2) NOT NULL DEFAULT 50.00,
    emergency_charge DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    platform_fee DECIMAL(10, 2) NOT NULL DEFAULT 20.00,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. TECHNICIANS TABLE
CREATE TABLE public.technicians (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    service_category_id UUID REFERENCES public.service_categories(id),
    experience_years INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 5.00,
    total_jobs INT DEFAULT 0,
    verification_status TEXT CHECK (verification_status IN ('PENDING', 'VERIFIED', 'REJECTED', 'SUSPENDED')) DEFAULT 'PENDING',
    is_available BOOLEAN DEFAULT false,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. ADDRESSES TABLE
CREATE TABLE public.addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    label TEXT DEFAULT 'Home',
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    pincode TEXT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. QUOTATIONS TABLE
CREATE TABLE public.quotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subtotal DECIMAL(10, 2) NOT NULL,
    visit_charge DECIMAL(10, 2) NOT NULL DEFAULT 50.00,
    emergency_charge DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    platform_fee DECIMAL(10, 2) NOT NULL DEFAULT 20.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    status TEXT CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'EXPIRED', 'UPDATED')) DEFAULT 'PENDING',
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 10. QUOTATION ITEMS TABLE
CREATE TABLE public.quotation_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quotation_id UUID NOT NULL REFERENCES public.quotations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    item_type TEXT CHECK (item_type IN ('MATERIAL', 'LABOUR', 'VISIT', 'EMERGENCY', 'PLATFORM_FEE')) NOT NULL
);

-- 11. BOOKINGS TABLE
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    technician_id UUID REFERENCES public.technicians(id),
    service_id UUID NOT NULL REFERENCES public.services(id),
    problem_id UUID REFERENCES public.service_problems(id),
    quotation_id UUID REFERENCES public.quotations(id),
    address_id UUID NOT NULL REFERENCES public.addresses(id),
    description TEXT,
    scheduled_at TIMESTAMPTZ NOT NULL,
    is_emergency BOOLEAN DEFAULT false,
    status TEXT CHECK (status IN (
        'REQUESTED', 'QUOTATION_READY', 'CUSTOMER_ACCEPTED',
        'SEARCHING_TECHNICIAN', 'TECHNICIAN_ASSIGNED', 'TECHNICIAN_ACCEPTED',
        'ON_THE_WAY', 'ARRIVED', 'IN_PROGRESS', 'EXTRA_WORK_APPROVAL_PENDING',
        'COMPLETED', 'CANCELLED', 'DISPUTED'
    )) DEFAULT 'REQUESTED',
    payment_status TEXT CHECK (payment_status IN ('PENDING', 'PROCESSING', 'PAID', 'FAILED', 'REFUNDED')) DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. MESSAGES TABLE (Realtime Chat)
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id),
    receiver_id UUID NOT NULL REFERENCES public.profiles(id),
    message TEXT NOT NULL,
    message_type TEXT CHECK (message_type IN ('TEXT', 'IMAGE', 'SYSTEM')) DEFAULT 'TEXT',
    attachment_url TEXT,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. TECHNICIAN LOCATIONS TABLE
CREATE TABLE public.technician_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    technician_id UUID NOT NULL REFERENCES public.technicians(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. PAYMENTS TABLE
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id),
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    amount DECIMAL(10, 2) NOT NULL,
    payment_method TEXT CHECK (payment_method IN ('UPI', 'CASH', 'CARD', 'NET_BANKING')) NOT NULL,
    transaction_id TEXT,
    status TEXT CHECK (status IN ('PENDING', 'PROCESSING', 'PAID', 'FAILED', 'REFUNDED')) DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. REVIEWS TABLE
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID UNIQUE NOT NULL REFERENCES public.bookings(id),
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    technician_id UUID NOT NULL REFERENCES public.technicians(id),
    rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    review TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 16. COMPLAINTS TABLE
CREATE TABLE public.complaints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id),
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    technician_id UUID REFERENCES public.technicians(id),
    reason TEXT NOT NULL,
    description TEXT NOT NULL,
    status TEXT CHECK (status IN ('OPEN', 'INVESTIGATING', 'RESOLVED', 'REJECTED')) DEFAULT 'OPEN',
    admin_response TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);
```

---

## 4. Row Level Security (RLS) Policies

```sql
-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.technicians ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can read & edit their own profile. Admins read all.
CREATE POLICY "Users view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Bookings: Customers view/create own. Assigned Technicians view/update assigned. Admins access all.
CREATE POLICY "Customer view own bookings" ON public.bookings FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "Customer create own bookings" ON public.bookings FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Technician view assigned bookings" ON public.bookings FOR SELECT USING (
    technician_id IN (SELECT id FROM public.technicians WHERE user_id = auth.uid())
);
CREATE POLICY "Technician update assigned bookings" ON public.bookings FOR UPDATE USING (
    technician_id IN (SELECT id FROM public.technicians WHERE user_id = auth.uid())
);

-- Messages: Only booking customer or assigned technician can view/send messages
CREATE POLICY "Booking participants view chat" ON public.messages FOR SELECT USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
);
CREATE POLICY "Booking participants send chat" ON public.messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id
);
```

---

## 5. Supabase Edge Functions Architecture

1. **`generate-quotation`**: Takes `problem_id` & optional extra `material_ids`, reads standard price tables (`service_pricing`, `materials`), builds `quotation` + `quotation_items` records, returns itemized breakdown object.
2. **`assign-technician`**: Triggered when customer accepts quotation. Finds active technicians in same `service_category_id`, within 10km radius, available status. Ranks by distance & rating, sends job notification via FCM.
3. **`update-extra-work`**: Used by technician when new mid-job material/repair cost is discovered. Creates updated quotation version and alerts customer via push notification.
4. **`verify-payment`**: Server-side validation of UPI / Razorpay payment webhooks and updates `bookings.payment_status` to `PAID`.
5. **`send-push-notification`**: Interacts with Firebase Cloud Messaging (FCM) API using service account credentials stored securely in Supabase Secrets.

---

## 6. Flutter Module Architecture (Feature-First Clean Architecture)

```
lib/
├── core/
│   ├── constants/        # Colors, Typography, API Endpoints, Assets
│   ├── theme/            # Light/Dark Theme Data, Glassmorphism styles
│   ├── router/           # GoRouter route definitions & guards
│   ├── network/          # Supabase client wrapper & Dio network service
│   ├── errors/           # Exception handlers & Failure types
│   ├── utils/            # Formatters (Currency, Date), Location utilities
│   └── widgets/          # Shared Buttons, Cards, Inputs, Shimmers
│
├── features/
│   ├── auth/             # Login, Signup, OTP, Profile setup
│   ├── home/             # Main Dashboard, Problem Search Bar, Categories
│   ├── services/         # Category browser, Sub-services, Problem list
│   ├── quotation/        # Quotation preview modal, Price breakdown card
│   ├── booking/          # Booking creation, Address picker, Date/Time picker
│   ├── status/           # Live Booking Status Stepper & Progress Tracker
│   ├── technician/       # Technician job accept modal, Active job sheet
│   ├── chat/             # Realtime Chat UI & Image attachment handler
│   ├── payments/         # UPI Deep-link trigger, Receipt view
│   ├── profile/          # User info, Saved addresses, Booking history
│   └── admin/            # Verification queue, Category/Pricing editor
│
└── main.dart             # App Entrypoint & ProviderScope initialization
```
