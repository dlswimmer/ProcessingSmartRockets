public class Obstacle {
  public PVector pos;
  public int w;
  public int h;
  public float rot;

  public Obstacle(int x, int y, int w, int h, float rotation) {
    this.pos = new PVector(x, y);
    this.w = w;
    this.h = h;
    this.rot = rotation;
  }
  
  
  public PVector[] getVectors() {
    PVector[] result = new PVector[4];
    result[0] = new PVector(this.w/2, -this.h/2).rotate(this.rot).add(this.pos);
    result[1] = new PVector(this.w/2, this.h/2).rotate(this.rot).add(this.pos);
    result[2] = new PVector(-this.w/2, this.h/2).rotate(this.rot).add(this.pos);
    result[3] = new PVector(-this.w/2, -this.h/2).rotate(this.rot).add(this.pos);
    
    return result;
  }

  public boolean impacts(PVector[] vectors) {
    return CollisionDetection.polyPoly(getVectors(), vectors);
  }

  public boolean impacts(float x, float y, float r) {
    return CollisionDetection.polyCircle(getVectors(), x, y, r);
  }

  public void show() {
    noStroke();
    fill(128);
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rectMode(CENTER);
    rotate(this.rot);
    rect(0, 0, w, h);
    popMatrix();
  }
}
