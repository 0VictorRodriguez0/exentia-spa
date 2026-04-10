# Exentia Spa & Beauty Salon — Pagina Web

Sitio web oficial para Exentia Spa & Beauty Salon en Cancun, Mexico.
Catalogo de servicios + sistema de reservas con formulario pre-cita + calendario integrado con GoHighLevel + tracking completo de eventos.

🌐 **Live:** https://0victorrodriguez0.github.io/exentia-spa/exentia-pagina.html (GitHub Pages)

📍 **Negocio:** Av. Huayacan, Plaza Hive, Cancun, Q. Roo
📞 **WhatsApp:** [+52 998 480 3595](https://wa.me/529984803595)
📷 **Instagram:** [@exentiaspabeautysalon](https://www.instagram.com/exentiaspabeautysalon/)

## Estructura

```
exentia/
├── exentia-pagina.html       # Pagina web principal (HTML/CSS/JS en un archivo)
├── form-exentia.html         # Formulario custom para GHL Form Builder
├── CLAUDE.md                 # Documentacion tecnica completa
├── README.md                 # Este archivo
└── assets/                   # Imagenes del branding (Fika Studio + Instagram)
    ├── exentia-01.jpg        # Logo oficial
    ├── exentia-logo-transparent.png
    └── instagram/            # Fotos reales del Instagram
```

## Servicios (6 categorias)

| Categoria | Servicios |
|---|---|
| **Masajes** | Relajante, Piedras Calientes, Aromaterapia, Descontracturante |
| **Faciales** | Limpieza Profunda, Hidratante, Antiedad, Desintoxicante |
| **Uñas** | Acrilicas, Gel, Dip Powder, Manicure Spa, Pedicure Spa |
| **Cabello** | Corte/Peinado, Color/Balayage, Tratamiento, Peinado Evento |
| **Depilacion & Maquillaje** | Cera, Cejas, Lash Lifting, Extensiones, Maquillaje Social/Novia |
| **SpaKids** | Mini Manicure, Mini Pedicure, Mini Spa, Peinado Princesa |

## Como funciona el flujo de reserva

1. Cliente explora servicios → selecciona los que quiere → se agregan al carrito (localStorage)
2. Click "Continuar" → popup formulario pre-cita (datos personales + preguntas condicionales segun servicio)
3. Submit → popup calendario con datos auto-rellenados
4. Cliente elige fecha y hora → cita confirmada en GHL

## Stack tecnico

- **HTML/CSS/JS vanilla** (sin frameworks)
- **GoHighLevel** — CRM, formularios y calendario embebidos
- **Supabase** — base de datos para tracking de eventos (schema `exentia`)
- **n8n** — workflows que reciben eventos del tracker e insertan en Supabase
- **Google Fonts** — Cormorant Garamond + Inter
- **CDN GHL** — imagenes servidas desde `assets.cdn.filesafe.space`

## Tracking incluido

La pagina dispara ~20 eventos canonicos al webhook de n8n:
- Engagement: page_view, scroll milestones, service card views
- Intent: form open, form fields completed, form submit
- Conversion: WhatsApp clicks, calendar booking
- Captura first-click + last-click UTMs, gclid, fbclid, msclkid
- Inyecta lead_ref en mensajes wa.me para que el negocio identifique cada lead

(El tracker no envia datos personales, solo metadata de uso. Toda la integracion respeta el aviso de privacidad de Exentia.)

## Brand identity

| Color | Hex |
|---|---|
| Olive | `#9a9854` |
| Olive dark | `#7d7c3f` |
| Cream | `#f3e4c7` |
| Brown | `#5c3a1e` |
| Off-white | `#fdfbf4` |

Tipografias: Cormorant Garamond (titulos serif) + Inter (body sans-serif).
Branding original disenado por [Fika Studio](https://fikastudio.mx/project/exentia/).

## Desarrollo local

```bash
# Cualquier static server funciona
python -m http.server 5175
# Abrir http://localhost:5175/exentia-pagina.html
```

## Licencia

Todos los derechos reservados © Exentia Spa & Beauty Salon.
Desarrollado por [Ainnovation](https://ainnovation.com.mx).
