// Problema del laberinto resuelto usando el algoritmo A*
//
// Autores: Alberto García Martín
// Iván Campos Alamillo

package laberinto;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;

public class Aestrella {
    public static Nodo encontrarCamino(Nodo inicio, Nodo fin, List<Nodo> cerrados) {
        // ABIERTOS siempre estará ordenada por el valor de f(n)
        PriorityQueue<Nodo> abiertos = new PriorityQueue<>();

        inicio.setG(0);
        inicio.setH(fin);
        // Iniciar con el nodo inicial una lista llamada ABIERTOS
        abiertos.add(inicio);

        // CICLO: si ABIERTOS está vacía, salida con fallo
        while (!abiertos.isEmpty()) {
            // Seleccionar el primer nodo de la lista ABIERTOS,
            // suprimirlo de ella e incluirlo en CERRADOS
            Nodo n = abiertos.poll();
            cerrados.add(n);

            // Si n es un nodo objetivo, salida con éxito
            if (n.equals(fin)) {
                return n;
            }

            // Expandir el nodo n
            for (Arco a : n.getVecinos()) {
                Nodo vecino = a.getFin();

                // Explorar los sucesores de n que no sean a la vez ascendientes de n
                if (vecino.getPadre() == null || !vecino.getPadre().equals(n)) {
                    // Establecer un apuntador a n desde aquellos nodos que
                    // no estaban ya incluidos en abiertos o cerrados
                    if (!abiertos.contains(vecino) && !cerrados.contains(vecino)) {
                        vecino.setPadre(n);
                        // Añadir estos nodos a abiertos
                        vecino.setG(n.getG() + a.getCoste());
                        vecino.setH(fin);
                        abiertos.add(vecino);
                    }
                    // Para cada nodo que ya figurase en ABIERTOS o CERRADOS,
                    // decidir si se modifican o no sus apuntadores, dirigiéndolos a n
                    else {
                        actualizarPadres(n, vecino, a, cerrados);
                    }
                }
            }
        }

        return null;
    }

    private static void actualizarPadres(Nodo nodo, Nodo vecino, Arco arco, List<Nodo> cerrados) {
        if (vecino.getG() > nodo.getG() + arco.getCoste()) {
            vecino.setPadre(nodo);
            vecino.setG(nodo.getG() + arco.getCoste());

            // Para cada nodo que estuviese ya en CERRADOS, decidir,
            // para cada uno de sus descendientes, si se modifican o no sus apuntadores
            if (cerrados.contains(vecino)) {
                for (Arco a : vecino.getVecinos()) {
                    Nodo n = a.getFin();
                    actualizarPadres(vecino, n, a, cerrados);
                }
            }
        }
    }

    public static void imprimeCamino(Nodo n) {
        if (n == null) {
            System.out.println("No hay solucion");
            return;
        }

        if (n.getPadre() != null) {
            imprimeCamino(n.getPadre());
        }
        System.out.println(n);
    }

    public static void main(String[] args) {
        Laberinto laberinto = new Laberinto();

        // La lista vacía CERRADOS se pasará como parámetro
        // para posteriormente obtener el número de nodos explorados
        List<Nodo> cerrados = new ArrayList<>();

        long startTime = System.nanoTime();
        Map<String, Nodo> graph = laberinto.crearGrafo();
        Nodo camino = encontrarCamino(graph.get("(4, 1)"), graph.get("(4, 7)"), cerrados);
        long endTime = System.nanoTime();
        long duration = (endTime - startTime) / 1000000;

        imprimeCamino(camino);
        System.out.println("\nTiempo de ejecución: " + duration + "ms");
        System.out.println("Nodos explorados: " + cerrados.size());
        System.out.println("Nodos totales: " + graph.size());
    }
}
