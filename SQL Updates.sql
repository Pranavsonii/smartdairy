SQL Updates

ALTER TABLE public.routes ADD description text NULL;
ALTER TABLE public.routes ADD route json NULL;

ALTER TABLE public.outlets ADD coordinates varchar NULL;

-- Soft Delete Implementation for Delivery Persons
-- Add is_active column to delivery_guys table for soft delete functionality
ALTER TABLE public.delivery_guys ADD COLUMN is_active BOOLEAN DEFAULT true;

-- Set existing records to active (if any are NULL)
UPDATE public.delivery_guys SET is_active = true WHERE is_active IS NULL;


payments 8
customer 10
delivery 7
drive execution 6
drive 13
qr 7
reports 5
route 8
user 7