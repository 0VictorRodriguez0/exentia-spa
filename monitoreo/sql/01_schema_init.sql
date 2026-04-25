-- ============================================================
-- EXENTIA SCHEMA INIT
-- Proyecto Supabase: n8n (fneppfjeywhayknrgahe)
-- Schema: exentia
-- Aplicado: 2026-04-25
-- ============================================================

CREATE SCHEMA IF NOT EXISTS exentia;

-- 1. LEADS (tracking raw, browser-side events)
CREATE TABLE exentia.leads (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now(),
  lead_ref TEXT NOT NULL,
  session_id TEXT,
  event_type TEXT NOT NULL,
  page_path TEXT,
  landing_version TEXT,
  gclid TEXT, gbraid TEXT, wbraid TEXT, fbclid TEXT, msclkid TEXT,
  utm_source TEXT, utm_medium TEXT, utm_campaign TEXT, utm_content TEXT, utm_term TEXT,
  utm_source_first TEXT, utm_medium_first TEXT, utm_campaign_first TEXT,
  utm_content_first TEXT, utm_term_first TEXT,
  referrer TEXT,
  time_on_page_ms INT,
  scroll_depth_pct INT,
  user_agent TEXT, device_type TEXT, screen_size TEXT, language TEXT, timezone_offset INT,
  ghl_contact_id TEXT,
  extra JSONB DEFAULT '{}'::jsonb
);
CREATE INDEX ON exentia.leads (created_at DESC);
CREATE INDEX ON exentia.leads (lead_ref);
CREATE INDEX ON exentia.leads (session_id);
CREATE INDEX ON exentia.leads (event_type);
CREATE INDEX ON exentia.leads (gclid) WHERE gclid IS NOT NULL;

-- 2. SERVICIOS
CREATE TABLE exentia.servicios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  nombre TEXT, descripcion TEXT,
  duracion_min INT, precio_mxn NUMERIC(10,2),
  categoria TEXT, orden_display INT,
  activo BOOLEAN DEFAULT TRUE,
  foto_url TEXT
);

-- 3. TERAPEUTAS (interno, no expuesto en landing)
CREATE TABLE exentia.terapeutas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  nombre TEXT, sexo TEXT,
  foto_url TEXT, bio TEXT,
  especialidades TEXT[], zonas_cobertura TEXT[],
  telefono TEXT,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. BOOKINGS (lifecycle 11-state)
CREATE TABLE exentia.bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ DEFAULT now(),
  booking_code TEXT UNIQUE NOT NULL,
  lead_ref TEXT,
  ghl_contact_id TEXT,
  cliente_nombre TEXT, cliente_telefono TEXT, cliente_email TEXT,
  servicios JSONB NOT NULL,
  fecha_agendada DATE, hora_agendada TIME,
  duracion_total_min INT, precio_total_mxn NUMERIC(10,2),
  terapeuta_id UUID REFERENCES exentia.terapeutas(id),
  terapeuta_asignado_at TIMESTAMPTZ,
  modo_asignacion TEXT DEFAULT 'whatsapp_group',
  preferencia_sexo TEXT,
  zona_municipio TEXT DEFAULT 'Cancun',
  zona_colonia TEXT,
  direccion_libre TEXT, direccion_maps_url TEXT,
  latitud NUMERIC(10,7), longitud NUMERIC(10,7),
  fotos_casa_urls TEXT[],
  es_recurrente BOOLEAN DEFAULT FALSE,
  notas_cliente TEXT, notas_internas TEXT,
  estado TEXT NOT NULL DEFAULT 'reservo',
  confirmacion_enviada_at TIMESTAMPTZ,
  recordatorio_24h_enviado_at TIMESTAMPTZ,
  recordatorio_2h_enviado_at TIMESTAMPTZ,
  checkin_terapeuta_at TIMESTAMPTZ, checkin_lat NUMERIC, checkin_lng NUMERIC,
  checkout_terapeuta_at TIMESTAMPTZ,
  pago_recibido_at TIMESTAMPTZ, pago_monto_mxn NUMERIC(10,2), pago_metodo TEXT,
  resena_enviada_at TIMESTAMPTZ, resena_respondida_at TIMESTAMPTZ,
  resena_rating INT, resena_texto TEXT,
  cancelado_at TIMESTAMPTZ, cancelado_motivo TEXT
);
CREATE INDEX ON exentia.bookings (fecha_agendada);
CREATE INDEX ON exentia.bookings (estado);
CREATE INDEX ON exentia.bookings (terapeuta_id);
CREATE INDEX ON exentia.bookings (cliente_telefono);

-- 5. DISPONIBILIDAD
CREATE TABLE exentia.disponibilidad (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  terapeuta_id UUID REFERENCES exentia.terapeutas(id),
  fecha DATE, hora_inicio TIME, hora_fin TIME,
  estado TEXT DEFAULT 'libre',
  booking_id UUID REFERENCES exentia.bookings(id)
);
CREATE UNIQUE INDEX ON exentia.disponibilidad (terapeuta_id, fecha, hora_inicio);

-- 6. EVENTOS_ATRIBUCION (audit Google Ads + Meta CAPI uploads)
CREATE TABLE exentia.eventos_atribucion (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now(),
  booking_id UUID REFERENCES exentia.bookings(id),
  destino TEXT, tipo_evento TEXT, event_id TEXT,
  payload JSONB, response JSONB,
  status TEXT, retry_count INT DEFAULT 0
);

