import 'package:hyperspace/hyperspace.dart';

main() {
  final space = Hyperspace(4);
  final cube = space.addHypercube(100.0);
  cube.setRotationVelocity(0, 3, 1.5);
  space.update(1);
  for (int i = 0; i < cube.numEdges; ++i) {
    print(cube.getEdge(i));
  }
}
