package laberinto;

import java.util.Objects;

public class Barrera {
    private final Integer x;
    private final Integer y;
    private final Character z;

    public Barrera(Integer x, Integer y, Character z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    @Override
    public boolean equals(Object o) {
        if (o == this)
            return true;
        if (!(o instanceof Barrera)) {
            return false;
        }
        Barrera barrera = (Barrera) o;
        return x.equals(barrera.x) && y.equals(barrera.y) && z.equals(barrera.z);
    }

    @Override
    public int hashCode() {
        return Objects.hash(x, y, z);
    }
}
