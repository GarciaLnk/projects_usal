with Text_IO, Ada.Numerics.Discrete_Random, Ada.Real_Time;
use Ada.Real_Time;
-- with Calendar; use Calendar;

with SensorTemperatura_P, ActuadorCompuerta_P, Reactor_P, ControlInicio_P;
use SensorTemperatura_P, ActuadorCompuerta_P, Reactor_P, ControlInicio_P;

procedure Main is
   subtype NumReactor is Integer range 1 .. 3;
   reactorArray : array (NumReactor) of aliased Reactor :=
     (("Reactor 1", 1_450), ("Reactor 2", 1_450), ("Reactor 3", 1_450));

   numTareas : constant Integer := NumReactor'Last * 2 + 1;
   tiempo    : aliased Ada.Real_Time.Time;
   inicio    : ControlInicio (numTareas);

   task type Coordinadora (r : access Reactor) is
      entry avisar;
   end Coordinadora;

   task type ControlReactor (r : access Reactor);

   task body Coordinadora is
   begin
      inicio.tareaIniciada (tiempo'Access);
      loop
         select
            accept avisar;
         or
            delay 3.0;
            Text_IO.Put_Line
              ("[ALERTA] " & r.all.nombre & ": mensaje no recibido");
         end select;
      end loop;
   end Coordinadora;

   task body ControlReactor is
      sensor           : SensorTemperatura;
      actuador         : ActuadorCompuerta;
      temperaturaLeida : TipoTemperatura;
      coordina         : Coordinadora (r);
   begin
      inicio.tareaIniciada (tiempo'Access);
      sensor.iniciar (r, tiempo);
      actuador.iniciar (r);
      loop
         sensor.leer (temperaturaLeida);
         -- delay 3.0;
         coordina.avisar;
         if temperaturaLeida >= 1_500 then
            actuador.abrir;
            if temperaturaLeida > 1_750 then
               Text_IO.Put_Line
                 ("[PELIGRO] " & r.all.nombre & ": temperatura critica");
            end if;
         else
            actuador.cerrar;
         end if;
      end loop;
   end ControlReactor;

   c1 : ControlReactor (reactorArray (1)'Access);
   c2 : ControlReactor (reactorArray (2)'Access);
   c3 : ControlReactor (reactorArray (3)'Access);

   package Aleatorio is new Ada.Numerics.Discrete_Random (NumReactor);
   tiempoSiguiente : Ada.Real_Time.Time;
   periodo         : constant Time_Span := Milliseconds (1_900);
   n               : Integer;
   seed            : Aleatorio.Generator;
begin
   Aleatorio.Reset (seed);
   inicio.tareaIniciada (tiempo'Access);
   tiempoSiguiente := tiempo + periodo;
   -- delay 2.0;
   loop
      n := Aleatorio.Random (seed);
      -- n := 1;

      reactorArray (n).temperatura := reactorArray (n).temperatura + 150;
      -- Text_IO.Put_Line (Day_Duration'Image (Seconds (Clock))
      --                   & " Subir: " & reactorArray (n).nombre);
      delay until tiempoSiguiente;
      tiempoSiguiente := tiempoSiguiente + periodo;
   end loop;
end Main;
