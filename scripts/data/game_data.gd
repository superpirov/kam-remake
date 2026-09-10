class_name GameData
extends RefCounted
## Все данные баланса TSK + TPR. Источники: KaM Remake Wiki, GameFAQs FAQ, kamclub.ru.
## «Последняя версия»: юниты/здания/ресурсы обеих частей в одной таблице.

const TILE_W := 64.0
const TILE_H := 32.0

const RESOURCES := {
	"timber": {"name": "Брёвна", "icon": "🪵"},
	"planks": {"name": "Доски", "icon": "🪚"},
	"stone": {"name": "Камень", "icon": "🪨"},
	"corn": {"name": "Зерно", "icon": "🌾"},
	"flour": {"name": "Мука", "icon": "🌫️"},
	"bread": {"name": "Хлеб", "icon": "🍞"},
	"wine": {"name": "Вино", "icon": "🍷"},
	"fish": {"name": "Рыба", "icon": "🐟", "tpr": true},
	"pig": {"name": "Свинья", "icon": "🐖"},
	"skin": {"name": "Шкура", "icon": "🦴"},
	"leather": {"name": "Кожа", "icon": "👝"},
	"sausage": {"name": "Колбаса", "icon": "🌭"},
	"horse": {"name": "Лошадь", "icon": "🐎"},
	"coal": {"name": "Уголь", "icon": "⬛"},
	"iron_ore": {"name": "Железная руда", "icon": "🟤"},
	"iron": {"name": "Железо", "icon": "⚙️"},
	"gold_ore": {"name": "Золотая руда", "icon": "🟡"},
	"gold": {"name": "Сундук золота", "icon": "💰"},
	"axe": {"name": "Топор", "icon": "🪓"},
	"bow": {"name": "Лук", "icon": "🏹"},
	"spear": {"name": "Копьё", "icon": "🔱"},
	"pike": {"name": "Пика", "icon": "📌"},
	"sword": {"name": "Меч", "icon": "⚔️"},
	"crossbow": {"name": "Арбалет", "icon": "🎯"},
	"wood_shield": {"name": "Деревянный щит", "icon": "🛡️"},
	"iron_shield": {"name": "Железный щит", "icon": "🔰"},
	"leather_armor": {"name": "Кожаный доспех", "icon": "🦺"},
	"iron_armor": {"name": "Железный доспех", "icon": "🥋"},
	"catapult": {"name": "Катапульта", "icon": "💣", "tpr": true},
	"ballista": {"name": "Баллиста", "icon": "🏗️", "tpr": true},
}

