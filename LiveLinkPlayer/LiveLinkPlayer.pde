import VLCJVideo.*;
import hypermedia.net.*;


UDP udp;
final String IP = "localhost";
final int PORT = 50000;

VLCJVideo mov;
String[] options = {
  "--direct3d11-hw-blending"
  //, "--input-fast-seek"
  //, "--extraintf=http"
  //, "--http-password=1234"
};
float fps;
float time = 0;
//long timeMillis = 0;
float backTime = -1;
boolean isPlay = false;

int countFrame = 0;
int frame = 0;
PImage frameImages[] = null;
boolean hasCached = false;

void setup() {
  size(1280, 750, P2D);
  surface.setResizable(true);
  frameRate(120);
  background(0);
  mov = new VLCJVideo(this, options);
  udp = new UDP(this, PORT);
  udp.listen( true );
  selectInput("Select movie file:", "openFile");
  //surface.setSize(mov.width, mov.height+30);
}

void draw() {
  background(0);
  if (isPlay) {
    mov.play();
    image(mov, 0, 0);
  } else {
    if (frameImages != null) {
      if (frameImages[frame] != null) {
        // キャッシュがある場合はキャッシュから再生
        image(frameImages[frame], 0, 0);
      } else {
        // フレームの取得とキャッシュの作成
        mov.setTime((long)(time*1000));
        image(mov, 0, 0);
        mov.loadPixels();
        frameImages[frame] = createImage(mov.width, mov.height, mov.format);
        arrayCopy(mov.pixels, frameImages[frame].pixels);
        frameImages[frame].updatePixels();
      }

      // フレームキャッシュの確認
      int countCache = 0;
      for (int i=0; i<frameImages.length; i++) {
        if (frameImages[i]==null)
          continue;
        println("Frame "+i+" is cached");
        noStroke();
        fill(0, 240, 20);
        rect(width/(countFrame-1)*i, height, width/countFrame-2, -30);
        countCache++;
      }
      noStroke();
      fill(230, 220, 20);
      rect(width/countFrame*frame, height-2, 6, -26);
      if (countCache == countFrame) {
        println("All frame cached!");
        mov.setPause(true);
      }
      println();
    }
    backTime = time;
  }
}

void keyPressed() {
  isPlay = !isPlay;
}

void openFile(File selection) {
  String filePath = selection.getAbsolutePath();

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
    String regexp = ".*([0-9]|¥.){1,} fps[^=].*";
    if (str.matches(regexp))
      fps = float(match(match(str, "([0-9]|¥.){1,} fps[^=]")[0], "([0-9]|¥.){1,}")[0]);
    if (str.matches(".*frame=   [0-9]*.*"))
      countFrame = int(match(match(str, "frame=   [0-9]*")[0], "[0-9]{1,}")[0]);
  }
  println("\n"
    + fps + " fps\n"
    + countFrame + " frame"
    );

  // ファイルのロード
  mov.openAndPlay(filePath);
  mov.setRepeat(true);
  mov.setPause(false);

  // フレームキャッシュ用のオブジェクトを作成
  frameImages = new PImage[countFrame];
}

void receive( byte[] data, String ip, int port ) {
  String message = new String( data );
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
  time = float(message);
  frame = constrain(round(time * fps), 0, countFrame-1);
}
