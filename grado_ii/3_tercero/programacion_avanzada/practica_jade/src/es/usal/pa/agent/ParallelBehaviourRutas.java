package es.usal.pa.agent;

import jade.core.Agent;
import jade.core.behaviours.ParallelBehaviour;
import jade.core.behaviours.ThreadedBehaviourFactory;

public class ParallelBehaviourRutas extends ParallelBehaviour {
  private static final long serialVersionUID = 1L;

  public ParallelBehaviourRutas(Agent a) {
    super();

    ThreadedBehaviourFactory tbf = new ThreadedBehaviourFactory();

    addSubBehaviour(tbf.wrap(new CyclicBehaviourRuta(a)));
    addSubBehaviour(tbf.wrap(new CyclicBehaviourRuta(a)));
    addSubBehaviour(tbf.wrap(new CyclicBehaviourRuta(a)));
    addSubBehaviour(tbf.wrap(new CyclicBehaviourRuta(a)));
    addSubBehaviour(tbf.wrap(new CyclicBehaviourRuta(a)));
  }
}
