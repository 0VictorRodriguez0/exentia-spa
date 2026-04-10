# Exentia Spa & Beauty Salon — Pagina Web + Sistema de Reservas + Tracking

## Descripcion del proyecto

Pagina web funcional para Exentia Spa & Beauty Salon (Cancun, Q. Roo) con sistema de reservas integrado a GoHighLevel (GHL), tracking de eventos a Supabase via n8n, y dashboard interno privado. Implementa el pattern combinado Arqalum + Sarahi del playbook Ainnovation (data-first reverse engineering).

## Estado actual (Fase 1 — abril 2026)

| # | Tarea | Estado |
|---|---|---|
| 1 | Supabase schema `exentia` (7 tablas + 4 vistas + RLS + Storage) | ✅ |
| 2 | n8n workflows base (track, reserva, checkin, resena, upload-conversions) | ✅ |
| 3 | GHL setup (27 custom fields exentia_*, 60 tags, pipeline 9-stage) | ✅ |
| 4 | GA4 + Microsoft Clarity (docs creadas, ejecucion manual del cliente) | 📝 pendiente |
| 5 | tracker.js IIFE inyectado en exentia-pagina.html | ✅ |
| 6 | Landing HTML con tracker integrado (no se rehizo desde cero) | ✅ |
| 7 | Dashboard srcdoc privado (`monitoreo/dashboard/`) | ✅ |
| 8 | Workflow exentia-pago (build only, NO activar — espera credenciales Google/Meta) | 📝 pendiente |
| 9 | Documentacion + Ralph Loop | 📝 ongoing |

## Archivos principales

### Pagina (publica — repo `0VictorRodriguez0/exentia-spa`)
| Archivo | Descripcion |
|---|---|
| `exentia-pagina.html` | Pagina web completa (SPA con hash routing, modales, carrito) — incluye tracker.js inyectado en `<head>` y bridge script antes de `</body>` |
| `form-exentia.html` | Codigo HTML del formulario (se pega en el elemento Html del Form Builder de GHL) |
| `assets/` | Imagenes del branding oficial (Fika Studio) e Instagram |

### Backend / monitoreo (LOCAL ONLY — gitignored)
| Archivo | Descripcion |
|---|---|
| `monitoreo/sql/01_schema_init.sql` | Schema completo aplicado en Supabase |
| `monitoreo/n8n/*.json` | 5 workflows listos para importar en n8n |
| `monitoreo/ghl/*.json` | IDs de custom fields, tags, pipeline (referencia para workflows) |
| `monitoreo/dashboard/index.html` | Dashboard interno (Variante B srcdoc privado) |
| `monitoreo/tracking/tracker.js` | Source del tracker (inlined en exentia-pagina.html) |
| `monitoreo/tracking/GA4_SETUP.md` + `CLARITY_SETUP.md` | Guias paso a paso |

## Datos del negocio

