# Exentia Spa & Beauty Salon — Web + CRM + Tracking

Pagina web + sistema de reservas + tracking para Exentia (Cancun). Sigue el playbook combinado Arqalum + Sarahi de Ainnovation.

> Las API keys NO viven en este repo. Estan solo en el `CLAUDE.md` raiz del workspace local del developer (gitignored).

---

## Estado actual (Fase 1 · 2026-04-25)

### ✅ Lo que ya esta en produccion

| # | Componente | Donde |
|---|---|---|
| 1 | **Pagina web publica** | https://0victorrodriguez0.github.io/exentia-spa/exentia-pagina.html |
| 2 | **Tracker.js inline** | Inyectado en `<head>` de `exentia-pagina.html`. ~20 eventos canonicos: page_view, scrolls, service_card_view, form_modal_open, calendar_view, whatsapp_direct_click, etc. |
| 3 | **Bridge script** | Antes de `</body>`. Hookea `openModal`, postMessage de iframes GHL, cart events, CTAs Agendar |
| 4 | **5 workflows n8n** | `exentia-track`, `-reserva`, `-checkin`, `-resena`, `-upload-conversions` (cron, scaffold) |
| 5 | **Schema Supabase `exentia.*`** | 7 tablas + 4 vistas + 8 vistas `public.exentia_*` para dashboard + RLS habilitado + 2 storage buckets |
| 6 | **GHL Exentia (`0hGSRrhxkdywVQxCsNOi`)** | 27 custom fields `exentia_*` + 60 tags + Pipeline `Reservas` (9 stages) + form `ElRuF6DqgcwUiSyJaXoi` + calendar `ep6YHJFqv8qFzrzJpL2W` |
| 7 | **Dashboard interno** | Standalone HTML en `monitoreo/dashboard/` (Variante B srcdoc, lista para pegar en GHL Custom Menu) |
| 8 | **Lifecycle verificado** | reservo → asistio → resenado end-to-end testeado, todos los webhooks responden |

### 📝 Lo que falta

**Inmediato — Henry:**
- Crear property GA4 + project Microsoft Clarity (guias en `monitoreo/tracking/GA4_SETUP.md` y `CLARITY_SETUP.md`). Pegar los IDs en `<head>` de la pagina → tracker auto-detecta gtag/fbq y empieza a enviar.
- Pegar dashboard srcdoc en GHL Custom Menu Link cuando Yaz lo apruebe (`python monitoreo/dashboard/deploy-srcdoc.py`).

**Yaz — checklist 2026-05-01:**
- Confirmar lista final de servicios a domicilio (las 28 tags `gen_servicio_*` son del spa fisico, algunas no aplican: balayage, color global con equipo grande). Renombrar `gen_*` → finales.
- Whitelist de zonas Cancun cubiertas a domicilio (las 8 tags `gen_zona_*` son tipicas).
- Telefono real de Yaz para el wa.me en workflow `exentia-reserva` (actualmente placeholder `529982XXXXXXX`).
- Precios + duracion por servicio → seed en `exentia.servicios`.

**Fase 2 — Henry + Jocelyn (cuando lleguen credenciales):**
- Meta Pixel + CAPI con scopes `ads_management + ads_read + business_management` (NUNCA `read_ads_dataset_quality` — bug Sarahi).
- Activar workflow `exentia-pago` para closed loop.

**Fase 3 — Henry + ex-Carem (Google Ads specialist):**
- Sub-cuenta nueva bajo MCC `876-257-5839` + conversion actions.
- Customer ID + OAuth + developer-token al workflow `exentia-upload-conversions`.

**Cosmetico:**
- Custom field GHL `exentia_es_recurrente` tiene mojibake en label "Si". Editar en UI, 30 segundos.

---

## Estructura

### Repo publico (GitHub Pages)

```
exentia-spa/
├── exentia-pagina.html       # SPA + tracker.js + bridge inlined
├── form-exentia.html         # Form custom para GHL Form Builder
├── README.md                 # Info publica
├── CLAUDE.md                 # Este archivo
├── .gitignore                # Excluye monitoreo/ y .claude/
└── assets/                   # Branding Fika Studio + fotos Instagram
```

### Local — `monitoreo/` (gitignored, NUNCA publicar)

```
monitoreo/
├── sql/01_schema_init.sql            # Schema exentia.* aplicado
├── n8n/                              # 5 workflows JSON listos para importar
│   └── exentia-{track,reserva,checkin,resena,upload-conversions}.json
├── ghl/                              # IDs de CFs, tags, pipeline + PENDIENTES.md
├── tracking/                         # tracker.js source + guias GA4/Clarity
└── dashboard/                        # Dashboard standalone + deploy-srcdoc.py
```

---

## Stack tecnico (resumen)

