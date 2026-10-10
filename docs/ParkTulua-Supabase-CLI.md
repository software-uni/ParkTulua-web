---
fileClass: NotaBase, NotaBase-mejorado
source: 
id: ParkTulua-Guia-Supabase-CLI
tipo: setup
aliases: [Guia Supabase CLI ParkTuluá, Configurar Supabase CLI, Supabase CLI parkTulua-web]
tags: [Gestion/Universidad, Dev/Backend, Infra/Bases-Datos]
fecha_creacion: 2026-10-09
fecha_actualizacion: 2026-10-09
autor: Alejandro
estado: En progreso
categoria:
  - SoftwareDeveloper
referencias: [ParkTulua-Modelo-Logico, ParkTulua-Especificacion-de-Requisitos, Readme-web]
enlace_directo: ""
---
# Guía de configuración de Supabase CLI: ParkTuluá

> Descripción
> 
> > Pasos para que cada integrante instale, enlace y use Supabase CLI dentro del repositorio `parkTulua-web` contra el proyecto Supabase `ParkTulua-backend`. Incluye reglas de equipo para migraciones, generación de tipos, desarrollo local opcional y solución de problemas. Estado: propuesta pendiente de validar en la máquina de cada integrante.

## Objetivo

**Objetivo principal:** Que los cuatro integrantes trabajen con la misma versión de la CLI, el mismo esquema versionado y las mismas reglas para tocar la base de datos, sin modificar por accidente el proyecto compartido.
## Contenido Principal

### 1. Alcance y estado

| Elemento | Estado |
| -------- | ------ |
| Supabase CLI como dependencia de desarrollo del repositorio web | En uso (`npm install supabase --save-dev`) |
| Carpeta `supabase/` con `config.toml` | Creada con `supabase init`, pendiente de subir al repositorio |
| Historial de migraciones versionado en el repositorio | Pendiente (ver sección 5) |
| Desarrollo local con Docker | Opcional |
| Proyecto remoto | `ParkTulua-backend`, referencia `vphjvtrjmhmdhozxhtww`, región us-west-2 |
| Quién aplica migraciones al proyecto remoto | Pendiente de acordar (propuesta: una sola persona, ver sección 7) |

Esta guía no define el backend de la Fase 2 ni cambia el esquema. Solo explica cómo operar la base con la CLI.

### 2. Requisitos previos

| Requisito | Para qué | Cómo comprobarlo |
| --------- | -------- | ---------------- |
| Node.js en la versión acordada por el grupo (`engines` en `package.json` y `.nvmrc`) | Ejecutar la CLI instalada con npm | `node --version` |
| npm (único gestor del proyecto) | Instalar dependencias | `npm --version` |
| Acceso al proyecto en Supabase | Enlazar y consultar migraciones | Invitación del líder a la organización |
| Docker Desktop (o Docker Engine) en ejecución | Solo para `db pull`, `db diff`, `start` y `db reset` | `docker ps` sin error |

Para solo enlazar el proyecto, ver migraciones y generar tipos, Docker no es necesario.

### 3. Regla de uso: la CLI se ejecuta con `npx`

La CLI está instalada dentro del proyecto, no en el sistema. Siempre se invoca con `npx supabase ...` (o desde un script de npm). No se instala de forma global con `npm install -g`, porque Supabase no soporta esa vía de instalación, y así todos usan la versión fijada en `package-lock.json`.

### 4. Configuración inicial (una vez por integrante)

| Paso | Comando | Resultado esperado |
| ---- | ------- | ------------------ |
| 1. Instalar dependencias | `npm install` | Termina sin errores. |
| 2. Verificar la CLI | `npx supabase --version` | Imprime un número de versión. |
| 3. Iniciar sesión | `npx supabase login` | Abre el navegador y confirma el inicio de sesión. |
| 4. Enlazar el proyecto | `npx supabase link --project-ref vphjvtrjmhmdhozxhtww` | Pide la contraseña de la base de datos y termina sin error. |
| 5. Ver migraciones | `npx supabase migration list` | Muestra la tabla de migraciones locales y remotas (puede estar vacía). |
| 6. Generar tipos | `npx supabase gen types typescript --project-id vphjvtrjmhmdhozxhtww > src/core/types/database.ts` | Crea el archivo de tipos sin caracteres extraños. |

Notas:

- `supabase init` ya fue ejecutado en el repositorio. No se repite: si se vuelve a correr, se debe conservar el `config.toml` existente.
- La contraseña de la base de datos la entrega el líder por un canal privado. Si se perdió, se restablece desde el panel de Supabase (Project Settings, Database) y se avisa al grupo.
- La contraseña, el token de acceso y cualquier archivo `.env` no se suben al repositorio.

### 5. Historial de migraciones: primera vez

El esquema del proyecto remoto (15 tablas con RLS en Fase 1) se creó antes de usar la CLI, por lo que `supabase/migrations/` está vacío en el repositorio. Antes de que alguien aplique cambios con la CLI, el repositorio debe tener la línea base. Esto lo hace una sola persona, una única vez.

