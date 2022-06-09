with Ada.Real_Time.Timing_Events;
use Ada.Real_Time, Ada.Real_Time.Timing_Events;

with Reactor_P; use Reactor_P;

package ActuadorCompuerta_P is
   protected type ActuadorCompuerta is
      procedure iniciar (r : access Reactor);
      procedure abrir;
      procedure cerrar;
      procedure manejador (evento : in out Timing_Event);
   private
      tiempoSiguiente : Time;
      reactorC        : access Reactor;
      abierto         : Boolean   := False;
      eventoActuador  : Timing_Event;
      periodoActuador : Time_Span := Milliseconds (950);
      -- periodoActuador : Time_Span := Milliseconds (50);
   end ActuadorCompuerta;
end ActuadorCompuerta_P;
