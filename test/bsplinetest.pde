BSpline spline;
int splineOrder = 4;

/**
 *
 */
void setup() {
  size(500, 500);
  noLoop();
  textAlign(CENTER);
  reset();
}

/**
 *
 */
void reset() {
  spline = new BSpline(splineOrder, BSpline.UNIFORM);
  float rotx, roty, a;
  int i, m=5, r = min(width, height)/3, mx = width/2, my = height/2;
  for (i=0; i<=m; i++) {
    a = map(i, 0, m, 0, TAU-1);
    rotx = mx + round(r * cos(a));
    roty = my + round(r * sin(a));
    spline.add(rotx, roty);
  }
}

/**
 *
 */
void draw() {
  clear();

  // graph paper
  background(245, 245, 250);
  stroke(255);
  for (int x=0; x<=width; x+=15) {
    line(x, 0, x, height);
  }
  for (int y=0; y<=height; y+=15) {
    line(0, y, width, y);
  }

  // the spline curve
  spline.draw();

  // the spline hull
  stroke(200);
  Point f = spline.controls.get(0), c;
  for (int p=1; p<spline.controls.size(); p++) {
    c = spline.controls.get(p);
    line(f.x, f.y, c.x, c.y);
    f = c;
  }
  if (spline.closed) {
    c = spline.controls.get(0);
    line(f.x, f.y, c.x, c.y);
  }

  textFont(createFont("Meiryo", 12));
  color inner = color(0, 105, 250);
  color outer = color(80, 165, 210, 100);
  for (int p=0; p<spline.controls.size(); p++) {
    spline.controls.get(p).draw(inner, outer, ""+(p+1));
  }

  fill(0);
  textFont(createFont("Meiryo", 20));
  String txt = "";
  txt += (spline.closed ? "Closed " : "");
  txt += (spline.isRational() ? "Rational " : "");
  txt += (spline.mode==BSpline.UNIFORM || spline.closed? "Uniform " : "Open-uniform ");
  switch(splineOrder) {
    case(2):
    txt+="Linear ";
    break;
    case(3):
    txt+="Quadratic ";
    break;
    case(4):
    txt+="Cubic ";
    break;
  default:
    txt+=splineOrder +"th Order ";
    break;
  }
  txt += "B-spline test";
  text(txt, width/2, 25);

  Double[] knots = {};
  knots = spline.getKnotVector().toArray(knots);
  String[] knotstrings = new String[knots.length];
  for (int i=0; i<knots.length; i++) {
    String v = "" + knots[i].doubleValue();
    int p = v.indexOf('.') + 3;
    p = Math.min(p, v.length());
    v = v.substring(0, p);
    knotstrings[i] = v;
  }

  Double[] nodes = {};
  nodes = getNodeVector(spline.order, spline.getKnotVector(), spline.controls).toArray(nodes);
  String[] nodestrings = new String[nodes.length];
  for (int i=0; i<nodes.length; i++) {
    String v = "" + nodes[i].doubleValue();
    int p = v.indexOf('.') + 3;
    p = Math.min(p, v.length());
    v = v.substring(0, p);
    nodestrings[i] = v;
  }

  textFont(createFont("Courier", 14));
  text("knot vector: " + join(knotstrings, ','), width/2, height-25);
//  text("node vector: " + join(nodestrings, ','), width/2, height-9);
}

/**
 *
 */
void mousePressed() {
  spline.mousePressed(mouseX, mouseY, mouseButton);
  redraw();
}

/**
 *
 */
void mouseReleased() {
  spline.mouseReleased(mouseX, mouseY, mouseButton);
  redraw();
}

/**
 *
 */
void mouseDragged() {
  spline.mouseDragged(mouseX, mouseY, mouseButton);
  redraw();
}

/**
 *
 */
void mouseWheel(MouseEvent e) {
  spline.mouseWheel(mouseX, mouseY, e.getCount());
  redraw();
}

/**
 *
 */
void keyPressed() {
  if (keyCode==38) {
    splineOrder++;
    reset();
  }
  if (keyCode==40 && splineOrder>2) {
    splineOrder--;
    reset();
  }
  if (key=='r') {
    reset();
  }
  if (key==' ') {
    spline.toggleOpen();
  }
  redraw();
}

