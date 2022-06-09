package body ControlInicio_P is
   protected body ControlInicio is
      entry tareaIniciada (tiempo : access Ada.Real_Time.Time)
        when tareaIniciada'Count = numTareas or else iniciado is
      begin
         if not iniciado then
            tiempo.all := Ada.Real_Time.Clock;
         end if;
         iniciado := True;
      end tareaIniciada;
   end ControlInicio;
end ControlInicio_P;
