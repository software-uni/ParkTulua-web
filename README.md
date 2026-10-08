# ParkTuluá Web – Aplicación de Administración (React / TypeScript)

Guía oficial del equipo para crear, ordenar y mantener este repositorio.
**Léela completa antes de escribir la primera línea de código.** Si algo no está claro, se pregunta en el grupo antes de improvisar.

---

## 1. ¿Qué estamos construyendo?

Una aplicación web para el **personal de los parqueaderos** (propietario, operador, supervisor), hecha con **React + TypeScript** y **Vite**. Es la herramienta con la que cada parqueadero administra su operación diaria.

| Pieza                                            | Tecnología                                              | Para qué sirve                                                   |
| ------------------------------------------------ | ------------------------------------------------------- | ---------------------------------------------------------------- |
| App web de administración (**este repositorio**) | React + TypeScript + Vite                               | Lo que usa el personal del parqueadero                           |
| App de conductores                               | Kotlin + Jetpack Compose (repositorio `parqueaderoapp`) | Lo que usa el conductor                                          |
| Base de datos y reglas de acceso                 | Supabase (PostgreSQL + RLS)                             | Guardar datos y decidir quién ve qué                             |
| Inicio de sesión                                 | Firebase Authentication                                 | Identificar a la persona que entra                               |
| Lógica de servidor                               | Funciones de Supabase (en definición)                   | Operaciones que cambian datos: reservar, cobrar, validar códigos |

> Este repositorio contiene **solo la web de administración**. La app de conductores tiene su propio repositorio. (Si algún documento dice que la app de administradores es React Native, está desactualizado: la de administración es esta web.)

### Principio de ParkTuluá que también afecta a esta web

Un conductor **no necesita cuenta** para usar el servicio. El personal **sí** debe iniciar sesión. Por eso esta web:

- Solo permite entrar a cuentas que tengan una asignación activa a un parqueadero.
- Debe permitir registrar el ingreso de una persona **sin cuenta y sin reserva**. Nunca se crea un usuario ficticio para ella.
- Muestra y valida códigos o QR de operaciones que pueden ser anónimas.

### Qué pantallas tiene (según el diseño en Figma)

| Pantalla                                                                    | Estado del diseño  |
| --------------------------------------------------------------------------- | ------------------ |
| Inicio de sesión                                                            | Diseñada           |
| Dashboard (ocupación, reservas del día, pagos recientes)                    | Diseñada           |
| Reservas                                                                    | Diseñada           |
| Servicios en curso                                                          | Diseñada           |
| Verificar retiro                                                            | Diseñada           |
| Pagos y comprobante                                                         | Diseñada           |
| Usuarios (personal del parqueadero)                                         | Diseñada           |
| Perfil del parqueadero, Catálogo de servicios, QR de entrada, Configuración | Sin diseño todavía |

> **Lo que lleva en Figma no es automáticamente un requisito aprobado.** La fuente de verdad es el documento `ParkTulua-Especificacion-de-Requisitos.md`.

### Qué puede hacer hoy esta web

La seguridad de la base de datos está en **Fase 1: solo lectura**. La web puede **leer** lo que le corresponde al personal de su parqueadero. Las acciones que **cambian datos** (actualizar cupos, confirmar un retiro, cambiar el estado de un servicio, registrar un ingreso) se conectan cuando existan las funciones de servidor de la Fase 2. Mientras tanto, esas pantallas se construyen hasta el punto de mostrar los datos y dejar el botón preparado.

---

## 2. Herramientas que debe tener cada integrante

- **Node.js** en la versión que se acuerde en el grupo (se fija en `package.json`, campo `engines`, y en `.nvmrc`).
- **npm** (viene con Node). En este proyecto se usa **solo npm**: no se mezcla con yarn ni pnpm.
- **Git** instalado y configurado con tu nombre y correo.
- **VS Code** con las extensiones _ESLint_ y _Tailwind CSS IntelliSense_.
- Acceso al repositorio y a los proyectos de Firebase y Supabase (te lo da el líder del grupo).

---

## 3. Cómo empezar (clonar el repositorio)

1. Clona el repositorio:
   ```
   git clone https://github.com/USUARIO/parkTulua-web.git
   cd parkTulua-web
   ```
2. Instala las librerías:
   ```
   npm install
   ```
3. Crea tu archivo de variables copiando el de ejemplo y completándolo con los datos que te dé el líder:
   ```
   cp .env.example .env.local
   ```
4. Cambia a la rama de trabajo:
   ```
   git branch main
   git pull
   git checkout -b
   ```
