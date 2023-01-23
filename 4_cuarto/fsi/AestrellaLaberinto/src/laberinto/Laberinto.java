package laberinto;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Laberinto {

    private final List<Barrera> listaBarreras = new ArrayList<>();
    private final Integer filas;
    private final Integer columnas;
    Map<String, Nodo> mapaNodos = new HashMap<>();

    public Laberinto() {
        this.filas = 6;
        this.columnas = 7;

        listaBarreras.add(new Barrera(1, 4, 'x'));
        listaBarreras.add(new Barrera(2, 2, 'y'));
        listaBarreras.add(new Barrera(2, 3, 'y'));
        listaBarreras.add(new Barrera(2, 3, 'x'));
        listaBarreras.add(new Barrera(2, 4, 'x'));
        listaBarreras.add(new Barrera(2, 5, 'x'));
        listaBarreras.add(new Barrera(2, 6, 'x'));
        listaBarreras.add(new Barrera(3, 1, 'y'));
        listaBarreras.add(new Barrera(3, 2, 'x'));
        listaBarreras.add(new Barrera(3, 4, 'y'));
        listaBarreras.add(new Barrera(3, 4, 'x'));
        listaBarreras.add(new Barrera(3, 5, 'y'));
        listaBarreras.add(new Barrera(3, 5, 'x'));
        listaBarreras.add(new Barrera(3, 6, 'x'));
        listaBarreras.add(new Barrera(4, 2, 'y'));
        listaBarreras.add(new Barrera(4, 2, 'x'));
        listaBarreras.add(new Barrera(4, 3, 'x'));
        listaBarreras.add(new Barrera(4, 4, 'y'));
        listaBarreras.add(new Barrera(4, 5, 'y'));
        listaBarreras.add(new Barrera(4, 6, 'x'));
        listaBarreras.add(new Barrera(5, 1, 'x'));
        listaBarreras.add(new Barrera(5, 6, 'x'));

        for (int i = 1; i <= filas; i++) {
            for (int j = 1; j <= columnas; j++) {
                Nodo n = new Nodo(i, j);
                mapaNodos.put(i + " " + j, n);
            }
        }
    }

    public Map<String, Nodo> crearGrafo() {
        Map<String, Nodo> grafo = new HashMap<>();

        for (int i = 1; i <= filas; i++) {
            for (int j = 1; j <= columnas; j++) {
                Nodo nodo = mapaNodos.get(i + " " + j);
                compruebaVecinos(nodo, i, j);
                grafo.put(nodo.toString(), nodo);
            }
        }

        return grafo;
    }

    public void compruebaVecinos(Nodo nodo, int i, int j) {
        if (j < columnas && !listaBarreras.contains(new Barrera(i, j, 'x')))
            nodo.addVecino(mapaNodos.get(i + " " + (j + 1)), 1);
        if (i > 1 && !listaBarreras.contains(new Barrera(i - 1, j, 'y')))
            nodo.addVecino(mapaNodos.get((i - 1) + " " + j), 1);
        if (j > 1 && !listaBarreras.contains(new Barrera(i, j - 1, 'x')))
            nodo.addVecino(mapaNodos.get(i + " " + (j - 1)), 1);
        if (i < filas && !listaBarreras.contains(new Barrera(i, j, 'y')))
            nodo.addVecino(mapaNodos.get((i + 1) + " " + j), 1);
    }
}
