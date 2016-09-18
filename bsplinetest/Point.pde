class Point {
  double x, y, w, t=-1;

  /**
   *
   */
  Point(Point other) {
    x = other.x;
    y = other.y;
    w = other.w;
  }
  /**
   *
   */
  Point(double _x, double _y) {
    this(_x, _y, 1);
  }
  /**
   *
   */
  Point(double _x, double _y, double _w) {
    x = _x;
    y = _y;
    w = _w;
  }
  /**
   *
   */
  void add(double dx, double dy) {
    x += dx;
    y += dy;
  }
  /**
   *
   */
  void interpolate(double a, Point prev) {
    x = a * x + (1-a) * prev.x;
    y = a * y + (1-a) * prev.y;
    w = a * w + (1-a) * prev.w;
  }
  /**
   *
   */
  void weigh(double _w) {
    w *= _w;
  }
  /**
   *
   */
  void unweigh() {
    x /= w;
    y /= w;
    w = 1;
  }
  /**
   *
   */
  void setWeight(double _w) {
    w = _w;
  }
  /**
   *
   */
  void setTValue(double _t) {
    t = _t;
  }
  /**
   *
   */
  public String toString() {
    return x+","+y+" (x"+w+")";
  }
  /**
   *
   */
  void draw() {
    draw(color(0));
  }
  /**
   *
   */
  void draw(color inner) {
    stroke(inner);
    fill(inner);
    ellipse(x, y, 3, 3);
  }
  /**
   *
   */
  void draw(color inner, color outer) {
    noStroke();
    fill(outer);
    ellipse(x, y, w*10, w*10);
    draw(inner);
  }
  /**
   *
   */
  void draw(color inner, color outer, String label) {
    draw(inner, outer);
    fill(0);
    text(label, x+10, y+5);
  }
  /**
   *
   */
  boolean near(int x, int y) {
    float d = dist(x, y, this.x, this.y);
    return d < 5;
  }
}

