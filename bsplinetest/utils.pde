/**
 *
 */
void updateKnotsNU(int order, ArrayList<Double> cknots, ArrayList<Point> controls) {
  cknots.clear();
  int n = controls.size(), d = order - 1, r = n + order - 2*d, i;
  double step = 0;
  if (n-order>0) step = (double)(n-1)/(double)(1+n-order);

  for (i=0; i<order; i++) cknots.add((double)0);
  for (i=1; i<n-order+1; i++) cknots.add((double)i*step);
  for (i=0; i<order; i++) cknots.add((double)n-1);
}

/**
 *
 */
int[] getDomain(int order, ArrayList<Double> knotVector) {
  return new int[]{
    order - 1,
    knotVector.size() - order
  };
}

/**
 *
 */
ArrayList<Double> getNodeVector(int order, ArrayList<Double> knots, ArrayList<Point> controls) {
  int[] domain = getDomain(order, knots);
  ArrayList<Double> nodes = new ArrayList<Double>();
  for (int i=0; i<controls.size(); i++) {
    double node = 0;
    for (int offset=1; offset<order; offset++) node += knots.get(i+offset);
    node /= (order-1);
    if (node < knots.get(domain[0])) continue;
    if (node > knots.get(domain[1])) continue;
    nodes.add(node);
  }
  return nodes;
}

