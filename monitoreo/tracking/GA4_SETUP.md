# GA4 — Setup Exentia

## Paso 1 — Crear property

1. Entra a https://analytics.google.com/ con la cuenta Google de Exentia (o la que vaya a administrar — recomendado usar una @exentia o gmail dedicada del negocio, no personal).
2. **Admin** (engranaje abajo izquierda) → **Create Property**
3. Property name: `Exentia`
4. Reporting time zone: **(GMT-05:00) America/Cancun**
5. Currency: **Mexican Peso (MXN)**
6. Industry: **Beauty & Fitness**
7. Business size: **Small**
8. Business objectives: marca **Generate leads** + **Examine user behavior**
9. **Next** → setup data stream:
   - Platform: **Web**
   - URL: el dominio donde vivira la pagina (`https://exentia.com.mx` o el que sea; si aun no esta, puedes poner uno temporal y editarlo despues)
   - Stream name: `Exentia Web`
10. Create
11. Copia el **Measurement ID** — formato `G-XXXXXXXXXX` y pegalo en `tracking_ids.json`

## Paso 2 — Configurar Enhanced Measurement (ya viene activo, verificar)

En la data stream → Enhanced measurement debe estar **ON** con todos los toggles activos:
- Page views, Scrolls, Outbound clicks, Site search, Video engagement, File downloads, Form interactions

## Paso 3 — Custom events para los 20 eventos del playbook

Los eventos custom (`form_submit_whatsapp`, `whatsapp_direct_click`, `service_card_view`, etc.) los disparara `tracker.js` en Tarea 5 via `gtag('event', 'event_name', {...})`. NO necesitas pre-crearlos en GA4 — aparecen solos cuando se disparan la primera vez.

Despues de 24h de trafico:
1. Admin → **Custom definitions** → **Custom dimensions** → marca como dimensiones:
   - `lead_ref`, `session_id`, `landing_version`
2. Conversions → marcar como conversiones:
   - `form_submit_whatsapp`
   - `whatsapp_direct_click`
   - `call_click`

## Paso 4 — Conectar Google Ads (Fase 9 — espera ex-Carem)

Cuando entre el specialist Google Ads:
- Admin → **Product links** → **Google Ads links** → vincular cuenta MCC
- Activa Auto-tagging en Google Ads
- Importa conversiones de GA4 a Google Ads como Enhanced Conversions

---

## Snippet de instalacion (para `landing/index.html` en Tarea 6)

Pegar **antes del `</head>`**, con el Measurement ID real:

```html
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX', {
    'send_page_view': true
  });
</script>
```

**NO hacer lazy load** del gtag (perderia eventos iniciales). Carga sincrono en `<head>`.
