package es.usal.pa.agent;

import es.usal.pa.model.ParadaRecorrido;
import es.usal.pa.model.Recorrido;
import es.usal.pa.model.Usuario;
import jade.core.Agent;
import jade.core.behaviours.CyclicBehaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import jade.lang.acl.UnreadableException;
import java.util.Scanner;

public class AgentUsuario extends Agent {
  private static final long serialVersionUID = 1L;

  @Override
  public void setup() {

    addBehaviour(new CyclicBehaviour(this) {
      private static final long serialVersionUID = 1L;

      Scanner sc = new Scanner(System.in);

      @Override
      public void action() {
        Usuario usuario;
        Integer origen;
        Integer destino;
        Float hora;

        try {
          System.out.println();
          System.out.print("Origen: ");
          origen = Integer.parseInt(sc.nextLine());
          System.out.println();

          System.out.print("Destino: ");
          destino = Integer.parseInt(sc.nextLine());
          System.out.println();

          System.out.print("Hora: ");
          hora = Float.parseFloat(sc.nextLine());
          System.out.println();

          usuario = new Usuario(hora, origen, destino);

          Utils.enviarMensaje(this.myAgent, "ruta", usuario);

          ACLMessage msg = blockingReceive(MessageTemplate.MatchPerformative(ACLMessage.INFORM));

          Recorrido recorrido = (Recorrido) msg.getContentObject();

          System.out.println();
          for (ParadaRecorrido paradaRecorrido : recorrido.getVectorParadas()) {
            if (paradaRecorrido.getParada().equals(recorrido.getParadaFinal())) {
              System.out.printf("Parada: %d Llegada: %.1f\n", paradaRecorrido.getParada(),
                  recorrido.getHora());
            } else {
              System.out.printf("Parada: %d Coger L�nea: %d Hora: %.1f\n",
                  paradaRecorrido.getParada(), paradaRecorrido.getLlegadaLinea().getLinea(),
                  paradaRecorrido.getLlegadaLinea().getHora());
            }
          }
        } catch (NumberFormatException e) {
          System.out.println("Por favor introduzca datos v�lidos");
        } catch (UnreadableException e) {
          e.printStackTrace();
        }
      }
    });
  }
}
