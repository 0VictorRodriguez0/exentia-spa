# Exentia GHL — Pendientes y notas

Cuenta: **Exentia Spa & Beauty Salon** (`0hGSRrhxkdywVQxCsNOi`)

## ✅ Creado vía API

- **27 custom fields** prefijo `exentia_*` → IDs en `custom_fields.json`
- **60 tags** → IDs en `tags.json`
  - 28 `gen_servicio_*` (genéricos, extraídos de `exentia-pagina.html`)
  - 8 `gen_zona_*` (genéricos, áreas típicas Cancún)
  - 5 `canal_*`, 9 `etapa_*`, 3 `preferencia_*`, 6 operativas (estos son finales del playbook, NO genéricos)

## ⚠️ Pendiente — crear pipeline manualmente

El API key actual NO tiene scope `opportunities/pipelines.write`. Necesitas:

**Opción A:** Ampliar scope del Private Integration Token en GHL UI:
1. Settings → Private Integrations → Editar token actual
2. Agregar scopes: `opportunities.write`, `opportunities/pipelines.write`
3. Re-correr el script

**Opción B (más rápido):** Crearlo manualmente:
1. GHL → Opportunities → Pipelines → **+ New Pipeline**
2. Nombre: **`Exentia — Reservas`**
3. 9 stages en orden:
   1. Lead entró
   2. Cotizó
   3. Reservó
   4. Agendado
   5. Confirmado
   6. Asistió
   7. Pago
   8. Reseña
   9. Recurrente
4. Save → copiar el pipeline ID y los stage IDs a `pipeline.json`

## ⚠️ Pendiente — confirmar con Yaz

Las tags con prefijo `gen_*` son **genéricas** (placeholders extraídos del HTML actual o áreas típicas). Cuando Yaz mande la lista oficial:

### Servicios
Yaz debe confirmar:
- ¿Cuáles servicios SÍ ofrece a domicilio? (la lista actual del HTML es para spa físico — algunos pueden no aplicar a domicilio: balayage, color global, faciales con equipo grande, etc.)
- ¿Se renombran o eliminan algunos `gen_servicio_*`?
- Precios + duración por servicio (van al seed `exentia.servicios` en Supabase)
- Orden por volumen de venta (top sellers arriba) → campo `orden_display`

**Acción cuando Yaz confirme:** renombrar `gen_servicio_*` → `servicio_*` (sin prefijo) y/o eliminar las que no aplican.

### Zonas
Yaz debe confirmar whitelist de zonas Cancún a domicilio:
- ¿Cubre toda la ciudad o solo algunas zonas?
- Las 8 actuales son típicas (SM 1, SM 24, Puerto Cancún, Zona Hotelera, Bonampak, Malecón Las Américas, Puerto Juárez, Huayacán)
- Posibles a agregar: Aldea Zama, Punta Sam, Costa Mujeres, Gran Santa Fe, etc.

**Acción cuando Yaz confirme:** renombrar `gen_zona_*` → `zona_*` y agregar/quitar según whitelist.

## 🔧 Pendiente — fixes técnicos menores

- Custom field `exentia_es_recurrente` (CHECKBOX): la opción "Sí" se guardó con encoding mojibake (`S�`) por un issue del API. Funcionalmente sigue siendo CHECKBOX. **Fix:** abrir el field en GHL UI y editar la opción a `Si` (sin tilde) o `Yes`.

## 📂 Archivos en esta carpeta

| Archivo | Contenido |
|---|---|
| `custom_fields.json` | Mapeo nombre → ID de los 27 custom fields (para referenciar en n8n workflows) |
| `tags.json` | Mapeo nombre → ID de las 60 tags |
| `pipeline.json` | (vacío hasta crear pipeline manual o ampliar scope) |
| `PENDIENTES.md` | Este archivo |
