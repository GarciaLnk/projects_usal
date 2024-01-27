package laberinto;

public class Arco {
    private final Nodo fin;
    private final Integer coste;

    public Arco(Nodo fin, Integer coste) {
        this.fin = fin;
        this.coste = coste;
    }

    public Nodo getFin() {
        return fin;
    }

    public Integer getCoste() {
        return coste;
    }
}
