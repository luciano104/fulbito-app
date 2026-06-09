# ⚽ Fulbito App
### Gestión y Reserva de Canchas de Fútbol — Salta Capital

Aplicación móvil que centraliza la búsqueda y reserva de canchas de fútbol amateur en Salta Capital.
Desarrollada con **Flutter** (frontend móvil) y **Django REST Framework** (backend + base de datos relacional).

---

## Equipo

| Integrante | Rol |
|---|---|
| Luciano Burgos | Backend Django + Autenticación |
| Walter Flores | Flutter — Flujo Usuario Jugador |
| Enzo | Flutter — Flujo Usuario Dueño de Complejo |

---

## Estructura del repositorio

```
fulbito-app/
├── backend/          # Servidor Django (Python)
│   ├── config/       # Configuración general (settings, urls)
│   ├── users/        # Modelo de usuario y roles
│   ├── authentication/  # Login, registro, tokens
│   ├── complejos/    # Complejos, canchas, horarios, reservas, reseñas
│   ├── manage.py
│   └── requirements.txt
│
└── mobile_app/       # App Flutter (Dart)
    ├── lib/
    │   ├── core/
    │   │   ├── constants/   # Roles, rutas
    │   │   └── services/    # ApiClient — cliente HTTP hacia Django
    │   ├── features/
    │   │   ├── auth/        # Pantallas de login y registro
    │   │   ├── jugador/     # Flujo completo del jugador
    │   │   └── dueno/       # Flujo completo del dueño de complejo
    │   └── main.dart
    └── pubspec.yaml
```

---

## Cómo levantar el proyecto

### Requisitos previos

- Python 3.10 o superior
- Flutter SDK
- Git

### 1 — Backend Django

```bash
# Entrar a la carpeta del backend
cd backend

# Crear y activar el entorno virtual
python -m venv venv

# Windows
venv\Scripts\activate.bat

# macOS / Linux
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Crear las tablas en la base de datos
python manage.py migrate

# Levantar el servidor
python manage.py runserver
```

El servidor queda corriendo en `http://127.0.0.1:8000`.

### 2 — App Flutter

```bash
# Entrar a la carpeta del frontend
cd mobile_app

# Instalar dependencias de Dart
flutter pub get

# Correr en Chrome
flutter run -d chrome

# Correr en emulador Android
flutter run -d android

## Arquitectura

La app sigue el patrón **Feature-First** con separación en capas:

```
Screen  →  Provider  →  Service  →  ApiClient  →  Django REST API
```

- **Screen:** solo renderiza la UI
- **Provider:** maneja el estado
- **Service:** lógica de negocio, llama a la API
- **ApiClient:** único punto de contacto con el backend Django

---

## Roles de usuario

| Rol | Descripción |
|---|---|
| Jugador | Busca complejos, hace reservas, deja reseñas |
| Dueño de Complejo | Gestiona sus canchas, confirma reservas |
| Super Admin | Modera la plataforma desde el panel Django |

---

## Estado del proyecto

- [x] Estructura base del proyecto
- [x] Configuración de Django + Django REST Framework
- [ ] Modelos y migraciones (users, complejos, reservas, reseñas)
- [ ] Endpoints de autenticación (registro, login, token)
- [ ] Flujo jugador en Flutter
- [ ] Flujo dueño en Flutter
- [ ] Integración Flutter ↔ Django

---