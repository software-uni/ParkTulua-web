SET local check_function_bodies = off;

CREATE TABLE "public"."asignacion_parqueadero" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "usuario_id"     uuid                     NOT NULL,
  "parqueadero_id" uuid                     NOT NULL,
  "rol"            text                     NOT NULL,
  "estado"         text                     NOT NULL DEFAULT 'activo'::text,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "asignacion_parqueadero_estado_check" CHECK ((estado = ANY (ARRAY['activo'::text, 'inactivo'::text]))),
  CONSTRAINT "asignacion_parqueadero_pkey" PRIMARY KEY (id),
  CONSTRAINT "asignacion_parqueadero_rol_check" CHECK ((rol = ANY (ARRAY['propietario'::text, 'operador'::text, 'supervisor'::text]))),
  CONSTRAINT "asignacion_unica" UNIQUE (usuario_id, parqueadero_id)
);

ALTER TABLE "public"."asignacion_parqueadero"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."asignacion_parqueadero" FROM "anon";

CREATE TABLE "public"."calificacion" (
  "id"          uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "estancia_id" uuid                     NOT NULL,
  "valoracion"  smallint                 NOT NULL,
  "comentario"  text,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "calificacion_comentario_check" CHECK (((comentario IS NULL) OR (btrim(comentario) <> ''::text))),
  CONSTRAINT "calificacion_estancia_id_key" UNIQUE (estancia_id),
  CONSTRAINT "calificacion_pkey" PRIMARY KEY (id),
  CONSTRAINT "calificacion_valoracion_check" CHECK (((valoracion >= 1) AND (valoracion <= 5)))
);

ALTER TABLE "public"."calificacion"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."calificacion" FROM "anon", "authenticated";

CREATE TABLE "public"."codigo_verificacion" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parqueadero_id"   uuid                     NOT NULL,
  "proposito"        text                     NOT NULL,
  "reserva_id"       uuid,
  "estancia_id"      uuid,
  "estado"           text                     NOT NULL DEFAULT 'generado'::text,
  "verificador_hash" text                     NOT NULL,
  "generado_en"      timestamp with time zone NOT NULL DEFAULT now(),
  "activado_en"      timestamp with time zone,
  "usado_en"         timestamp with time zone,
  "expira_en"        timestamp with time zone,
  CONSTRAINT "codigo_id_parqueadero_uq" UNIQUE (id, parqueadero_id),
  CONSTRAINT "codigo_proposito_operacion" CHECK ((((proposito = 'ingreso'::text) AND (reserva_id IS
    NOT NULL) AND (estancia_id IS NULL)) OR ((proposito = 'retiro'::text) AND (estancia_id IS NOT NULL) AND (reserva_id IS NULL)))),
  CONSTRAINT "codigo_usado_coherente" CHECK (((estado = 'usado'::text) = (usado_en IS NOT NULL))),
  CONSTRAINT "codigo_verificacion_estado_check" CHECK ((estado = ANY (ARRAY['generado'::text, 'activo'::text, 'usado'::text, 'revocado'::text, 'expirado'::text]))),
  CONSTRAINT "codigo_verificacion_pkey" PRIMARY KEY (id),
  CONSTRAINT "codigo_verificacion_proposito_check" CHECK ((proposito = ANY (ARRAY['ingreso'::text, 'retiro'::text]))),
  CONSTRAINT "codigo_verificacion_verificador_hash_check" CHECK ((btrim(verificador_hash) <> ''::text))
);

ALTER TABLE "public"."codigo_verificacion"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."codigo_verificacion" FROM "anon", "authenticated";

CREATE TABLE "public"."estancia" (
  "id"                        uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parqueadero_id"            uuid                     NOT NULL,
  "vehiculo_id"               uuid                     NOT NULL,
  "reserva_id"                uuid,
  "usuario_id"                uuid,
  "registrada_por_usuario_id" uuid,
  "hora_entrada"              timestamp with time zone NOT NULL DEFAULT now(),
  "hora_salida"               timestamp with time zone,
  "estado"                    text                     NOT NULL DEFAULT 'en_curso'::text,
  "numero_ficha"              text,
  "valor_parqueo_generado"    numeric(14,2),
  CONSTRAINT "estancia_estado_check" CHECK ((estado = ANY (ARRAY['en_curso'::text, 'finalizada'::text]))),
  CONSTRAINT "estancia_id_parqueadero_uq" UNIQUE (id, parqueadero_id),
  CONSTRAINT "estancia_numero_ficha_check" CHECK ((btrim(numero_ficha) <> ''::text)),
  CONSTRAINT "estancia_pkey" PRIMARY KEY (id),
  CONSTRAINT "estancia_salida_coherente" CHECK (((estado = 'finalizada'::text) = (hora_salida IS NOT NULL))),
  CONSTRAINT "estancia_salida_posterior" CHECK (((hora_salida IS NULL) OR (hora_salida >= hora_entrada))),
  CONSTRAINT "estancia_una_por_reserva" UNIQUE (reserva_id),
  CONSTRAINT "estancia_valor_parqueo_generado_check" CHECK ((valor_parqueo_generado >= (0)::numeric))
);

ALTER TABLE "public"."estancia"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."estancia" FROM "anon";

CREATE TABLE "public"."intento_validacion" (
  "id"                   uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parqueadero_id"       uuid                     NOT NULL,
  "proposito"            text                     NOT NULL,
  "reserva_id"           uuid,
  "estancia_id"          uuid,
  "codigo_id"            uuid,
  "validador_usuario_id" uuid,
  "resultado"            text                     NOT NULL,
  "created_at"           timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "intento_proposito_operacion" CHECK ((((proposito = 'ingreso'::text) AND (reserva_id IS
    NOT NULL) AND (estancia_id IS NULL)) OR ((proposito = 'retiro'::text) AND (estancia_id IS NOT NULL) AND (reserva_id IS NULL)))),
  CONSTRAINT "intento_validacion_pkey" PRIMARY KEY (id),
  CONSTRAINT "intento_validacion_proposito_check" CHECK ((proposito = ANY (ARRAY['ingreso'::text, 'retiro'::text]))),
  CONSTRAINT "intento_validacion_resultado_check" CHECK ((resultado = ANY (ARRAY['aprobado'::text, 'fallido'::text])))
);

ALTER TABLE "public"."intento_validacion"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."intento_validacion" FROM "anon", "authenticated";