5. Arranca la web en modo desarrollo:
   ```
   npm run dev
   ```
6. Crea tu propia rama para tu tarea (ver sección 9).

### Comandos del proyecto

| Comando           | Para qué                                 |
| ----------------- | ---------------------------------------- |
| `npm run dev`     | Arrancar la web en tu computador         |
| `npm run build`   | Revisar tipos y generar la versión final |
| `npm run lint`    | Revisar el código con ESLint             |
| `npm run preview` | Ver cómo queda la versión final          |

---

## 4. Librerías del proyecto

Todas se agregan **solo con acuerdo del grupo** (ver sección 8).

| Librería                                   | Para qué                                               | Estado                       |
| ------------------------------------------ | ------------------------------------------------------ | ---------------------------- |
| `react`, `react-dom`, `typescript`, `vite` | Base del proyecto (vienen con la plantilla `react-ts`) | En uso                       |
| `react-router` (versión 7)                 | Navegación entre pantallas                             | En uso                       |
| `@supabase/supabase-js`                    | Leer datos de Supabase                                 | En uso                       |
| `firebase`                                 | Inicio de sesión (Firebase Authentication)             | En uso                       |
| `tailwindcss` y `@tailwindcss/vite`        | Estilos                                                | En uso                       |
| `clsx` y `tailwind-merge`                  | Combinar clases de Tailwind sin choques                | En uso                       |
| `lucide-react`                             | Iconos de la interfaz                                  | En uso                       |
| `dotlottie-react`                          | Animación del inicio de sesión                         | En uso                       |
| `@tanstack/react-query`                    | Manejo de datos del servidor (cargando, error, caché)  | Propuesta                    |
| `react-hook-form` y `zod`                  | Formularios y validaciones                             | Propuesta                    |
| `vitest` y `@testing-library/react`        | Pruebas                                                | Propuesta, para más adelante |

### Datos base del proyecto

| Dato                   | Valor                                           |
| ---------------------- | ----------------------------------------------- |
| Nombre del repositorio | `parkTulua-web`                                 |
| Lenguaje               | TypeScript (modo estricto, sin `any`)           |
| Interfaz               | React                                           |
| Construcción           | Vite                                            |
| Estilos                | Tailwind CSS (versión 4, con el plugin de Vite) |
| Idioma de la interfaz  | Español                                         |

---

## 5. Estructura del código

Todo el código vive dentro de `src/`.

```
parkTulua-web/
├── public/                         archivos estáticos (iconos, animaciones)
├── src/
│   ├── main.tsx                    puerta de entrada
│   ├── index.css                   estilos globales y tema (colores, letras)
│   │
│   ├── app/                        el armado de la aplicación
│   │   ├── App.tsx
│   │   ├── router.tsx              el mapa de pantallas y rutas protegidas
│   │   └── providers/              sesión, datos del servidor, parqueadero activo
│   │
│   ├── core/                       lo que usa toda la app
│   │   ├── config/                 lectura de variables de entorno
│   │   ├── firebase/               cliente de Firebase
│   │   ├── supabase/               cliente de Supabase
│   │   ├── types/                  tipos de la base de datos (generados)
│   │   └── lib/                    ayudas pequeñas (cn, formato de fechas y dinero)
│   │
│   ├── shared/                     piezas reutilizables sin lógica de negocio
│   │   ├── ui/                     Button, Input, Card, Modal, Spinner
│   │   ├── layout/                 Sidebar, Topbar, PageHeader
│   │   └── hooks/                  hooks genéricos
│   │
│   └── features/                   lo que el usuario ve, una carpeta por módulo
│       ├── auth/                   login y control de acceso
│       ├── dashboard/
│       ├── reservas/
│       ├── servicios/
│       ├── retiro/                 verificación de retiro
│       ├── pagos/
│       └── usuarios/               personal del parqueadero
│
├── .env.example                    ejemplo de variables (SÍ se sube)
├── .env.local                      TUS variables (NO se sube)
├── eslint.config.js
├── index.html
├── package.json
├── tsconfig.json / tsconfig.app.json
├── vite.config.ts
└── README.md
```

Cada módulo de `features/` se ve así (se crean solo las carpetas que se necesitan):

```
features/reservas/
├── pages/          pantallas completas (ReservasPage.tsx)
├── components/     piezas propias del módulo (ReservaCard.tsx)
├── hooks/          estado y datos de la pantalla (useReservas.ts)
├── api/            ÚNICO lugar que habla con Supabase (reservasApi.ts)
└── types/          tipos propios del módulo
```

