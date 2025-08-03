# 🧠 argOS OSINT Installer

**Instalador automático e interactivo de herramientas OSINT libres para la distribución argentina [argOS](https://github.com/arg-os).**

---

## 🚀 ¿Qué es esto?

Este script instala automáticamente algunas de las herramientas OSINT más utilizadas, configurando entornos funcionales, accesos desde el menú del sistema (XFCE) y alias útiles desde terminal.

Está pensado para integrarse con la estética y filosofía de **argOS**, permitiendo tanto instalaciones completas como manuales.

---

## 🛠️ Características

- ✔️ Instalación automática o manual (menú interactivo con `whiptail`)
- 🔄 Actualización automática del sistema tras la instalación
- 📋 Registro de logs
- 🧩 Alias de terminal para cada herramienta
- 🖥️ Accesos desde el menú de aplicaciones (entorno XFCE)
- 🇦🇷 Optimizado para funcionar directamente sobre argOS

---

## 📦 Herramientas que puede instalar

| Herramienta    | Función principal                      |
|----------------|----------------------------------------|
| SpiderFoot     | Reconocimiento automatizado OSINT      |
| theHarvester   | Recopilación de correos, hosts, etc.   |
| Amass          | Recolección de subdominios             |
| Photon         | Crawler OSINT avanzado                 |
| Sherlock       | Busca usuarios en redes sociales       |
| Holehe         | Email checker en sitios comunes        |
| GHunt          | Recolector de datos desde cuentas Google |
| Metagoofil     | Extracción de metadatos en documentos  |

---

## 📥 Instalación

1. Cloná este repositorio o descargá el `.deb` desde la [sección releases](https://github.com/tu-repo-url/releases).

2. Instalar el paquete `.deb`:

```bash
sudo dpkg -i argos-installer_0.1-1_all.deb
