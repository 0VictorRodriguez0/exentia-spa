"""
Convierte index.html en un iframe srcdoc listo para pegar en GHL Custom Menu Link.
Output va al portapapeles (Windows: clip; Mac: pbcopy).

Uso:
  python deploy-srcdoc.py
"""
import os, subprocess, sys, html

DIR = os.path.dirname(__file__)
src = open(os.path.join(DIR, 'index.html'), 'r', encoding='utf-8').read()

# Escape para srcdoc
escaped = html.escape(src, quote=True)

iframe = '<iframe srcdoc="' + escaped + '" style="width:100%;height:100vh;border:none;display:block" allow="clipboard-write"></iframe>'

# Save to file
out_path = os.path.join(DIR, 'dashboard-srcdoc.html')
with open(out_path, 'w', encoding='utf-8') as f:
    f.write(iframe)

# Copy to clipboard
copied = False
try:
    if sys.platform == 'win32':
        subprocess.run('clip', input=iframe, encoding='utf-8', check=True)
        copied = True
    elif sys.platform == 'darwin':
        subprocess.run('pbcopy', input=iframe, encoding='utf-8', check=True)
        copied = True
    elif sys.platform.startswith('linux'):
        subprocess.run(['xclip', '-selection', 'clipboard'], input=iframe, encoding='utf-8', check=True)
        copied = True
except Exception as e:
    pass

size_kb = round(len(iframe) / 1024, 1)
print('=== DASHBOARD srcdoc ===')
print(f'Source: {os.path.relpath(out_path)}')
print(f'Size: {size_kb} KB')
print(f'Clipboard: {"OK" if copied else "FAIL (copia manual desde dashboard-srcdoc.html)"}')
print('')
print('Pegar en GHL: Custom Menu Link -> Custom Code/HTML mode -> paste')