> No hace falta crear todo desde el primer día. Se empieza con `app/`, `core/`, `shared/layout` y `features/auth`, y el resto se crea cuando se necesite.

### Qué va en cada carpeta (en palabras simples)

| Carpeta            | Analogía                | Qué contiene                                        |
| ------------------ | ----------------------- | --------------------------------------------------- |
| `features/*/pages` | El comedor              | Pantallas que ve el personal                        |
| `features/*/hooks` | El mesero               | Pide los datos y los entrega a la pantalla          |
| `features/*/api`   | La cocina               | El código que realmente habla con Supabase          |
| `shared`           | La vajilla              | Botones, tarjetas y estructura que todos reutilizan |
| `core`             | Los servicios generales | Conexiones, configuración y ayudas compartidas      |

### Reglas de dependencia (importante)

```
pages  ->  hooks  ->  api  ->  core/supabase
features  ->  shared  ->  core
```

- Una **pantalla o componente nunca llama directo a Supabase ni a Firebase**. Pasa por un `hook`, y el `hook` por `api`.
- `shared` **no conoce** a `features`.
- Un módulo **no importa** archivos de otro módulo. Si dos módulos necesitan lo mismo, eso sube a `shared` o `core`.
- Las llamadas a funciones de servidor (Fase 2) también viven en `api`.

Si rompes esta regla, el proyecto se vuelve un sancocho. Si dudas, pregunta.

---

## 6. Conexión con Firebase y Supabase

La persona inicia sesión con **Firebase**. Supabase recibe el token de Firebase y aplica las reglas **RLS** según quién es.

Reglas de la conexión:

- Hay **un solo cliente de Supabase** y **un solo cliente de Firebase**, en `core/`. Nadie crea clientes por su cuenta.
- El cliente de Supabase obtiene el token de la sesión de Firebase en cada petición.
- Para que Supabase reconozca al usuario como autenticado, el token de Firebase debe llevar el rol `authenticated`. Esa configuración es la tarea de Firebase conectado a Supabase (UNI-57). Hasta que esté lista, las lecturas protegidas devolverán vacío o error de permisos.
- Los tipos de la base de datos se generan, no se escriben a mano:
  ```
  npx supabase gen types typescript --project-id vphjvtrjmhmdhozxhtww > src/core/types/database.ts
  ```
  Se regeneran cada vez que cambia la base de datos.

### Variables de entorno

Archivo `.env.example` (se sube al repositorio, **sin valores reales**):

```
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
VITE_FIREBASE_API_KEY=
VITE_FIREBASE_AUTH_DOMAIN=
VITE_FIREBASE_PROJECT_ID=
VITE_FIREBASE_APP_ID=
```

Cada integrante copia ese archivo a `.env.local` y lo completa. En Vite, **todo lo que empieza por `VITE_` queda visible en el navegador**, así que ahí solo van datos públicos.

---

## 7. Cómo nombrar las cosas

| Qué es                | Cómo se llama        | Ejemplo              | Dónde va                              |
| --------------------- | -------------------- | -------------------- | ------------------------------------- |
| Pantalla completa     | `NombrePage`         | `ReservasPage.tsx`   | `features/*/pages`                    |
| Componente            | nombre en PascalCase | `ReservaCard.tsx`    | `features/*/components` o `shared/ui` |
| Hook                  | `useNombre`          | `useReservas.ts`     | `features/*/hooks`                    |
| Acceso a datos        | `nombreApi`          | `reservasApi.ts`     | `features/*/api`                      |
| Tipos                 | `nombre.types.ts`    | `reserva.types.ts`   | `features/*/types`                    |
| Proveedor de contexto | `NombreProvider`     | `AuthProvider.tsx`   | `app/providers`                       |
| Función de ayuda      | camelCase            | `formatearMoneda.ts` | `core/lib`                            |

### Idioma del código

- **Comentarios, documentación, mensajes de commit y textos de la interfaz: en español.**
- Las terminaciones técnicas (`Page`, `Provider`, `Api`, `use...`) se mantienen tal cual.
- Los nombres de variables y funciones propias del proyecto **se escriben en un solo idioma por archivo**. No se mezclan.

---

## 8. Buenas prácticas

### Orden y claridad

1. **Un componente por archivo.** El nombre del archivo es el nombre del componente.
2. **Cada cosa en su carpeta.** Si no sabes dónde va, pregunta antes de ponerlo "donde cabe".
3. **Nada de carpetas nuevas por gusto.** Si necesitas una, se acuerda con el grupo.
4. **Archivos cortos.** Si un archivo pasa de unas 200 líneas, probablemente hace demasiado: divídelo.
5. **Nombres que se entiendan solos.** `reservasDelDia` sí; `x`, `dato2`, `temp` no.

