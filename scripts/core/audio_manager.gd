extends Node
## AudioManager: процедурные звуки без бинарных ассетов (чистый синтез).
## Фанфары победы, звон мечей, стук стройки — как в оригинале по духу.

var players: Array = []

func _ready() -> void:
	for i in 6:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)

func _tone(freq: float, dur: float, vol := 0.35, slide := 0.0) -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * dur)
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in n:
		var t := float(i) / rate
		var f := freq + slide * t
		var v := sin(TAU * f * t) * exp(-3.0 * t / dur) * vol
		var s := int(clampf(v, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.data = data
	return w

func play(name: String) -> void:
	var p: AudioStreamPlayer = players[randi() % players.size()]
	match name:
		"click": p.stream = _tone(660.0, 0.07, 0.25)
		"build": p.stream = _tone(140.0, 0.18, 0.4, 60.0)
		"sword": p.stream = _tone(2400.0, 0.12, 0.3, -1400.0)
		"bow": p.stream = _tone(900.0, 0.1, 0.3, -500.0)
		"gold": p.stream = _tone(1320.0, 0.2, 0.3, 400.0)
		"alarm": p.stream = _tone(220.0, 0.5, 0.4, 220.0)
		"win": p.stream = _tone(523.0, 0.8, 0.35, 300.0)
		"eat": p.stream = _tone(440.0, 0.12, 0.25, -100.0)
		_: p.stream = _tone(500.0, 0.08, 0.25)
	p.play()
