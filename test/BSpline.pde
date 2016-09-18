/**
 *
 */
class BSpline {
  final static int UNIFORM = 0;
  final static int NONUNIFORM = 1;
  int mode;

  int order;
  float segmentPointCount = 20;
  ArrayList<Point> controls;
  ArrayList<Double> knots;
  ArrayList<Double> cknots;
  boolean closed;

  String test = "test\nstuff";

  /**
   *
   */
  BSpline() {
    this(4);
  }

  /**
   *
   */
  BSpline(int _order) {
    this(_order, NONUNIFORM);
  }

  /**
   *
   */
  BSpline(int _order, int _mode) {
    order = _order;
    mode = _mode;
    controls = new ArrayList<Point>();
    knots = new ArrayList<Double>();
    cknots = new ArrayList<Double>();
    for (int i=0; i<order; i++) knots.add((double)i);
    closed = false;
  }

  /**
   *
   */
  void add(double x, double y) {
    controls.add(new Point(x, y));
    knots.add((double)knots.size());
    updateKnotsNU(order, cknots, controls);
  }

  /**
   *
   */
  void toggleMode() {
    mode = (mode==UNIFORM) ? NONUNIFORM : UNIFORM;
  }

  /**
   *
   */
  void toggleOpen() {
    closed = !closed;
  }

  boolean isClosed() {
    return closed;
  }

  /**
   *
   */
  ArrayList<Double> getKnotVector() {
    if (mode == NONUNIFORM && !closed) return cknots;
    ArrayList<Double> knots = new ArrayList<Double>(this.knots);
    if (closed) {
      double max = knots.get(knots.size()-1);
      for (int i=1; i<=order; i++) {
        knots.add(max + i);
      }
    }
    return knots;
  }

  /**
   *
   */
  boolean isRational() {
    for (Point c : controls) {
      if (c.w!=1.0) return true;
    }
    return false;
  }

  /**
   *
   */
  void draw() {
    int n = controls.size();
    if (n<order) return;
    pushStyle();
    ArrayList<Double> knotVector = getKnotVector();
    drawPoints(n, knotVector);
    drawKnots(knotVector);
    drawNodes(knotVector);
    popStyle();
  }

  void drawPoints(int n, ArrayList<Double> knotVector) {
    stroke(255, 235, 25);
    strokeWeight(3);
    Point f = interpolate(0, knotVector), p;
    for (double step=1.0/(segmentPointCount*Math.max(1, (n-order))), t=step; t<1.0; t+=step) {
      p = interpolate(t, knotVector);
      line(f.x * f.w, f.y * f.w, p.x * p.w, p.y * p.w);
      f = p;
    }
    p = interpolate(1, knotVector);
    line(f.x, f.y, p.x, p.y);
    strokeWeight(1);
  }

  void drawKnots(ArrayList<Double> knotVector) {
    int[] domain = getDomain(order, knotVector);

    stroke(255, 0, 0);
    strokeWeight(2);
    Point p;
    for (int i=domain[0]; i<=domain[1]; i++) {
      p = interpolate(knotVector.get(i), knotVector, true);
      ellipse(p.x * p.w, p.y * p.w, 5, 5);
    }
    strokeWeight(1);
  }

  void drawNodes(ArrayList<Double> knotVector) {
    ArrayList<Double> nodeVector = getNodeVector(order, knotVector, controls);

    noFill();
    stroke(10, 220, 15);
    strokeWeight(2);
    Point p;
    for (double node : nodeVector) {
      p = interpolate(node, knotVector, true);
      ellipse(p.x * p.w, p.y * p.w, 9, 9);
    }
    strokeWeight(1);
  }

  /**
   *
   */
  Point interpolate(double t) {
    return interpolate(t, this.knots);
  }

  /**
   *
   */
  Point interpolate(double t, ArrayList<Double> knots) {
    return interpolate(t, knots, false);
  }

  /**
   *
   */
  Point interpolate(double t, ArrayList<Double> knots, boolean scaled) {
    if (!scaled && t < 0) throw new Error("unscaled t cannot be less than 0");
    if (!scaled && t > 1) throw new Error("unscaled t cannot exceed 1");

    int n = controls.size();    // points count
    if (order < 2) throw new Error("order must be at least 2 (linear)");
    if (order > n) throw new Error("order must be less than point count");

    int[] domain = getDomain(order, knots);
    t = scaled ? t : mapToDomain(t, domain, knots);
    int s = findSegment(t, domain, knots);
    return getPoint(t, s, controls, knots);
  }

  /**
   *
   */
  int findSegment(double t, int[] domain, ArrayList<Double> knots) {
    int s = -1;
    for (s=domain[0]; s<domain[1]; s++) {
      if (t >= knots.get(s) && t <= knots.get(s+1)) {
        break;
      }
    }
    if (s == -1) {
      throw new Error("No segment could be found for specified t-value "+t);
    }
    return s;
  }

  /**
   *
   */
  double mapToDomain(double t, int[] domain, ArrayList<Double> knots) {
    double low  = knots.get(domain[0]);
    double high = knots.get(domain[1]);
    t = t * (high - low) + low;
    if (t < low || t > high) {
      throw new Error("t out of bounds  ("+low+" < t < "+high+")");
    }
    return t;
  }

  /**
   *
   */
  Point getPoint(double t, int s, ArrayList<Point> controls, ArrayList<Double> knots) {

    // Create the weight-corrected Points
    ArrayList<Point> weighted = new ArrayList<Point>();
    for (int i=0; i<controls.size(); i++) {
      Point c = controls.get(i);
      c = new Point(c.x * c.w, c.y * c.w, c.w);
      weighted.add(c);
    }

    if (closed) {
      for (int i=0; i<order; i++) {
        weighted.add(weighted.get(i));
      }
    }

    // Run through the Cox - De Boor algorithm, in-situ
    // rather than constructing the pyramid as distinct
    // values, mostly for efficiency.

    // l (level) goes from 1 to the curve order
    for (int l=1; l<=order; l++) {
      // build level l of the pyramid
      for (int i=s; i>s-order+l; i--) {
        // compute mix ratio
        double ki = knots.get(i);
        double kiol = knots.get(i+order-l);
        double a = (t - ki) / (kiol - ki);
        // perform interpolate for this level
        Point pi = weighted.get(i);
        Point pmi = weighted.get(i-1);
        pi.interpolate(a, pmi);
      }
    }

    // unweigh and return
    Point p = weighted.get(s);
    p.setTValue(t);
    p.unweigh();
    return p;
  }


  // point interaction
  Point cp = null;
  double dx=0, dy=0;

  void mousePressed(int x, int y, int mb) {
    cp = null;
    for (Point p : controls) {
      if (p.near(x, y)) {
        cp = p;
        dx = p.x - x;
        dy = p.y - y;
      }
    }
    if (cp==null) {
      if (mb==LEFT) add(x, y);
      if (mb==RIGHT) toggleMode();
    }
  }

  void mouseReleased(int x, int y, int mb) {
    cp = null;
    dx = 0;
    dy = 0;
  }

  void mouseDragged(int x, int y, int mb) {
    if (cp!=null) {
      if (mb==LEFT) {
        cp.x = x + dx;
        cp.y = y + dy;
      }
    }
  }

  void mouseWheel(int x, int y, float scroll) {
    for (Point p : controls) {
      if (p.near(x, y)) {
        cp = p;
      }
    }
    if (cp!=null) {
      cp.setWeight(cp.w - scroll/(cp.w<1 ? 50 : 4));
      if (Math.abs(cp.w - 1)<0.001) cp.setWeight(1);
    }
  }
}

