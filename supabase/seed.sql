-- seed.sql: datos DEMO de ParkTulua para desarrollo local (supabase db reset).
-- Todos los datos son inventados. No ejecutar en el proyecto compartido sin acordarlo con el equipo.
-- Validado contra el esquema actual (migraciones 1 a 4) dentro de una transaccion revertida.

-- Parqueaderos
insert into public.parqueadero (id, nombre, direccion, latitud, longitud) values
  ('11111111-1111-4111-8111-111111111111', '[DEMO] Parqueadero Central', 'Direccion de prueba 1, Tulua', 4.0847, -76.1954),
  ('22222222-2222-4222-8222-222222222222', '[DEMO] Parqueadero Plaza',   'Direccion de prueba 2, Tulua', 4.0862, -76.1971);

-- Capacidad, cupos reservables y tarifa por tipo
insert into public.parqueadero_tipo_vehiculo (parqueadero_id, tipo_vehiculo_id, capacidad, cupos_reservables, tarifa_hora)
select v.pid, t.id, v.cap, v.res, v.tarifa
from (values
  ('11111111-1111-4111-8111-111111111111'::uuid, 'automovil',   40, 12, 4000),
  ('11111111-1111-4111-8111-111111111111'::uuid, 'motocicleta', 30,  9, 2000),
  ('11111111-1111-4111-8111-111111111111'::uuid, 'bicicleta',   20,  0,  500),
  ('22222222-2222-4222-8222-222222222222'::uuid, 'automovil',   25,  7, 3500),
  ('22222222-2222-4222-8222-222222222222'::uuid, 'motocicleta', 15,  4, 1800)
) v(pid, codigo, cap, res, tarifa)
join public.tipo_vehiculo t on t.codigo = v.codigo;

-- Usuarios. Para probar con Firebase real, reemplazar firebase_uid por el uid de la cuenta de prueba
-- (en Postman: variable firebase_uid despues del login).
insert into public.usuario (id, firebase_uid, nombre_completo, correo) values
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'demo_uid_conductor', 'Conductor Demo', 'conductor.demo@example.com'),
  ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'demo_uid_personal',  'Personal Demo',  'personal.demo@example.com');

-- Personal con asignacion activa al parqueadero central
insert into public.asignacion_parqueadero (usuario_id, parqueadero_id, rol, estado) values
  ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', '11111111-1111-4111-8111-111111111111', 'propietario', 'activo');

-- Vehiculos (la bicicleta no tiene placa)
insert into public.vehiculo (tipo_vehiculo_id, placa)
select t.id, v.placa
from (values ('automovil', 'ABC123'), ('motocicleta', 'XYZ98A'), ('motocicleta', 'QWE45B'), ('bicicleta', null)) v(codigo, placa)
join public.tipo_vehiculo t on t.codigo = v.codigo;

insert into public.usuario_vehiculo (usuario_id, vehiculo_id)
select 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid, id from public.vehiculo where placa = 'ABC123';

-- Reservas: una con cuenta (confirmada) y una anonima (pendiente)
insert into public.reserva (parqueadero_id, vehiculo_id, usuario_id, estado, duracion_estimada_min, vence_en)
select '11111111-1111-4111-8111-111111111111'::uuid, id, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid, 'confirmada', 120, now() + interval '30 minutes'
from public.vehiculo where placa = 'ABC123';

insert into public.reserva (parqueadero_id, vehiculo_id, usuario_id, estado, duracion_estimada_min, vence_en)
select '11111111-1111-4111-8111-111111111111'::uuid, id, null, 'pendiente', 60, now() + interval '20 minutes'
from public.vehiculo where placa = 'QWE45B';

-- Estancias: moto sin cuenta ni reserva, bicicleta con ficha, y una finalizada con cuenta
insert into public.estancia (parqueadero_id, vehiculo_id, registrada_por_usuario_id, hora_entrada, estado)
select '11111111-1111-4111-8111-111111111111'::uuid, id, 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid, now() - interval '85 minutes', 'en_curso'
from public.vehiculo where placa = 'XYZ98A';

insert into public.estancia (parqueadero_id, vehiculo_id, registrada_por_usuario_id, hora_entrada, estado, numero_ficha)
select '11111111-1111-4111-8111-111111111111'::uuid, id, 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid, now() - interval '40 minutes', 'en_curso', '452'
from public.vehiculo where placa is null;

insert into public.estancia (parqueadero_id, vehiculo_id, usuario_id, registrada_por_usuario_id, hora_entrada, hora_salida, estado, valor_parqueo_generado)
select '11111111-1111-4111-8111-111111111111'::uuid, id, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid, 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid,
       now() - interval '1 day', now() - interval '1 day' + interval '2 hours', 'finalizada', 8000
from public.vehiculo where placa = 'ABC123';

-- Pagos (referencias ficticias, sin relacion con Stripe)
insert into public.pago (parqueadero_id, reserva_id, estado, monto, referencia_externa)
select '11111111-1111-4111-8111-111111111111'::uuid, r.id, 'aprobado', 8000, 'pi_demo_0001'
from public.reserva r join public.vehiculo v on v.id = r.vehiculo_id where v.placa = 'ABC123';

insert into public.pago (parqueadero_id, reserva_id, estado, monto, referencia_externa)
select '11111111-1111-4111-8111-111111111111'::uuid, r.id, 'pendiente', 4000, 'pi_demo_0002'
from public.reserva r join public.vehiculo v on v.id = r.vehiculo_id where v.placa = 'QWE45B';

insert into public.pago (parqueadero_id, estancia_id, estado, monto, referencia_externa)
select '11111111-1111-4111-8111-111111111111'::uuid, e.id, 'aprobado', 8000, 'pi_demo_0003'
from public.estancia e where e.estado = 'finalizada';

-- Servicios y un servicio en proceso sobre la moto
insert into public.servicio (parqueadero_id, nombre, precio, duracion_estimada_min) values
  ('11111111-1111-4111-8111-111111111111', 'Lavado basico', 15000, 45),
  ('11111111-1111-4111-8111-111111111111', 'Polichado',     40000, 90);

insert into public.servicio_solicitado (parqueadero_id, servicio_id, estancia_id, precio_pactado, estado)
select '11111111-1111-4111-8111-111111111111'::uuid, s.id, e.id, s.precio, 'en_proceso'
from public.servicio s, public.estancia e join public.vehiculo v on v.id = e.vehiculo_id
where s.nombre = 'Lavado basico' and v.placa = 'XYZ98A';