```
Browser (exentia-pagina.html)
  └── tracker.js → fetch text/plain (sin preflight CORS)
                     ↓
                  n8n webhook /exentia-{track,reserva,...}
                     ↓
                  Postgres INSERT exentia.{leads,bookings,...} (RETURNING)
                     ↓
                  Dashboard interno (anon key + RLS read-only en views public.exentia_*)

GHL Form/Calendar iframes (cross-origin)
  └── postMessage → bridge → tracker → form_submit_intent / calendar_booking_success
```

### Endpoints n8n (instancia compartida)

- `POST /webhook/exentia-track` — eventos browser → `exentia.leads`
- `POST /webhook/exentia-reserva` — form submit, devuelve `{booking_code, wa_link}`
- `POST /webhook/exentia-checkin` — terapeuta marca llegada
- `POST /webhook/exentia-resena` — cliente responde resena
- Cron 1h `exentia-upload-conversions` — retry Google/Meta (NO activado)

### GHL IDs clave

| Item | ID |
|---|---|
| Location | `0hGSRrhxkdywVQxCsNOi` |
| Calendar embed | `ep6YHJFqv8qFzrzJpL2W` |
| Form | `ElRuF6DqgcwUiSyJaXoi` |
| Pipeline `Reservas` | `0yWVmwR1YLLZfwjPXRcw` |
| CDN Base | `https://assets.cdn.filesafe.space/0hGSRrhxkdywVQxCsNOi/media/` |

---

## Tracker — eventos capturados

**Engagement:** page_view, scroll_25/50/75/100, service_card_view (IntersectionObserver), service_select, service_detail_view, session_end (pagehide).
**Intent:** form_modal_open, form_start, form_field_complete, form_submit_intent.
**Conversion:** form_submit_whatsapp, whatsapp_direct_click, call_click, calendar_view, calendar_time_slot_click, calendar_booking_success.
**Upload:** photo_upload_start/complete, maps_link_paste.
**Cart:** cart_continue, service_remove.

**Atribucion:** cookie `ex_first_attr` (30d, first-click) + query params (last-click) + 5 click IDs (gclid, gbraid, wbraid, fbclid, msclkid). Lead_ref 8-char alfanum se inyecta en mensajes wa.me como `[Ref XXXXXXXX]`.

---

## Brand identity

| Color | Hex |
|---|---|
| Olive | `#9a9854` |
| Olive dark | `#7d7c3f` |
| Cream | `#f3e4c7` |
| Brown | `#5c3a1e` |
| Off-white | `#fdfbf4` |

Tipografias: Cormorant Garamond (serif, titulos) + Inter (sans, body). Branding original por [Fika Studio](https://fikastudio.mx/project/exentia/).

---

## Datos del negocio

- **Ubicacion:** Av. Huayacan, Plaza Hive, Cancun, Q. Roo
- **Telefono:** +52 998 480 3595
- **Horario:** Lunes a Sabado 9AM-6PM
- **Instagram:** [@exentiaspabeautysalon](https://www.instagram.com/exentiaspabeautysalon/)

### Servicios (6 categorias — del HTML actual, marcadas como genericas hasta confirmacion Yaz)

1. **Masajes** · Relajante, Piedras Calientes, Aromaterapia, Descontracturante
2. **Faciales** · Limpieza, Hidratante, Antiedad, Desintoxicante
3. **Unas** · Acrilicas, Gel, Dip Powder, Manicure Spa, Pedicure Spa
4. **Cabello** · Corte, Color, Tratamiento, Peinado Evento
5. **Depilacion & Maquillaje** · Cera, Cejas, Lash Lifting, Extensiones, Maquillaje Social/Novia
6. **SpaKids** · Mini Manicure, Mini Pedicure, Mini Spa, Peinado Princesa

---

## Notas tecnicas

- **CORS bypass:** tracker usa `fetch()` SIN Content-Type → text/plain → simple request, sin preflight. `sendBeacon` con JSON Blob fuerza preflight (que no maneja) → falla.
- **GHL form quirks:** campos nativos ocultos con CSS (`.form-field-container:not(:has(.exf))`). Boton submit es `button.button-element`. `form_embed.js` aplica `pointer-events: auto` a iframes → modales usan `display: none`, no `opacity: 0`.
- **Auto-relleno calendario:** GHL lee URL del padre (no del iframe). Se usa `history.replaceState` para agregar `?first_name=X&...`.
- **n8n workflows:** usan `executeQuery` con UN solo param JSONB + `jsonb_populate_record` (evita el bug de `queryReplacement` con multiples comas que tenia en intentos previos).
- **Dashboard seguridad:** anon key publico + RLS bloquea INSERT/UPDATE/DELETE. Vistas `public.exentia_*` ya tienen PII enmascarada (cliente "S. Test", telefono "5219****34"). Si el JWT se filtra, atacante solo lee agregados.
