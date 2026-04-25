# Exentia Dashboard

Dashboard privado Variante B (srcdoc en GHL custom menu link). Lee Supabase con anon key + RLS.

## Archivos

| Archivo | Para que |
|---|---|
| `index.html` | Dashboard standalone (abre en navegador para preview local) |
| `deploy-srcdoc.py` | Script que escapa HTML y lo copia al portapapeles como `<iframe srcdoc=...>` |
| `dashboard-srcdoc.html` | Output del script (regenerado cada deploy) |

## Como usar

### Local (preview/desarrollo)
1. Servir la carpeta con cualquier static server (ej: `python -m http.server 5175 --directory ../..`)
2. Abrir `http://localhost:5175/monitoreo/dashboard/index.html`

### Deploy a GHL
```bash
python deploy-srcdoc.py
# Output: iframe srcdoc en portapapeles + dashboard-srcdoc.html
```
1. GHL UI -> Settings -> Custom Menu Links -> + New
2. Name: "Dashboard Exentia"
3. Type: **Custom Code/HTML**
4. Paste del clipboard
5. Save -> aparece en menu lateral

## Que muestra

**KPIs Hoy** (desde `public.exentia_kpis_today`)
- Reservas, Pagadas, Revenue, Ticket promedio

**KPIs 7 dias** (desde `public.exentia_kpis_7d` + `public.exentia_sessions_summary`)
- Reservas 7d, Revenue 7d, Clientes unicos, Sesiones 24h + % conversion WA

**Embudo 7d** (desde `public.exentia_funnel_7d`)
- Visitas -> Form abierto -> Form enviado -> Click WA -> Calendario -> Booking

**Charts**
- Eventos ultimas 24h (bar chart)
- Revenue por canal 7d (donut chart)

**Tablas**
- Reservas recientes (PII enmascarada: cliente "S. Test", telefono "5219****34")
- Eventos recientes (page_view, scroll, click, etc.)

## Seguridad

- Usa **anon key** publico (incrustado en HTML)
- RLS bloquea INSERT/UPDATE/DELETE en tablas
- Anon SELECT permitido SOLO en views `public.exentia_*` (nunca en tablas raw)
- PII en `public.exentia_bookings_safe` viene enmascarada (iniciales + telefono parcial)
- Direcciones reales y fotos casa NO se exponen aqui — Yaz las consulta directo en GHL

Si el JWT se filtra, lo unico que un atacante puede hacer es leer agregados publicos. Cero capacidad de modificar datos.

## Auto-refresh

- Polling: cada 30s todas las queries se re-ejecutan
- Realtime: WebSocket de Supabase escucha cambios en `exentia.bookings` y `exentia.leads` -> refresh inmediato

## Customizar

Para agregar un KPI nuevo:
1. Crea un VIEW en Supabase: `CREATE VIEW public.exentia_xxx AS SELECT ... FROM exentia.xxx;`
2. `GRANT SELECT ON public.exentia_xxx TO anon;`
3. En `index.html` agrega un card y una funcion `loadXxx()` similar a las existentes
4. Llamar dentro de `refreshAll()`

## Pendientes

- Conectar boton "ver detalle PII" que abra el contacto en GHL (necesita link al contact_id)
- Filtros sticky por fecha/canal/zona
- Exportar CSV de reservas para Yaz/Jocelyn
- Bloque ROAS cuando se conecte Meta/Google Ads (Fase 7)
