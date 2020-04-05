import VLCJVideo.*;

//import uk.co.caprica.vlcj.factory.MediaPlayerFactory;
import uk.co.caprica.vlcj.player.base.MediaPlayer;
//import uk.co.caprica.vlcj.player.embedded.EmbeddedMediaPlayer;
import uk.co.caprica.vlcj.player.embedded.videosurface.callback.BufferFormat;
import uk.co.caprica.vlcj.player.embedded.videosurface.callback.BufferFormatCallback;
import uk.co.caprica.vlcj.player.embedded.videosurface.callback.RenderCallback;
import uk.co.caprica.vlcj.player.embedded.videosurface.callback.format.RV32BufferFormat;

import java.nio.ByteBuffer;
import java.nio.IntBuffer;
//import java.util.Iterator;
import java.lang.reflect.*;

class VLCJVideo2 extends VLCJVideo {
  protected Object eventHandler;
  protected Method VLCJVideo2EventMethod;

  private final class TestBufferFormatCallback implements BufferFormatCallback {

    @Override
      public BufferFormat getBufferFormat(int sourceWidth, int sourceHeight) {
      if (firstFrame) {
        firstFrame = false;
        init(sourceWidth, sourceHeight, parent.ARGB);
        rgbBuffer = new int[sourceWidth * sourceHeight];
      }
      return new RV32BufferFormat(sourceWidth, sourceHeight);
    }
  }

  //private void handleEvent(MediaPlayerEventType type) {
  //  if (handlers.containsKey(type)) {
  //    ArrayList<Runnable> eventHandlers = handlers.get(type);
  //    Iterator<Runnable> it = eventHandlers.iterator();
  //    while (it.hasNext()) {
  //      it.next().run();
  //    }
  //  }
  //}

  private final class TestRenderCallback implements RenderCallback {

    @Override
      public void display(MediaPlayer mediaPlayer, ByteBuffer[] nativeBuffers, BufferFormat bufferFormat) {
      ByteBuffer bb = nativeBuffers[0];
      IntBuffer ib = bb.asIntBuffer();
      ib.get(rgbBuffer);
      pixels = rgbBuffer;
      updatePixels();
      try {
        if (isPlaying()) 
          fireVLCJVideo2Event();
      } 
      catch (Exception e) {
        e.printStackTrace();
      }
    }
  }

  public VLCJVideo2(PApplet parent, Object obj, String... options) {
    super(parent, options);
    setEventHandlerObject(obj);
    mediaPlayer.videoSurface().set(factory.videoSurfaces().newVideoSurface(new TestBufferFormatCallback(), new TestRenderCallback(), true));
  }

  public VLCJVideo2(PApplet parent, String... options) {
    super(parent, options);
    setEventHandlerObject(parent);
    mediaPlayer.videoSurface().set(factory.videoSurfaces().newVideoSurface(new TestBufferFormatCallback(), new TestRenderCallback(), true));
  }

  protected void setEventHandlerObject(Object obj) {
    eventHandler = obj;

    try {
      VLCJVideo2EventMethod = eventHandler.getClass().getMethod("VLCJVideo2Event", VLCJVideo2.class);
      return;
    } 
    catch (Exception e) {
      // no such method, or an error... which is fine, just ignore
    }

    // VLCJVideo2EventMethod can alternatively be defined as receiving an Object, to allow
    // Processing mode implementors to support the video library without linking
    // to it at build-time.
    try {
      VLCJVideo2EventMethod = eventHandler.getClass().getMethod("VLCJVideo2Event", Object.class);
    } 
    catch (Exception e) {
      // no such method, or an error... which is fine, just ignore
    }
  }

  private void fireVLCJVideo2Event() {
    if (VLCJVideo2EventMethod != null) {
      try {
        VLCJVideo2EventMethod.invoke(eventHandler, this);
      } 
      catch (Exception e) {
        System.err.println("error, disabling VLCJVideo2Event() for " + filename);
        e.printStackTrace();
        VLCJVideo2EventMethod = null;
      }
    }
  }
}
