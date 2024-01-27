with Text_IO;
-- with Calendar; use Calendar;

package body ActuadorCompuerta_P is
   protected body ActuadorCompuerta is
      procedure iniciar (r : access Reactor) is
      begin
         reactorC := r;
      end iniciar;

      procedure abrir is
      begin
         if not abierto then
            abierto := True;
            Text_IO.Put_Line ("Abrir: " & reactorC.all.nombre);
            tiempoSiguiente := Clock;
            Set_Handler (eventoActuador, tiempoSiguiente, manejador'Access);
         end if;
      end abrir;

      procedure cerrar is
      begin
         if abierto then
            abierto := False;
            Text_IO.Put_Line ("Cerrar: " & reactorC.all.nombre);
            Set_Handler (eventoActuador, tiempoSiguiente, null);
         end if;
      end cerrar;

      procedure manejador (evento : in out Timing_Event) is
         tiempoActuar : Ada.Real_Time.Time;
         jitter       : constant Time_Span := Milliseconds (100);
      begin
         if abierto then
            tiempoActuar             := tiempoSiguiente + jitter;
            reactorC.all.temperatura := reactorC.all.temperatura - 50;
            delay until tiempoActuar;
            -- Text_IO.Put_Line (Day_Duration'Image (Seconds (Clock))
            --                   & " Bajar: " & reactorC.all.nombre);
            tiempoSiguiente := tiempoSiguiente + periodoActuador;
            Set_Handler (evento, tiempoSiguiente, manejador'Access);
         end if;
      end manejador;
   end ActuadorCompuerta;
end ActuadorCompuerta_P;
