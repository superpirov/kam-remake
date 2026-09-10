extends Node
## Military: отряды 1–9, формации, автобой с потерей управления, штурм пехоты, контр-юниты.

signal battle_started(squad_a: Node, squad_b: Node)

func make_damage(att: Dictionary, deff: Dictionary) -> float:
	var base := float(att.get("atk", 5))
	var mult := GameData.counter_mult(str(att.get("type", "infantry")), str(deff.get("type", "infantry")))
	var armor := float(deff.get("def", 0)) * 0.35
	return maxf(1.0, base * mult - armor)

func train_soldier(soldier_id: String) -> bool:
	# казарма: рекрут + комплект. Рекруты — абстрактно: нужен свободный рекрут на складе духа :)
	var s := GameData.soldier(soldier_id)
	if s.is_empty():
		return false
	if s.get("merc", false):
		var cost := int(s.get("gold", 10))
		if not GameManager.take_res("gold", cost):
			GameManager.add_message("Нужно золота: %d" % cost, "warn")
			return false
		return true
	for res_id in (s.get("equip", {}) as Dictionary):
		if int(GameManager.store.get(res_id, 0)) < int(s["equip"][res_id]):
			GameManager.add_message("Нет экипировки: " + GameData.res_name(res_id), "warn")
			return false
	for res_id in (s.get("equip", {}) as Dictionary):
		GameManager.take_res(res_id, int(s["equip"][res_id]))
	return true

func formation_offsets(count: int, kind: String) -> Array:
	var out: Array = []
	var cols := 3 if kind == "line" else 2
	for i in count:
		var r := i / cols
		var c := i % cols
		out.append(Vector2((c - cols / 2.0) * 26.0, (r - count / cols / 2.0) * 26.0))
	return out