### Código limpio

6. **Un trabajo por función.** Si necesitas la palabra "y" para describirla, son dos funciones.
7. **Comenta el porqué, no el qué.**
8. **Cero código muerto.** No se deja código comentado "por si acaso". Para eso existe Git.
9. **TypeScript estricto.** Sin `any`. Los tipos de la base salen de `core/types`.
10. **Sin números ni textos "sueltos".** Los valores fijos van en constantes.
11. **`npm run lint` debe pasar sin errores** antes de subir.

### Pantallas

12. **La pantalla solo dibuja.** La lógica va en el `hook`.
13. **Nada de llamadas a Supabase o Firebase dentro de una pantalla o componente.**
14. **Las piezas que se repiten van en `shared/ui`.**
15. **Todo color, tamaño de letra y forma sale del tema** (`index.css`). No se escribe un color suelto en un componente.
16. **Las clases de Tailwind se combinan con `cn()`** (que usa `clsx` y `tailwind-merge`).
17. **Esconder un botón no es seguridad.** La seguridad real la ponen las reglas de la base y el servidor. La interfaz solo se adapta al rol.

### Librerías y configuración

18. **No se agrega una librería sin avisar.** Cada librería nueva afecta a todos.
19. **No se actualizan versiones mayores a mitad de una tarea.** Se acuerda y se hace en una rama aparte.
20. **`package-lock.json` sí se sube.** Evita que cada uno tenga versiones distintas.

### Manejo de errores

21. **Toda llamada a internet puede fallar.** Siempre se contempla el caso de error y el de "sin conexión".
22. **El usuario nunca ve un mensaje técnico.** Se le muestra un texto claro en español.
23. **Toda pantalla que carga datos tiene tres estados:** cargando, error y vacío.

---

## 9. Trabajo con Git (para no pisarnos)

### Ramas

| Rama                   | Para qué                                          |
| ---------------------- | ------------------------------------------------- |
| `main`                 | Código estable. **Nadie sube directo aquí.**      |
| `feature/nombre-corto` | Una por tarea. Ej.: `feature/login-firebase`      |
| `fix/nombre-corto`     | Para corregir errores. Ej.: `fix/filtro-reservas` |

Flujo: se crea la rama desde `main`, se trabaja, se abre una solicitud de integración (_Pull Request_), otro compañero la revisa y se une.

```
git checkout main
git pull
git checkout -b feature/nombre-corto
```

### Mensajes de commit (en español)

Formato: `tipo: descripción corta en presente`

| Tipo      | Cuándo                                          |
| --------- | ----------------------------------------------- |
| `nuevo`   | Se agrega algo nuevo                            |
| `arreglo` | Se corrige un error                             |
| `mejora`  | Se mejora algo que ya existía                   |
| `docs`    | Cambios solo de documentación                   |
| `orden`   | Se reorganizan archivos sin cambiar lo que hace |

Ejemplos buenos:

```
nuevo: pantalla de login con animación
arreglo: el filtro de reservas no se limpiaba
orden: mover tipos de reserva a features/reservas/types
```

### Reglas

- **Un commit = un cambio con sentido.**
- **Actualiza tu rama antes de empezar a trabajar** (`git pull`).
- **Nunca subas código que no compila ni pasa `npm run lint`.**
- **Nunca uses `git push --force`** sin avisar al grupo.
- **Antes de `git add .`, revisa `git status`.**
- Cada tarea se enlaza con su issue de Linear en la descripción del Pull Request.

---

## 10. Seguridad: lo que NUNCA se sube al repositorio

| Qué                                                 | Por qué                                 | Qué hacer                                                      |
| --------------------------------------------------- | --------------------------------------- | -------------------------------------------------------------- |
| `.env.local` y cualquier `.env` con valores         | Contienen datos de conexión             | Deben estar en `.gitignore`; se comparten por un canal privado |
| Clave `service_role` de Supabase                    | Da control total sobre la base de datos | **Jamás va en la web.** Solo en servidores                     |
| Clave secreta de Stripe                             | Permite cobrar y reembolsar             | Solo en el servidor                                            |
| Archivo de cuenta de servicio de Firebase (`.json`) | Da control sobre los usuarios           | Solo en el servidor                                            |
| Tokens y contraseñas                                | Cualquiera podría usarlos               | Nunca en el código ni en capturas                              |
| Carpetas `node_modules/` y `dist/`                  | Son generadas y pesan                   | Ya vienen ignoradas                                            |

