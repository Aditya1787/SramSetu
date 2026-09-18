-- ==============================================================================
-- SRAM SETU — Production SQL Schema Migration (Phase 1, Step 2)
-- Core 16 Tables with Foreign Keys, Constraints, and Geospatial Indexing
-- ==============================================================================

-- Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Profiles Table (Linked to auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    role TEXT NOT NULL CHECK (role IN ('customer', 'technician', 'admin')) DEFAULT 'customer',
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Service Categories (Electrician, Plumber, Carpenter, AC, RO, etc.)
CREATE TABLE IF NOT EXISTS public.service_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    icon TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Specific Services
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES public.service_categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    base_price NUMERIC(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Standard Problems Under Services
CREATE TABLE IF NOT EXISTS public.service_problems (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    typical_resolution_minutes INT DEFAULT 60,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Standard Materials Price Index
CREATE TABLE IF NOT EXISTS public.materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    unit TEXT NOT NULL DEFAULT 'piece',
    standard_rate NUMERIC(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Pricing Rules & Modifiers
CREATE TABLE IF NOT EXISTS public.service_pricing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    visit_charge NUMERIC(10,2) DEFAULT 50.00,
    platform_fee NUMERIC(10,2) DEFAULT 20.00,
    emergency_multiplier NUMERIC(3,2) DEFAULT 1.50,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Technicians Profiles
CREATE TABLE IF NOT EXISTS public.technicians (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    service_category_id UUID NOT NULL REFERENCES public.service_categories(id),
    is_available BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    rating NUMERIC(3,2) DEFAULT 5.00,
    total_jobs INT DEFAULT 0,
    experience_years INT DEFAULT 1,
    aadhaar_masked TEXT,
    bank_account_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Customer Saved Addresses
CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT DEFAULT 'Home',
    address_line TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    pincode TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Upfront Quotations
CREATE TABLE IF NOT EXISTS public.quotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id),
    material_cost NUMERIC(10,2) DEFAULT 0.00,
    labor_fee NUMERIC(10,2) NOT NULL,
    visit_charge NUMERIC(10,2) DEFAULT 50.00,
    platform_fee NUMERIC(10,2) DEFAULT 20.00,
    emergency_charge NUMERIC(10,2) DEFAULT 0.00,
    total_amount NUMERIC(10,2) NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('draft', 'accepted', 'rejected', 'expired')) DEFAULT 'draft',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Itemized Quotation Items
CREATE TABLE IF NOT EXISTS public.quotation_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quotation_id UUID NOT NULL REFERENCES public.quotations(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL CHECK (item_type IN ('labor', 'material', 'visit', 'fee', 'emergency')),
    description TEXT NOT NULL,
    quantity INT DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) NOT NULL
);

-- 11. Bookings Lifecycle
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    technician_id UUID REFERENCES public.technicians(id),
    quotation_id UUID REFERENCES public.quotations(id),
    address_id UUID REFERENCES public.addresses(id),
    status TEXT NOT NULL CHECK (
        status IN ('pending', 'technician_assigned', 'on_the_way', 'arrived', 'in_progress', 'completed', 'cancelled')
    ) DEFAULT 'pending',
    is_emergency BOOLEAN DEFAULT FALSE,
    issue_description TEXT,
    scheduled_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. Chat Messages
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id),
    content TEXT NOT NULL,
    attachment_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. Live Technician GPS Tracking
CREATE TABLE IF NOT EXISTS public.technician_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    technician_id UUID NOT NULL REFERENCES public.technicians(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    heading DOUBLE PRECISION,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. Payments Table
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    amount NUMERIC(10,2) NOT NULL,
    method TEXT NOT NULL CHECK (method IN ('upi', 'card', 'cash', 'netbanking')),
    status TEXT NOT NULL CHECK (status IN ('pending', 'successful', 'failed', 'refunded')) DEFAULT 'pending',
    transaction_ref TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. Ratings & Reviews
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL UNIQUE REFERENCES public.bookings(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.profiles(id),
    technician_id UUID NOT NULL REFERENCES public.technicians(id),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. Complaints & Dispute Handling
CREATE TABLE IF NOT EXISTS public.complaints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    raised_by UUID NOT NULL REFERENCES public.profiles(id),
    reason TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL CHECK (status IN ('open', 'under_investigation', 'resolved', 'dismissed')) DEFAULT 'open',
    resolution_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_bookings_customer ON public.bookings(customer_id, status);
CREATE INDEX IF NOT EXISTS idx_bookings_technician ON public.bookings(technician_id, status);
CREATE INDEX IF NOT EXISTS idx_technicians_category ON public.technicians(service_category_id, is_available);
CREATE INDEX IF NOT EXISTS idx_messages_booking ON public.messages(booking_id, created_at);
CREATE INDEX IF NOT EXISTS idx_locations_technician ON public.technician_locations(technician_id);
