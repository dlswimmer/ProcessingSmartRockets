public class Dna {
  public PVector[] actions = new PVector[lifespan];
  
  public Dna() {
    for (int i = 0; i < lifespan; i++) {
      actions[i] = PVector.random2D().mult(velocityMultiplier);
    }
  }
}