const BUILDINGS := {
	"storehouse": {"name": "Склад", "timber": 6, "stone": 4, "hp": 1200, "size": 3, "cat": "base", "desc": "Хранит все ресурсы. Потеря всех складов = поражение."},
	"school": {"name": "Школа", "timber": 6, "stone": 5, "hp": 550, "size": 2, "cat": "base", "desc": "Золото → мирные жители и рекруты."},
	"inn": {"name": "Харчевня", "timber": 5, "stone": 5, "hp": 550, "size": 2, "cat": "food", "desc": "Кормит голодных. 4 вида еды: хлеб, колбаса, вино, рыба."},
	"quarry": {"name": "Каменоломня", "timber": 3, "stone": 2, "hp": 250, "size": 2, "cat": "mine", "worker": "stonemason", "desc": "Каменотёс рубит скалы."},
	"woodcutter": {"name": "Хижина лесоруба", "timber": 2, "stone": 0, "hp": 200, "size": 1, "cat": "mine", "worker": "woodcutter", "desc": "Лесоруб валит лес."},
	"sawmill": {"name": "Лесопилка", "timber": 4, "stone": 2, "hp": 350, "size": 2, "cat": "mine", "worker": "carpenter", "recipes": ["planks", "axe_wood", "bow_wood", "spear_wood"], "desc": "Бревно → доски / дерево-оружие."},
	"farm": {"name": "Ферма", "timber": 4, "stone": 3, "hp": 350, "size": 2, "cat": "food", "worker": "farmer", "desc": "Нужны поля (6–12 кл.). Зерно → мука/свиньи/лошади."},
	"vineyard": {"name": "Виноградник", "timber": 4, "stone": 3, "hp": 350, "size": 2, "cat": "food", "worker": "farmer", "desc": "Лоза → вино. Размечается вручную."},
	"mill": {"name": "Мельница", "timber": 4, "stone": 3, "hp": 350, "size": 2, "cat": "food", "worker": "baker", "recipes": ["flour"], "desc": "Зерно → мука."},
	"bakery": {"name": "Пекарня", "timber": 4, "stone": 3, "hp": 350, "size": 2, "cat": "food", "worker": "baker", "recipes": ["bread"], "desc": "Мука → хлеб. Главная еда королевства."},
	"swine": {"name": "Свиноферма", "timber": 4, "stone": 3, "hp": 350, "size": 2, "cat": "food", "worker": "breeder", "desc": "Зерно → свиньи + шкуры."},
	"stables": {"name": "Конюшня", "timber": 5, "stone": 3, "hp": 400, "size": 2, "cat": "war", "worker": "breeder", "desc": "Зерно → лошади для рыцарей/разведчиков."},
	"butcher": {"name": "Бойня", "timber": 4, "stone": 3, "hp": 350, "size": 2, "cat": "food", "worker": "butcher", "recipes": ["sausage"], "desc": "1 свинья → 3 колбасы."},
	"tannery": {"name": "Кожевня", "timber": 4, "stone": 3, "hp": 350, "size": 2, "cat": "war", "worker": "tanner", "recipes": ["leather"], "desc": "1 шкура → 3 кожи."},
	"coal_mine": {"name": "Угольная шахта", "timber": 4, "stone": 2, "hp": 300, "size": 2, "cat": "mine", "worker": "miner", "desc": "Строй только на угле."},
	"iron_mine": {"name": "Железная шахта", "timber": 4, "stone": 2, "hp": 300, "size": 2, "cat": "mine", "worker": "miner", "desc": "Строй только на руде."},
	"gold_mine": {"name": "Золотая шахта", "timber": 4, "stone": 2, "hp": 300, "size": 2, "cat": "mine", "worker": "miner", "desc": "Строй только на золоте."},
	"metallurgist": {"name": "Плавильня", "timber": 5, "stone": 4, "hp": 450, "size": 2, "cat": "mine", "worker": "metallurgist", "recipes": ["gold"], "desc": "Зол. руда + уголь → сундуки."},
	"iron_smithy": {"name": "Кузница железа", "timber": 5, "stone": 4, "hp": 450, "size": 2, "cat": "war", "worker": "smith", "recipes": ["iron"], "desc": "Жел. руда + уголь → слитки."},
	"weapon_smithy": {"name": "Кузница оружия", "timber": 5, "stone": 4, "hp": 450, "size": 2, "cat": "war", "worker": "smith", "recipes": ["sword", "pike", "crossbow"], "desc": "Железо + уголь → мечи/пики/арбалеты."},
	"armor_smithy": {"name": "Кузница брони", "timber": 5, "stone": 4, "hp": 450, "size": 2, "cat": "war", "worker": "smith", "recipes": ["iron_armor", "iron_shield"], "desc": "Железо + уголь → жел. доспехи/щиты."},
	"weapon_workshop": {"name": "Мастерская оружия", "timber": 4, "stone": 2, "hp": 350, "size": 2, "cat": "war", "worker": "carpenter", "recipes": ["axe_wood", "bow_wood", "spear_wood"], "desc": "2 доски → топор/лук/копьё."},
	"armor_workshop": {"name": "Мастерская брони", "timber": 4, "stone": 2, "hp": 350, "size": 2, "cat": "war", "worker": "carpenter", "recipes": ["wood_shield", "leather_armor"], "desc": "Доска/кожа → дер. щит/кож. доспех."},
	"barracks": {"name": "Казармы", "timber": 8, "stone": 6, "hp": 1500, "size": 3, "cat": "war", "desc": "Рекрут + оружие + броня (+лошадь) → солдат. 9 типов."},
	"tower": {"name": "Сторожевая башня", "timber": 3, "stone": 4, "hp": 600, "size": 1, "cat": "war", "desc": "Рекрут мечет камни. Держит рубеж."},
	"fisherman": {"name": "Хижина рыбака", "timber": 4, "stone": 2, "hp": 300, "size": 2, "cat": "food", "worker": "fisher", "tpr": true, "desc": "TPR: ловля рыбы у воды."},
	"town_hall": {"name": "Муниципалитет", "timber": 6, "stone": 6, "hp": 800, "size": 2, "cat": "war", "tpr": true, "desc": "TPR: наёмники за золото (6 типов)."},
	"siege_workshop": {"name": "Осадная мастерская", "timber": 6, "stone": 4, "hp": 600, "size": 3, "cat": "war", "worker": "carpenter", "tpr": true, "recipes": ["catapult", "ballista"], "desc": "TPR: 5 жел. + 5 брёвен → катапульта/баллиста."},
}

