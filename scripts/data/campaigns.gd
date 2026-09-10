class_name Campaigns
extends RefCounted
## 34 миссии: TSK 1–20 + TPR 1–14. Тип: peaceful (строй+штурм) / battle (только бой).
## win: снести казармы+склады+школы и всех солдат; lose: потерял все склады.

const TSK := [
	{"id": "tsk01", "n": 1, "name": "Первые шаги", "type": "peaceful", "map": 64, "brief": "Советник встречает вас. Освойте дороги, склад, школу и харчевню. Маленький отряд дезертиров бродит рядом — рекруты с топорами справятся.", "start": {"planks": 20, "stone": 15, "bread": 10, "gold": 4}, "enemy": {"squads": 1}},
	{"id": "tsk02", "n": 2, "name": "Хлеб насущный", "type": "peaceful", "map": 64, "brief": "Ферма, мельница, пекарня. Разметьте поля вручную — 12 клеток хватит. Голод убивает быстрее меча.", "start": {"planks": 25, "stone": 15, "gold": 5}, "enemy": {"squads": 1}},
	{"id": "tsk03", "n": 3, "name": "Камень и дерево", "type": "peaceful", "map": 72, "brief": "Каменоломни и лесорубы. Стройматериалы — кровь стройки. Дороги от склада обязательны.", "start": {"bread": 15, "gold": 6}, "enemy": {"squads": 2}},
	{"id": "tsk04", "n": 4, "name": "Вино для духа", "type": "peaceful", "map": 72, "brief": "Виноградники поднимут сытость. Противник впервые держит башню — готовьте лучников.", "start": {"planks": 20, "stone": 20, "bread": 12, "gold": 8}, "enemy": {"squads": 2, "towers": 1}},
	{"id": "tsk05", "n": 5, "name": "Железо решает", "type": "peaceful", "map": 80, "brief": "Уголь + железо + кузницы. Мечники и копейщики против первой серьёзной армии Лотара.", "start": {"planks": 30, "stone": 25, "bread": 15, "sausage": 8, "gold": 10}, "enemy": {"squads": 3}},
	{"id": "tsk06", "n": 6, "name": "Засада", "type": "battle", "map": 64, "brief": "Боевая миссия: города не будет. Только ваши отряды — удержите переправу.", "start": {}, "enemy": {"squads": 4}, "army": ["footman", "footman", "bowman", "spearman"]},
	{"id": "tsk07", "n": 7, "name": "Свиньи и кожа", "type": "peaceful", "map": 80, "brief": "Свиноферма → бойня (1 мясо = 3 колбасы) и кожевня (1 шкура = 3 кожи). Кожаные доспехи для армии.", "start": {"planks": 30, "stone": 20, "bread": 15, "gold": 10}, "enemy": {"squads": 3, "towers": 2}},
	{"id": "tsk08", "n": 8, "name": "Золото короны", "type": "peaceful", "map": 88, "brief": "Золотая шахта и плавильня. Золото нужно школе — без рекрутов нет армии.", "start": {"planks": 35, "stone": 30, "bread": 20, "gold": 6}, "enemy": {"squads": 4}},
	{"id": "tsk09", "n": 9, "name": "Казарма", "type": "peaceful", "map": 88, "brief": "Стройте казарму. Экипируйте мечников и арбалетчиков. Враг держит две деревни.", "start": {"planks": 40, "stone": 35, "bread": 20, "sausage": 10, "gold": 14}, "enemy": {"squads": 5, "towers": 2}},
	{"id": "tsk10", "n": 10, "name": "Северный ветер", "type": "peaceful", "map": 96, "brief": "Варвары с севера! Башни + пикинёры против их конницы. Кормите солдат вовремя.", "start": {"planks": 40, "stone": 40, "bread": 25, "gold": 14}, "enemy": {"squads": 6}},
	{"id": "tsk11", "n": 11, "name": "Ночной рейд", "type": "battle", "map": 72, "brief": "Ночь. Только кавалерия и стрелки. Обойдите башни с фланга.", "start": {}, "enemy": {"squads": 5, "towers": 2}, "army": ["scout", "scout", "bowman", "bowman", "spearman"]},
	{"id": "tsk12", "n": 12, "name": "Кузницы победы", "type": "peaceful", "map": 96, "brief": "Полный цикл железа: 2 угольные + 2 железные шахты, кузницы оружия и брони. Рыцари!", "start": {"planks": 50, "stone": 45, "bread": 25, "sausage": 12, "gold": 18}, "enemy": {"squads": 6, "towers": 3}},
	{"id": "tsk13", "n": 13, "name": "Осада мельниц", "type": "peaceful", "map": 96, "brief": "Три деревни Лотара. Нужна большая армия и запас еды для долгого штурма.", "start": {"planks": 50, "stone": 45, "bread": 30, "gold": 20}, "enemy": {"squads": 7, "towers": 3}},
	{"id": "tsk14", "n": 14, "name": "Кровь и вино", "type": "battle", "map": 80, "brief": "Виноградная долина. Удержите обоз с вином — это жалованье наёмникам... то есть еда армии.", "start": {}, "enemy": {"squads": 7}, "army": ["swordsman", "swordsman", "pikeman", "crossbowman", "crossbowman"]},
	{"id": "tsk15", "n": 15, "name": "Конюшни", "type": "peaceful", "map": 104, "brief": "Конюшни + фермы под овёс. Разведчики и рыцари сомнут стрелков врага.", "start": {"planks": 55, "stone": 50, "bread": 30, "sausage": 15, "gold": 22}, "enemy": {"squads": 8, "towers": 3}},
	{"id": "tsk16", "n": 16, "name": "Железный кулак", "type": "peaceful", "map": 104, "brief": "Цитадель наместника. Башни, ров, тяжёлая пехота. Готовьте штурмовые отряды.", "start": {"planks": 60, "stone": 55, "bread": 35, "sausage": 15, "gold": 25}, "enemy": {"squads": 9, "towers": 4}},
	{"id": "tsk17", "n": 17, "name": "Дорога на столицу", "type": "battle", "map": 88, "brief": "Марш на столицу. Три волны мятежников. Держите каре пик вокруг арбалетчиков.", "start": {}, "enemy": {"squads": 9}, "army": ["knight", "knight", "pikeman", "pikeman", "crossbowman", "swordsman"]},
	{"id": "tsk18", "n": 18, "name": "Предместья", "type": "peaceful", "map": 112, "brief": "Последний рубеж Лотара. Огромный город-декорация, но гарнизон настоящий.", "start": {"planks": 70, "stone": 60, "bread": 40, "sausage": 20, "wine": 10, "gold": 30}, "enemy": {"squads": 10, "towers": 5}},
	{"id": "tsk19", "n": 19, "name": "Варвары у ворот", "type": "battle", "map": 96, "brief": "Пока вы громили Лотара, варвары прорвали северную границу. Только бой, только хардкор.", "start": {}, "enemy": {"squads": 11}, "army": ["knight", "knight", "swordsman", "swordsman", "pikeman", "crossbowman", "bowman"]},
	{"id": "tsk20", "n": 20, "name": "Разрушенное королевство", "type": "peaceful", "map": 128, "brief": "Финал. Столица мятежников. Всё, чему научились: экономика, голод, штурм, контр-юниты. За короля Каролуса!", "start": {"planks": 80, "stone": 70, "bread": 45, "sausage": 20, "wine": 15, "gold": 35}, "enemy": {"squads": 12, "towers": 6}},
]

