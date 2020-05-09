// Credits to: http://www.jeffreythompson.org/collision-detection/table_of_contents.php

public static class CollisionDetection {


  // POLYGON/POLYGON
  public static boolean polyPoly(PVector[] p1, PVector[] p2) {

    // go through each of the vertices, plus the next
    // vertex in the list
    int next = 0;
    for (int current=0; current<p1.length; current++) {

      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current+1;  
      if (next == p1.length) next = 0;

      // get the PVectors at our current position
      // this makes our if statement a little cleaner
      PVector vc = p1[current];    // c for "current"
      PVector vn = p1[next];       // n for "next"

      // now we can use these two points (a line) to compare
      // to the other polygon's vertices using polyLine()
      boolean collision = polyLine(p2, vc.x, vc.y, vn.x, vn.y);
      if (collision) return true;

      // optional: check if the 2nd polygon is INSIDE the first
      collision = polyPoint(p1, p2[0].x, p2[0].y);
      if (collision) return true;
    }

    return false;
  }
  // POLYGON/LINE
  public static boolean polyLine(PVector[] vertices, float x1, float y1, float x2, float y2) {

    // go through each of the vertices, plus the next
    // vertex in the list
    int next = 0;
    for (int current=0; current<vertices.length; current++) {

      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current+1;
      if (next == vertices.length) next = 0;

      // get the PVectors at our current position
      // extract X/Y coordinates from each
      float x3 = vertices[current].x;
      float y3 = vertices[current].y;
      float x4 = vertices[next].x;
      float y4 = vertices[next].y;

      // do a Line/Line comparison
      // if true, return 'true' immediately and
      // stop testing (faster)
      boolean hit = lineLine(x1, y1, x2, y2, x3, y3, x4, y4);
      if (hit) {
        return true;
      }
    }

    // never got a hit
    return false;
  }

  // LINE/LINE
  public static boolean lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {

    // calculate the direction of the lines
    float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

    // if uA and uB are between 0-1, lines are colliding
    if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
      return true;
    }
    return false;
  }


  // POLYGON/POINT
  // used only to check if the second polygon is
  // INSIDE the first
  public static boolean polyPoint(PVector[] vertices, float px, float py) {
    boolean collision = false;

    // go through each of the vertices, plus the next
    // vertex in the list
    int next = 0;
    for (int current=0; current<vertices.length; current++) {

      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current+1;
      if (next == vertices.length) next = 0;

      // get the PVectors at our current position
      // this makes our if statement a little cleaner
      PVector vc = vertices[current];    // c for "current"
      PVector vn = vertices[next];       // n for "next"

      // compare position, flip 'collision' variable
      // back and forth
      if (((vc.y > py && vn.y < py) || (vc.y < py && vn.y > py)) &&
        (px < (vn.x-vc.x)*(py-vc.y) / (vn.y-vc.y)+vc.x)) {
        collision = !collision;
      }
    }
    return collision;
  }
  public static boolean polyCircle(PVector[] vertices, float cx, float cy, float r) {

    // go through each of the vertices, plus
    // the next vertex in the list
    int next = 0;
    for (int current=0; current<vertices.length; current++) {

      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current+1;
      if (next == vertices.length) next = 0;

      // get the PVectors at our current position
      // this makes our if statement a little cleaner
      PVector vc = vertices[current];    // c for "current"
      PVector vn = vertices[next];       // n for "next"

      // check for collision between the circle and
      // a line formed between the two vertices
      boolean collision = lineCircle(vc.x, vc.y, vn.x, vn.y, cx, cy, r);
      if (collision) return true;
    }

    // the above algorithm only checks if the circle
    // is touching the edges of the polygon – in most
    // cases this is enough, but you can un-comment the
    // following code to also test if the center of the
    // circle is inside the polygon

    // boolean centerInside = polygonPoint(vertices, cx,cy);
    // if (centerInside) return true;

    // otherwise, after all that, return false
    return false;
  }


  // LINE/CIRCLE
  public static boolean lineCircle(float x1, float y1, float x2, float y2, float cx, float cy, float r) {

    // is either end INSIDE the circle?
    // if so, return true immediately
    boolean inside1 = pointCircle(x1, y1, cx, cy, r);
    boolean inside2 = pointCircle(x2, y2, cx, cy, r);
    if (inside1 || inside2) return true;

    // get length of the line
    float distX = x1 - x2;
    float distY = y1 - y2;
    float len = sqrt( (distX*distX) + (distY*distY) );

    // get dot product of the line and circle
    float dot = ( ((cx-x1)*(x2-x1)) + ((cy-y1)*(y2-y1)) ) / pow(len, 2);

    // find the closest point on the line
    float closestX = x1 + (dot * (x2-x1));
    float closestY = y1 + (dot * (y2-y1));

    // is this point actually on the line segment?
    // if so keep going, but if not, return false
    boolean onSegment = linePoint(x1, y1, x2, y2, closestX, closestY);
    if (!onSegment) return false;

    // get distance to closest point
    distX = closestX - cx;
    distY = closestY - cy;
    float distance = sqrt( (distX*distX) + (distY*distY) );

    // is the circle on the line?
    if (distance <= r) {
      return true;
    }
    return false;
  }


  // LINE/POINT
  public static boolean linePoint(float x1, float y1, float x2, float y2, float px, float py) {

    // get distance from the point to the two ends of the line
    float d1 = dist(px, py, x1, y1);
    float d2 = dist(px, py, x2, y2);

    // get the length of the line
    float lineLen = dist(x1, y1, x2, y2);

    // since floats are so minutely accurate, add
    // a little buffer zone that will give collision
    float buffer = 0.1;    // higher # = less accurate

    // if the two distances are equal to the line's
    // length, the point is on the line!
    // note we use the buffer here to give a range, rather
    // than one #
    if (d1+d2 >= lineLen-buffer && d1+d2 <= lineLen+buffer) {
      return true;
    }
    return false;
  }

  // POINT/CIRCLE
  public static boolean pointCircle(float px, float py, float cx, float cy, float r) {

    // get distance between the point and circle's center
    // using the Pythagorean Theorem
    float distX = px - cx;
    float distY = py - cy;
    float distance = sqrt( (distX*distX) + (distY*distY) );

    // if the distance is less than the circle's 
    // radius the point is inside!
    if (distance <= r) {
      return true;
    }
    return false;
  }
}