- **Nombre**: Exentia Spa & Beauty Salon
- **Ubicacion**: Av. Huayacan, Plaza Hive, Cancun, Q. Roo, Mexico
- **Telefono**: +52 998 480 3595
- **Horario**: Lunes a Sabado 9AM - 6PM, Domingo cerrado
- **Instagram**: @exentiaspabeautysalon (1,380 seguidores)
- **Tagline**: "Realzamos la belleza de tu esencia"
- **Branding designer**: Fika Studio (https://fikastudio.mx/project/exentia/)

## Credenciales GHL

> Las API keys NO se almacenan en este archivo. Se mantienen en el CLAUDE.md raiz del workspace local del developer (no commiteado a ningun repo publico).

- **Location ID**: `0hGSRrhxkdywVQxCsNOi`
- **Calendar embed ID**: `ep6YHJFqv8qFzrzJpL2W`
- **Form ID**: `ElRuF6DqgcwUiSyJaXoi`
- **Pipeline ID** (Reservas): `0yWVmwR1YLLZfwjPXRcw`
- **CDN Base**: `https://assets.cdn.filesafe.space/0hGSRrhxkdywVQxCsNOi/media/`

## Stack de tracking + datos

```
Browser (exentia-pagina.html)
  ├── tracker.js inline → fetch POST → n8n webhook /exentia-track
  │                                       ↓
  │                                    Postgres INSERT exentia.leads (Supabase)
  ├── (futuro) gtag → GA4
  ├── (futuro) Clarity → heatmaps
  └── (futuro) fbq → Meta Pixel + CAPI dedup

GHL Form/Calendar iframes (cross-origin)
  └── postMessage → bridge script → tracker → n8n webhook
                                                 ↓
                                              exentia.bookings (Supabase)

Dashboard interno (Variante B srcdoc en GHL)
  └── Supabase anon key + RLS read-only en views public.exentia_*
```

### Endpoints n8n
- `POST /webhook/exentia-track` — eventos browser
- `POST /webhook/exentia-reserva` — submit form, devuelve booking_code + wa_link
- `POST /webhook/exentia-checkin` — terapeuta marca llegada
- `POST /webhook/exentia-resena` — cliente responde resena
- Cron 1h `exentia-upload-conversions` — retry Google/Meta (no activado, espera creds)

### Schema Supabase exentia (7 tablas, 4 vistas, RLS habilitado en todas)
- `leads` — eventos browser raw (32 cols, indices en created_at, lead_ref, session_id, gclid)
- `bookings` — lifecycle 11-state (`reservo→agendado→confirmado→asistio→pagado→resenado→recurrente|cancelado|no_asistio`)
- `servicios` — catalogo (pendiente seed Yaz)
- `terapeutas` — interno, NO expuesto en landing (modelo C grupo WhatsApp)
- `disponibilidad`, `eventos_atribucion`, `mensajes_wa`
- Views: `dashboard_kpis_today`, `revenue_by_channel_7d`, `terapeuta_utilization`, `sessions`

### Storage Supabase
- `exentia-public` — fotos servicios (anon read)
- `exentia-private` — fotos casa cliente (service_role only)

## Paleta de colores oficial

| Color | Hex | Uso |
|---|---|---|
| Olive | `#9a9854` | Color principal, botones, acentos |
| Olive dark | `#7d7c3f` | Hover de botones |
| Cream | `#f3e4c7` | Fondos secundarios |
| Brown | `#5c3a1e` | Texto del logo, titulos |
| Off-white | `#fdfbf4` | Fondo principal |

## Tipografias

- **Titulos**: Cormorant Garamond (serif, italic para acentos)
- **Body**: Inter (sans-serif)

## Servicios (6 categorias)

1. **Masajes**: Relajante, Piedras Calientes, Aromaterapia, Descontracturante
2. **Faciales**: Limpieza, Hidratante, Antiedad, Desintoxicante
3. **Unas**: Acrilicas, Gel, Dip Powder, Manicure Spa, Pedicure Spa
4. **Cabello**: Corte/Peinado, Color/Balayage, Tratamiento Capilar, Peinado Evento
5. **Depilacion & Maquillaje**: Cera, Cejas, Lash Lifting, Extensiones Pestanas, Maquillaje Social, Maquillaje Novia
6. **SpaKids**: Mini Manicure, Mini Pedicure, Mini Spa Experience, Peinado Princesa

> Las 28 tags en GHL llevan prefijo `gen_servicio_*` (genericas). Pendiente que Yaz confirme cuales si aplican a domicilio y precios finales.

## Arquitectura de la pagina

### Sistema de vistas (SPA con hash routing)
- `#home` o vacio: Landing page con hero, values, servicios, filosofia
- `#servicio/{slug}`: Vista de detalle por categoria

### Sistema de modales
- **Modal Select** (`#modal-select`): Selector de servicios con imagenes, acordeon de tratamientos
- **Modal Form** (`#modal-form`): Iframe del formulario GHL embebido
- **Modal Calendar** (`#modal-calendar`): Iframe del calendario GHL con datos auto-rellenados

### Flujo del cliente
```
1. Cliente navega → tracker dispara page_view, scroll_25/50/75/100, service_card_view
2. Click "Reservar" en tratamiento → service_select + push al carrito (localStorage)
3. Badge flotante "N servicios · Continuar" → cart_continue
4. Click "Continuar" → openModal('modal-form') → form_modal_open
5. Llena form GHL embebido + preguntas condicionales → submit
6. postMessage al padre → form_submit_intent + auto-fill calendar
7. openModal('modal-calendar') → calendar_view
8. Elige slot → calendar_time_slot_click
9. Confirma → BOOKING_SUCCESS postMessage → calendar_booking_success
```

## Tracker eventos capturados

- **Engagement**: page_view, scroll_25/50/75/100, service_card_view (IntersectionObserver), service_select, service_detail_view, session_end (pagehide)
- **Intent**: form_modal_open, form_start, form_field_complete, form_submit_intent
- **Conversion**: form_submit_whatsapp, whatsapp_direct_click, call_click, calendar_view, calendar_time_slot_click, calendar_booking_success
- **Upload**: photo_upload_start/complete, maps_link_paste
- **Cart**: cart_continue, service_remove

## Atribucion

- **First-click** UTM: cookie `ex_first_attr` (30d, inmutable primera visita)
- **Last-click** UTM: query params cada visita
- **Click IDs**: gclid, gbraid, wbraid (Google), fbclid (Meta), msclkid (Microsoft)
- **session_id**: localStorage `ex_sid`, rolling 30 min
- **lead_ref**: 8-char alfanum UPPERCASE generado server-side, persiste en localStorage `ex_lead_ref`, se inyecta en mensajes wa.me como `[Ref XXXXXXXX]`

## Custom Fields en GHL (Form Builder)

| Campo | ID | Tipo |
|---|---|---|
| Servicio de Interes | `YdXMTdkEDSLVcstpRAtX` | LARGE_TEXT |
| Tipo de Piel | `26FKQCpTI60jSUZVRv1L` | TEXT |
| Alergias | `kfjWinFpLclgA3e65394` | LARGE_TEXT |
| Presion Masaje | `3X1Q3hARpiBH6UZK6xeV` | TEXT |
| Primera Visita | `kjHgysIwIcyvzdOScV1C` | TEXT |
| Notas | `67CrR2g1U7HC5vwmGmKT` | LARGE_TEXT |

Mas 27 custom fields tracking `exentia_*` (lead_ref, session_id, gclid/fbclid/etc, utm_*_first/last, servicio_elegido, zona, preferencia_sexo, terapeuta_asignado, valor_ticket_mxn, etc.). Lista completa en `monitoreo/ghl/custom_fields.json` (local).

## Notas tecnicas

### GHL Form Builder
- Campos nativos se ocultan con CSS (`.form-field-container:not(:has(.exf))`)
- Boton submit nativo: `button.button-element`
- Campos SINGLE/MULTIPLE_OPTIONS NO aceptan `.value` directo → usar TEXT/LARGE_TEXT
- `form_embed.js` aplica `pointer-events: auto` a iframes (los modales usan `display: none`, no `opacity: 0`)

### Auto-relleno del calendario
GHL lee parametros del URL del padre (no del iframe). Se usa `history.replaceState` para agregar `?first_name=X&last_name=Y&email=Z&phone=W`.

### Clicks en modales
Los onclick directos en innerHTML dinamico NO funcionan en algunos browsers. Se usa `el.onclick = function()` asignado despues de `innerHTML`.

### Tracker → n8n CORS
El tracker envia `fetch()` SIN Content-Type → text/plain → simple request, sin preflight CORS. `sendBeacon` con `application/json` Blob fuerza preflight (que sendBeacon no maneja) → falla. Pattern del playbook Arqalum.

## Pendientes principales

### Cliente (Yaz / Jocelyn)
- Confirmar lista final de servicios a domicilio (los 28 actuales son del spa fisico — algunos no aplican)
- Whitelist de zonas Cancun (las 8 actuales son tipicas)
- Manual de marca + logos completos (Jocelyn lo tiene)
- Precios + duracion por servicio → seed `exentia.servicios`
- Telefono real de Yaz para wa.me en workflow `exentia-reserva` (actualmente placeholder `529982XXXXXXX`)

### Tecnico
- Crear property GA4 + Clarity (ver `monitoreo/tracking/GA4_SETUP.md` y `CLARITY_SETUP.md`)
- Conectar Meta Pixel + CAPI con scopes correctos (Fase 2, espera Jocelyn)
- Conectar Google Ads sub-cuenta (Fase 3, espera ex-Carem)
- Activar workflow `exentia-pago` cuando lleguen credenciales Google/Meta
- Editar custom field GHL `exentia_es_recurrente` para corregir encoding mojibake en opcion "Si"

## Referencias

- Repo de referencia (Henry, read-only): `exentia-vic-refs/`
- Playbook combinado: `00-plan/01-playbook.md`
- Action plan completo: `00-plan/02-action-plan.md`
