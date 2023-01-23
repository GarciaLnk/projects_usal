package laberinto;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class Nodo implements Comparable<Nodo> {
    private final Integer x;
    private final Integer y;
    private Integer g;
    private Integer h;
    private Nodo padre = null;
    private final List<Arco> vecinos = new ArrayList<>();

    public Nodo(Integer x, Integer y) {
        this.x = x;
        this.y = y;
    }

    public Integer getG() {
        return g;
    }

    public void setG(Integer g) {
        this.g = g;
    }

    public Integer getH() {
        return h;
    }

    public void setH(Nodo objetivo) {
        this.h = Math.abs(objetivo.x - this.x) + Math.abs(objetivo.y - this.y);
    }

    public Nodo getPadre() {
        return padre;
    }

    public void setPadre(Nodo padre) {
        this.padre = padre;
    }

    public List<Arco> getVecinos() {
        return vecinos;
    }

    public void addVecino(Nodo n, Integer coste) {
        this.vecinos.add(new Arco(n, coste));
    }

    @Override
    public int compareTo(Nodo n) {
        return Integer.compare(this.g + this.h, n.g + n.h);
    }

    @Override
    public String toString() {
        return "(" + this.x + ", " + this.y + ")";
    }

    @Override
    public boolean equals(Object o) {
        if (o == this)
            return true;
        if (!(o instanceof Nodo)) {
            return false;
        }
        Nodo nodo = (Nodo) o;
        return x.equals(nodo.x) && y.equals(nodo.y);
    }

    @Override
    public int hashCode() {
        return Objects.hash(x, y);
    }
}
