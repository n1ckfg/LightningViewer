// Based on code by GeneKao (https://github.com/GeneKao)
import drop.*;

DropApplet child;
SDrop drop;
String url = "";
boolean urlUpdated = false;

void setupChild() {
  child = new DropApplet();
}

class DropApplet extends PApplet {
  
  //JFrame frame;
  int w = 400;
  int h = 400;
  int margin = 20;
  int strokeWeightVal = 4;
 
  public DropApplet() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h, JAVA2D);
  }
  
  public void setup() { 
    windowTitle("Drop Zone");
    drop = new SDrop(this);

    background(127);
    strokeWeight(strokeWeightVal);
    stroke(255);
    noFill();
    rectMode(CORNER);
    rect(0, 0, w - strokeWeightVal / 2, h - strokeWeightVal / 2);
    rect(margin, margin, w - margin * 2 - strokeWeightVal / 2, h - margin * 2 - strokeWeightVal / 2);
  }

  public void dropEvent(DropEvent theDropEvent) {
    url = "" + theDropEvent;
    urlUpdated = true;
    println("url: " + url);
  }

}
