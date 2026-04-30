-- Agrega columna ghl_appointment_id a exentia.bookings para idempotencia
-- del workflow exentia-cita-creada (GHL Workflow → n8n)

ALTER TABLE exentia.bookings
  ADD COLUMN IF NOT EXISTS ghl_appointment_id TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS bookings_ghl_appointment_id_uidx
  ON exentia.bookings (ghl_appointment_id)
  WHERE ghl_appointment_id IS NOT NULL;

-- Eliminar lead_ref de bookings (decisión 2026-04-30: no se usaba)
DROP VIEW IF EXISTS public.exentia_revenue_by_channel_7d;
DROP VIEW IF EXISTS exentia.revenue_by_channel_7d;
ALTER TABLE exentia.bookings DROP COLUMN IF EXISTS lead_ref;
