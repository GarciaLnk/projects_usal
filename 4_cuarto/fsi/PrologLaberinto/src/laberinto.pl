% Problema Laberinto
%
% Autores: Alberto García Martín
%          Iván Campos Alamillo
%
% MAPA
%
%   1 2 3 4 5 6 7
%   _ _ _ _ _ _ _
% 1|       |     |
% 2| |_ _| | | | |
% 3|_  |  _|_| | |
% 4   _| |_ _  |  
% 5| |         | |
% 6|_ _ _ _ _ _ _|
%

% barrera(X,Y,Z)
%  X: coordenada X
%  Y: coordenada Y
%  Z: dirección de la barrera, x bloquea el eje horizontal e y bloquea el eje vertical
barrera(X,Y,Z) :-
    (X=:=1,Y=:=4,Z=x);
    (X=:=2,Y=:=2,Z=y);
    (X=:=2,Y=:=3,Z=y);
    (X=:=2,Y=:=3,Z=x);
    (X=:=2,Y=:=4,Z=x);
    (X=:=2,Y=:=5,Z=x);
    (X=:=2,Y=:=6,Z=x);
    (X=:=3,Y=:=1,Z=y);
    (X=:=3,Y=:=2,Z=x);
    (X=:=3,Y=:=4,Z=y);
    (X=:=3,Y=:=4,Z=x);
    (X=:=3,Y=:=5,Z=y);
    (X=:=3,Y=:=5,Z=x);
    (X=:=3,Y=:=6,Z=x);
    (X=:=4,Y=:=2,Z=y);
    (X=:=4,Y=:=2,Z=x);
    (X=:=4,Y=:=3,Z=x);
    (X=:=4,Y=:=4,Z=y);
    (X=:=4,Y=:=5,Z=y);
    (X=:=4,Y=:=6,Z=x);
    (X=:=5,Y=:=1,Z=x);
    (X=:=5,Y=:=6,Z=x).

% Giro Izquierda (Antihorario)
% Precondición: ninguna
% Modificación: si q < 3, q = q + 1, si no q = 0
giro_antihorario(f(X,Y,Q), f(X,Y,Qf)) :-
    (Q < 3, Qf is Q + 1);
    (Q = 3, Qf is 0).

% Giro Derecha (Horario)
% Precondición: ninguna
% Modificación: si q > 0, q = q - 1, si no q = 3
giro_horario(f(X,Y,Q), f(X,Y,Qf)) :-
    (Q > 0, Qf is Q - 1);
    (Q = 0, Qf is 3).

% Avanzar
% Regla 1
% Precondiciones: no(pared_enfrente), q = 0, y < 7
% Modificación: xf = xi, yf = yi + 1
avanza(f(X,Y,0), f(X,Yf,0)) :-
    Y < 7,
    \+(barrera(X, Y, x)),
    Yf is Y + 1.

% Regla 2 
% Precondiciones: no(pared_enfrente), q = 1, xi > 1
% Modificación: xf = xi - 1, yf = yi
avanza(f(X,Y,1), f(Xf,Y,1)) :-
    X > 1,
    \+(barrera(X - 1, Y, y)),
    Xf is X - 1.

% Regla 3
% Precondiciones: no(pared_enfrente), q = 2, yi > 1
% Modificación: xf = xi, yf = yi - 1
avanza(f(X,Y,2), f(X,Yf,2)) :-
    Y > 1,
    \+(barrera(X, Y - 1, x)),
    Yf is Y - 1.

% Regla 4
% Precondiciones: no(pared_enfrente), q = 3, xi < 6
% Modificación: xf = xi + 1, yf = yi
avanza(f(X,Y,3), f(Xf,Y,3)) :-
    X < 6,
    \+(barrera(X, Y, y)),
    Xf is X + 1.

mueve(Inicio, Nuevo) :-
    avanza(Inicio, Nuevo).

mueve(Inicio, Nuevo) :-
    giro_horario(Inicio, Temp),
    avanza(Temp, Nuevo).

mueve(Inicio, Nuevo) :-
    giro_antihorario(Inicio, Temp),
    avanza(Temp, Nuevo).

mueve(Inicio, Nuevo) :-
    giro_horario(Inicio, Temp1),
    giro_horario(Temp1, Temp2),
    avanza(Temp2, Nuevo).

escribe([]).
  
escribe([H|T]):-
    escribe(T),
    writeln(H).

miembro(f(X,Y,_), [f(X,Y,_)|_]).
  
miembro(Posicion, [_|Resto]):-
    miembro(Posicion, Resto).

resuelve_basico(Lista, Final) :-
    Lista = [f(X,Y,Q)|_],
    Final = f(X,Y,Q),
    escribe(Lista).

resuelve_basico(Lista, Final) :-
    Lista = [f(X,Y,Q)|_],
    Final = f(X,Y,Qf),
    giro_horario(f(X,Y,Q), f(X,Y,Qt)),
    NLista = [f(X,Y,Qt)|Lista],
    resuelve_basico(NLista, f(X,Y,Qf)). 

resuelve_basico(Lista, Final) :-
    Lista = [f(X,Y,Q)|T],
    not(miembro(f(X,Y,Q),T)),
    mueve(f(X,Y,Q), Nuevo),
    NLista = [Nuevo|Lista],
    resuelve_basico(NLista, Final).

resuelve(Lista, Final, _, _) :-
    Lista = [f(X,Y,Q)|_],
    Final = f(X,Y,Q),
    escribe(Lista).

resuelve(Lista, Final, Contador, Limite) :-
    Lista = [f(X,Y,Q)|_],
    Final = f(X,Y,Qf),
    giro_horario(f(X,Y,Q), f(X,Y,Qt)),
    NLista = [f(X,Y,Qt)|Lista],
    NContador is Contador + 1,
    NContador < Limite,
    resuelve(NLista, f(X,Y,Qf), NContador, Limite). 

resuelve(Lista, Final, Contador, Limite) :-
    Lista = [f(X,Y,Q)|T],
    not(miembro(f(X,Y,Q),T)),
    mueve(f(X,Y,Q), Nuevo),
    NLista = [Nuevo|Lista],
    NContador is Contador + 1,
    NContador < Limite,
    resuelve(NLista, Final, NContador, Limite).

resol(Lim):-
    resuelve([f(4,1,0)], f(4,7,0), 0, Lim).
  
resol(Lim):-
    % Limite de iteraciones para salir en caso de bucle infinito
    Lim < 10000,
    NewLim is Lim + 1,
    resol(NewLim).

solucion_limite :-
    time(resol(0)).

solucion_basica :-
    time(resuelve_basico([f(4,1,0)], f(4,7,0))).