CREATE TABLE "public"."pago" (
  "id"                 uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parqueadero_id"     uuid                     NOT NULL,
  "reserva_id"         uuid,
  "estancia_id"        uuid,
  "estado"             text                     NOT NULL DEFAULT 'pendiente'::text,
  "monto"              numeric(14,2)            NOT NULL,
  "moneda"             text                     NOT NULL DEFAULT 'COP'::text,
  "referencia_externa" text                     NOT NULL,
  "created_at"         timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "pago_estado_check" CHECK ((estado = ANY (ARRAY['pendiente'::text, 'aprobado'::text, 'rechazado'::text]))),
  CONSTRAINT "pago_moneda_check" CHECK ((moneda ~ '^[A-Z]{3}$'::text)),
  CONSTRAINT "pago_monto_check" CHECK ((monto > (0)::numeric)),
  CONSTRAINT "pago_pkey" PRIMARY KEY (id),
  CONSTRAINT "pago_referencia_externa_check" CHECK ((btrim(referencia_externa) <> ''::text)),
  CONSTRAINT "pago_referencia_externa_key" UNIQUE (referencia_externa),
  CONSTRAINT "pago_una_operacion" CHECK ((num_nonnulls(reserva_id, estancia_id) = 1))
);

ALTER TABLE "public"."pago"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."pago" FROM "anon";

CREATE TABLE "public"."parqueadero_tipo_vehiculo" (
  "id"                uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parqueadero_id"    uuid                     NOT NULL,
  "tipo_vehiculo_id"  uuid                     NOT NULL,
  "capacidad"         integer                  NOT NULL,
  "activo"            boolean                  NOT NULL DEFAULT true,
  "tarifa_hora"       numeric(14,2),
  "created_at"        timestamp with time zone NOT NULL DEFAULT now(),
  "cupos_reservables" integer                  NOT NULL DEFAULT 0,
  CONSTRAINT "cupos_reservables_dentro_de_capacidad" CHECK ((cupos_reservables <= capacidad)),
  CONSTRAINT "parqueadero_tipo_unico" UNIQUE (parqueadero_id, tipo_vehiculo_id),
  CONSTRAINT "parqueadero_tipo_vehiculo_capacidad_check" CHECK ((capacidad >= 0)),
  CONSTRAINT "parqueadero_tipo_vehiculo_cupos_reservables_check" CHECK ((cupos_reservables >= 0)),
  CONSTRAINT "parqueadero_tipo_vehiculo_pkey" PRIMARY KEY (id),
  CONSTRAINT "parqueadero_tipo_vehiculo_tarifa_hora_check" CHECK ((tarifa_hora >= (0)::numeric))
);

ALTER TABLE "public"."parqueadero_tipo_vehiculo"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."parqueadero_tipo_vehiculo" FROM "anon";

CREATE TABLE "public"."parqueadero" (
  "id"         uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "nombre"     text                     NOT NULL,
  "direccion"  text                     NOT NULL,
  "latitud"    numeric(9,6)             NOT NULL,
  "longitud"   numeric(9,6)             NOT NULL,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "parqueadero_direccion_check" CHECK ((btrim(direccion) <> ''::text)),
  CONSTRAINT "parqueadero_latitud_check" CHECK (((latitud >= ('-90'::integer)::numeric) AND (latitud <= (90)::numeric))),
  CONSTRAINT "parqueadero_longitud_check" CHECK (((longitud >= ('-180'::integer)::numeric) AND (longitud <= (180)::numeric))),
  CONSTRAINT "parqueadero_nombre_check" CHECK ((btrim(nombre) <> ''::text)),
  CONSTRAINT "parqueadero_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."parqueadero"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."parqueadero" FROM "anon";

CREATE TABLE "public"."reserva" (
  "id"                       uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parqueadero_id"           uuid                     NOT NULL,
  "vehiculo_id"              uuid                     NOT NULL,
  "usuario_id"               uuid,
  "estado"                   text                     NOT NULL DEFAULT 'pendiente'::text,
  "duracion_estimada_min"    integer                  NOT NULL,
  "vence_en"                 timestamp with time zone NOT NULL,
  "created_at"               timestamp with time zone NOT NULL DEFAULT now(),
  "cancelada_en"             timestamp with time zone,
  "cancelada_por_usuario_id" uuid,
  CONSTRAINT "reserva_cancelacion_coherente" CHECK (((estado = 'cancelada'::text) = (cancelada_en IS NOT NULL))),
  CONSTRAINT "reserva_cancelador_coherente" CHECK (((cancelada_por_usuario_id IS NULL) OR (estado = 'cancelada'::text))),
  CONSTRAINT "reserva_duracion_estimada_min_check" CHECK ((duracion_estimada_min > 0)),
  CONSTRAINT "reserva_estado_check" CHECK ((estado = ANY (ARRAY['pendiente'::text, 'confirmada'::text, 'utilizada'::text, 'cancelada'::text, 'vencida'::text]))),
  CONSTRAINT "reserva_id_parqueadero_uq" UNIQUE (id, parqueadero_id),
  CONSTRAINT "reserva_id_parqueadero_vehiculo_uq" UNIQUE (id, parqueadero_id, vehiculo_id),
  CONSTRAINT "reserva_pkey" PRIMARY KEY (id),
  CONSTRAINT "reserva_vence_posterior" CHECK ((vence_en > created_at))
);

ALTER TABLE "public"."reserva"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."reserva" FROM "anon";

CREATE TABLE "public"."servicio_solicitado" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parqueadero_id" uuid                     NOT NULL,
  "servicio_id"    uuid                     NOT NULL,
  "reserva_id"     uuid,
  "estancia_id"    uuid,
  "precio_pactado" numeric(14,2)            NOT NULL,
  "estado"         text                     NOT NULL DEFAULT 'en_espera'::text,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "servicio_solicitado_estado_check" CHECK ((estado = ANY (ARRAY['en_espera'::text, 'en_proceso'::text, 'completado'::text]))),
  CONSTRAINT "servicio_solicitado_pkey" PRIMARY KEY (id),
  CONSTRAINT "servicio_solicitado_precio_pactado_check" CHECK ((precio_pactado >= (0)::numeric)),
  CONSTRAINT "servicio_solicitado_una_operacion" CHECK ((num_nonnulls(reserva_id, estancia_id) = 1))
);

