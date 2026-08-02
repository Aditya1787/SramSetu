# Product Requirements Document (PRD) — SRAM SETU

## 1. Executive Summary & Vision
**Product Name:** SRAM SETU (श्रम सेतु)  
**Product Type:** On-Demand Blue-Collar Home Service Platform  
**Target Services:** Electrician, Plumber, Carpenter, AC Technician, Appliance Repair, Painter, RO Technician, Handyman, etc.  
**Primary Platforms:** Mobile (Android & iOS) + Web Admin Dashboard  

### 1.1 Problem Statement
Finding reliable blue-collar service professionals (plumbers, electricians, carpenters, etc.) in urban and semi-urban India is fragmented and untrustworthy. 

**Key Customer Pain Points:**
1. **Opaque & Arbitrary Pricing:** Technicians often quote arbitrary prices on-site with hidden fees and unexpected markups.
2. **Lack of Material vs. Labor Transparency:** Customers cannot distinguish between raw material expenses and actual labor charges.
3. **Post-Inspection Price Hijacking:** Technicians start work and demand higher fees mid-job without prior explicit consent.
4. **Unreliable Arrival & Tracking:** Long waiting windows without live ETA or real-time progress status.
5. **Emergency Assistance Gap:** Sudden electrical short circuits, pipe bursts, or gas leaks have no instant-dispatch booking workflow.
6. **Trust & Accountability Deficit:** Lack of verified background check badges, clear service warranty, or formal dispute resolution.

### 1.2 The Solution
Sram Setu bridges customers with verified home service professionals through a **Quotation-First, Upfront-Transparent Model**. Customers state their issue in natural language or select standard problem categories, receive an instant itemized price estimate (Material + Labor + Visit Charge + Platform Fee), accept the transparent pricing, and track verified technicians step-by-step. Mid-job cost variations require explicit customer app authorization.

---

## 2. Core Value Proposition & USPs
1. **Know Before You Book:** Upfront itemized breakdown of expected material cost, technician labor, visit charge, and platform fee before technician dispatch.
2. **Transparent Mid-Job Approval:** Technicians cannot add extra fees without sending a digital modification request that the customer explicitly approves/rejects on-screen.
3. **Emergency Quick-Dispatch:** 1-tap booking workflow for urgent issues (short circuits, leaks, lockouts) with priority dispatch.
4. **Verified Local Workforce:** Multi-tier verification (ID proof, skill check, background verification) displayed on technician trust profiles.

---

## 3. User Personas & Roles

### 3.1 Customer Persona
- **Who:** Homeowners, tenants, working professionals, elderly residents, students.
- **Goals:** Get home repairs fixed quickly at fair, predictable prices without haggling or unexpected post-repair bills.
- **Key Features:** Natural language problem input, image/video upload, upfront quotation preview, booking schedule, live status tracking, emergency toggle, multi-channel payment (UPI/Cash), ratings & reviews.

### 3.2 Service Professional (Technician) Persona
- **Who:** Electricians, plumbers, carpenters, AC/appliance technicians, handymen.
- **Goals:** Secure regular local job leads, track daily/weekly earnings transparently, receive clear work instructions before arrival.
- **Key Features:** Job request notification modal (distance, issue, estimate), accept/decline toggle, navigation link, job status update pipeline (On the way -> Arrived -> In Progress -> Complete), submit extra material request, daily earnings summary.

### 3.3 Platform Administrator Persona
- **Who:** Operations and support teams.
- **Goals:** Verify technician credentials, manage dynamic service catalog and material pricing tables, handle dispute resolution, oversee platform metrics and payouts.
- **Key Features:** Verification queue, master service/problem/material database editor, booking audit logs, dispute investigation center, analytics dashboard.

---

## 4. Comprehensive Feature Specifications

### 4.1 Onboarding & Authentication
- **Multi-Modal Auth:** Email & Password, Phone Number + OTP, Google OAuth via Supabase Auth.
- **Role Assignment:** Automatic profile creation (`customer`, `technician`, `admin`).
- **Profile Setup:** Name, primary/secondary phone, email, profile picture, saved addresses (Home, Office, Other with GPS coordinates).

