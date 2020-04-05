//public enum State {
//  READY, 
//    CACHEING
//}

class MovieManager {
  protected VLCJVideo2 mov;
  final protected String[] OPTIONS = {
    "--direct3d11-hw-blending"
    //"--gl=any"
    , "--rate=0.75"
    //, "--input-fast-seek"
    //, "--extraintf=http"
    //, "--http-password=1234"
  };
  protected boolean hasLoaded;
  protected float fps;
  //protected float time;
  protected int millis;
  protected int countFrame;
  protected int frame = 0;
  protected PImage frameImages[];
  protected boolean hasCached;
  //protected boolean isPlay;
  //long timeMillis = 0;
  //float backTime = -1;
  final private PImage DEFAULT_IMG = loadImage("D:/Pictures/FMS/ぽんだこ.png");

  private int backMillis = 0;

  MovieManager(PApplet parent) {
    mov = new VLCJVideo2(parent, this, OPTIONS);
    hasLoaded = false;
    fps = 1;
    //time = 0;
    millis = 0;
    countFrame = 0;
    frame = 0;
    frameImages = new PImage[0];
    hasCached = false;
    //isPlay = false;
  }

  public void loadMovie(String filePath) {
    // 動画の総フレーム数とFPSの検出
    StringList strOut = new StringList();
    StringList strErr = new StringList();
    String cmd = sketchPath("ffmpeg.exe -i \"") + filePath + "\" -map 0:v:0 -c copy -f null -";
    shell(strErr, strOut, cmd);
    println(cmd + "\n");
    for (String str : strErr.array()) {
      println(str);
    }
    for (String str : strOut.array()) {
      println(str);
      if (str.matches(".*([0-9]|\\.)+ fps[^=].*"))
        fps = float(match(match(str, "([0-9]|\\.)+ fps[^=]")[0], "([0-9]|\\.)+")[0]);
      if (str.matches(".*frame= *[0-9]+.*"))
        countFrame = int(match(match(str, "frame= *[0-9]+")[0], "[0-9]+")[0]);
    }
    println("\n"
      + fps + " fps\n"
      + countFrame + " frame"
      );

    // ファイルのロード
    mov.open(filePath);
    mov.setRepeat(true);
    mov.setPause(false);
    mov.setMute(true);
    mov.play();

    // フレームキャッシュ用のオブジェクトを作成
    frameImages = new PImage[countFrame];
    //for (PImage img : frameImages)
    //img = createImage(mov.width, mov.height, mov.format);

    hasLoaded = true;
    backMillis = millis();
  }

  //private void createCache() {
  //}

  public void setTimeSec(float sec) {
    setTimeMillis(floor(sec * 1000));
  }

  public void setTimeMillis(int milliSec) {
    millis = milliSec;
    frame = constrain(ceil(millis * 0.001 * fps), 0, countFrame-1);
    mov.setTime(millis);
  }

  public void setFrame(int frameNum) {
    frame = constrain(frameNum, 0, countFrame-1);
    millis = floor((frame * 1000.0) / fps);
    mov.setTime(millis);
  }

  public PImage getFrameImage() {
    if (hasLoaded == false)
      return DEFAULT_IMG;
    if (frameImages[frame]!=null)
      return frameImages[frame];
    //mov.setTime(millis);
    return mov;
  }

  public boolean hasLoaded() {
    return hasLoaded;
  }

  public float getFPS() {
    return fps;
  }

  public int getMillis() {
    return millis;
  }

  public int countFrame() {
    return countFrame;
  }

  public int getFrame() {
    return frame;
  }

  public void VLCJVideo2Event(VLCJVideo2 vVideo) {
    //setTimeMillis((int)vVideo.time());
    if (frameImages[frame] == null) {
      if (vVideo.time() != millis) {
        println("Syncing frame...");
        //setTimeMillis(millis);
        setFrame(frame);
        return;
      }
      println("Caching...");
      vVideo.loadPixels();
      frameImages[frame] = createImage(vVideo.width, vVideo.height, vVideo.format);
      arrayCopy(vVideo.pixels, frameImages[frame].pixels);
      frameImages[frame].updatePixels();
    }

    println("Frame "+frame+" is cached", millis() - backMillis);
    //if (frame<countFrame-1) {
    if (frame<min(200, countFrame-1)) {
      //if (millis() - backMillis < 2000 / fps) {
        setFrame(frame+1);
      //} else {
        //setFrame(min(frame-ceil(fps*1.1), 0));
      //}
      backMillis = millis();
      return;
    }
    println("All frame cached!");
    hasCached = true;
    vVideo.stop();
    //vVideo.dispose();
  }
}
