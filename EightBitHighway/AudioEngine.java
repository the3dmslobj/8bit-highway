import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.SourceDataLine;

class AudioEngine {
  final float SAMPLE_RATE = 22050;
  volatile boolean muted = false;
  volatile boolean musicActive = false;
  volatile boolean available = true;

  int[] melody = {
    220, 277, 330, 277, 392, 330, 277, 220,
    247, 294, 370, 294, 440, 370, 294, 247
  };
  int[] melodyDurations = {
    150, 150, 150, 150, 220, 120, 150, 220,
    150, 150, 150, 150, 220, 120, 150, 220
  };

  void startMusic() {
    Thread musicThread = new Thread(new Runnable() {
      public void run() {
        runMusicLoop();
      }
    });
    musicThread.setDaemon(true);
    musicThread.start();
  }

  void setMusicActive(boolean active) {
    musicActive = active;
  }

  void toggleMute() {
    muted = !muted;
  }

  void playMove() {
    playSequence(new int[] { 220, 330 }, new int[] { 45, 55 }, 0.18);
  }

  void playCoin() {
    playSequence(new int[] { 660, 880, 1320 }, new int[] { 55, 55, 85 }, 0.20);
  }

  void playCrash() {
    if (!available || muted) {
      return;
    }

    Thread effectThread = new Thread(new Runnable() {
      public void run() {
        playNoise(230, 0.34);
        playTone(80, 170, 0.28);
      }
    });
    effectThread.setDaemon(true);
    effectThread.start();
  }

  void playSelect() {
    playSequence(new int[] { 440, 660 }, new int[] { 50, 70 }, 0.14);
  }

  void runMusicLoop() {
    while (true) {
      if (!available || muted || !musicActive) {
        sleepFor(80);
        continue;
      }

      for (int i = 0; i < melody.length; i++) {
        if (muted || !musicActive) {
          break;
        }
        playTone(melody[i], melodyDurations[i], 0.09);
        sleepFor(25);
      }
    }
  }

  void playSequence(final int[] notes, final int[] durations, final double volume) {
    if (!available || muted) {
      return;
    }

    Thread effectThread = new Thread(new Runnable() {
      public void run() {
        for (int i = 0; i < notes.length; i++) {
          if (muted) {
            return;
          }
          playTone(notes[i], durations[i], volume);
        }
      }
    });
    effectThread.setDaemon(true);
    effectThread.start();
  }

  synchronized void playTone(int frequency, int durationMs, double volume) {
    SourceDataLine audioLine = null;

    try {
      AudioFormat format = new AudioFormat(SAMPLE_RATE, 8, 1, true, false);
      DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
      audioLine = (SourceDataLine)AudioSystem.getLine(info);
      audioLine.open(format);
      audioLine.start();

      int sampleCount = (int)(SAMPLE_RATE * durationMs / 1000.0);
      byte[] samples = new byte[sampleCount];

      for (int i = 0; i < sampleCount; i++) {
        double progress = i / (double)sampleCount;
        double wave = Math.sin(Math.PI * 2 * frequency * i / SAMPLE_RATE) >= 0 ? 1 : -1;
        double envelope = Math.min(1, Math.min(progress * 18, (1 - progress) * 18));
        samples[i] = (byte)(wave * 127 * volume * envelope);
      }

      audioLine.write(samples, 0, samples.length);
      audioLine.drain();
    } catch (Exception e) {
      available = false;
    } finally {
      if (audioLine != null) {
        audioLine.close();
      }
    }
  }

  synchronized void playNoise(int durationMs, double volume) {
    SourceDataLine audioLine = null;

    try {
      AudioFormat format = new AudioFormat(SAMPLE_RATE, 8, 1, true, false);
      DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
      audioLine = (SourceDataLine)AudioSystem.getLine(info);
      audioLine.open(format);
      audioLine.start();

      int sampleCount = (int)(SAMPLE_RATE * durationMs / 1000.0);
      byte[] samples = new byte[sampleCount];

      for (int i = 0; i < sampleCount; i++) {
        double progress = i / (double)sampleCount;
        double envelope = Math.min(1, Math.min(progress * 10, (1 - progress) * 6));
        double wave = Math.random() * 2 - 1;
        samples[i] = (byte)(wave * 127 * volume * envelope);
      }

      audioLine.write(samples, 0, samples.length);
      audioLine.drain();
    } catch (Exception e) {
      available = false;
    } finally {
      if (audioLine != null) {
        audioLine.close();
      }
    }
  }

  void sleepFor(int millis) {
    try {
      Thread.sleep(millis);
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
    }
  }
}
