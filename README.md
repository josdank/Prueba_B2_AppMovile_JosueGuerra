# 🐾 PetAdopt

**PetAdopt** es una aplicación móvil desarrollada en **Flutter** que permite gestionar procesos de **adopción de mascotas**, conectando **refugios** y **adoptantes** de forma sencilla e intuitiva.  
La aplicación utiliza **Supabase** como backend para autenticación, base de datos y almacenamiento, e integra una **web auxiliar** para confirmación de cuenta y restablecimiento de contraseña.

---

## 📥 Descargar la aplicación (APK)
Puedes descargar e instalar la aplicación directamente desde el siguiente enlace:

👉 **[Descargar PetAdopt APK (Release)](https://github.com/josdank/Prueba_B2_AppMovile_JosueGuerra/blob/7b36d7e3df2dbd9df3f65d652094f007db88dadd/app-release.apk)**

> ⚠️ En Android puede ser necesario habilitar *“Instalar aplicaciones de orígenes desconocidos”*.

---

## 📱 Funcionalidades principales

- **Autenticación**
  - Registro e inicio de sesión con correo y contraseña
  - Inicio de sesión con Google OAuth
  - Confirmación de cuenta y recuperación de contraseña mediante web auxiliar

- **Gestión de Mascotas (Refugio)**
  - Crear, editar y eliminar mascotas
  - Subir múltiples imágenes por mascota
  - Seleccionar imagen principal
  - Información completa (nombre, raza, estado, descripción, etc.)

- **Adopciones**
  - Envío de solicitudes de adopción por parte del adoptante
  - Aprobación o rechazo por parte del refugio
  - Visualización de nombre de la mascota, raza, estado y mensaje

- **Chat con IA**
  - Chat integrado con **Google Gemini**
  - Consultas relacionadas con adopción y cuidado de mascotas

- **Mapa y localización**
  - Obtención de la ubicación del usuario
  - Visualización de refugios cercanos

---

## 🌐 Web Auxiliar
Aplicación web desplegada para:
- Confirmación de cuentas por correo
- Restablecimiento de contraseña
- Redirección automática a la app mediante **deep links**

---

## 🛠️ Tecnologías utilizadas
- Flutter (Material 3)
- Dart
- Supabase (Auth, Database, Storage, RLS)
- Google OAuth
- Google Gemini API
- Riverpod
- GoRouter
- Vercel

---

## 📂 Estructura general
```text
lib/
 ├── core/
 ├── features/
 │    ├── auth
 │    ├── pets
 │    ├── adoption
 │    ├── chat_ai
 │    └── map
 └── main.dart