ALTER TABLE "public"."servicio_solicitado"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."servicio_solicitado" FROM "anon";

CREATE TABLE "public"."servicio" (
  "id"                    uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "parqueadero_id"        uuid                     NOT NULL,
  "nombre"                text                     NOT NULL,
  "precio"                numeric(14,2)            NOT NULL,
  "duracion_estimada_min" integer,
  "activo"                boolean                  NOT NULL DEFAULT true,
  "created_at"            timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "servicio_duracion_estimada_min_check" CHECK ((duracion_estimada_min > 0)),
  CONSTRAINT "servicio_id_parqueadero_uq" UNIQUE (id, parqueadero_id),
  CONSTRAINT "servicio_nombre_check" CHECK ((btrim(nombre) <> ''::text)),
  CONSTRAINT "servicio_pkey" PRIMARY KEY (id),
  CONSTRAINT "servicio_precio_check" CHECK ((precio >= (0)::numeric))
);

ALTER TABLE "public"."servicio"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."servicio" FROM "anon";

CREATE TABLE "public"."tipo_vehiculo" (
  "id"             uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "codigo"         text                     NOT NULL,
  "nombre"         text                     NOT NULL,
  "requiere_placa" boolean                  NOT NULL,
  "activo"         boolean                  NOT NULL DEFAULT true,
  "created_at"     timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "tipo_vehiculo_codigo_check" CHECK ((codigo ~ '^[a-z0-9_]+$'::text)),
  CONSTRAINT "tipo_vehiculo_codigo_key" UNIQUE (codigo),
  CONSTRAINT "tipo_vehiculo_nombre_check" CHECK ((btrim(nombre) <> ''::text)),
  CONSTRAINT "tipo_vehiculo_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."tipo_vehiculo"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."tipo_vehiculo" FROM "anon";

CREATE TABLE "public"."usuario_vehiculo" (
  "usuario_id"  uuid                     NOT NULL,
  "vehiculo_id" uuid                     NOT NULL,
  "activo"      boolean                  NOT NULL DEFAULT true,
  "created_at"  timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "usuario_vehiculo_pkey" PRIMARY KEY (usuario_id, vehiculo_id)
);

ALTER TABLE "public"."usuario_vehiculo"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."usuario_vehiculo" FROM "anon";

CREATE TABLE "public"."usuario" (
  "id"              uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "firebase_uid"    text,
  "nombre_completo" text,
  "correo"          text,
  "created_at"      timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "usuario_correo_normalizado" CHECK (((correo IS NULL) OR (correo = lower(btrim(correo))))),
  CONSTRAINT "usuario_firebase_uid_key" UNIQUE (firebase_uid),
  CONSTRAINT "usuario_pkey" PRIMARY KEY (id)
);

ALTER TABLE "public"."usuario"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."usuario" FROM "anon";

CREATE TABLE "public"."vehiculo" (
  "id"               uuid                     NOT NULL DEFAULT gen_random_uuid(),
  "tipo_vehiculo_id" uuid                     NOT NULL,
  "placa"            text,
  "created_at"       timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "vehiculo_pkey" PRIMARY KEY (id),
  CONSTRAINT "vehiculo_placa_check" CHECK ((placa ~ '^[A-Z0-9]+$'::text)),
  CONSTRAINT "vehiculo_placa_key" UNIQUE (placa)
);

ALTER TABLE "public"."vehiculo"
  ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE "public"."vehiculo" FROM "anon";

CREATE OR REPLACE FUNCTION public.calificacion_validar_estancia_finalizada()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_estado text;
begin
  select estado into v_estado from public.estancia where id = new.estancia_id;
  if v_estado is distinct from 'finalizada' then
    raise exception 'Solo se puede calificar una estancia finalizada' using errcode = '23514';
  end if;
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."calificacion_validar_estancia_finalizada"() FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.es_cuenta_con_registro()
  RETURNS boolean
  LANGUAGE sql
  STABLE
  SET search_path TO ''
  AS $function$
  select coalesce((select auth.jwt() -> 'firebase' ->> 'sign_in_provider'), '') <> 'anonymous'
$function$;

REVOKE ALL ON FUNCTION "public"."es_cuenta_con_registro"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.estancia_marcar_reserva_utilizada()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
  if new.reserva_id is not null then
    update public.reserva
    set estado = 'utilizada'
    where id = new.reserva_id
      and estado in ('pendiente', 'confirmada');
  end if;
  return null;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."estancia_marcar_reserva_utilizada"() FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.estancia_validar_reserva()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_usuario_reserva uuid;
begin
  if new.reserva_id is null then
    return new;
  end if;

  select usuario_id into v_usuario_reserva
  from public.reserva
  where id = new.reserva_id;

  if v_usuario_reserva is not null then
    if new.usuario_id is null then
      new.usuario_id := v_usuario_reserva;
    elsif new.usuario_id <> v_usuario_reserva then
      raise exception 'La estancia debe pertenecer al usuario de la reserva' using errcode = '23514';
    end if;
  end if;
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."estancia_validar_reserva"() FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.operacion_validar_tipo_admitido()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
begin
  if not exists (
    select 1
    from public.vehiculo v
    join public.parqueadero_tipo_vehiculo ptv on ptv.tipo_vehiculo_id = v.tipo_vehiculo_id
    where v.id = new.vehiculo_id
      and ptv.parqueadero_id = new.parqueadero_id
      and ptv.activo
  ) then
    raise exception 'El parqueadero no admite el tipo de este vehiculo' using errcode = '23514';
  end if;
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."operacion_validar_tipo_admitido"() FROM PUBLIC, "anon", "authenticated";

CREATE OR REPLACE FUNCTION public.parqueaderos_del_personal()
  RETURNS SETOF uuid
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select a.parqueadero_id
  from public.asignacion_parqueadero a
  where a.usuario_id = (select public.usuario_actual_id())
    and a.estado = 'activo'
$function$;

REVOKE ALL ON FUNCTION "public"."parqueaderos_del_personal"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.usuario_actual_id()
  RETURNS uuid
  LANGUAGE sql
  STABLE
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
  select u.id
  from public.usuario u
  where u.firebase_uid = (select auth.jwt() ->> 'sub')
$function$;

REVOKE ALL ON FUNCTION "public"."usuario_actual_id"() FROM PUBLIC, "anon";

CREATE OR REPLACE FUNCTION public.vehiculo_validar_tipo_placa()
  RETURNS TRIGGER
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO ''
  AS $function$
declare
  v_requiere_placa boolean;
begin
  select requiere_placa into v_requiere_placa
  from public.tipo_vehiculo
  where id = new.tipo_vehiculo_id;

  if v_requiere_placa and new.placa is null then
    raise exception 'El tipo de vehiculo requiere placa' using errcode = '23514';
  end if;
  return new;
end;
$function$;

REVOKE ALL ON FUNCTION "public"."vehiculo_validar_tipo_placa"() FROM PUBLIC, "anon", "authenticated";

ALTER TABLE "public"."codigo_verificacion"
  ADD CONSTRAINT "codigo_estancia_coherente" FOREIGN KEY (estancia_id, parqueadero_id) REFERENCES public.estancia(id, parqueadero_id);

ALTER TABLE "public"."calificacion"
  ADD CONSTRAINT "calificacion_estancia_id_fkey" FOREIGN KEY (estancia_id) REFERENCES public.estancia(id);

ALTER TABLE "public"."intento_validacion"
  ADD CONSTRAINT "intento_codigo_coherente" FOREIGN KEY (codigo_id, parqueadero_id) REFERENCES public.codigo_verificacion(id, parqueadero_id);

ALTER TABLE "public"."intento_validacion"
  ADD CONSTRAINT "intento_estancia_coherente" FOREIGN KEY (estancia_id, parqueadero_id) REFERENCES public.estancia(id, parqueadero_id);

ALTER TABLE "public"."pago"
  ADD CONSTRAINT "pago_estancia_coherente" FOREIGN KEY (estancia_id, parqueadero_id) REFERENCES public.estancia(id, parqueadero_id);

ALTER TABLE "public"."asignacion_parqueadero"
  ADD CONSTRAINT "asignacion_parqueadero_parqueadero_id_fkey" FOREIGN KEY (parqueadero_id) REFERENCES public.parqueadero(id);

ALTER TABLE "public"."codigo_verificacion"
  ADD CONSTRAINT "codigo_verificacion_parqueadero_id_fkey" FOREIGN KEY (parqueadero_id) REFERENCES public.parqueadero(id);

ALTER TABLE "public"."estancia"
  ADD CONSTRAINT "estancia_parqueadero_id_fkey" FOREIGN KEY (parqueadero_id) REFERENCES public.parqueadero(id);

ALTER TABLE "public"."intento_validacion"
  ADD CONSTRAINT "intento_validacion_parqueadero_id_fkey" FOREIGN KEY (parqueadero_id) REFERENCES public.parqueadero(id);

ALTER TABLE "public"."pago"
  ADD CONSTRAINT "pago_parqueadero_id_fkey" FOREIGN KEY (parqueadero_id) REFERENCES public.parqueadero(id);

ALTER TABLE "public"."parqueadero_tipo_vehiculo"
  ADD CONSTRAINT "parqueadero_tipo_vehiculo_parqueadero_id_fkey" FOREIGN KEY (parqueadero_id) REFERENCES public.parqueadero(id);

ALTER TABLE "public"."codigo_verificacion"
  ADD CONSTRAINT "codigo_reserva_coherente" FOREIGN KEY (reserva_id, parqueadero_id) REFERENCES public.reserva(id, parqueadero_id);

ALTER TABLE "public"."intento_validacion"
  ADD CONSTRAINT "intento_reserva_coherente" FOREIGN KEY (reserva_id, parqueadero_id) REFERENCES public.reserva(id, parqueadero_id);

ALTER TABLE "public"."pago"
  ADD CONSTRAINT "pago_reserva_coherente" FOREIGN KEY (reserva_id, parqueadero_id) REFERENCES public.reserva(id, parqueadero_id);

ALTER TABLE "public"."estancia"
  ADD CONSTRAINT "estancia_reserva_coherente" FOREIGN KEY (reserva_id, parqueadero_id, vehiculo_id) REFERENCES public.reserva(id, parqueadero_id, vehiculo_id);

ALTER TABLE "public"."reserva"
  ADD CONSTRAINT "reserva_parqueadero_id_fkey" FOREIGN KEY (parqueadero_id) REFERENCES public.parqueadero(id);

ALTER TABLE "public"."servicio"
  ADD CONSTRAINT "servicio_parqueadero_id_fkey" FOREIGN KEY (parqueadero_id) REFERENCES public.parqueadero(id);

ALTER TABLE "public"."servicio_solicitado"
  ADD CONSTRAINT "servicio_solicitado_estancia_coherente" FOREIGN KEY (estancia_id, parqueadero_id) REFERENCES public.estancia(id, parqueadero_id);

ALTER TABLE "public"."servicio_solicitado"
  ADD CONSTRAINT "servicio_solicitado_parqueadero_id_fkey" FOREIGN KEY (parqueadero_id) REFERENCES public.parqueadero(id);

ALTER TABLE "public"."servicio_solicitado"
  ADD CONSTRAINT "servicio_solicitado_reserva_coherente" FOREIGN KEY (reserva_id, parqueadero_id) REFERENCES public.reserva(id, parqueadero_id);

ALTER TABLE "public"."servicio_solicitado"
  ADD CONSTRAINT "servicio_solicitado_servicio_coherente" FOREIGN KEY (servicio_id, parqueadero_id) REFERENCES public.servicio(id, parqueadero_id);

ALTER TABLE "public"."parqueadero_tipo_vehiculo"
  ADD CONSTRAINT "parqueadero_tipo_vehiculo_tipo_vehiculo_id_fkey" FOREIGN KEY (tipo_vehiculo_id) REFERENCES public.tipo_vehiculo(id);

ALTER TABLE "public"."asignacion_parqueadero"
  ADD CONSTRAINT "asignacion_parqueadero_usuario_id_fkey" FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);

