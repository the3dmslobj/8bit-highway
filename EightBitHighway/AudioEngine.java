import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.SourceDataLine;

class AudioEngine {
  final float SAMPLE_RATE = 22050;
  final int BUFFER_SIZE = 256;

  volatile boolean muted = false;
  volatile boolean musicActive = false;
  volatile boolean available = true;
  volatile SoundSequence effect = null;

  int[] melody = {
    220, 277, 330, 277, 392, 330, 277, 220,
    247, 294, 370, 294, 440, 370, 294, 247
  };
  int[] melodyDurations = {
    150, 150, 150, 150, 220, 120, 150, 220,
    150, 150, 150, 150, 220, 120, 150, 220
  };
  boolean musicRest = false;

  int musicIndex = 0;
  int musicSamplesLeft = 0;
  int musicSamplesTotal = 1;
  double musicPhase = 0;

  void startMusic() {
    Thread audioThread = new Thread(new Runnable() {
      public void run() {
        runAudioLoop();
      }
    });
    audioThread.setDaemon(true);
    audioThread.start();
  }

  void setMusicActive(boolean active) {
    musicActive = active;
    if (!active) {
      musicSamplesLeft = 0;
      musicPhase = 0;
    }
  }

  void toggleMute() {
    muted = !muted;
    if (muted) {
      effect = null;
    }
  }

  void playMove() {
    triggerEffect(new int[] { 220, 330 }, new int[] { 45, 55 }, 0.18, false);
  }

  void playCoin() {
    triggerEffect(new int[] { 660, 880, 1320 }, new int[] { 55, 55, 85 }, 0.20, false);
  }

  void playCrash() {
    triggerEffect(new int[] { 120, 85 }, new int[] { 190, 170 }, 0.34, true);
  }

  void playSelect() {
    triggerEffect(new int[] { 440, 660 }, new int[] { 50, 70 }, 0.14, false);
  }

  void triggerEffect(int[] notes, int[] durations, double volume, boolean noise) {
    if (!available || muted) {
      return;
    }
    effect = new SoundSequence(notes, durations, volume, noise);
  }

  void runAudioLoop() {
    SourceDataLine audioLine = null;

    try {
      AudioFormat format = new AudioFormat(SAMPLE_RATE, 8, 1, true, false);
      DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
      audioLine = (SourceDataLine)AudioSystem.getLine(info);
      audioLine.open(format, BUFFER_SIZE * 4);
      audioLine.start();

      byte[] buffer = new byte[BUFFER_SIZE];
      while (true) {
        fillBuffer(buffer);
        audioLine.write(buffer, 0, buffer.length);
      }
    } catch (Exception e) {
      available = false;
    } finally {
      if (audioLine != null) {
        audioLine.close();
      }
    }
  }

  void fillBuffer(byte[] buffer) {
    for (int i = 0; i < buffer.length; i++) {
      double mixed = 0;

      if (!muted) {
        mixed += nextMusicSample();
        mixed += nextEffectSample();
      }

      mixed = Math.max(-1, Math.min(1, mixed));
      buffer[i] = (byte)(mixed * 127);
    }
  }

  double nextMusicSample() {
    if (!musicActive) {
      return 0;
    }

    if (musicSamplesLeft <= 0) {
      musicRest = !musicRest;
      musicSamplesTotal = samplesFromMillis(musicRest ? 70 : melodyDurations[musicIndex]);
      musicSamplesLeft = musicSamplesTotal;
      if (!musicRest) {
        musicIndex = (musicIndex + 1) % melody.length;
      }
    }

    if (musicRest) {
      musicSamplesLeft--;
      return 0;
    }

    int noteIndex = (musicIndex + melody.length - 1) % melody.length;
    int frequency = melody[noteIndex];
    double progress = 1 - musicSamplesLeft / (double)musicSamplesTotal;
    double envelope = Math.min(1, Math.min(progress * 16, (1 - progress) * 16));
    double sample = squareWave(musicPhase) * 0.035 * envelope;

    musicPhase = advancePhase(musicPhase, frequency);
    musicSamplesLeft--;
    return sample;
  }

  double nextEffectSample() {
    SoundSequence current = effect;
    if (current == null) {
      return 0;
    }

    double sample = current.nextSample();
    if (current.done) {
      effect = null;
    }
    return sample;
  }

  int samplesFromMillis(int millis) {
    return Math.max(1, (int)(SAMPLE_RATE * millis / 1000.0));
  }

  double squareWave(double phase) {
    return phase < 0.5 ? 1 : -1;
  }

  double advancePhase(double phase, int frequency) {
    phase += frequency / (double)SAMPLE_RATE;
    while (phase >= 1) {
      phase -= 1;
    }
    return phase;
  }

  class SoundSequence {
    int[] notes;
    int[] durations;
    double volume;
    boolean noise;
    boolean done = false;

    int index = -1;
    int samplesLeft = 0;
    int samplesTotal = 1;
    double phase = 0;

    SoundSequence(int[] startNotes, int[] startDurations, double startVolume, boolean startNoise) {
      notes = startNotes;
      durations = startDurations;
      volume = startVolume;
      noise = startNoise;
      advanceNote();
    }

    double nextSample() {
      if (done) {
        return 0;
      }

      if (samplesLeft <= 0) {
        advanceNote();
        if (done) {
          return 0;
        }
      }

      double progress = 1 - samplesLeft / (double)samplesTotal;
      double envelope = Math.min(1, Math.min(progress * 18, (1 - progress) * 12));
      double sample;

      if (noise) {
        sample = (Math.random() * 2 - 1) * volume * envelope;
      } else {
        sample = squareWave(phase) * volume * envelope;
        phase = advancePhase(phase, notes[index]);
      }

      samplesLeft--;
      return sample;
    }

    void advanceNote() {
      index++;
      if (index >= notes.length) {
        done = true;
        return;
      }

      samplesTotal = samplesFromMillis(durations[index]);
      samplesLeft = samplesTotal;
      phase = 0;
    }
  }
}
