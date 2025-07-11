# ECUAEXPLORE - App Móvil de Turismo Ciudadano

## Descripción

La empresa de desarrollo **IsaacQ** presenta *ECUAEXPLORE*, una aplicación móvil orientada al turismo ciudadano. La app permite a los usuarios explorar y compartir sitios turísticos en Ecuador a través de un microblog interactivo, reseñas y fotografías.

---

## Funcionalidades principales

- ✅ Registro e inicio de sesión de usuarios (Soporte para roles: Publicador y Visitante)
- ✅ Publicación de entradas (lugares turísticos) en el microblog
- ✅ Subida de imágenes (hasta 5 fotos por sitio), desde la cámara o galería
- ✅ Validación de tamaño y tipo de archivo en las fotos
- ✅ Redacción de reseñas sobre sitios turísticos
- ✅ Responder a reseñas existentes

---

## Perfiles de usuario

### Visitante

- Puede visualizar contenido (lugares, fotos y reseñas)
- No puede publicar entradas ni responder

![Imagen de WhatsApp 2025-07-10 a las 20 22 49_684c5136](https://github.com/user-attachments/assets/245e3938-b783-42aa-87fa-d32a24e8d79e)

![Imagen de WhatsApp 2025-07-10 a las 20 22 49_040ec65f](https://github.com/user-attachments/assets/4667830b-7de7-4bd3-87da-8af0cb691442)


### Publicador

- Puede crear lugares turísticos
- Puede subir fotos y agregar ubicaciones
- Puede escribir y responder reseñas

![Imagen de WhatsApp 2025-07-10 a las 20 25 59_4e616c57](https://github.com/user-attachments/assets/004552b6-bd37-4e1b-8810-16fd92d6ae76)

![Imagen de WhatsApp 2025-07-10 a las 20 26 00_39f654e6](https://github.com/user-attachments/assets/325a518a-a36e-467c-950e-ba8df8b381f1)

![Imagen de WhatsApp 2025-07-10 a las 20 26 00_7653bc49](https://github.com/user-attachments/assets/760a3dc0-3c45-4c3a-aabf-02474b2dd33d)


---

## Flujos principales

### Registro e inicio de sesión

- Usuarios pueden registrarse como publicadores (con nombre, email y contraseña)
- Visitantes pueden ingresar sin registro

### Publicación de lugares

- Crear lugares con nombre, descripción, calificación y fotos
- Agregar ubicación actual (enlace a Google Maps)

### Reseñas

- Usuarios pueden dejar reseñas en lugares
- Publicadores pueden responder a reseñas

---

## Estructura del repositorio sugerida

```
/lib
  ├── login_page.dart
  ├── turismo_page.dart
  ├── detalle_lugar.dart
  ├── services
       ├── auth_service.dart
       ├── image_service.dart
       ├── location_service.dart
```

---

## Entregables

- ✅ APK funcional para dispositivos Android
- ✅ Repositorio GitHub con código fuente completo

---

## Capturas sugeridas

- Registro e inicio de sesión
  
  ![IMG-20250708-WA0028](https://github.com/user-attachments/assets/a4abf36c-d4cd-465e-af9e-abe276bae833)
  
  ![IMG-20250708-WA0027](https://github.com/user-attachments/assets/21745699-42f0-4df0-88b3-a1e1dc37faa7)

  
- Pantalla principal (lista de lugares)
  
  ![Imagen de WhatsApp 2025-07-10 a las 20 26 00_39f654e6](https://github.com/user-attachments/assets/758f971d-39f3-4cb5-8e09-235587d9c31e)


- Formulario para agregar lugar
  
  ![Imagen de WhatsApp 2025-07-10 a las 20 46 33_f1829379](https://github.com/user-attachments/assets/739c8de6-ba70-4143-ab28-3be5d24ed575)


- Vista de detalle de lugar (reseñas y fotos)
  
  ![Imagen de WhatsApp 2025-07-10 a las 20 26 00_7653bc49](https://github.com/user-attachments/assets/2be4ecab-d973-47f3-b238-0d8c07a76dae)

- Respuesta a reseñas
  
  ![Imagen de WhatsApp 2025-07-10 a las 20 25 59_4e616c57](https://github.com/user-attachments/assets/2868b1c4-78bb-4ca0-a354-84d09eb2b129)


---

## Tecnologías utilizadas

- **Frontend**: Flutter
  
  <img width="1923" height="1012" alt="image" src="https://github.com/user-attachments/assets/26c8c551-c104-49e4-b47d-f4c430246144" />


- **Backend**: Supabase
  
  <img width="1923" height="875" alt="image" src="https://github.com/user-attachments/assets/bab21662-a569-485f-b1de-a2db28c8a669" />

  
- **Autenticación**: Supabase Auth

  <img width="1923" height="871" alt="image" src="https://github.com/user-attachments/assets/ec128db6-c1c4-4d82-836d-35903a6f0e01" />

  
- **Almacenamiento**: Supabase Storage (para imágenes)

  <img width="1923" height="881" alt="image" src="https://github.com/user-attachments/assets/733c67a3-1441-445a-b745-a786cd14f7ae" />

  
- **Base de datos**: Supabase Postgres
  
  <img width="1923" height="878" alt="image" src="https://github.com/user-attachments/assets/0e0519fb-0ed1-44dc-9b2e-5899df4ef2ea" />
  
  <img width="1923" height="880" alt="image" src="https://github.com/user-attachments/assets/201b4601-2d21-4dfd-9402-ab7a1c05674d" />
  
  <img width="1923" height="879" alt="image" src="https://github.com/user-attachments/assets/4074cb98-dd9c-4cd0-8aed-5125c5afa097" />
  
  <img width="1923" height="881" alt="image" src="https://github.com/user-attachments/assets/f4030daa-cc6f-4809-ba1b-b9dc97161a64" />

---

## 📄 Privacy Policy

### Declaración general

La aplicación **Ecuaexplore**, desarrollada por **IsaacQ** (Isaac Quinapallo), se compromete a proteger la privacidad de sus usuarios. La presente política explica cómo se recopila, utiliza y protege la información proporcionada.

### Información recopilada

- Datos de cuenta: nombre, correo y contraseña (solo para publicadores).
- Publicaciones, reseñas y fotos.
- Ubicación (opcional al crear un lugar).
- Datos de uso básicos (tipo de dispositivo, sistema operativo).

### Información que NO se recopila

- No se recopilan datos financieros ni sensibles.
- No se comparten datos con terceros con fines publicitarios.

### Almacenamiento y seguridad

- Datos guardados en Supabase con cifrado y seguridad.
- Imágenes en Supabase Storage, solo accesibles a usuarios y administradores.

### Uso de la información

- Gestionar cuentas y publicaciones.
- Mejorar la experiencia y personalizar el contenido.

### Compartición de datos

- No se venden ni alquilan datos.
- Solo se comparte lo necesario para funcionamiento interno.

### Permisos solicitados

- Ubicación (opcional).
- Cámara y galería (para fotos).
- Almacenamiento.

### Derechos del usuario

- Puede solicitar eliminación de su cuenta y datos escribiendo a isaac.quinapallo@epn.edu.ec

### Cambios

- Se notificará cualquier cambio en la app o repositorio.

### Contacto

isaac.quinapallo@epn.edu.ec

---

## Créditos

De: Isaac Quinapallo
