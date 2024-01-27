with Ada.Real_Time;

package ControlInicio_P is
   protected type ControlInicio (numTareas : Integer) is
      entry tareaIniciada (tiempo : access Ada.Real_Time.Time);
   private
      iniciado : Boolean := False;
   end ControlInicio;
end ControlInicio_P;
