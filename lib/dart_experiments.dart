import 'dart:collection';

typedef EdgeIndex = int;
typedef EdgeList = List<Edge>;
typedef EdgeIterable = Iterable<Edge>;

class Edge {
  final int from;
  final int to;
  final double weight;

  const Edge({required this.from, required this.to, required this.weight});

  @override
  int get hashCode => Object.hash(from, to, weight);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Edge &&
        from == other.from &&
        to == other.to &&
        weight == other.weight;
  }
}

class Node {
  final int index;
  final String label;
  // Using SplayTreeMap for ordering
  final Map<EdgeIndex, Edge> edges;

  Node({required this.index, required this.label})
    : edges = SplayTreeMap.fromIterable([]);

  int get neigborsCount {
    return edges.values.length;
  }

  EdgeIterable get edgeList => edges.values;

  Edge? getEdge(EdgeIndex index) {
    return edges[index];
  }

  void addEdge({required EdgeIndex neighbor, required double weight}) {
    edges[neighbor] = Edge(from: index, to: neighbor, weight: weight);
  }

  void removeEdge(EdgeIndex neighbor) {
    edges.remove(neighbor);
  }
}

class Graph {
  final List<Node> nodes;
  final bool isUndirected;

  Graph({required this.isUndirected, required int numOfNodes})
    : nodes = List.generate(
        numOfNodes,
        (index) => Node(index: index, label: '$index'),
      );

  int get numOfNodes => nodes.length;

  Edge? getEdge({required EdgeIndex from, required EdgeIndex to}) {
    // if (from < 0 || from >= numOfNodes ) throw IndexError.check('Index out of bounds');

    IndexError.check(from, numOfNodes);
    IndexError.check(to, numOfNodes);

    return nodes[from].getEdge(to);
  }

  bool hasEdge({required EdgeIndex from, required EdgeIndex to}) =>
      getEdge(from: from, to: to) != null;

  EdgeList getAllEdges() {
    EdgeList edges = [];

    for (final node in nodes) {
      for (final edge in node.edgeList) {
        if (isUndirected && edge.from > edge.to) {
          continue;
        }

        edges.add(edge);
      }
    }

    return edges;
  }

  void insertEdge({required int from, required int to, double weight = 1}) {
    IndexError.check(from, numOfNodes, name: 'from');
    IndexError.check(to, numOfNodes, name: 'to');

    nodes[from].addEdge(neighbor: to, weight: weight);

    if (isUndirected) {
      nodes[to].addEdge(neighbor: from, weight: weight);
    }
  }

  void removeEdge({required int from, required int to}) {
    IndexError.check(from, numOfNodes, name: 'from');
    IndexError.check(to, numOfNodes, name: 'to');

    nodes[from].removeEdge(to);

    if (isUndirected) {
      nodes[to].removeEdge(from);
    }
  }

  Node insertNode({String? label}) {
    final node = Node(index: numOfNodes, label: label ?? '$numOfNodes');
    nodes.add(node);
    return node;
  }

  Graph makeCopy() {
    final graph = Graph(isUndirected: isUndirected, numOfNodes: numOfNodes);

    for (final node in nodes) {
      graph.nodes[node.index] = Node(index: node.index, label: node.label);
      for (final edge in node.edgeList) {
        if (isUndirected && edge.from > edge.to) continue;
        graph.insertEdge(from: node.index, to: edge.to, weight: edge.weight);
      }
    }
    return graph;
  }
}

List<int> depthFirstSearch(Graph graph) {
  final last = List.filled(graph.numOfNodes, -1);
  final seen = List.filled(graph.numOfNodes, false);

  for (int index = 0; index < graph.numOfNodes; index++) {
    if (!seen[index]) {
      depthFirstSearchRecursive(g: graph, index: index, seen: seen, last: last);
    }
  }

  return last;
}

void depthFirstSearchRecursive({
  required Graph g,
  required int index,
  required List<bool> seen,
  required List<int> last,
}) {
  seen[index] = true;
  final edges = g.nodes[index].edgeList;

  for (final edge in edges) {
    final neighbor = edge.to;
    if (!seen[neighbor]) {
      last[neighbor] = index;
      depthFirstSearchRecursive(g: g, index: neighbor, seen: seen, last: last);
    }
  }
}

List<int> depthFirstSearchStack(Graph g) {
  final parents = List.filled(g.numOfNodes, -1);
  final seen = List.filled(g.numOfNodes, false);

  List<int> stack = [];

  for (int i = 0; i < g.numOfNodes; i++) {
    if (seen[i]) continue;

    stack.add(i);

    while (stack.isNotEmpty) {
      final position = stack.removeLast();

      if (!seen[position]) {
        print('EXPLORING ${position}');
        seen[position] = true;
        final edges = g.nodes[position].edgeList.toList();

        // This loop is responsible for
        // pushing the outward edges to
        // stack for exploring later
        for (final edge in edges) {
          final target = edge.to;
          if (!seen[target]) {
            print('\tTarget ${target}');
            // seen[target] = true;
            stack.add(target);
            // if (parents[target] == -1) {
            parents[target] = position;
            // }
          }
        }
      }
    }
  }

  return parents;
}

List<int> breathFirstSearch(Graph g) {
  final seen = List.filled(g.numOfNodes, false);
  final parents = List.filled(g.numOfNodes, -1);

  final to_explore = Queue<int>();

  for (int i = 0; i < g.numOfNodes; i++) {
    if (seen[i]) continue;

    to_explore.add(i);
    seen[i] = true;
    while (to_explore.isNotEmpty) {
      final exploring = to_explore.removeFirst();

      final edges = g.nodes[exploring].edgeList;

      for (final edge in edges) {
        final target = edge.to;
        if (!seen[target]) {
          to_explore.add(target);
          seen[target] = true;
          parents[target] = exploring;
        }
      }
    }
  }

  return parents;
}
