public class Rocket {
  public int h = 15;
  public int w = 5;
  public int x = width / 2;
  public int y = height - h;
  public PVector pos = new PVector(x, y);
  public PVector vel = new PVector(0, 0);
  public PVector acc = new PVector(0, 0);
  public Dna dna;
  public int crashedOn = -1;
  public int completedOn = -1;
  public double score = 0;
  public double distance = -1;
  //private ArrayList<PVector> trails = new ArrayList<PVector>();

  public Rocket(Dna seedDna) {
    if (seedDna == null) {      
      dna = new Dna();
    } else {
      dna = seedDna;
    }
  }

  public void applyForce(PVector force) {
    this.acc.add(force);
  }  

  public void applyDnaForce(int dnaIndex) {
    this.applyForce(this.dna.actions[dnaIndex]);
  }

  public double getDistance(PVector tar) {
    return this.completedOn > 0 ? 1 : tar.dist(this.pos);
  }

  public PVector[] getVectors() {    
    PVector[] result = new PVector[3];
    float heading = this.vel.heading();
    result[0] = new PVector(-this.w/2, -this.h/2).rotate(heading - PI / 2).add(this.pos);
    result[1] = new PVector(0, this.h/2).rotate(heading - PI / 2).add(this.pos);
    result[2] = new PVector(this.w/2, -this.h/2).rotate(heading - PI / 2).add(this.pos);

    return result;
  }

  public void checkForImpacts(Obstacle[] obstacles, int counter) {
    for (int i = 0; i < obstacles.length; i++) {
      if (obstacles[i].impacts(this.getVectors())) {
        this.crashedOn = counter;
        return;
      }
    }
  }

  public boolean shouldUpdate() {
    return this.crashedOn < 0 && this.completedOn < 0;
  }
  
  
  private boolean atTarget() {
    return CollisionDetection.polyCircle(getVectors(), target.pos.x, target.pos.y, target.r);
  }

  public void update(int counter) {
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
    this.vel.limit(velocityLimit);
    //this.trails.add(new PVector(this.pos.x, this.pos.y));
    //if (this.trails.size() > 80) {
    //  this.trails.remove(0);
    //}

    if (boundary.impacts(getVectors())) {
      this.crashedOn = counter;
    }

    if (atTarget()) {
      this.completedOn = counter;
    }
  }

  public void show() {
    noStroke();
    fill(255);
    PVector[] vectors = getVectors();
    beginShape();
    for (int i = 0; i < vectors.length; i++) {
      vertex(vectors[i].x, vectors[i].y);
    }
    endShape(CLOSE);
    
    stroke(128, 128, 255, 50);
    strokeWeight(1);
    
    //for (int i = 0; i < this.trails.size(); i++) {
    //  point(trails.get(i).x, trails.get(i).y);
    //}
  }
}
