# Microsoft Clarity — Setup Exentia

Clarity es **gratis e ilimitado** (heatmaps + session recordings + rage clicks + dead clicks). Mismo cliente que Arqalum.

## Paso 1 — Crear project

1. Entra a https://clarity.microsoft.com/ con cuenta Microsoft (Outlook/Hotmail/Live) o Google.
2. **+ New project**
3. Project name: `Exentia`
4. Website URL: el dominio donde vivira la pagina (puedes dejarlo temporal y editar despues)
5. Category: **Beauty / Spa**
6. Create

## Paso 2 — Copiar el ID

Despues de crear, te da el snippet con el **project ID** (string alfanumerico de ~10 chars, ej: `wcs7oe8lhe` que es el de Arqalum).

Pegalo en `tracking_ids.json`.

## Paso 3 — Configuracion recomendada

Settings del project Clarity:
- **Data masking**: Strict (oculta inputs por default — direcciones de cliente son PII)
- **Custom data masking**: agrega `.private`, `[data-private]` como CSS selectors a enmascarar
- **IP anonymization**: ON
- **Session recording opt-out**: agrega tu propio dominio interno si tu equipo prueba la pagina (no contamina recordings)

## Paso 4 — Filtros y dashboards utiles

- **Heatmaps** → ver por seccion donde hacen click vs donde no
- **Recordings** → filtrar por `Rage clicks` o `Dead clicks` para detectar bugs UX
- **Insights** → JavaScript errors, scroll depth, clicks
- **Smart Events** → no usar (Clarity los detecta solo, no necesario configurar)

---

## Snippet de instalacion (para `landing/index.html` en Tarea 6)

Pegar **antes del `</head>`**, reemplazando `XXXXXXXXXX` con el project ID:

```html
<!-- Microsoft Clarity -->
<script type="text/javascript">
    (function(c,l,a,r,i,t,y){
        c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
        t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
        y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
    })(window, document, "clarity", "script", "XXXXXXXXXX");
</script>
```

## Notas

- Clarity puede mostrar grabaciones a las 2-5 minutos del primer trafico
- Heatmaps necesitan ~100 sesiones para ser estadisticamente utiles
- No hay costo, no hay limite de sesiones, no hay sampling. Producto Microsoft 100% gratuito.
