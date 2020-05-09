public class Boundary {
  public float x1;
  public float x2;
  public float y1;
  public float y2;
  
  public Boundary(float x1, float y1, float x2, float y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
  }
  
  
  public boolean Impacts(PVector[] vectors) {
    return CollisionDetection.polyLine(vectors, x1, y1, x2, y1)
      || CollisionDetection.polyLine(vectors, x2, y1, x2, y2)
      || CollisionDetection.polyLine(vectors, x1, y2, x2, y2)
      || CollisionDetection.polyLine(vectors, x1, y1, x1, y2);
  }
}
