package Reactor_P is
   type TipoTemperatura is new Integer;
   type Reactor is record
      nombre      : String (1 .. 9);
      temperatura : TipoTemperatura;
   end record;
end Reactor_P;