ALTER TABLE "public"."estancia"
  ADD CONSTRAINT "estancia_registrada_por_usuario_id_fkey" FOREIGN KEY (registrada_por_usuario_id) REFERENCES public.usuario(id);

ALTER TABLE "public"."estancia"
  ADD CONSTRAINT "estancia_usuario_id_fkey" FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);

ALTER TABLE "public"."intento_validacion"
  ADD CONSTRAINT "intento_validacion_validador_usuario_id_fkey" FOREIGN KEY (validador_usuario_id) REFERENCES public.usuario(id);

ALTER TABLE "public"."reserva"
  ADD CONSTRAINT "reserva_cancelada_por_usuario_id_fkey" FOREIGN KEY (cancelada_por_usuario_id) REFERENCES public.usuario(id);

ALTER TABLE "public"."reserva"
  ADD CONSTRAINT "reserva_usuario_id_fkey" FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);

ALTER TABLE "public"."usuario_vehiculo"
  ADD CONSTRAINT "usuario_vehiculo_usuario_id_fkey" FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);

ALTER TABLE "public"."estancia"
  ADD CONSTRAINT "estancia_vehiculo_id_fkey" FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo(id);

ALTER TABLE "public"."reserva"
  ADD CONSTRAINT "reserva_vehiculo_id_fkey" FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo(id);

