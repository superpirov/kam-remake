class_name Building
extends Node2D
## Здание: стройка по этапам, работник с голодом, производство, HP.

var building_id := "storehouse"
var tile := Vector2i.ZERO
var under_construction := true
var build_progress := 0.0
var build_needed := 30.0
var hp := 100.0
var max_hp := 100.0
var worker_hunger := 100.0
var worker_eating := false
var current_recipe := ""
var work_progress := 0.0
var team := 0  # 0 игрок, 1 враг
var produced_flash := 0.0

const COLORS := {
	"storehouse": Color(0.55, 0.4, 0.25), "school": Color(0.7, 0.6, 0.4),
	"inn": Color(0.75, 0.5, 0.3), "quarry": Color(0.6, 0.6, 0.62),
	"barracks": Color(0.5, 0.2, 0.2), "tower": Color(0.65, 0.65, 0.7),
	"farm": Color(0.5, 0.7, 0.3), "default": Color(0.6, 0.5, 0.35),
}

func setup(p_id: String, p_tile: Vector2i, p_team := 0) -> void:
	building_id = p_id
	tile = p_tile
	team = p_team
	var b := GameData.building(p_id)
	max_hp = float(b.get("hp", 300))
	hp = max_hp if not under_construction else max_hp * 0.3
	build_needed = 20.0 + float(b.get("timber", 3)) * 5.0
	queue_redraw()

func is_working() -> bool:
	if under_construction:
		return false
	if worker_eating:
		return false
	return true

func flash_produced() -> void:
	produced_flash = 1.0

func _process(delta: float) -> void:
	var s := GameManager.speed() if team == 0 else 1.0
	if under_construction and s > 0.0:
		build_progress += delta * s
		if build_progress >= build_needed:
			under_construction = false
			hp = max_hp
			GameManager.add_message("%s построено." % str(GameData.building(building_id).get("name", building_id)), "info")
			AudioManager.play("build")
		queue_redraw()
	if produced_flash > 0.0:
		produced_flash -= delta * 2.0
		queue_redraw()

func take_damage(d: float) -> void:
	hp -= d
	queue_redraw()
	if hp <= 0.0:
		var w := get_parent()
		if w != null and w.has_method("building_destroyed"):
			w.call("building_destroyed", self)
		else:
			queue_free()

func _draw() -> void:
	var c: Color = COLORS.get(building_id, COLORS["default"])
	if team == 1:
		c = c.lerp(Color(0.6, 0.1, 0.1), 0.45)
	# домик: основание-ромб + крыша
	var w := 44.0
	var h := 22.0
	var pts := PackedVector2Array([Vector2(0, -h), Vector2(w / 2, 0), Vector2(0, h), Vector2(-w / 2, 0)])
	draw_colored_polygon(pts, c.darkened(0.2))
	# стены
	draw_colored_polygon(PackedVector2Array([Vector2(-w / 2, 0), Vector2(0, h), Vector2(0, h - 16), Vector2(-w / 2, -16)]), c)
	draw_colored_polygon(PackedVector2Array([Vector2(w / 2, 0), Vector2(0, h), Vector2(0, h - 16), Vector2(w / 2, -16)]), c.darkened(0.15))
	# крыша
	draw_colored_polygon(PackedVector2Array([Vector2(-w / 2 - 4, -16), Vector2(0, -16 - 18), Vector2(w / 2 + 4, -16), Vector2(0, -16 + 2)]), Color(0.45, 0.22, 0.12))
	if building_id == "tower":
		draw_rect(Rect2(-8, -58, 16, 44), Color(0.55, 0.55, 0.6))
		draw_rect(Rect2(-12, -62, 24, 8), Color(0.4, 0.4, 0.45))
	if building_id == "barracks":
		# зубцы казармы
		for i in 3:
			draw_rect(Rect2(-20 + i * 14, -40, 10, 8), Color(0.35, 0.12, 0.12))
	if under_construction:
		var p: float = clampf(build_progress / build_needed, 0.0, 1.0)
		draw_rect(Rect2(-24, 14, 48, 6), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-24, 14, 48 * p, 6), Color(0.3, 0.8, 0.3))
		# леса
		draw_line(Vector2(-24, 14), Vector2(-24, -30), Color(0.7, 0.55, 0.3), 2.0)
		draw_line(Vector2(24, 14), Vector2(24, -30), Color(0.7, 0.55, 0.3), 2.0)
	else:
		if produced_flash > 0.0:
			draw_circle(Vector2(0, -34), 6.0 + produced_flash * 4.0, Color(1, 0.9, 0.3, produced_flash))
	# полоска HP
	if hp < max_hp:
		var f := clampf(hp / max_hp, 0.0, 1.0)
		draw_rect(Rect2(-24, -46, 48, 5), Color(0, 0, 0, 0.7))
		draw_rect(Rect2(-24, -46, 48 * f, 5), Color(0.9, 0.2, 0.2) if f < 0.4 else Color(0.3, 0.8, 0.3))
