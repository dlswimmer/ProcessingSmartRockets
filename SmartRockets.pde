Target target;
Rocket[] rockets;
Obstacle[] obstacles;
int numRockets = 100;
int numObstacles = 30;
int lifespan = 800;
int counter;

void setup() {
  size(600, 600);
  target = new Target(100, 100, 15);
  rockets = new Rocket[numRockets];
  for (int i = 0; i < numRockets; i++) {
    rockets[i] = new Rocket(null);
  }
  obstacles = new Obstacle[numObstacles];
  int cnt = 0;
  while (cnt < numObstacles) {
    Obstacle ob = new Obstacle((int)random(0, width), (int)random(0, height * 2 / 3), (int)random(20, 70), (int)random (20, 70), random(PI));
    if (!ob.Impacts(target.pos.x, target.pos.y, target.r)) {
       obstacles[cnt] = ob;
       cnt++;
    }
  }
}

double evaluate() {
  double highScore = 0;
  for (int i = 0; i < numRockets; i++) {
    double dist = rockets[i].GetDistance(target.pos);
    rockets[i].distance = dist;
    double score = (1.0 / dist) * lifespan * 10;
    if (rockets[i].crashedOn < 0) {
      score += lifespan / 10.0;
    } else {
      score += rockets[i].crashedOn / 10.0;
    }
    if (rockets[i].completedOn >= 0) {
      score += (1.0 / rockets[i].completedOn) * lifespan * 1000;
    }
    rockets[i].score = score;
    if (score > highScore) {
      highScore = score;
    }
  } 
  return highScore;
}

void rebirth(double highScore) {
  ArrayList<Rocket> pool = new ArrayList<Rocket>();
  Rocket winner = null;
  for (int i = 0; i < numRockets; i++) {
    if (rockets[i].score == highScore && winner == null) {
      winner = rockets[i];
    }
    double poolCount = (rockets[i].score / highScore) * 50;
    for (int j = 0; j < poolCount; j++) {
      pool.add(rockets[i]);
    }
  }
  
  int deviants = (int)(numRockets * 0.05);

  for (int i = 0; i < numRockets - 1 - deviants; i++) {
    Rocket parentA = pool.get((int)random(0, pool.size()));
    Rocket parentB = pool.get((int)random(0, pool.size()));

    Dna childDna = new Dna();
    float midPoint = random(0, lifespan/2);
    for (int j = 0; j < lifespan; j++) {
      if (j <= midPoint) {
        childDna.actions[j] = parentA.dna.actions[j];
      } else {
        childDna.actions[j] = parentB.dna.actions[j];
      }
    }
    rockets[i] = new Rocket(childDna);
    mutate(rockets[i]);
  }
  
  for (int i = 0; i < deviants; i++) {
    rockets[i+numRockets-1-deviants] = new Rocket(null);
  }
  rockets[numRockets - 1] = new Rocket(winner.dna);
  
  print((int)highScore);
  println(" (distance: " + (int)winner.distance + " completed on: " + winner.completedOn + ", crashed on: " + winner.crashedOn + ")");
}

void mutate(Rocket rocket) {
    for (int j = 0; j < lifespan; j++) {
      if (random(1) < .01) {
        rocket.dna.actions[j] = PVector.random2D().mult(0.1);
      }
    }
}

void draw() {
  background(0); 
  target.Show();

  if (counter >= lifespan) {
    counter = 0;
    rebirth(evaluate());
  }

  boolean anyUpdated = false;
  for (int i = 0; i < numRockets; i++) {
    if (rockets[i].ShouldUpdate()) {
      anyUpdated = true;
      rockets[i].ApplyDnaForce(counter);
      rockets[i].Update(counter);
      rockets[i].CheckForImpacts(obstacles, counter);
    }
    rockets[i].Show();
  }


  for (int i = 0; i < numObstacles; i++) {
    obstacles[i].Show();
  }

  counter++;
  if (!anyUpdated) {
    counter = lifespan;
  }
}