ALTER TABLE "public"."usuario_vehiculo"
  ADD CONSTRAINT "usuario_vehiculo_vehiculo_id_fkey" FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo(id);

ALTER TABLE "public"."vehiculo"
  ADD CONSTRAINT "vehiculo_tipo_vehiculo_id_fkey" FOREIGN KEY (tipo_vehiculo_id) REFERENCES public.tipo_vehiculo(id);

CREATE INDEX asignacion_parqueadero_parqueadero_idx ON public.asignacion_parqueadero USING btree (parqueadero_id);

CREATE UNIQUE INDEX codigo_ingreso_vigente_uq ON public.codigo_verificacion USING btree (reserva_id)
  WHERE ((proposito = 'ingreso'::text) AND (estado = ANY (ARRAY['generado'::text, 'activo'::text])));

CREATE INDEX codigo_parqueadero_idx ON public.codigo_verificacion USING btree (parqueadero_id);

CREATE UNIQUE INDEX codigo_retiro_vigente_uq ON public.codigo_verificacion USING btree (estancia_id)
  WHERE ((proposito = 'retiro'::text) AND (estado = ANY (ARRAY['generado'::text, 'activo'::text])));

CREATE UNIQUE INDEX estancia_en_curso_por_vehiculo_uq ON public.estancia USING btree (vehiculo_id, parqueadero_id)
  WHERE (estado = 'en_curso'::text);

CREATE UNIQUE INDEX estancia_ficha_en_curso_uq ON public.estancia USING btree (parqueadero_id, numero_ficha)
  WHERE ((estado = 'en_curso'::text) AND (numero_ficha IS NOT NULL));

CREATE INDEX estancia_parqueadero_idx ON public.estancia USING btree (parqueadero_id);

CREATE INDEX estancia_usuario_idx ON public.estancia USING btree (usuario_id)
  WHERE (usuario_id IS NOT NULL);

CREATE INDEX estancia_vehiculo_idx ON public.estancia USING btree (vehiculo_id);

CREATE INDEX intento_validacion_estancia_idx ON public.intento_validacion USING btree (estancia_id, created_at)
  WHERE (estancia_id IS NOT NULL);

CREATE INDEX intento_validacion_parqueadero_idx ON public.intento_validacion USING btree (parqueadero_id);

CREATE INDEX intento_validacion_reserva_idx ON public.intento_validacion USING btree (reserva_id, created_at)
  WHERE (reserva_id IS NOT NULL);

CREATE INDEX pago_estancia_idx ON public.pago USING btree (estancia_id)
  WHERE (estancia_id IS NOT NULL);

CREATE INDEX pago_parqueadero_idx ON public.pago USING btree (parqueadero_id);

CREATE INDEX pago_reserva_idx ON public.pago USING btree (reserva_id)
  WHERE (reserva_id IS NOT NULL);

CREATE INDEX parqueadero_tipo_vehiculo_tipo_idx ON public.parqueadero_tipo_vehiculo USING btree (tipo_vehiculo_id);

CREATE UNIQUE INDEX reserva_activa_por_vehiculo_uq ON public.reserva USING btree (vehiculo_id, parqueadero_id)
  WHERE (estado = ANY (ARRAY['pendiente'::text, 'confirmada'::text]));

CREATE INDEX reserva_parqueadero_idx ON public.reserva USING btree (parqueadero_id);

CREATE INDEX reserva_usuario_idx ON public.reserva USING btree (usuario_id)
  WHERE (usuario_id IS NOT NULL);

CREATE INDEX reserva_vehiculo_idx ON public.reserva USING btree (vehiculo_id);

CREATE INDEX servicio_parqueadero_idx ON public.servicio USING btree (parqueadero_id);

CREATE INDEX servicio_solicitado_estancia_idx ON public.servicio_solicitado USING btree (estancia_id)
  WHERE (estancia_id IS NOT NULL);

CREATE INDEX servicio_solicitado_parqueadero_idx ON public.servicio_solicitado USING btree (parqueadero_id);

CREATE INDEX servicio_solicitado_reserva_idx ON public.servicio_solicitado USING btree (reserva_id)
  WHERE (reserva_id IS NOT NULL);

CREATE UNIQUE INDEX usuario_correo_uq ON public.usuario USING btree (correo)
  WHERE (correo IS NOT NULL);

CREATE INDEX usuario_vehiculo_vehiculo_idx ON public.usuario_vehiculo USING btree (vehiculo_id);

CREATE INDEX vehiculo_tipo_idx ON public.vehiculo USING btree (tipo_vehiculo_id);

CREATE TRIGGER calificacion_validar_estancia_finalizada
  BEFORE INSERT ON public.calificacion
  FOR EACH ROW
  EXECUTE FUNCTION public.calificacion_validar_estancia_finalizada();

CREATE TRIGGER estancia_marcar_reserva_utilizada
  AFTER INSERT ON public.estancia
  FOR EACH ROW
  EXECUTE FUNCTION public.estancia_marcar_reserva_utilizada();

CREATE TRIGGER estancia_validar_reserva
  BEFORE INSERT ON public.estancia
  FOR EACH ROW
  EXECUTE FUNCTION public.estancia_validar_reserva();

CREATE TRIGGER estancia_validar_tipo_admitido
  BEFORE INSERT ON public.estancia
  FOR EACH ROW
  EXECUTE FUNCTION public.operacion_validar_tipo_admitido();

CREATE TRIGGER reserva_validar_tipo_admitido
  BEFORE INSERT ON public.reserva
  FOR EACH ROW
  EXECUTE FUNCTION public.operacion_validar_tipo_admitido();

