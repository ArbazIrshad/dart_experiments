import 'package:dart_experiments/dart_experiments.dart' as de;

void main(List<String> arguments) {
  final graph = de.Graph(isUndirected: false, numOfNodes: 6);

  graph.insertEdge(from: 0, to: 1);
  graph.insertEdge(from: 1, to: 4);
  graph.insertEdge(from: 4, to: 3);
  graph.insertEdge(from: 3, to: 4);
  graph.insertEdge(from: 2, to: 5);
  graph.insertEdge(from: 5, to: 2);
  graph.insertEdge(from: 5, to: 4);

  final parent = de.depthFirstSearch(graph);
  final parentStack = de.depthFirstSearchStack(graph);

  print('PARENTS :$parent');
  print('PARENTS_STACK :$parentStack');
}
