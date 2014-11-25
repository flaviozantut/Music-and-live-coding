# Daniele Filaretti - "first sonic pi tune" :)  

# INTRUCTIONS:
#   Uncomment the line below and update it with the path 
#   to the "samples" folder on your system!

# use_sample_pack "YOUR-LOCATION/Music-and-live-coding/first-tune/samples"

bpm = 130.0
beat = 60 / bpm
pulse = beat / 4
bar = beat * 4

# noise

define :noise do
  with_fx :reverb, mix: 0.1 do
    use_synth [:gnoise,:beep].choose
    play [:d6,:f6,:a6].choose, amp: rrand(0.01,0.02), release: 0.06, pan: rrand(-1,1)
    sleep pulse
  end
end

# synth1

define :synth1 do
  with_fx :reverb, mix: 0.2 do
    use_synth [:beep,:supersaw,:zawa].choose
    n = play [:d3].choose, amp: 0.03, sustain: bar, release: 0, note_slide: [beat,bar].choose
    control n, note: :d6
    4.times do
      control n, note: [:d3,:d5,:d6,:d7,:f6].choose
      sleep beat
    end
  end
end

# synth

define :synth2 do
  with_fx :reverb, mix: 0.4, room: 0.9 do
    with_fx :distortion do
      use_synth :beep
      play [:d7].choose, release: [0.1].choose, amp: 0.01
      sleep pulse * 30
      use_synth :tb303
      play [:d3].choose, release: pulse,
        attack: [0.0, 0.2].choose,
        amp: [0.03,0.0].choose,
        cutoff: rrand(40,100),
        res: 0.05
      sleep pulse * 2
    end
  end
end

# hats

define :hats do
  2.times do
    sample :hat_1, amp: 0.1, attack: 0.02, rate: 1.1
    sleep pulse
  end
  sample :hat_2, amp: 0.15, attack: 0.01, rate: 1
  2.times do
    sample :hat_1, amp: 0.1, attack: 0.02, rate: 1.1
    sleep pulse
  end
end

# kick

define :kick do
  sample :kick_1, rate: 1.1, amp: 0.7
  sample :fx_1, rate: -2, amp: 0.1
  sleep pulse
  3.times do
    sample :kick_1, rate: 2.2, amp: 0.02
    sample :click_1, rate: 1, amp: rrand(0.1,0.15), pan: rrand(-0.1,0.1)
    sleep pulse
  end
end

# clap

define :clap do
  sleep beat
  sample :clap_1, amp: 0.2, attack: 0.01, rate: 0.9
  sleep beat
end

# bass

define :bass do
  sleep pulse * 2
  play :d2, amp: 0.2, release: 0.2
  sleep beat
  n = [1,2].choose
  1.times do
    play :f2, amp: 0.2, release: 0.2
    sleep beat / 2
  end
end

n = in_thread do
  loop do
    noise
  end
end

sleep bar * 4

s = in_thread do
  loop do
    synth2
  end
end

sleep bar * 4

s1 = in_thread do
  loop do
    synth1
  end
end

sleep bar * 4

h =in_thread do
  loop do
    hats
  end
end

sleep bar * 4

k = in_thread do
  loop do
    kick
  end
end

c = in_thread do
  loop do
    clap
  end
end

b = in_thread do
  loop do
    bass
  end
end

sleep bar * 16

k.kill
s1.kill
c.kill

sleep bar * 8

h.kill

k = in_thread do
  loop do
    kick
  end
end

sleep bar * 8

k.kill

sleep bar * 8

b.kill

sleep bar * 8

n.kill

sleep pulse

s1.kill
s.kill
