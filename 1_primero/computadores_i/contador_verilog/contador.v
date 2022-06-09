/* Contador de cuenta arbitraria - Computadores I B4

Realizado por:
- Alberto Blázquez Matías
- Alberto García Martín

Nuestro contador tiene que realizar la siguiente serie:
    15, 9, 15, 1, 14, 8, 6, 0...

Para hacerlo hemos usado las siguientes puertas:
1 AND de tres entradas
1 AND de dos entradas
1 OR de dos entradas
4 biestables JK

27.5 puertas en total
*/

module JK(output reg Q, output wire NQ, input wire J, input wire K,   input wire C);
  not(NQ,Q);

  // Al inicio reseteamos el valor de Q a 0
  initial
  begin
    Q=0;
  end

  always @(posedge C)  // Siempre que haya un flanco de subida del reloj cambia la salida
  begin
    if (J & K)
      Q=~Q;
    else if (J)
      Q=1;
    else if (K)
      Q=0;
  end
endmodule

module contador(output wire [3:0] Q, input wire C);
  wire [3:0] NQ;
  wire Qt, NQt;
  wire wJK0;
  wire wq0q1q2;

  and JK0 (wJK0, NQt, NQ[1]);
  JK jk1 (Q[0], NQ[0], wJK0,  wJK0,  C);
  JK jk2 (Q[1], NQ[1], 1'b1,  1'b1,  C);
  JK jk3 (Q[2], NQ[2], NQ[1], 1'b1,  C);
  JK jk4 (Qt,   NQt,   NQ[1], NQ[1], C);
  and q0q1q2 (wq0q1q2, Q[0], Q[1], Q[2]);
  or  NQ3    (Q[3], wq0q1q2, Qt);
endmodule

module prueba;
  reg C;
  wire [3:0] Q;
  contador cont (Q,C);

  // Cada 10 unidades de tiempo cambia el valor del reloj, teniendo un periodo de 20
  always #10 C=~C;

  initial
  begin
    $dumpfile("contador13.dmp");
    $dumpvars(1, cont);

    $monitor ($time, "  C=%b, Q=%b (%d)", C, Q, Q);
      C=0;

    #250 $finish;
  end
endmodule