| Paso | Comando | Resultado esperado |
| ---- | ------- | ------------------ |
| 1. Verificar que Docker corre | `docker ps` | Sin error de conexión. |
| 2. Traer el esquema remoto | `npx supabase db pull` | Crea un archivo en `supabase/migrations/` y pregunta si actualizar el historial remoto. |
| 3. Aceptar la actualización del historial | Responder `Y` | El historial remoto queda alineado con el archivo local. |
| 4. Comprobar | `npx supabase migration list` | La misma versión aparece en las columnas Local y Remote. |
| 5. Subir | `git add supabase/` y commit en una rama | La línea base queda en el repositorio. |

Si la CLI informa que el historial remoto no coincide con los archivos locales, se ejecutan exactamente los comandos `migration repair` que la propia CLI imprime. No se inventan versiones.

Alternativa si el equipo conserva los archivos SQL originales de las migraciones: copiarlos a `supabase/migrations/` con el nombre `<version>_<nombre>.sql` y marcar cada versión como aplicada:

```
npx supabase migration repair --status applied <version>
```

Esta alternativa solo es válida si el contenido de cada archivo es idéntico a lo aplicado en remoto. Si hay duda, se usa `db pull`.

### 6. Flujo de trabajo para cambios en la base

| Paso | Comando | Quién |
| ---- | ------- | ----- |
| 1. Crear el archivo de migración | `npx supabase migration new nombre_en_snake_case` | Quien propone el cambio |
| 2. Escribir el SQL en el archivo creado | Editor | Quien propone el cambio |
| 3. Probar en local (opcional) | `npx supabase db reset` | Quien propone el cambio |
| 4. Abrir Pull Request con el archivo | Git | Quien propone el cambio |
| 5. Revisión por otro integrante | Pull Request | Revisor |
| 6. Aplicar al proyecto remoto | `npx supabase db push` | Responsable de la base (propuesta) |
| 7. Regenerar tipos | Ver sección 4, paso 6 | Quien aplicó la migración |

Reglas:

1. Una migración ya aplicada no se edita. Se crea otra nueva.
2. Cada tabla nueva en `public` activa RLS en la misma migración.
3. Los cambios hechos desde el panel de Supabase se evitan. Si ocurren, se registran con `db pull`.
4. Nunca se ejecuta `npx supabase db reset --linked`: borra y recrea el proyecto remoto compartido.
5. `db push` se ejecuta solo después de aprobar el Pull Request.

### 7. Desarrollo local (opcional)

Requiere Docker en ejecución.

| Comando                                                                                                 | Qué hace                                                                    |
| ------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `npx supabase start` o `npx supabase start -x logflare,vector,studio,imgproxy,storage,realtime,pg_meta` | Levanta una instancia local de Supabase. La primera vez descarga imágenes.  |
| `npx supabase status`                                                                                   | Muestra las URL y claves locales.                                           |
| `npx supabase db reset`                                                                                 | Recrea la base local aplicando las migraciones y luego `supabase/seed.sql`. |
| `npx supabase stop`                                                                                     | Detiene la instancia local.                                                 |

Los datos de ejemplo (`supabase/seed.sql`) son inventados y solo se usan en local. Para probar con Firebase en local se configura en `supabase/config.toml` la sección de autenticación de terceros de Firebase con el identificador del proyecto de Firebase. El rol `authenticated` en el token sigue dependiendo de la tarea UNI-57. Esta configuración local no se ha validado todavía.

### 8. Scripts sugeridos en `package.json`

Sujeto a aprobación del grupo.

```json
{
  "scripts": {
    "db:local": "supabase start -x logflare,vector,studio,imgproxy,realtime,pg_meta",
    "db:local:parar": "supabase stop",
    "db:local:reset": "supabase db reset",
    "db:migraciones": "supabase migration list",
    "db:tipos": "supabase gen types typescript --linked > src/core/types/database.ts"
  }
}
```

#### Scripts de base de datos (utilizar la db localmente)

`db:local`
```json
"db:local": "supabase start -x logflare,vector,studio,imgproxy,realtime,pg_meta"
```
**Levanta la base de datos local de Supabase en Docker**, excluyendo (`-x`) los servicios que no usas (Logflare, Vector, Studio, Imgproxy, Realtime y Pg Meta). Arranca solo lo esencial: PostgreSQL + Auth + API (Kong). Pensado para desarrollo rápido y ligero.

`db:local:parar`
```json
"db:local:parar": "supabase stop"
```
**Detiene todos los contenedores** de Supabase local. No borra datos ni volúmenes, solo apaga los servicios. La próxima vez que uses `db:local` los vuelves a levantar con los mismos datos.

`db:local:reset`
```json
"db:local:reset": "supabase db reset"
```

**Reconstruye la base de datos local desde cero**. Borra todo, recrea la BD, reaplica todas las migraciones de `supabase/migrations/` y ejecuta `seed.sql`. Útil cuando cambias migraciones o quieres un estado limpio. **Solo afecta local, no toca producción**.

`db:migraciones`
```json
"db:migraciones": "supabase migration list"
```

