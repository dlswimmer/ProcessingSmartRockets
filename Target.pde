public class Target {
  public PVector pos;
  public float r;
  
  public Target(int x, int y, float r) {
    this.pos = new PVector(x, y);
    this.r = r;
  }
  
  public void Show() {
    noStroke();
    fill(128, 255, 128);
    ellipseMode(CENTER);
    ellipse(this.pos.x, this.pos.y, this.r, this.r);
  }
}
