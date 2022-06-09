package es.usal.pa.agent;

import jade.content.lang.sl.SLCodec;
import jade.core.Agent;
import jade.domain.DFService;
import jade.domain.FIPAAgentManagement.DFAgentDescription;
import jade.domain.FIPAAgentManagement.ServiceDescription;
import jade.domain.FIPAException;

public class AgentRuta extends Agent {
  private static final long serialVersionUID = 1L;

  @Override
  public void setup() {
    // Crear servicios proporcionados por el agentes y registrarlos en la plataforma
    DFAgentDescription dfd = new DFAgentDescription();
    dfd.setName(getAID());
    ServiceDescription sd = new ServiceDescription();
    sd.setName("Servicio-Ruta");
    // Establezco el tipo del servicio para poder localizarlo cuando haga una busqueda
    sd.setType("ruta");
    // Agents that want to use this service need to "know" the ontologia
    sd.addOntologies("ontologia");
    // Agents that want to use this service need to "speak" the FIPA-SL language
    sd.addLanguages(new SLCodec().getName());
    dfd.addServices(sd);

    // Registro los servicios
    try {
      DFService.register(this, dfd);
    } catch (FIPAException e) {
      e.printStackTrace();
    }

    // Definir comportamientos
    addBehaviour(new ParallelBehaviourRutas(this));
  }
}