# вход -> выход, секунды на 1 шт. (баланс оригинала, округлённо)
const RECIPES := {
	"planks": {"in": {"timber": 1}, "out": {"planks": 1}, "time": 12.0, "where": "sawmill"},
	"flour": {"in": {"corn": 1}, "out": {"flour": 1}, "time": 15.0, "where": "mill"},
	"bread": {"in": {"flour": 1}, "out": {"bread": 1}, "time": 15.0, "where": "bakery"},
	"sausage": {"in": {"pig": 1}, "out": {"sausage": 3}, "time": 20.0, "where": "butcher"},
	"leather": {"in": {"skin": 1}, "out": {"leather": 3}, "time": 20.0, "where": "tannery"},
	"gold": {"in": {"gold_ore": 1, "coal": 1}, "out": {"gold": 1}, "time": 25.0, "where": "metallurgist"},
	"iron": {"in": {"iron_ore": 1, "coal": 1}, "out": {"iron": 1}, "time": 25.0, "where": "iron_smithy"},
	"sword": {"in": {"iron": 1, "coal": 1}, "out": {"sword": 1}, "time": 30.0, "where": "weapon_smithy"},
	"pike": {"in": {"iron": 1, "coal": 1}, "out": {"pike": 1}, "time": 30.0, "where": "weapon_smithy"},
	"crossbow": {"in": {"iron": 1, "coal": 1}, "out": {"crossbow": 1}, "time": 35.0, "where": "weapon_smithy"},
	"iron_armor": {"in": {"iron": 2, "coal": 1}, "out": {"iron_armor": 1}, "time": 35.0, "where": "armor_smithy"},
	"iron_shield": {"in": {"iron": 1, "coal": 1}, "out": {"iron_shield": 1}, "time": 30.0, "where": "armor_smithy"},
	"axe_wood": {"in": {"planks": 2}, "out": {"axe": 1}, "time": 18.0, "where": "weapon_workshop"},
	"bow_wood": {"in": {"planks": 2}, "out": {"bow": 1}, "time": 18.0, "where": "weapon_workshop"},
	"spear_wood": {"in": {"planks": 2}, "out": {"spear": 1}, "time": 18.0, "where": "weapon_workshop"},
	"wood_shield": {"in": {"planks": 1}, "out": {"wood_shield": 1}, "time": 12.0, "where": "armor_workshop"},
	"leather_armor": {"in": {"leather": 1}, "out": {"leather_armor": 1}, "time": 15.0, "where": "armor_workshop"},
	"catapult": {"in": {"iron": 5, "timber": 5}, "out": {"catapult": 1}, "time": 120.0, "where": "siege_workshop"},
	"ballista": {"in": {"iron": 5, "timber": 5}, "out": {"ballista": 1}, "time": 100.0, "where": "siege_workshop"},
}

const CIVILIANS := {
	"serf": {"name": "Слуга", "desc": "Носильщик. Таскает всё по дорогам."},
	"builder": {"name": "Строитель", "desc": "Строит здания и дороги."},
	"stonemason": {"name": "Каменотёс", "desc": "Рубит камень."},
	"woodcutter": {"name": "Лесоруб", "desc": "Валит лес."},
	"carpenter": {"name": "Столяр", "desc": "Доски и дерево-оружие."},
	"farmer": {"name": "Крестьянин", "desc": "Зерно и вино."},
	"baker": {"name": "Пекарь", "desc": "Мука и хлеб."},
	"breeder": {"name": "Животновод", "desc": "Свиньи и лошади."},
	"butcher": {"name": "Мясник", "desc": "Колбаса из свиней."},
	"tanner": {"name": "Кожевник", "desc": "Кожа из шкур."},
	"miner": {"name": "Шахтёр", "desc": "Уголь и руды."},
	"metallurgist": {"name": "Плавильщик", "desc": "Золото из руды."},
	"smith": {"name": "Кузнец", "desc": "Железо, оружие, броня."},
	"fisher": {"name": "Рыбак", "desc": "TPR: ловит рыбу.", "tpr": true},
	"recruit": {"name": "Рекрут", "desc": "Школа → казарма или башня."},
}