const TPR := [
	{"id": "tpr01", "n": 1, "name": "Пепел короны", "type": "peaceful", "map": 72, "brief": "После войны — разруха. Рыба спасёт от голода: стройте хижину рыбака (новое!).", "start": {"planks": 25, "stone": 20, "bread": 8, "gold": 8}, "enemy": {"squads": 2}},
	{"id": "tpr02", "n": 2, "name": "Муниципалитет", "type": "peaceful", "map": 72, "brief": "Новое здание: муниципалитет. Нанимайте бандитов и бунтарей за золото.", "start": {"planks": 30, "stone": 25, "bread": 12, "gold": 20}, "enemy": {"squads": 3}},
	{"id": "tpr03", "n": 3, "name": "Речная доля", "type": "peaceful", "map": 80, "brief": "Карта на реках — рыба решает. Держите переправы пикинёрами.", "start": {"planks": 30, "stone": 25, "bread": 10, "gold": 12}, "enemy": {"squads": 3, "towers": 1}},
	{"id": "tpr04", "n": 4, "name": "Сквайры", "type": "peaceful", "map": 80, "brief": "Нанимайте сквайров — крепче ополчения. Ускорение F8 (новое!) сократит стройку.", "start": {"planks": 35, "stone": 30, "bread": 15, "gold": 25}, "enemy": {"squads": 4}},
	{"id": "tpr05", "n": 5, "name": "Осадный двор", "type": "peaceful", "map": 88, "brief": "Новое: осадная мастерская. Катапульта (по зданиям) и баллиста (по войскам): 5 жел. + 5 брёвен.", "start": {"planks": 40, "stone": 35, "bread": 18, "gold": 20}, "enemy": {"squads": 4, "towers": 3}},
	{"id": "tpr06", "n": 6, "name": "Ночной обоз", "type": "battle", "map": 72, "brief": "Конвой с осадными машинами. Прикройте баллисты пиками.", "start": {}, "enemy": {"squads": 5}, "army": ["warrior", "squire", "pikeman", "crossbowman"]},
	{"id": "tpr07", "n": 7, "name": "Воители", "type": "peaceful", "map": 96, "brief": "Дорогие, но страшные воители. Плюс свои катапульты против стен.", "start": {"planks": 50, "stone": 45, "bread": 25, "gold": 40}, "enemy": {"squads": 6, "towers": 4}},
	{"id": "tpr08", "n": 8, "name": "Варвары среди нас", "type": "peaceful", "map": 96, "brief": "Нанятые варвары дерутся как черти, но жрут в три горла. Запасайте рыбу и колбасу.", "start": {"planks": 50, "stone": 45, "bread": 25, "sausage": 15, "fish": 10, "gold": 50}, "enemy": {"squads": 7, "towers": 3}},
	{"id": "tpr09", "n": 9, "name": "Мятежный граф", "type": "battle", "map": 80, "brief": "Замок графа. Только армия + 2 катапульты. Цель — казармы и башни.", "start": {}, "enemy": {"squads": 7, "towers": 4}, "army": ["knight", "warrior", "barbarian", "pikeman", "crossbowman"]},
	{"id": "tpr10", "n": 10, "name": "Голодный край", "type": "peaceful", "map": 104, "brief": "Недород. Выживут те, у кого рыба + свиньи + хлеб. Считайте каждую буханку.", "start": {"planks": 45, "stone": 40, "fish": 15, "gold": 20}, "enemy": {"squads": 7, "towers": 3}},
	{"id": "tpr11", "n": 11, "name": "Две короны", "type": "peaceful", "map": 112, "brief": "Самозванец короновался. Снесите его столицу: катапульты по стенам, рыцари в пролом.", "start": {"planks": 65, "stone": 60, "bread": 35, "sausage": 20, "gold": 45}, "enemy": {"squads": 9, "towers": 5}},
	{"id": "tpr12", "n": 12, "name": "Перевал", "type": "battle", "map": 88, "brief": "Удержите перевал малыми силами, пока принц уходит с обозом.", "start": {}, "enemy": {"squads": 9}, "army": ["squire", "squire", "pikeman", "pikeman", "crossbowman", "bowman"]},
	{"id": "tpr13", "n": 13, "name": "Последний гарнизон", "type": "peaceful", "map": 112, "brief": "Предпоследний бой. Всё сразу: наёмники, осада, рыцари, голод.", "start": {"planks": 70, "stone": 65, "bread": 40, "sausage": 20, "fish": 15, "gold": 55}, "enemy": {"squads": 10, "towers": 5}},
	{"id": "tpr14", "n": 14, "name": "Вторая корона", "type": "peaceful", "map": 128, "brief": "Финал. Коронация законного принца. Разбейте последний союз мятежников. Ускорение F8 — в помощь!", "start": {"planks": 80, "stone": 70, "bread": 45, "sausage": 25, "fish": 15, "wine": 15, "gold": 60}, "enemy": {"squads": 12, "towers": 6}},
]

static func all_missions() -> Array:
	var out: Array = []
	for m in TSK:
		var c: Dictionary = m.duplicate()
		c["campaign"] = "tsk"
		out.append(c)
	for m in TPR:
		var c2: Dictionary = m.duplicate()
		c2["campaign"] = "tpr"
		out.append(c2)
	return out

static func get_mission(campaign: String, n: int) -> Dictionary:
	var arr: Array = TSK if campaign == "tsk" else TPR
	for m in arr:
		if int(m["n"]) == n:
			var c: Dictionary = (m as Dictionary).duplicate()
			c["campaign"] = campaign
			return c
	return {}
