// Definição da classe Grafo
class Grafo {
  int numVertices;
  int[][] matrizAdj;
  PVector[] posicoes; // Posições das partículas (nós do grafo)
  PVector[] velocidades; // Velocidades das partículas
  float raio = 10; // Raio dos nós
  float k = 0.001; // Constante da mola para a atração
  float c = 3000; // Constante de repulsão

  // Construtor da classe Grafo
  Grafo(int numVertices) {
    this.numVertices = numVertices;
    matrizAdj = new int[numVertices][numVertices];
    posicoes = new PVector[numVertices];
    velocidades = new PVector[numVertices];
    inicializarPosicoes();
  }

  Grafo(int[][] adj) {
    this.numVertices = adj.length;
    matrizAdj = adj;
    posicoes = new PVector[numVertices];
    velocidades = new PVector[numVertices];
    inicializarPosicoes();
  }

  // Adiciona uma aresta entre dois vértices
  void adicionarAresta(int i, int j) {
    matrizAdj[i][j] = 1;
    matrizAdj[j][i] = 1; // Para grafos não direcionados
  }

  // Adiciona uma aresta entre dois vértices
  void adicionarAresta(int i, int j, int peso) {
    matrizAdj[i][j] = peso;
    matrizAdj[j][i] = peso; // Para grafos não direcionados
  }

  // Inicializa as posições das partículas em um círculo
  void inicializarPosicoes() {
    float angulo = TWO_PI / (numVertices - 1);
    float raioCirculo = min(width, height) / 3;
    for (int i = 1; i < numVertices; i++) {
      float x = width / 2 + raioCirculo * cos((i - 1) * angulo);
      float y = height / 2 + raioCirculo * sin((i - 1) * angulo);
      posicoes[i] = new PVector(x, y);
      velocidades[i] = new PVector(0, 0);
    }
    // Posição fixa do vértice 0
    posicoes[0] = new PVector(width / 2, height / 2);
    velocidades[0] = new PVector(0, 0);
  }

  // Atualiza as posições das partículas
  void atualizar() {
    for (int i = 1; i < numVertices; i++) {
      PVector forca = new PVector(0, 0);

      // Força de repulsão
      for (int j = 0; j < numVertices; j++) {
        if (i != j) {
          PVector direcao = PVector.sub(posicoes[i], posicoes[j]);
          float distancia = direcao.mag();
          if (distancia > 0) {
            direcao.normalize();
            float forcaRepulsao = c / (distancia * distancia);
            direcao.mult(forcaRepulsao);
            forca.add(direcao);
          }
        }
      }

      // Força de atração
      for (int j = 0; j < numVertices; j++) {
        if (matrizAdj[i][j] > 0) {
          PVector direcao = PVector.sub(posicoes[j], posicoes[i]);
          float distancia = direcao.mag();
          direcao.normalize();
          float forcaAtracao = k * (distancia - raio);
          direcao.mult(forcaAtracao);
          forca.add(direcao);
        }
      }

      velocidades[i].add(forca);
      posicoes[i].add(velocidades[i]);

      // Reduz a velocidade para estabilizar a simulação
      velocidades[i].mult(0.5);

      // Mantém as partículas dentro da tela
      if (posicoes[i].x < 0 || posicoes[i].x > width) velocidades[i].x *= -1;
      if (posicoes[i].y < 0 || posicoes[i].y > height) velocidades[i].y *= -1;
    }
  }

  // Desenha o grafo
  void desenhar(int[] caminho) {
    textAlign(CENTER);
    // Desenha as arestas
    strokeWeight(1);
    for (int i = 0; i < numVertices; i++) {
      for (int j = i + 1; j < numVertices; j++) {
        if (matrizAdj[i][j] > 0) {
          boolean arestaCaminho = false;
          for (int k = 0; k < caminho.length - 1; k++) {
            if ((caminho[k] == i && caminho[k + 1] == j) || (caminho[k] == j && caminho[k + 1] == i)) {
              arestaCaminho = true;
              break;
            }
          }
          if (arestaCaminho) {
            stroke(255, 0, 0);
          } else {
            stroke(0);
          }
          strokeWeight(matrizAdj[i][j]);
          line(posicoes[i].x, posicoes[i].y, posicoes[j].x, posicoes[j].y);
        }
      }
    }

    // Desenha os nós
    fill(255);
    stroke(0);
    strokeWeight(1);
    for (int i = 0; i < numVertices; i++) {
      fill(255);
      ellipse(posicoes[i].x, posicoes[i].y, raio * 2, raio * 2);
      fill(0);
      text(str(i), posicoes[i].x, posicoes[i].y + 4);
    }
  }

  // Implementa o algoritmo de Dijkstra para encontrar o menor caminho
  int[] dijkstra(int origem, int destino) {
    int[] dist = new int[numVertices];
    int[] anterior = new int[numVertices];
    boolean[] visitado = new boolean[numVertices];

    for (int i = 0; i < numVertices; i++) {
      dist[i] = Integer.MAX_VALUE;
      anterior[i] = -1;
    }
    dist[origem] = 0;

    for (int i = 0; i < numVertices; i++) {
      int u = -1;
      for (int j = 0; j < numVertices; j++) {
        if (!visitado[j] && (u == -1 || dist[j] < dist[u])) {
          u = j;
        }
      }

      if (dist[u] == Integer.MAX_VALUE) break;
      visitado[u] = true;

      for (int v = 0; v < numVertices; v++) {
        if (matrizAdj[u][v] > 0) {
          int alt = dist[u] + matrizAdj[u][v];
          if (alt < dist[v]) {
            dist[v] = alt;
            anterior[v] = u;
          }
        }
      }
    }

    // Reconstrução do caminho
    List<Integer> caminho = new ArrayList<>();
    for (int v = destino; v != -1; v = anterior[v]) {
      caminho.add(v);
    }
    Collections.reverse(caminho);
    return caminho.stream().mapToInt(Integer::intValue).toArray();
  }
}

Grafo grafo;

void setup() {
  size(800, 600);
  frameRate(60);

  int n = 10;
  int[][] adj = new int[n][n];

  for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j++) {
      if (i == j) {
        adj[i][j] = 0;
      } else {
        adj[i][j] = random(1) > 0.5 ? int(random(1, 5)) : 0;
        adj[j][i] = adj[i][j];
      }
    }

  grafo = new Grafo(adj);
}

void draw() {
  background(255);
  grafo.atualizar();
  int[] caminho = grafo.dijkstra(0, 5);
  grafo.desenhar(caminho);
}