# hp/атака/защита/скорость/дальность + комплект для обучения
const SOLDIERS := {
	"militia": {"name": "Ополчение", "type": "infantry", "hp": 60, "atk": 6, "def": 2, "speed": 62.0, "range": 0, "equip": {"axe": 1, "wood_shield": 1}, "desc": "Дешёвое мясо. Учится быстрее всех."},
	"footman": {"name": "Пехотинец", "type": "infantry", "hp": 110, "atk": 10, "def": 5, "speed": 60.0, "range": 0, "equip": {"axe": 1, "leather_armor": 1, "wood_shield": 1}, "desc": "Крепкая средняя пехота."},
	"swordsman": {"name": "Мечник", "type": "heavy_infantry", "hp": 160, "atk": 15, "def": 9, "speed": 58.0, "range": 0, "equip": {"sword": 1, "iron_armor": 1, "iron_shield": 1}, "desc": "Рубит копейщиков. Умеет в штурм."},
	"scout": {"name": "Разведчик", "type": "cavalry_light", "hp": 120, "atk": 11, "def": 5, "speed": 110.0, "range": 0, "equip": {"bow": 1, "leather_armor": 1, "horse": 1}, "desc": "Быстрый, топчет стрелков."},
	"knight": {"name": "Рыцарь", "type": "cavalry_heavy", "hp": 220, "atk": 20, "def": 12, "speed": 95.0, "range": 0, "equip": {"sword": 1, "iron_armor": 1, "iron_shield": 1, "horse": 1}, "desc": "Элита. Боится только пик."},
	"bowman": {"name": "Лучник", "type": "ranged", "hp": 70, "atk": 9, "def": 2, "speed": 60.0, "range": 9, "equip": {"bow": 1, "leather_armor": 1}, "desc": "Дёшево косит пехоту издали."},
	"crossbowman": {"name": "Арбалетчик", "type": "ranged", "hp": 90, "atk": 14, "def": 4, "speed": 55.0, "range": 11, "equip": {"crossbow": 1, "leather_armor": 1}, "desc": "Медленный, но пробивает броню."},
	"spearman": {"name": "Копейщик", "type": "pike", "hp": 100, "atk": 9, "def": 6, "speed": 58.0, "range": 0, "equip": {"spear": 1, "leather_armor": 1, "wood_shield": 1}, "desc": "×2.2 урона по кавалерии."},
	"pikeman": {"name": "Пикинёр", "type": "pike", "hp": 130, "atk": 12, "def": 8, "speed": 55.0, "range": 0, "equip": {"pike": 1, "iron_armor": 1, "iron_shield": 1}, "desc": "Стена против конницы."},
	# Наёмники TPR — только за золото, без экипировки
	"bandit": {"name": "Бандит", "type": "infantry", "hp": 90, "atk": 9, "def": 3, "speed": 66.0, "range": 0, "gold": 8, "merc": true, "desc": "TPR: дешёвый наёмник."},
	"rebel": {"name": "Бунтарь", "type": "infantry", "hp": 120, "atk": 12, "def": 5, "speed": 62.0, "range": 0, "gold": 12, "merc": true, "desc": "TPR: злой крестьянин с вилами."},
	"squire": {"name": "Сквайр", "type": "heavy_infantry", "hp": 150, "atk": 14, "def": 8, "speed": 60.0, "range": 0, "gold": 18, "merc": true, "desc": "TPR: оруженосец."},
	"warrior": {"name": "Воитель", "type": "heavy_infantry", "hp": 180, "atk": 17, "def": 10, "speed": 58.0, "range": 0, "gold": 25, "merc": true, "desc": "TPR: тяжёлый рубака."},
	"barbarian": {"name": "Варвар", "type": "heavy_infantry", "hp": 240, "atk": 22, "def": 8, "speed": 64.0, "range": 0, "gold": 35, "merc": true, "desc": "TPR: северный громила."},
}

# Треугольник урона: атакующий_тип -> защищающийся_тип -> множитель
const COUNTERS := {
	"cavalry_light": {"ranged": 1.6, "infantry": 1.5, "pike": 0.6},
	"cavalry_heavy": {"ranged": 1.7, "infantry": 1.6, "heavy_infantry": 1.2, "pike": 0.5},
	"pike": {"cavalry_light": 2.2, "cavalry_heavy": 2.2},
	"heavy_infantry": {"pike": 1.8, "infantry": 1.4},
	"ranged": {"infantry": 1.4, "heavy_infantry": 0.8, "cavalry_light": 0.7, "cavalry_heavy": 0.6},
	"infantry": {},
}

const SCHOOL_COST := {"serf_all": 0, "civilian": 1, "recruit": 2}
const HUNGER_MAX := 100.0
const HUNGER_DECAY := 100.0 / 1500.0  # ~25 мин до голода (на скорости x1)
const SERF_CAP := 60

static func building(id: String) -> Dictionary:
	return BUILDINGS.get(id, {})

static func res_name(id: String) -> String:
	return str(RESOURCES.get(id, {}).get("name", id))

static func soldier(id: String) -> Dictionary:
	return SOLDIERS.get(id, {})

static func counter_mult(atk_type: String, def_type: String) -> float:
	return float(COUNTERS.get(atk_type, {}).get(def_type, 1.0))
