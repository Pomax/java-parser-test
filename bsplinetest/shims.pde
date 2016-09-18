// Retarded shims for float-only API functions

void point(double a, double b) { 
  point((float)a, (float)b);
}
void line(double a, double b, double c, double d) { 
  line((float)a, (float)b, (float)c, (float)d);
}
void ellipse(double a, double b, double c, double d) { 
  ellipse((float)a, (float)b, (float)c, (float)d);
}
float dist(double a, double b, double c, double d) { 
  return dist((float)a, (float)b, (float)c, (float)d);
}
void text(String s, double a, double b) { 
  text(s, (float)a, (float)b);
}