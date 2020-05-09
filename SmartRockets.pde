Target target;
Boundary boundary;
Rocket[] rockets;
Obstacle[] obstacles;
int numRockets = 100;
int numObstacles = 30;
int lifespan = 600;
int counter;
int generation = 0;
double bestHighScore = 0;
ArrayList<Rocket> winners = new ArrayList<Rocket>();
boolean showOnlyWinners = false;
float velocityMultiplier = 0.2;
float velocityLimit = 10;

void setup() {
  size(600, 600);
  target = new Target(100, 100, 10);
  boundary = new Boundary(0, 0, width, height);
  rockets = new Rocket[numRockets];
  for (int i = 0; i < numRockets; i++) {
    rockets[i] = new Rocket(null);
  }
  obstacles = new Obstacle[numObstacles];
  int cnt = 0;
  while (cnt < numObstacles) {
    Obstacle ob = new Obstacle((int)random(0, width), (int)random(0, height * 2 / 3), (int)random(20, 70), (int)random (20, 70), random(PI));
    // This isn't perfect since if the obstacle fully encases the target, it doesn't register.
    if (!ob.impacts(target.pos.x, target.pos.y, target.r)) {
      obstacles[cnt] = ob;
      cnt++;
    }
  }
}

double evaluate() {
  double highScore = 0;
  for (int i = 0; i < numRockets; i++) {
    double dist = rockets[i].getDistance(target.pos);
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
      if (highScore > bestHighScore) {
        winners.add(winner);
        bestHighScore = highScore;
      }
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
  generation++;
}

void mutate(Rocket rocket) {
  for (int j = 0; j < lifespan; j++) {
    if (random(1) < .01) {
      rocket.dna.actions[j] = PVector.random2D().mult(velocityMultiplier);
    }
  }
}

void resetWinners() {  
    for (int i = 0; i < winners.size(); i++) {
      winners.set(i, new Rocket(winners.get(i).dna));
    }
}
void resetRockets() {  
    for (int i = 0; i < numRockets; i++) {
      rockets[i] = new Rocket(rockets[i].dna);
    }
}

void draw() {
  background(0); 
  target.show();

  boolean anyUpdated = false;
  if (!showOnlyWinners) {
    if (counter >= lifespan) {
      counter = 0;
      rebirth(evaluate());
    }
  
    for (int i = 0; i < numRockets; i++) {
      Rocket rocket = rockets[i];
      if (rocket.shouldUpdate()) {
        anyUpdated = true;
        rocket.applyDnaForce(counter);
        rocket.update(counter);
        rocket.checkForImpacts(obstacles, counter);
      }
      rocket.show();
    }

    textSize(16);
    fill(255);
    stroke(0);
    text("Generation: " + generation, 5, 16);
  } else {    
    if (counter >= lifespan) {
      counter = 0;
      resetWinners();
    }

    for (int i = 0; i < winners.size(); i++) {
      Rocket rocket = winners.get(i);
      if (rocket.shouldUpdate()) {
        anyUpdated = true;
        rocket.applyDnaForce(counter);
        rocket.update(counter);
        rocket.checkForImpacts(obstacles, counter);
      }
      rocket.show();
    }
  }

  for (int i = 0; i < numObstacles; i++) {
    obstacles[i].show();
  }

  counter++;
  if (!anyUpdated) {
    counter = lifespan;
  }

  if (!showOnlyWinners) {
    textSize(16);
    fill(255);
    stroke(0);
    text("Generation: " + generation, 5, 16);
  } else {
    textSize(16);
    fill(255);
    stroke(0);
    text("Showing Winners (" + generation + " generations, " + winners.size() + " winning rockets)", 5, 16);
  }
}

void keyPressed() {
  if (keyCode == 32) {
    counter = 0;
    showOnlyWinners = !showOnlyWinners;
    if (showOnlyWinners) {
      resetWinners();
    } else {      
      resetRockets();
    }
  }
}
