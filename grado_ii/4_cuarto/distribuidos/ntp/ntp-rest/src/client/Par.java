package client;

public class Par implements Comparable<Par> {
  private double offset;
  private double delay;

  public Par() {
    super();
  }

  public Par(double offset, double delay) {
    this.offset = offset;
    this.delay = delay;
  }

  public double getDelay() {
    return delay;
  }

  public double getOffset() {
    return offset;
  }

  public void setDelay(double delay) {
    this.delay = delay;
  }

  public void setOffset(double offset) {
    this.offset = offset;
  }

  @Override
  public int compareTo(Par par) {
    int res = Double.compare(this.offset, par.offset);
    if (res == 0) {
      res = -Double.compare(this.delay, this.delay);
    }

    return res;
  }
}
