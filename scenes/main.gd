extends Node2D

var rng = RandomNumberGenerator.new()

const OFFSET_X := 80
const OFFSET_Y := 63

var weights = {
		Global.States.CLEAR: 70,
		Global.States.SUN: 15,
		Global.States.CLOUD: 8,
		Global.States.RAIN: 5,
		Global.States.STORM: 2
	}

# ******************************************************************
# GLOBAL FUNCTIONS
# ******************************************************************

func _ready() -> void:
	show_day()
	create_board()
	_glider()
	#create_random_board()
	print_board(Global.board)


# ******************************************************************
# BOARD CREATION
# ******************************************************************

func create_board() -> void:
	Global.board = []

	var cell_scene = load("res://scenes/cell.tscn")

	for i in range(Global.ROWS):
		var row = []
		for j in range(Global.COLS):
			
			var new_cell = cell_scene.instantiate()
			add_child(new_cell)
			
			new_cell.position = Vector2(
				j * Global.CELL_SIZE + OFFSET_X,
				i * Global.CELL_SIZE + OFFSET_Y
			)

			new_cell.setup(Global.States.CLEAR, Vector2i(i,j))

			row.append(new_cell)

		Global.board.append(row)

func create_random_board() -> void:
	Global.board = []
	var cell_scene = load("res://scenes/cell.tscn")
	rng.randomize()

	for i in range(Global.ROWS):
		var row = []
		for j in range(Global.COLS):
			var new_cell = cell_scene.instantiate()
			add_child(new_cell)
			
			new_cell.position = Vector2(
				j * Global.CELL_SIZE + OFFSET_X,
				i * Global.CELL_SIZE + OFFSET_Y
			)

			# Lógica de pesos: tiramos un dado del 0 al 100
			var roll = rng.randi_range(0, 100)
			var chosen_state = Global.States.CLEAR
			var current_sum = 0
			
			for state in weights:
				current_sum += weights[state]
				if roll <= current_sum:
					chosen_state = state
					break # Salimos del bucle al encontrar el estado correspondiente

			new_cell.setup(chosen_state, Vector2i(i, j))
			row.append(new_cell)
			
		Global.board.append(row)

# ******************************************************************
# PATTERNS
# ******************************************************************

func _glider() -> void:
	var pattern = [
		[0,1,0],
		[0,0,1],
		[1,1,1],
	]

	for i in range(pattern.size()):
		for j in range(pattern[i].size()):
			if pattern[i][j] == 1:
				Global.board[i][j].set_state(Global.States.SUN)


# ******************************************************************
# LOGIC
# ******************************************************************

func get_vecinos(row: int, col: int) -> int:

	var vecinos = 0

	for i in range(-1, 2):
		for j in range(-1, 2):

			if i == 0 and j == 0:
				continue

			var r = (row + i + Global.ROWS) % Global.ROWS
			var c = (col + j + Global.COLS) % Global.COLS

			if Global.board[r][c].state != Global.States.CLEAR:
				vecinos += 1

	return vecinos


func simulate_board() -> void:

	var next_states = []

	for i in range(Global.ROWS):

		var row = []

		for j in range(Global.COLS):

			var vecinos = get_vecinos(i, j)
			var current = Global.board[i][j].state
			var next_state: int

			if current != Global.States.CLEAR:
				if vecinos == 2 or vecinos == 3:
					next_state = Global.States.SUN
				else:
					next_state = Global.States.CLEAR
			else:
				if vecinos == 3:
					next_state = Global.States.SUN
				else:
					next_state = Global.States.CLEAR

			row.append(next_state)

		next_states.append(row)

	for i in range(Global.ROWS):
		for j in range(Global.COLS):
			Global.board[i][j].set_state(next_states[i][j])


# ******************************************************************
# UI
# ******************************************************************

func show_day() -> void:
	$UI/CurrentDay/CurrentDayText.text = str(Global.Day)


func next_day() -> void:

	Global.Day += 1

	if Global.Day > Global.MaxDay:
		get_tree().quit()
	else:
		show_day()

	simulate_board()
	print_board(Global.board)


# ******************************************************************
# DEBUG
# ******************************************************************

func print_board(matrix) -> void:

	for i in range(Global.ROWS):

		var row = ""

		for j in range(Global.COLS):
			row += str(matrix[i][j].state) + " "

		print(row)

	print("\n")


# ******************************************************************
# EVENTS
# ******************************************************************

func _on_mouse_click_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		var mouse_pos = event.position

		var col = int((mouse_pos.x - OFFSET_X) / Global.CELL_SIZE)
		var row = int((mouse_pos.y - OFFSET_Y) / Global.CELL_SIZE)

		if row >= 0 and row < Global.ROWS and col >= 0 and col < Global.COLS:
			print(Vector2i(row, col))


func _on_button_pressed() -> void:
	next_day()
