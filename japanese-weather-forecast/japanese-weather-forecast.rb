# Add your path to the samples folder!
# use_sample_pack_as "YOUR-PATH-TO/japanese-weather-forecast/samples", 'mySamples'

bpm = 110.0
beat = 60.0 / bpm
pulse = beat / 4
bar = beat * 4

chords = [:c, :d, :e, :f, :g, :a]
mode = [:major,:minor]

define :voc do
  with_fx :level, amp: 0.2 do
    with_fx :reverb, mix: rrand(0.1,0.5), room: rrand(0.95, 0.99) do
      with_fx :nhpf, cutoff: rrand(90,120) do
        point = rand
        sample :mySamples_voc_1, 
          start: point, 
          finish: point + [0.01, 0.015].choose, pan: rrand(-1,1) if one_in(2)
        sleep bar
      end
    end
  end
end

define :play_arp do |chord, len|
  use_synth :saw
  with_fx :level, amp: 0.0, amp_slide: 32 do |g|
    control g, amp: 0.4 if one_in(4)
    with_fx :reverb, mix: 0.4, room: 0.7 do
      with_fx :rlpf, cutoff: 90 do
        (4 * len).times do
          with_transpose [0,12,7].choose + [0,12].choose do
            play_pattern_timed chord, pulse,
              attack: rrand(0.0,0.02),
              release: rrand(0.05, 0.08),
              amp: rrand(0.5,1.0),
              pan: rrand(-0.5,0.5)
            sleep pulse
          end
        end
      end
    end
  end
end

define :play_ch do |chord, len|
  use_synth :zawa
  with_fx :level, amp: 0.15 do
    with_fx :reverb, mix: 0.8, room: 0.7 do
      with_fx :rlpf, cutoff: 70 do
        with_transpose 0 do
          play chord,
            attack: 0.1, sustain: len, release: 0.1
        end
      end
    end
  end
end

define :fx do
  with_fx :level, amp: 0.6 do
    sample [:elec_fuzz_tom].choose,
      rate: rrand(-1.1,2.2) * [1,-1].choose,
      amp: rrand(0,1) if one_in(32)
    if (rand > 0.98) then
      sample :ambi_soft_buzz,
        rate: rrand(-2,2),
        pan: rrand(-1,1),
        amp: rrand(0.4,0.9)
    end
    sample [:elec_blip2,:elec_blip].choose,
      rate: rrand(-1.1,2.2) * [1,-1].choose,
      amp: rrand(0.5,1.0) if one_in(8)
    sleep pulse
  end
end

define :hats do
  with_fx :level, amp: 0.6 do
    4.times do
      sample [:drum_cymbal_closed, :drum_cymbal_pedal].choose,
        amp: rrand(0.0,1.0),
        attack: rrand(0.0,0.05),
        pan: rrand(-0.5, 0.5)
      sleep pulse
    end
  end
end

define :kick do
  with_fx :level, amp: 0.7 do
    if (rand > 0.15) then
      sample :drum_heavy_kick
    else
      sample :drum_bass_hard, rate: rrand(-2,2)
    end
    sleep beat
  end
end

define :percs do
  with_fx :level, amp: 0.5 do
    4.times do
      sample :elec_twip, amp: rrand(0.25,1.0), pan: rrand(-1,1)
      sleep pulse
    end
    if (rand > 0.1) then
      rate = 1
    else
      rate = -1
    end
    sample :elec_triangle, rate: rate, amp: 0.9
    sample [:elec_snare, :drum_snare_soft].choose, amp: 0.8 if one_in(3)
    4.times do
      sample [:elec_bell,:elec_fuzz_tom].choose, amp: rrand(0.2,0.9), pan: rrand(-1,1) if one_in(4)
      sleep pulse
    end
  end
end

f = in_thread do
  loop do
    fx
  end
end

v = in_thread do
  loop do
    voc
  end
end

p = in_thread do
  loop do
    chord = chord(chords.choose, mode.choose)
    in_thread do
      play_ch chord, 4 * bar
    end
    in_thread do
      play_arp chord, 4
    end
    sleep 4 * bar
  end
end

sleep bar * 8

h = in_thread do
  loop do
    hats
  end
end

pp = in_thread do
  loop do
    percs
  end
end

sleep bar * 8

k = in_thread do
  loop do
    kick
  end
end

sleep bar * 8

k.kill
pp.kill
p.kill

sleep bar * 4

pp = in_thread do
  loop do
    percs
  end
end

sleep 4 * bar

p = in_thread do
  loop do
    chord = chord(chords.choose, mode.choose)
    in_thread do
      play_ch chord, 4 * bar
    end
    in_thread do
      play_arp chord, 4
    end
    sleep 4 * bar
  end
end




sleep 8 * bar

k = in_thread do
  loop do
    kick
  end
end

sleep 16 * bar

pp.kill
k.kill

sleep 8

f.kill
p.kill
h.kill
f.kill
v.kill
