import peasy.PeasyCam;
import latkProcessing.*;

PeasyCam cam;
Latk latk;

void setup() {
  size(800, 600, P3D); 

  latk = new Latk(this, "latk_logo.latk");  
  latk.normalize();

  setupChild();
  
  cam = new PeasyCam(this, 300);
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/100.0, cameraZ*100.0);
}

void draw() {
  background(63);
   
  if (urlUpdated) {
    latk = new Latk(this, url);
    latk.normalize();
    urlUpdated = false;
  }
  
  latk.run();
  
  surface.setTitle(""+frameRate);
}
