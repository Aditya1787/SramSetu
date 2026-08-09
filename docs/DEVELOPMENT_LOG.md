# SRAM SETU — Engineering & Development Changelog

Milestone logs, architecture decisions, and daily progress tracking.

- **[2026-08-02 09:40]**: feat: scaffold repository structure and configure base environment
- **[2026-08-02 13:56]**: docs: initialize system architecture outline and milestone plan
- **[2026-08-02 21:54]**: feat(auth): initialize Supabase authentication client setup
- **[2026-08-03 18:33]**: feat(auth): implement phone OTP verification service
- **[2026-08-03 20:47]**: feat(auth): add role-based authorization rules (customer, technician, admin)
- **[2026-08-03 21:53]**: feat(db): create initial schema for user profiles and contact info
- **[2026-08-04 09:45]**: feat(db): add migrations for technician trust badges and certifications
- **[2026-08-04 10:50]**: feat(catalog): define service categories: electrical, plumbing, carpentry
- **[2026-08-04 12:58]**: feat(catalog): add sub-service definitions and standard problem lists
- **[2026-08-05 12:38]**: feat(pricing): implement upfront quotation calculation algorithm
- **[2026-08-05 18:49]**: feat(pricing): add material pricing lookup matrix with regional modifiers
- **[2026-08-05 21:28]**: feat(pricing): introduce transparent visit charge and platform fee breakdown
- **[2026-08-06 09:21]**: test(pricing): add unit tests for upfront quotation calculator
- **[2026-08-06 13:00]**: feat(customer): create mobile home screen layout and search banner
- **[2026-08-06 13:59]**: feat(customer): add natural language issue input parser
- **[2026-08-06 16:54]**: feat(customer): implement problem category selector component
- **[2026-08-06 19:18]**: feat(customer): build photo/video upload preview for repair inspection
- **[2026-08-06 22:12]**: feat(booking): design booking lifecycle state machine
- **[2026-08-07 10:49]**: feat(booking): add emergency priority quick-dispatch mode
- **[2026-08-07 10:59]**: feat(geo): add geolocation radius clustering for nearby technicians
- **[2026-08-07 14:59]**: feat(geo): implement Haversine distance calculator for technician dispatch
- **[2026-08-07 22:16]**: feat(technician): build incoming job lead alert modal
- **[2026-08-08 09:59]**: feat(technician): implement lead accept and decline action handlers
- **[2026-08-08 11:22]**: feat(technician): build technician active job timeline (En Route -> Arrived)
- **[2026-08-08 17:05]**: feat(technician): add live navigation launcher for service destination
- **[2026-08-08 18:24]**: feat(workflow): implement mid-job extra material approval protocol
- **[2026-08-08 21:42]**: feat(workflow): add customer authorization prompt for price adjustments
- **[2026-08-09 10:01]**: feat(payments): integrate Razorpay payment intent initialization
- **[2026-08-09 10:26]**: feat(payments): add Cash on Delivery (COD) settlement workflow
- **[2026-08-09 12:31]**: feat(payments): generate itemized digital invoice with GST breakdown
- **[2026-08-09 19:06]**: feat(feedback): add post-service rating and review submission