En la web **solo** se usa la clave pública (`anon`) de Supabase y la configuración pública de Firebase. La seguridad real la ponen las reglas **RLS**.

Para comprobar que `.env.local` está ignorado:

```
git check-ignore -v .env.local
```

Si no responde nada, **no lo subas** y avisa al grupo.

---

## 11. Normas y estándares que debemos tener en cuenta

| Norma                           | De qué trata                   | Cómo la aplicamos                                                                             |
| ------------------------------- | ------------------------------ | --------------------------------------------------------------------------------------------- |
| **ISO/IEC 25010**               | Calidad del software           | Estructura por capas, nombres claros, manejo de errores y pantallas fáciles de usar           |
| **ISO/IEC 27001**               | Seguridad de la información    | No subir claves, usar RLS, mínimos permisos por rol, no guardar datos sensibles sin necesidad |
| **ISO/IEC 12207**               | Ciclo de vida del software     | Trabajo por ramas, revisión entre compañeros y documentación al día                           |
| **Ley 1581 de 2012 (Colombia)** | Protección de datos personales | Mostrar solo los datos necesarios (placas, nombres, correos) y solo a quien corresponde       |

> Las normas ISO son estándares de referencia. No se "certifican" en un proyecto de formación, pero sirven como lista de buenas prácticas.

---

## 12. Lista de revisión antes de subir tu trabajo

- [ ] La web arranca (`npm run dev`) y la pantalla funciona.
- [ ] `npm run lint` y `npm run build` pasan sin errores.
- [ ] Cada archivo está en su carpeta correcta.
- [ ] Los nombres siguen las reglas de la sección 7.
- [ ] No hay código comentado, imports sin usar ni `any`.
- [ ] Ninguna pantalla llama directo a Supabase ni a Firebase.
- [ ] Se contemplan los estados de cargando, error y vacío.
- [ ] `git status` no muestra ningún archivo de la lista de la sección 10.
- [ ] El mensaje del commit sigue el formato en español.
- [ ] Trabajé en mi rama, no en `main`.
- [ ] El Pull Request enlaza su issue de Linear.

---

## 13. Orden de trabajo recomendado

1. Proyecto corriendo en el navegador (`npm run dev`).
2. Tailwind, alias `@/` y carpetas iniciales de la sección 5.
3. Enrutador y estructura base (barra lateral y barra superior, como en Figma).
4. Pantalla de login con la animación, sin conectar nada todavía.
5. Firebase conectado: iniciar y cerrar sesión.
6. Cliente de Supabase con el token de Firebase y control de acceso del personal.
7. Dashboard y listas en modo lectura (reservas, servicios en curso, pagos, usuarios).
8. Acciones que cambian datos, a medida que existan las funciones de servidor.

Cada paso se prueba antes de pasar al siguiente.

---

## 14. Decisiones que siguen abiertas

| Tema                                                                                 | Estado                           |
| ------------------------------------------------------------------------------------ | -------------------------------- |
| Confirmar React como tecnología oficial de la web (issue de definición del frontend) | Por aprobar en el grupo          |
| Librería de componentes (solo Tailwind o una base como shadcn/ui)                    | Pendiente                        |
| Manejo de datos del servidor y formularios (`react-query`, `react-hook-form`, `zod`) | Propuesta                        |
| Selector de parqueadero cuando una persona administra varios                         | Pendiente (decisión de interfaz) |
| Mapa para ubicar el parqueadero en su perfil                                         | Pendiente (tecnología de mapas)  |
| Pruebas automáticas (`vitest`)                                                       | Para más adelante                |

---

## 15. Preguntas frecuentes

**¿Dónde pongo una pantalla nueva?**
En `features/nombre-del-modulo/pages`. Si el módulo no existe, se acuerda con el grupo.

**¿Puedo meter una librería nueva?**
No sin avisar. Se propone en el grupo y se agrega entre todos.

**Me sale "permission denied" o una lista vacía al leer datos.**
Casi siempre es una de dos: no has iniciado sesión, o tu cuenta no tiene una asignación activa al parqueadero. Si ya lo revisaste, puede ser que el token de Firebase aún no lleve el rol `authenticated` (ver sección 6).

**¿Por qué el botón de confirmar retiro no hace nada?**
Porque esa acción cambia datos y depende de las funciones de servidor de la Fase 2.

**Creé una carpeta pero no aparece en GitHub.**
Git no sube carpetas vacías. Aparecerá cuando tenga un archivo adentro.