**Lista el historial de migraciones** comparando lo que existe en local vs. lo que está aplicado en remoto. Te muestra qué migraciones están aplicadas, pendientes o desincronizadas. Es tu comando de "¿en qué estado estoy?".

`db:tipos`

```json
"db:tipos": "supabase gen types typescript --linked > src/core/types/database.ts"
```

**Genera tipos TypeScript automáticamente** a partir del esquema de tu base de datos remota (`--linked`) y los guarda en `src/core/types/database.ts`. Así tienes autocompletado y seguridad de tipos al consultar Supabase desde React. **Debes re-ejecutarlo cada vez que cambies el esquema remoto** (nuevas tablas, columnas, etc.).
#### Flujo típico de trabajo

| Momento                                      | Comando                  |
| -------------------------------------------- | ------------------------ |
| Empiezo a trabajar                           | `npm run db:local`       |
| Cambié el esquema remoto (nueva tabla, etc.) | `npm run db:tipos`       |
| Traje migraciones nuevas con git             | `npm run db:local:reset` |
| Quiero ver qué migraciones están aplicadas   | `npm run db:migraciones` |
| Termino de trabajar                          | `npm run db:local:parar` |

**Regla mental**

- **`db:local`** → enciende
- **`db:local:parar`** → apaga
- **`db:local:reset`** → reinicia desde cero (destructivo, local)
- **`db:migraciones`** → consulta el estado
- **`db:tipos`** → sincroniza TypeScript con el esquema remoto
### 9. Archivos del repositorio relacionados

| Ruta                                      | Se sube | Contenido                                                                |
| ----------------------------------------- | ------- | ------------------------------------------------------------------------ |
| `supabase/config.toml`                    | Sí      | Configuración de la CLI.                                                 |
| `supabase/migrations/*.sql`               | Sí      | Migraciones versionadas.                                                 |
| `supabase/seed.sql`                       | Sí      | Datos de ejemplo para desarrollo local.                                  |
| `supabase/.temp/` y `supabase/.branches/` | No      | Estado local de la CLI. Verificar que `supabase/.gitignore` los excluya. |
| `.env.local`                              | No      | Variables personales.                                                    |
| `postman/`                                | Sí      | Colección y environment de Postman, sin claves (ver sección 10).         |

### 10. Colección de Postman en el repositorio

| Archivo | Se sube | Notas |
| ------- | ------- | ----- |
| `postman/ParkTulua-Supabase-Fase1.postman_collection.json` | Sí | Variables sensibles vacías. |
| `postman/ParkTulua-Supabase.postman_environment.json` | Sí, solo con valores vacíos | Cada integrante completa `supabase_anon_key`, `firebase_api_key`, `email` y `password` en su Postman. |

Reglas:

- No se re-exporta el environment con valores reales.
- Los tokens de Firebase se guardan en variables de la colección (valor actual, no inicial) y no se sincronizan al valor inicial.
- Cambios en la colección entran por Pull Request, igual que el código.

### 11. Solución de problemas

Las causas son probables y deben confirmarse con el mensaje exacto del error.

| Síntoma | Causa probable | Acción |
| ------- | -------------- | ------ |
| `supabase: command not found` | Se invocó sin `npx` | Usar `npx supabase ...` |
| Error de conexión con el daemon de Docker | Docker no está en ejecución | Abrir Docker Desktop y repetir |
| Token de acceso no encontrado o no autorizado | Falta iniciar sesión | `npx supabase login` |
| `link` falla por autenticación de base de datos | Contraseña incorrecta | Restablecerla en el panel y repetir `link` |
| El historial remoto no coincide con los archivos locales | Faltan migraciones locales o el historial remoto fue modificado | Aplicar la sección 5 y usar los comandos `migration repair` que imprime la CLI |
| `db push` falla con objetos que ya existen | El historial remoto no registra migraciones ya aplicadas | No forzar. Resolver primero la sección 5 |
| El archivo `database.ts` queda con caracteres extraños | Redirección `>` en Windows PowerShell 5 guarda en UTF-16 | Ejecutar `npm run db:tipos` o usar PowerShell 7 |
| Errores de campos desconocidos en `config.toml` | Versión de la CLI distinta a la que generó el archivo | Usar la versión de `package-lock.json` (`npm ci`) |

Si el problema persiste se comparte en el grupo el comando ejecutado y el mensaje completo, sin contraseñas ni tokens.

### 12. Criterios de verificación

| Criterio | Cómo se comprueba |
| -------- | ----------------- |
| La CLI funciona | `npx supabase --version` imprime una versión. |
| El proyecto está enlazado | `npx supabase migration list` responde sin error. |
| La línea base está versionada | Existe un archivo en `supabase/migrations/` y la misma versión aparece en Local y Remote. |
| Los tipos se generan | `src/core/types/database.ts` contiene tipos de `parqueadero`, `reserva` y `estancia`. |
| Nada sensible en Git | `git status` no muestra `.env*`, `supabase/.temp` ni claves. |

## Véase También

- [[ParkTulua-Modelo-Logico]]
- [[ParkTulua-Especificacion-de-Requisitos]]
- [[Readme-web]]
- [[NotaBase-mejorado]]

**Última modificación:** 2026-10-09