CREATE TRIGGER vehiculo_validar_tipo_placa
  BEFORE INSERT OR UPDATE OF tipo_vehiculo_id, placa ON public.vehiculo
  FOR EACH ROW
  EXECUTE FUNCTION public.vehiculo_validar_tipo_placa();

CREATE POLICY "asignacion_select_propia" ON "public"."asignacion_parqueadero"
  FOR SELECT
  TO "authenticated"
  USING ((usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id)));

CREATE POLICY "estancia_select" ON "public"."estancia"
  FOR SELECT
  TO "authenticated"
  USING
    (((usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id)) OR (parqueadero_id IN ( SELECT public.parqueaderos_del_personal() AS parqueaderos_del_personal))));

CREATE POLICY "pago_select" ON "public"."pago"
  FOR SELECT
  TO "authenticated"
  USING (((parqueadero_id IN ( SELECT public.parqueaderos_del_personal() AS parqueaderos_del_personal)) OR (EXISTS ( SELECT 1
   FROM public.reserva r
  WHERE ((r.id = pago.reserva_id) AND (r.usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id))))) OR (EXISTS ( SELECT 1
   FROM public.estancia e
  WHERE ((e.id = pago.estancia_id) AND (e.usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id)))))));

CREATE POLICY "parqueadero_lectura" ON "public"."parqueadero"
  FOR SELECT
  TO "authenticated"
  USING (true);

CREATE POLICY "parqueadero_tipo_vehiculo_lectura" ON "public"."parqueadero_tipo_vehiculo"
  FOR SELECT
  TO "authenticated"
  USING (activo);

CREATE POLICY "reserva_select" ON "public"."reserva"
  FOR SELECT
  TO "authenticated"
  USING
    (((usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id)) OR (parqueadero_id IN ( SELECT public.parqueaderos_del_personal() AS parqueaderos_del_personal))));

CREATE POLICY "servicio_lectura" ON "public"."servicio"
  FOR SELECT
  TO "authenticated"
  USING (activo);

CREATE POLICY "servicio_solicitado_select" ON "public"."servicio_solicitado"
  FOR SELECT
  TO "authenticated"
  USING (((parqueadero_id IN ( SELECT public.parqueaderos_del_personal() AS parqueaderos_del_personal)) OR (EXISTS ( SELECT 1
   FROM public.reserva r
  WHERE ((r.id = servicio_solicitado.reserva_id) AND (r.usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id))))) OR (EXISTS ( SELECT 1
   FROM public.estancia e
  WHERE ((e.id = servicio_solicitado.estancia_id) AND (e.usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id)))))));

CREATE POLICY "tipo_vehiculo_lectura" ON "public"."tipo_vehiculo"
  FOR SELECT
  TO "authenticated"
  USING (activo);

CREATE POLICY "usuario_insert_propio" ON "public"."usuario"
  FOR INSERT
  TO "authenticated"
  WITH CHECK (((firebase_uid = ( SELECT (auth.jwt() ->> 'sub'::text))) AND ( SELECT public.es_cuenta_con_registro() AS es_cuenta_con_registro)));

CREATE POLICY "usuario_select_propio" ON "public"."usuario"
  FOR SELECT
  TO "authenticated"
  USING ((firebase_uid = ( SELECT (auth.jwt() ->> 'sub'::text))));

CREATE POLICY "usuario_update_propio" ON "public"."usuario"
  FOR UPDATE
  TO "authenticated"
  USING ((firebase_uid = ( SELECT (auth.jwt() ->> 'sub'::text))))
  WITH CHECK ((firebase_uid = ( SELECT (auth.jwt() ->> 'sub'::text))));

CREATE POLICY "usuario_vehiculo_select_propio" ON "public"."usuario_vehiculo"
  FOR SELECT
  TO "authenticated"
  USING ((usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id)));

CREATE POLICY "usuario_vehiculo_update_propio" ON "public"."usuario_vehiculo"
  FOR UPDATE
  TO "authenticated"
  USING ((usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id)))
  WITH CHECK ((usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id)));

CREATE POLICY "vehiculo_select" ON "public"."vehiculo"
  FOR SELECT
  TO "authenticated"
  USING (((EXISTS ( SELECT 1
   FROM public.usuario_vehiculo uv
  WHERE ((uv.vehiculo_id = vehiculo.id) AND (uv.usuario_id = ( SELECT public.usuario_actual_id() AS usuario_actual_id)) AND uv.activo))) OR (EXISTS ( SELECT 1
   FROM public.estancia e
  WHERE ((e.vehiculo_id = vehiculo.id) AND (e.parqueadero_id IN ( SELECT public.parqueaderos_del_personal() AS parqueaderos_del_personal))))) OR (EXISTS ( SELECT 1
   FROM public.reserva r
  WHERE ((r.vehiculo_id = vehiculo.id) AND (r.parqueadero_id IN ( SELECT public.parqueaderos_del_personal() AS parqueaderos_del_personal)))))));

COMMENT ON COLUMN "public"."codigo_verificacion"."verificador_hash" IS 'Material de verificacion protegido (hash). No es unico: un PIN corto puede repetirse entre operaciones; la validacion siempre se acota a una operacion concreta.';

COMMENT ON COLUMN "public"."estancia"."numero_ficha" IS 'Ficha fisica (por ejemplo de bicicletas). Pertenece a la estancia, no al vehiculo. No es un secreto ni sustituye la credencial de retiro.';

COMMENT ON COLUMN "public"."estancia"."valor_parqueo_generado" IS 'Se conserva al cerrar la estancia porque la tarifa puede cambiar. No incluye servicios.';

COMMENT ON COLUMN "public"."pago"."moneda" IS 'PROVISIONAL: COP por defecto (inferencia), pendiente de confirmar (D-ER2-24).';

COMMENT ON COLUMN "public"."pago"."referencia_externa" IS 'Identificador externo del cobro en Stripe. Si la integracion requiere un segundo identificador se agregara despues (D-ER2-05).';

COMMENT ON COLUMN "public"."parqueadero_tipo_vehiculo"."cupos_reservables" IS 'Cupos de este tipo que la app puede reservar al mismo tiempo. Lo fija el administrador; nunca supera la capacidad. 0 = sin reservas. La verificacion atomica al reservar la hace el backend (B-1).';

