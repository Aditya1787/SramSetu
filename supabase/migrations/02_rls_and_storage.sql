-- ==============================================================================
-- SRAM SETU — Row Level Security (RLS) & Storage Buckets (Phase 1, Steps 3 & 4)
-- ==============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_pricing ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.technicians ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotation_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.technician_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;

-- 1. Profiles Policies
CREATE POLICY "Public profiles are viewable by everyone" 
ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 2. Service Catalog Policies (Publicly readable by all authenticated/anon users)
CREATE POLICY "Categories are readable by everyone" 
ON public.service_categories FOR SELECT USING (true);

CREATE POLICY "Services are readable by everyone" 
ON public.services FOR SELECT USING (true);

CREATE POLICY "Problems are readable by everyone" 
ON public.service_problems FOR SELECT USING (true);

CREATE POLICY "Materials are readable by everyone" 
ON public.materials FOR SELECT USING (true);

CREATE POLICY "Pricing rules are readable by everyone" 
ON public.service_pricing FOR SELECT USING (true);

-- 3. Addresses Policies (Strictly user-isolated)
CREATE POLICY "Users can view own addresses" 
ON public.addresses FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own addresses" 
ON public.addresses FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own addresses" 
ON public.addresses FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own addresses" 
ON public.addresses FOR DELETE USING (auth.uid() = user_id);

-- 4. Bookings & Quotations (Participant isolation)
CREATE POLICY "Customers view their own bookings" 
ON public.bookings FOR SELECT USING (auth.uid() = customer_id);

CREATE POLICY "Technicians view assigned bookings" 
ON public.bookings FOR SELECT USING (
    technician_id IN (SELECT id FROM public.technicians WHERE profile_id = auth.uid())
);

CREATE POLICY "Customers insert bookings" 
ON public.bookings FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- 5. Chat Messages (Only between assigned customer and technician)
CREATE POLICY "Participants can read booking messages" 
ON public.messages FOR SELECT USING (
    booking_id IN (
        SELECT id FROM public.bookings 
        WHERE customer_id = auth.uid() 
           OR technician_id IN (SELECT id FROM public.technicians WHERE profile_id = auth.uid())
    )
);

CREATE POLICY "Participants can send booking messages" 
ON public.messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    booking_id IN (
        SELECT id FROM public.bookings 
        WHERE customer_id = auth.uid() 
           OR technician_id IN (SELECT id FROM public.technicians WHERE profile_id = auth.uid())
    )
);

-- ==============================================================================
-- Automatic Profile Creation Trigger on auth.users insert
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email, role, avatar_url)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'full_name', 'Customer'),
        new.email,
        COALESCE(new.raw_user_meta_data->>'role', 'customer'),
        new.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==============================================================================
-- Storage Buckets Provisioning
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public) 
VALUES 
    ('avatars', 'avatars', true),
    ('service-images', 'service-images', true),
    ('booking-images', 'booking-images', false),
    ('chat-attachments', 'chat-attachments', false),
    ('technician-documents', 'technician-documents', false)
ON CONFLICT (id) DO NOTHING;
