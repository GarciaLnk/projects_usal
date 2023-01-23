package es.usal.pa.agent;

import es.usal.pa.model.Linea;
import jade.core.Agent;
import jade.core.behaviours.CyclicBehaviour;
import jade.lang.acl.ACLMessage;
import jade.lang.acl.MessageTemplate;
import java.io.IOException;
import java.io.Serializable;

public class CyclicBehaviourLinea extends CyclicBehaviour {
  private static final long serialVersionUID = 1L;

  protected Linea linea;

  public CyclicBehaviourLinea(Agent a) {
    super(a);

    linea = new Linea();
  }

  @Override
  public void action() {
    ACLMessage msgRuta =
        this.myAgent.blockingReceive(MessageTemplate.MatchPerformative(ACLMessage.REQUEST));

    try {
      ACLMessage msg = msgRuta.createReply();
      msg.setPerformative(ACLMessage.INFORM);
      msg.setOntology("ontologia" + this.linea.getNumLinea());
      msg.setContentObject((Serializable) linea);
      this.myAgent.send(msg);
    } catch (IOException e) {
      e.printStackTrace();
    }
  }
}