COMMENT ON COLUMN "public"."parqueadero_tipo_vehiculo"."tarifa_hora" IS 'PROVISIONAL: unica tarifa respaldada (por hora, Figma). Modelo de tarifas pendiente (D-31). Puede reemplazarse por una entidad TARIFA sin afectar el resto.';

COMMENT ON COLUMN "public"."reserva"."cancelada_por_usuario_id" IS 'Nulo con estado cancelada = cancelacion por quien posee la credencial sin cuenta. La expiracion automatica usa estado vencida.';

COMMENT ON COLUMN "public"."reserva"."vence_en" IS 'Instante limite de llegada, calculado al crear la reserva. La regla de tolerancia queda pendiente (D-18).';

COMMENT ON COLUMN "public"."usuario"."correo" IS 'Duplicado de Firebase, pendiente de decision (D-ER2-16). Normalizado en minusculas.';

COMMENT ON COLUMN "public"."usuario"."firebase_uid" IS 'Identidad externa en Firebase Authentication. Nulo hasta que una persona invitada active su cuenta.';

COMMENT ON FUNCTION "public"."calificacion_validar_estancia_finalizada"() IS 'R-24: solo se califica una estancia finalizada.';

COMMENT ON FUNCTION "public"."estancia_marcar_reserva_utilizada"() IS 'La reserva activa pasa a utilizada al originar su estancia.';

COMMENT ON FUNCTION "public"."estancia_validar_reserva"() IS 'R-22 parcial: hereda o valida el usuario de la reserva cuando esta tiene usuario.';

COMMENT ON FUNCTION "public"."operacion_validar_tipo_admitido"() IS 'R-19: el parqueadero admite y tiene activo el tipo del vehiculo. No evalua capacidad ni disponibilidad.';

COMMENT ON FUNCTION "public"."vehiculo_validar_tipo_placa"() IS 'R-11: el tipo exige placa => placa no nula.';

COMMENT ON TABLE "public"."asignacion_parqueadero" IS 'Relacion N:M entre personal y parqueadero (DC-02). Rol y estado pertenecen a la relacion. El rol personalizado y los permisos por modulo quedan fuera hasta definirlos.';

COMMENT ON TABLE "public"."calificacion" IS 'Calificacion de 1 a 5 estrellas con comentario opcional, a lo sumo una por estancia finalizada. Sin usuario propio: el titular, si existe, es el de la estancia. El promedio por parqueadero es derivado. Quien puede calificar sin cuenta: pendiente (D-ER3-14).';

COMMENT ON TABLE "public"."codigo_verificacion" IS 'Credencial asociada a una reserva (ingreso) o a una estancia (retiro). Permite identificar operaciones sin cuenta. Nunca se guarda el valor en claro ni la imagen QR. Forma de la credencial, expiracion y bloqueo pendientes (D-ER2-06).';

COMMENT ON TABLE "public"."estancia" IS 'Uso real del parqueadero. reserva_id y usuario_id opcionales (casos A a D). Si hay reserva, parqueadero y vehiculo deben coincidir (clave foranea compuesta). Coherencia de usuario_id con la reserva: pendiente de aplicar (R-22).';

COMMENT ON TABLE "public"."intento_validacion" IS 'Cada intento de validar una credencial sobre una reserva (ingreso) o una estancia (retiro). codigo_id nulo = el valor ingresado no correspondio a ningun codigo. validador_usuario_id nulo = intento hecho por quien posee la credencial sin cuenta. Limite de intentos y bloqueo: pendientes (D-ER3-03).';

COMMENT ON TABLE "public"."pago" IS 'Registro de un cobro asociado a una reserva O a una estancia, sin usuario obligatorio. 0..N por operacion (reintentos). No almacena numero de tarjeta, CVV ni credenciales.';

COMMENT ON TABLE "public"."parqueadero" IS 'Establecimiento independiente. Unidad de aislamiento de datos (DC-01). Horario, estado operativo y caracteristicas quedan pendientes de definicion.';

COMMENT ON TABLE "public"."parqueadero_tipo_vehiculo" IS 'Admision y capacidad de un tipo de vehiculo en un parqueadero (DC-05). La disponibilidad NO se almacena aqui: es derivada; formula pendiente (D-ER2-01).';

COMMENT ON TABLE "public"."reserva" IS 'Reserva INMEDIATA (MVP). usuario_id nulo = reserva anonima, valida. Una reserva origina como maximo una estancia. Estados provisionales (D-ER2-11).';

COMMENT ON TABLE "public"."servicio" IS 'Catalogo de servicios de un parqueadero. precio es el precio vigente; el historico vive en servicio_solicitado.precio_pactado. Un servicio con solicitudes se desactiva, no se elimina.';

COMMENT ON TABLE "public"."servicio_solicitado" IS 'Servicio pedido sobre una reserva O una estancia, con el precio pactado al solicitar. Estados provisionales. El cobro consolidado con el parqueo esta pendiente.';

COMMENT ON TABLE "public"."tipo_vehiculo" IS 'Catalogo administrable de tipos de vehiculo. Contenido inicial minimo; tipos adicionales (por ejemplo camioneta) pendientes de decision (D-36).';

COMMENT ON TABLE "public"."usuario" IS 'Perfil de negocio de una persona AUTENTICADA (identidad en Firebase). Nunca representa a una persona sin cuenta.';

COMMENT ON TABLE "public"."usuario_vehiculo" IS 'Relacion N:M: un usuario registrado declara usar un vehiculo (DC-03). No implica propiedad. NO debe usarse para derivar historial.';

COMMENT ON TABLE "public"."vehiculo" IS 'Identidad fisica del vehiculo. Sin propietario obligatorio. Placa nula valida (bicicletas); unica cuando existe y debe guardarse normalizada (mayusculas, sin espacios ni guiones).';

REVOKE ALL ON FUNCTION "public"."calificacion_validar_estancia_finalizada"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."calificacion_validar_estancia_finalizada"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."calificacion_validar_estancia_finalizada"() TO "service_role";

GRANT EXECUTE ON FUNCTION "public"."es_cuenta_con_registro"() TO "authenticated";

REVOKE ALL ON FUNCTION "public"."es_cuenta_con_registro"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."es_cuenta_con_registro"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."es_cuenta_con_registro"() TO "service_role";

REVOKE ALL ON FUNCTION "public"."estancia_marcar_reserva_utilizada"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."estancia_marcar_reserva_utilizada"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."estancia_marcar_reserva_utilizada"() TO "service_role";

