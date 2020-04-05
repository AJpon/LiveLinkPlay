import hypermedia.net.*;


UDP udp;
final String IP = "localhost";
final int PORT = 50000;

//VLCJVideo mov;

MovieManager movMgr;


void setup() {
  size(1280, 750, P2D);
  surface.setResizable(true);
  frameRate(120);
  background(0);
  udp = new UDP(this, PORT);
  udp.listen( true );
  movMgr = new MovieManager(this);
  selectInput("Select movie file:", "openFile");
  //surface.setSize(mov.width, mov.height+30);
}

void draw() {
  background(0);
  if (movMgr.hasLoaded() && movMgr.hasCached) {
    image(movMgr.getFrameImage(), 0, 0);

    int countFrame = movMgr.countFrame();
    // フレームキャッシュの確認
    for (int i=0; i<countFrame; i++) {
      noStroke();
      fill(0, 240, 20);
      rect(2+width/max((countFrame-1), 1)*i, height, width/countFrame-2, -30);
    }
    noStroke();
    fill(230, 20, 220);
    rect(width/countFrame*movMgr.getFrame(), height-2, 2, -26);
  }
}


void openFile(File selection) {
  String filePath = selection.getAbsolutePath();
  movMgr.loadMovie(filePath);
}

void receive( byte[] data, String ip, int port ) {
  String message = new String( data );
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
  if (movMgr.hasLoaded() && movMgr.hasCached) {
    movMgr.setTimeSec(float(message));
  }
}