-- 7. MENSAJES_WA
CREATE TABLE exentia.mensajes_wa (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now(),
  telefono TEXT, direccion TEXT, mensaje TEXT,
  booking_id UUID REFERENCES exentia.bookings(id)
);

-- ============================================================
-- VIEWS
-- ============================================================
CREATE OR REPLACE VIEW exentia.dashboard_kpis_today AS
SELECT
  COUNT(*) FILTER (WHERE estado NOT IN ('cancelado','no_asistio')) AS reservas_hoy,
  COUNT(*) FILTER (WHERE estado='pagado') AS pagadas_hoy,
  SUM(pago_monto_mxn) FILTER (WHERE estado='pagado') AS revenue_hoy,
  AVG(pago_monto_mxn) FILTER (WHERE estado='pagado') AS ticket_promedio,
  COUNT(*) FILTER (WHERE es_recurrente) AS recurrentes_hoy
FROM exentia.bookings
WHERE fecha_agendada = CURRENT_DATE;

CREATE OR REPLACE VIEW exentia.revenue_by_channel_7d AS
SELECT
  COALESCE(l.utm_source, 'direct') AS canal,
  COUNT(DISTINCT b.id) AS n_reservas,
  SUM(b.pago_monto_mxn) AS revenue,
  AVG(b.pago_monto_mxn) AS ticket_promedio
FROM exentia.bookings b
LEFT JOIN exentia.leads l ON l.lead_ref = b.lead_ref AND l.event_type='page_view'
WHERE b.fecha_agendada >= CURRENT_DATE - 7
GROUP BY 1;

CREATE OR REPLACE VIEW exentia.terapeuta_utilization AS
SELECT t.id, t.nombre,
  SUM(b.duracion_total_min) FILTER (WHERE b.fecha_agendada >= CURRENT_DATE - 7) AS min_agendados_7d,
  COUNT(b.id) FILTER (WHERE b.fecha_agendada >= CURRENT_DATE - 7) AS n_bookings_7d
FROM exentia.terapeutas t
LEFT JOIN exentia.bookings b ON b.terapeuta_id = t.id
WHERE t.activo
GROUP BY 1, 2;

CREATE OR REPLACE VIEW exentia.sessions AS
SELECT
  session_id,
  MIN(created_at) AS sesion_inicio,
  MAX(created_at) AS sesion_fin,
  EXTRACT(EPOCH FROM (MAX(created_at) - MIN(created_at))) * 1000 AS duracion_ms,
  MAX(scroll_depth_pct) AS max_scroll,
  bool_or(event_type='form_submit_whatsapp') AS convirtio_wa,
  bool_or(event_type='whatsapp_direct_click') AS clickeo_wa,
  bool_or(event_type='call_click') AS clickeo_call,
  MAX(utm_source) AS utm_source,
  MAX(gclid) AS gclid
FROM exentia.leads
GROUP BY session_id;

-- ============================================================
-- RLS
-- ============================================================
ALTER TABLE exentia.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE exentia.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE exentia.terapeutas ENABLE ROW LEVEL SECURITY;
ALTER TABLE exentia.servicios ENABLE ROW LEVEL SECURITY;
ALTER TABLE exentia.eventos_atribucion ENABLE ROW LEVEL SECURITY;
ALTER TABLE exentia.disponibilidad ENABLE ROW LEVEL SECURITY;
ALTER TABLE exentia.mensajes_wa ENABLE ROW LEVEL SECURITY;

CREATE POLICY "leads_anon_insert" ON exentia.leads FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "leads_auth_select" ON exentia.leads FOR SELECT TO authenticated USING (true);
CREATE POLICY "bookings_auth_select" ON exentia.bookings FOR SELECT TO authenticated USING (true);
CREATE POLICY "servicios_anon_select" ON exentia.servicios FOR SELECT TO anon USING (activo = TRUE);
CREATE POLICY "servicios_auth_select" ON exentia.servicios FOR SELECT TO authenticated USING (true);

GRANT USAGE ON SCHEMA exentia TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA exentia TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA exentia TO service_role;
GRANT SELECT, INSERT ON exentia.leads TO anon;
GRANT SELECT ON exentia.leads TO authenticated;
GRANT SELECT ON exentia.servicios TO anon, authenticated;
GRANT SELECT ON exentia.bookings TO authenticated;
GRANT SELECT ON exentia.dashboard_kpis_today TO authenticated;
GRANT SELECT ON exentia.revenue_by_channel_7d TO authenticated;
GRANT SELECT ON exentia.terapeuta_utilization TO authenticated;
GRANT SELECT ON exentia.sessions TO authenticated;

-- ============================================================
-- STORAGE
-- ============================================================
INSERT INTO storage.buckets (id, name, public) VALUES
  ('exentia-public', 'exentia-public', true),
  ('exentia-private', 'exentia-private', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "exentia_public_read" ON storage.objects
  FOR SELECT TO anon, authenticated USING (bucket_id = 'exentia-public');
CREATE POLICY "exentia_public_service_write" ON storage.objects
  FOR INSERT TO service_role WITH CHECK (bucket_id = 'exentia-public');
CREATE POLICY "exentia_private_service_only" ON storage.objects
  FOR ALL TO service_role
  USING (bucket_id = 'exentia-private')
  WITH CHECK (bucket_id = 'exentia-private');
