with Text_IO;
-- with Calendar; use Calendar;

package body SensorTemperatura_P is
   protected body SensorTemperatura is
      procedure iniciar (r : access Reactor; tiempo : Ada.Real_Time.Time) is
      begin
         tempDisponible  := False;
         reactorS        := r;
         tiempoSiguiente := tiempo;
         Set_Handler (eventoSensor, tiempoSiguiente, manejador'Access);
      end iniciar;

      entry leer (temperatura : out TipoTemperatura) when tempDisponible is
      begin
         temperatura    := tempLeida;
         tempDisponible := False;
         Text_IO.Put_Line (reactorS.all.nombre & ":" & temperatura'Image);
      end leer;

      procedure manejador (evento : in out Timing_Event) is
         tiempoLeer : Ada.Real_Time.Time;
         jitter     : constant Time_Span := Milliseconds (100);
      begin
         tiempoLeer := tiempoSiguiente + jitter;
         tempLeida  := reactorS.all.temperatura;
         delay until tiempoLeer;
         -- Text_IO.Put_Line (Day_Duration'Image (Seconds (Clock))
         --                   & " Leer: " & reactorS.all.nombre);
         tempDisponible  := True;
         tiempoSiguiente := tiempoSiguiente + periodoSensor;
         Set_Handler (evento, tiempoSiguiente, manejador'Access);
      end manejador;
   end SensorTemperatura;
end SensorTemperatura_P;