REVOKE ALL ON FUNCTION "public"."estancia_validar_reserva"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."estancia_validar_reserva"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."estancia_validar_reserva"() TO "service_role";

REVOKE ALL ON FUNCTION "public"."operacion_validar_tipo_admitido"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."operacion_validar_tipo_admitido"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."operacion_validar_tipo_admitido"() TO "service_role";

GRANT EXECUTE ON FUNCTION "public"."parqueaderos_del_personal"() TO "authenticated";

REVOKE ALL ON FUNCTION "public"."parqueaderos_del_personal"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."parqueaderos_del_personal"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."parqueaderos_del_personal"() TO "service_role";

GRANT EXECUTE ON FUNCTION "public"."usuario_actual_id"() TO "authenticated";

REVOKE ALL ON FUNCTION "public"."usuario_actual_id"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."usuario_actual_id"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."usuario_actual_id"() TO "service_role";

REVOKE ALL ON FUNCTION "public"."vehiculo_validar_tipo_placa"() FROM "postgres";

GRANT EXECUTE ON FUNCTION "public"."vehiculo_validar_tipo_placa"() TO "postgres";

GRANT EXECUTE ON FUNCTION "public"."vehiculo_validar_tipo_placa"() TO "service_role";

REVOKE ALL ON TABLE "public"."asignacion_parqueadero" FROM "authenticated";

GRANT SELECT ON TABLE "public"."asignacion_parqueadero" TO "authenticated";

REVOKE ALL ON TABLE "public"."asignacion_parqueadero" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."asignacion_parqueadero" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."asignacion_parqueadero" TO "service_role";

REVOKE ALL ON TABLE "public"."calificacion" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."calificacion" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."calificacion" TO "service_role";

REVOKE ALL ON TABLE "public"."codigo_verificacion" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."codigo_verificacion" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."codigo_verificacion" TO "service_role";

REVOKE ALL ON TABLE "public"."estancia" FROM "authenticated";

GRANT SELECT ON TABLE "public"."estancia" TO "authenticated";

REVOKE ALL ON TABLE "public"."estancia" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."estancia" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."estancia" TO "service_role";

REVOKE ALL ON TABLE "public"."intento_validacion" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."intento_validacion" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."intento_validacion" TO "service_role";

REVOKE ALL ON TABLE "public"."pago" FROM "authenticated";

GRANT SELECT ON TABLE "public"."pago" TO "authenticated";

REVOKE ALL ON TABLE "public"."pago" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."pago" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."pago" TO "service_role";

REVOKE ALL ON TABLE "public"."parqueadero" FROM "authenticated";

GRANT SELECT ON TABLE "public"."parqueadero" TO "authenticated";

REVOKE ALL ON TABLE "public"."parqueadero" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parqueadero" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parqueadero" TO "service_role";

REVOKE ALL ON TABLE "public"."parqueadero_tipo_vehiculo" FROM "authenticated";

GRANT SELECT ON TABLE "public"."parqueadero_tipo_vehiculo" TO "authenticated";

REVOKE ALL ON TABLE "public"."parqueadero_tipo_vehiculo" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parqueadero_tipo_vehiculo" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."parqueadero_tipo_vehiculo" TO "service_role";

REVOKE ALL ON TABLE "public"."reserva" FROM "authenticated";

GRANT SELECT ON TABLE "public"."reserva" TO "authenticated";

REVOKE ALL ON TABLE "public"."reserva" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."reserva" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."reserva" TO "service_role";

REVOKE ALL ON TABLE "public"."servicio" FROM "authenticated";

GRANT SELECT ON TABLE "public"."servicio" TO "authenticated";

REVOKE ALL ON TABLE "public"."servicio" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."servicio" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."servicio" TO "service_role";

REVOKE ALL ON TABLE "public"."servicio_solicitado" FROM "authenticated";

GRANT SELECT ON TABLE "public"."servicio_solicitado" TO "authenticated";

REVOKE ALL ON TABLE "public"."servicio_solicitado" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."servicio_solicitado" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."servicio_solicitado" TO "service_role";

REVOKE ALL ON TABLE "public"."tipo_vehiculo" FROM "authenticated";

GRANT SELECT ON TABLE "public"."tipo_vehiculo" TO "authenticated";

REVOKE ALL ON TABLE "public"."tipo_vehiculo" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tipo_vehiculo" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."tipo_vehiculo" TO "service_role";

REVOKE ALL ON TABLE "public"."usuario" FROM "authenticated";

REVOKE ALL ("correo") ON TABLE "public"."usuario" FROM "authenticated";

GRANT INSERT ("correo"), UPDATE ("correo") ON TABLE "public"."usuario" TO "authenticated";

REVOKE ALL ("firebase_uid") ON TABLE "public"."usuario" FROM "authenticated";

GRANT INSERT ("firebase_uid") ON TABLE "public"."usuario" TO "authenticated";

REVOKE ALL ("nombre_completo") ON TABLE "public"."usuario" FROM "authenticated";

GRANT INSERT ("nombre_completo"), UPDATE ("nombre_completo") ON TABLE "public"."usuario" TO "authenticated";

GRANT SELECT ON TABLE "public"."usuario" TO "authenticated";

REVOKE ALL ON TABLE "public"."usuario" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."usuario" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."usuario" TO "service_role";

REVOKE ALL ON TABLE "public"."usuario_vehiculo" FROM "authenticated";

REVOKE ALL ("activo") ON TABLE "public"."usuario_vehiculo" FROM "authenticated";

GRANT UPDATE ("activo") ON TABLE "public"."usuario_vehiculo" TO "authenticated";

GRANT SELECT ON TABLE "public"."usuario_vehiculo" TO "authenticated";

REVOKE ALL ON TABLE "public"."usuario_vehiculo" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."usuario_vehiculo" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."usuario_vehiculo" TO "service_role";

REVOKE ALL ON TABLE "public"."vehiculo" FROM "authenticated";

GRANT SELECT ON TABLE "public"."vehiculo" TO "authenticated";

REVOKE ALL ON TABLE "public"."vehiculo" FROM "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."vehiculo" TO "postgres";

GRANT DELETE, INSERT, MAINTAIN, REFERENCES, SELECT, TRIGGER, TRUNCATE, UPDATE ON TABLE "public"."vehiculo" TO "service_role";