### 4.2 Home Screen & Service Catalog
- **Smart Search Header:** Greeting + "What problem are you facing?" input box with natural language text and camera image picker.
- **Category Grid:** Large visual cards for primary service categories (⚡ Electrician, 🔧 Plumber, 🪚 Carpenter, ❄️ AC Repair, 🧊 Refrigerator, 🚿 RO Repair, etc.).
- **Emergency Service Banner:** Prominent red banner for immediate emergency dispatch with immediate SLA.
- **Active Booking Floating Bar:** Live banner showing active booking status when a job is in progress.

### 4.3 Quotation Engine (Core USP)
- **Problem Selector:** Category -> Sub-Service -> Specific Problem (e.g., Electrician -> Fan Repair -> Capacitor Replacement).
- **Itemized Price Card:**
  - **Material Cost:** Pre-configured standard part price (e.g., Capacitor ₹120).
  - **Labor Charge:** Skill-based labor fee (e.g., ₹150).
  - **Visit/Inspection Charge:** Fixed base dispatch fee (e.g., ₹50).
  - **Platform & Tax Fee:** Nominal service platform fee (e.g., ₹20).
  - **Estimated Total:** Sum total with explicit disclaimer (*"Final price subject to user-approved mid-job additions"*).
- **Actions:** `[ Accept & Book ]`, `[ Custom Problem Request ]`, `[ Cancel ]`.

### 4.4 Booking & Dispatch Flow
- **Schedule Options:** "As Soon As Possible" (Emergency/Instant) or "Schedule for Later" (Date & Time slot picker).
- **Address Selector:** Map picker or saved address selection.
- **Booking Status Lifecycle:**
  1. `REQUESTED`: Problem submitted.
  2. `QUOTATION_GENERATED`: Estimate rendered.
  3. `CUSTOMER_ACCEPTED`: Price approved by user.
  4. `SEARCHING_TECHNICIAN`: Radius search matching active category technicians.
  5. `TECHNICIAN_ASSIGNED`: Job routed to qualified professional.
  6. `TECHNICIAN_ACCEPTED`: Professional confirmed job.
  7. `ON_THE_WAY`: ETA timer active & location updates.
  8. `ARRIVED`: Technician at customer doorstep.
  9. `IN_PROGRESS`: Service work initiated.
  10. `COMPLETED`: Work finished; final bill generated.
  11. `PAYMENT_COMPLETED`: Settlement via UPI/Cash/Card.
  12. `REVIEWED`: Star rating & feedback logged.

### 4.5 Technician Job Management & Upfront Variation Approval
- **Job Accept/Decline:** Modal displaying distance, service type, problem description, estimated payout, scheduled time.
- **Mid-Job Pricing Adjustment (Critical Feature):** If additional defects or parts are required:
  1. Technician selects additional item from verified list or types custom entry with price.
  2. Status moves to `EXTRA_WORK_APPROVAL_PENDING`.
  3. Customer receives push notification & full-screen modal with updated breakdown (`Previous ₹320 + New Motor Repair ₹250 = Updated Total ₹570`).
  4. Customer taps `[ Approve ]` or `[ Reject ]`. Work only proceeds upon customer digital sign-off.

### 4.6 Communication & Realtime Tracking
- **Service Chat:** In-app real-time messaging between assigned customer and technician (Text + Image uploads + Location pin).
- **ETA & Status Updates:** Real-time visual progress steps on customer screen.

### 4.7 Payments, Ratings & Disputes
- **Payment Options:** UPI Deep-linking, Cash on Completion, Razorpay/Stripe integration support.
- **Rating Matrix:** 1–5 Star Rating + Tags (On time, Professional, Affordable, High Quality) + Detailed Review text.
- **Dispute Resolution:** Report issue button for wrong pricing, non-arrival, poor quality, or technician misconduct.

---

## 5. Non-Functional Requirements (NFRs)
- **Performance:** App launch < 2.0s; Quotation lookup < 300ms; Realtime chat latency < 100ms.
- **Security:** Strict Supabase Row Level Security (RLS); Zero exposure of `SUPABASE_SERVICE_ROLE_KEY` in mobile app binaries; Private buckets for identity verification docs with signed URLs.
- **Reliability & Offline Cache:** Graceful offline handling for catalog browsing and profile viewing; Network connection enforced for booking submission and payment actions.
