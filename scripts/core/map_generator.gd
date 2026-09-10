class_name MapGenerator
extends RefCounted
## Процедурная карта под миссию: лес, камень, уголь/железо/золото, вода+рыба, плодородность.

const T_GRASS := 0
const T_FOREST := 1
const T_STONE := 2
const T_COAL := 3
const T_IRON := 4
const T_GOLD := 5
const T_WATER := 6
const T_FERTILE := 7
const T_ROAD := 8

static func generate(size: int, seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var tiles: Array = []
	for y in size:
		var row: Array = []
		for x in size:
			row.append(T_GRASS)
		tiles.append(row)
	# вода по краям/река
	for i in size:
		if rng.randf() < 0.5:
			tiles[i][0] = T_WATER
			tiles[i][size - 1] = T_WATER
	# лес пятнами
	_scatter(tiles, size, rng, T_FOREST, 14, 6)
	# плодородная земля рядом с центром игрока
	_scatter(tiles, size, rng, T_FERTILE, 8, 5)
	# камень/уголь/железо/золото — жилы кучно
	_scatter(tiles, size, rng, T_STONE, 6, 4)
	_scatter(tiles, size, rng, T_COAL, 4, 3)
	_scatter(tiles, size, rng, T_IRON, 4, 3)
	_scatter(tiles, size, rng, T_GOLD, 3, 2)
	return {"size": size, "tiles": tiles, "seed": seed_value}

static func _scatter(tiles: Array, size: int, rng: RandomNumberGenerator, t: int, blobs: int, rad: int) -> void:
	for b in blobs:
		var cx := rng.randi_range(rad, size - 1 - rad)
		var cy := rng.randi_range(rad, size - 1 - rad)
		for y in range(cy - rad, cy + rad):
			for x in range(cx - rad, cx + rad):
				if x < 0 or y < 0 or x >= size or y >= size:
					continue
				var d := Vector2(x - cx, y - cy).length()
				if d <= rad and rng.randf() > d / (rad + 1.0) * 0.5:
					if tiles[y][x] == T_GRASS:
						tiles[y][x] = t
