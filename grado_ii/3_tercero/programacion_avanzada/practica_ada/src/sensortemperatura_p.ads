with Ada.Real_Time.Timing_Events;
use Ada.Real_Time, Ada.Real_Time.Timing_Events;

with Reactor_P; use Reactor_P;

package SensorTemperatura_P is
   protected type SensorTemperatura is
      procedure iniciar (r : access Reactor; tiempo : Time);
      entry leer (temperatura : out TipoTemperatura);
      procedure manejador (evento : in out Timing_Event);
   private
      tiempoSiguiente : Time;
      tempLeida       : TipoTemperatura;
      tempDisponible  : Boolean   := True;
      reactorS        : access Reactor;
      eventoSensor    : Timing_Event;
      periodoSensor   : Time_Span := Milliseconds (1_900);
   end SensorTemperatura;
end SensorTemperatura_P;
