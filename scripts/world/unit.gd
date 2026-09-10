class_name Unit
extends Node2D
## Юнит: мирный или солдат. Солдаты объединяются в отряды через group_id.
## Бой: в ближнем бою — потеря управления (флаг in_melee), штурм у пехоты.

var unit_id := "militia"
var kind := "soldier"  # soldier | civilian | serf
var team := 0
var hp := 100.0
var max_hp := 100.0
var hunger := 100.0
var group_id := -1
var in_melee := false
var melee_timer := 0.0
var charge_cd := 0.0
var charging := 0.0
var target: Node2D = null
var move_target := Vector2.INF
var speed := 60.0
var is_siege := false

const BODY := {
	0: Color(0.2, 0.35, 0.75),  # игрок — синий плащ
	1: Color(0.75, 0.2, 0.2),   # враг — красный
}

func setup(p_id: String, p_team := 0, p_group := -1) -> void:
	unit_id = p_id
	team = p_team
	group_id = p_group
	if GameData.SOLDIERS.has(p_id):
		var s: Dictionary = GameData.SOLDIERS[p_id]
		kind = "soldier"
		max_hp = float(s["hp"])
		hp = max_hp
		speed = float(s["speed"])
		hunger = 100.0
	else:
		kind = "civilian"
		max_hp = 40.0
		hp = 40.0
		speed = 55.0
	if p_id == "catapult" or p_id == "ballista":
		is_siege = true
		max_hp = 200.0
		hp = max_hp
		speed = 30.0
	queue_redraw()

func _process(delta: float) -> void:
	var s := GameManager.speed() if team == 0 else 1.0
	if s <= 0.0:
		return
	var dt := delta * s
	if kind == "soldier":
		hunger = maxf(0.0, hunger - GameData.HUNGER_DECAY * dt * 8.0)
		if hunger <= 0.0:
			hp -= 4.0 * dt # голодная смерть как в оригинале
			if hp <= 0.0:
				_die()
				return
	if charge_cd > 0.0:
		charge_cd -= dt
	if charging > 0.0:
		charging -= dt
	if melee_timer > 0.0:
		melee_timer -= dt
		if melee_timer <= 0.0:
			in_melee = false
	# движение
	if target != null and is_instance_valid(target):
		var d: Vector2 = target.global_position - global_position
		var reach := 26.0 if not _is_ranged() else _range_px()
		if d.length() > reach:
			_step(d.normalized(), dt, charging > 0.0)
		else:
			_fight(target, dt)
	elif move_target != Vector2.INF:
		if not in_melee: # в мелее приказы игнорируются — как в оригинале
			var d2: Vector2 = move_target - global_position
			if d2.length() < 6.0:
				move_target = Vector2.INF
			else:
				_step(d2.normalized(), dt, charging > 0.0)
	queue_redraw()

func _step(dir: Vector2, dt: float, fast: bool) -> void:
	var mult := 2.2 if fast else 1.0
	global_position += dir * speed * mult * dt

func order_move(p: Vector2) -> void:
	if in_melee:
		return # потеря управления в бою!
	move_target = p
	target = null

func order_attack(t: Node2D) -> void:
	if in_melee:
		return
	target = t
	move_target = Vector2.INF

func order_charge(p: Vector2) -> void:
	# штурм пехоты: рывок без управления
	if charge_cd > 0.0 or kind != "soldier":
		return
	charging = 1.6
	charge_cd = 30.0
	move_target = p
	target = null
	in_melee = true
	melee_timer = 3.0

func _is_ranged() -> bool:
	return unit_id == "bowman" or unit_id == "crossbowman"

func _range_px() -> float:
	if unit_id == "crossbowman":
		return 11.0 * 22.0
	if unit_id == "bowman":
		return 9.0 * 22.0
	return 26.0

func _fight(t: Node2D, dt: float) -> void:
	if t is Unit:
		var a: Dictionary = GameData.soldier(unit_id)
		var b: Dictionary = GameData.soldier((t as Unit).unit_id)
		var dmg := Military.make_damage(a, b) * dt
		(t as Unit).take_damage(dmg, self)
		in_melee = true # сошлись — управление потеряно
		melee_timer = 2.5
		if randf() < dt * 2.0:
			AudioManager.play("sword")
	elif t is Building:
		(t as Building).take_damage(20.0 * dt)
		if randf() < dt * 1.5:
			AudioManager.play("sword")

func take_damage(d: float, from: Node = null) -> void:
	hp -= d
	if hp <= 0.0:
		_die(from)

func _die(from: Node = null) -> void:
	var world := get_parent()
	if world != null and world.has_method("unit_died"):
		world.call("unit_died", self, from)
	else:
		queue_free()

func restore_food(n: int) -> void:
	hunger = clampf(hunger + float(n) * 60.0, 0.0, 100.0)

func _draw() -> void:
	var c: Color = BODY.get(team, Color.WHITE)
	# тень
	draw_ellipse(Vector2(0, 8), 10, 5, Color(0, 0, 0, 0.35))
	# тело
	draw_circle(Vector2.ZERO, 8.0, c)
	draw_circle(Vector2(0, -3), 5.0, Color(0.9, 0.75, 0.55)) # голова
	# оружие-метка
	if _is_ranged():
		draw_line(Vector2(-6, 0), Vector2(-12, -8), Color(0.4, 0.25, 0.12), 2.0)
	elif unit_id == "knight" or unit_id == "scout":
		draw_circle(Vector2(6, 4), 4.0, Color(0.5, 0.35, 0.2)) # лошадь условно
	elif is_siege:
		draw_rect(Rect2(-10, -6, 20, 12), Color(0.4, 0.3, 0.2))
	# голод
	if kind == "soldier" and hunger < 35.0:
		draw_string(ThemeDB.fallback_font, Vector2(-6, -16), "🍗", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	if hp < max_hp:
		var f := clampf(hp / max_hp, 0.0, 1.0)
		draw_rect(Rect2(-10, -24, 20, 4), Color(0, 0, 0, 0.7))
		draw_rect(Rect2(-10, -24, 20 * f, 4), Color(0.9, 0.2, 0.2))

func draw_ellipse(center: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * i / 16.0
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)
