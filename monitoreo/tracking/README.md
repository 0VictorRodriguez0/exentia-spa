# Exentia Tracking — Cliente

Toda la instrumentacion que va incrustada en la pagina web.

## Archivos

| Archivo | Para que |
|---|---|
| `tracker.js` | Tracker IIFE — captura ~20 eventos canonicos, dispara a n8n + GA4 + Pixel |
| `GA4_SETUP.md` | Guia paso a paso para crear property GA4 (manual en dashboard) |
| `CLARITY_SETUP.md` | Guia paso a paso para crear project Microsoft Clarity (manual) |
| `tracking_ids.json` | Placeholders para los IDs de GA4, Clarity, Google Ads, Meta Pixel |

## Como instalar el tracker en la pagina

Justo antes del `</body>` (despues de gtag/clarity/fbq si los tienes):

```html
<script src="/tracker.js"></script>
```

O inline para evitar request extra:

```html
<script>
  // pegar contenido completo de tracker.js
</script>
```

## Eventos que captura

**Engagement:**
- `page_view` — automatico al cargar
- `scroll_25`, `scroll_50`, `scroll_75`, `scroll_100`
- `service_card_view` — IntersectionObserver, al ver card del servicio
- `service_select` — click en card
- `service_detail_view` — click en boton "ver detalle"
- `session_end` — pagehide, incluye time_on_page_ms y max_scroll

**Intent:**
- `form_start` — primer focus en input del form
- `form_field_complete` — al terminar de llenar cada field (blur)
- `form_submit_intent` — submit click

**Conversion:**
- `form_submit_whatsapp` — submit valido que abre wa.me
- `whatsapp_direct_click` — click en sticky WA o cualquier `a[href*="wa.me"]`
- `call_click` — click en `a[href^="tel:"]`
- `calendar_view`
- `calendar_time_slot_click`

**Upload:**
- `photo_upload_start` — click en input file
- `photo_upload_complete` — change con N archivos
- `maps_link_paste` — paste de link Google Maps

## Atributos data-* requeridos en el HTML

Para que el tracker enganche eventos, marca elementos con:

```html
<!-- Cards de servicios (para service_card_view via IntersectionObserver) -->
<div data-service-slug="masaje-relajante">...</div>

<!-- Click en card -->
<button data-event="service_select" data-service-slug="masaje-relajante">Reservar</button>

<!-- Sticky WA bar -->
<a href="https://wa.me/52..." data-location="sticky-bottom">Chatear</a>

<!-- Calendario -->
<div data-event="calendar_view">Selecciona fecha</div>
<div data-event="calendar_time_slot_click" data-slot="2026-04-25T10:00">10:00 AM</div>
```

Los enlaces `wa.me` y `tel:` se enganchan **automaticamente** sin requerir data-*.

## Form de reserva

Para el flujo form -> n8n -> wa.me, usar el helper:

```html
<form id="reserva-form">
  <input name="cliente_nombre" required>
  <input name="cliente_telefono" required>
  <select name="servicios" required>...</select>
  <input name="zona_colonia">
  <input name="direccion_maps_url">
  <input type="file" name="fotos_casa" multiple>
  <button type="submit">Reservar</button>
</form>

<script>
document.getElementById('reserva-form').addEventListener('submit', function(e){
  e.preventDefault();
  var fd = new FormData(e.target);
  var data = Object.fromEntries(fd.entries());
  window.exentiaSubmitReserva(data); // dispara form_submit_whatsapp y redirige a wa.me
});
</script>
```

## Pendiente

- Conectar GA4 ID real cuando lo cree (ver `GA4_SETUP.md`)
- Conectar Clarity ID real cuando lo cree (ver `CLARITY_SETUP.md`)
- Conectar Meta Pixel ID cuando entre Jocelyn (Fase 2 — credenciales)
- Tracker funciona ahora sin estos: solo guarda en n8n + Supabase. gtag/fbq son condicionales.

## Test rapido en consola

```js
window.ExentiaTrack.send('test_event', { foo: 'bar' });
window.ExentiaTrack.ref(); // ver lead_ref actual
window.ExentiaTrack.sid;   // ver session_id
```
