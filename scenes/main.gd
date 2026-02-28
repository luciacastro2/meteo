extends Node2D

var rng = RandomNumberGenerator.new()

const OFFSET_X := 40
const OFFSET_Y := 60

var weights = {
	Global.States.CLEAR: 60,        
	Global.States.SUN: 15,
	Global.States.PARTLY_CLOUD: 10, 
	Global.States.CLOUD: 8,
	Global.States.RAIN: 5,
	Global.States.STORM: 2
}

# ******************************************************************
# CLASS PREDICTION
# ******************************************************************

class Prediction:
	var position: Vector2i
	var state: int
	var turn: int
	
	func _init(p: Vector2i, t: int):
		position = p
		turn = t
		state = -1 # aún no elegido
	
	func is_complete() -> bool:
		return state != -1

var predictions: Array[Prediction] = []
var selected_prediction: Prediction = null

func check_predictions() -> void:
	for p in predictions.duplicate(): 
		if p.turn == Global.Day - 1: 
			var real_state = Global.board[p.position.x][p.position.y].state
			if real_state == p.state:
				print("✔ Acierto en", p.position)
				Global.Credibility += 5
			else:
				print("✘ Fallo en", p.position)
				Global.Credibility -= 5
			predictions.erase(p)
	update_credibility() 
	end_game()		
# ******************************************************************
# GLOBAL FUNCTIONS
# ******************************************************************

func _ready() -> void:
	show_day()
	show_credibility()
	show_predictions_left()
	#create_board()
	#_glider()
	create_random_board()
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

			var roll = rng.randi_range(0, 100)
			var chosen_state = Global.States.CLEAR
			var current_sum = 0
			
			for state in weights:
				current_sum += weights[state]
				if roll <= current_sum:
					chosen_state = state
					break 
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

func decide_weather_state(row: int, col: int) -> int:
	var sun_count = 0
	var partly_count = 0
	var cloud_count = 0
	var rain_count = 0
	var storm_count = 0
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
				
			var r = (row + i + Global.ROWS) % Global.ROWS
			var c = (col + j + Global.COLS) % Global.COLS
			var neighbor_state = Global.board[r][c].state
			
			match neighbor_state:
				Global.States.SUN:
					sun_count += 1
				Global.States.PARTLY_CLOUD:
					partly_count += 1
				Global.States.CLOUD:
					cloud_count += 1
				Global.States.RAIN:
					rain_count += 1
				Global.States.STORM:
					storm_count += 1
	
	if storm_count >= 2:
		return Global.States.STORM
	
	if rain_count >= 2:
		return Global.States.RAIN
	
	if cloud_count >= 2:
		if randf() < 0.6:
			return Global.States.CLOUD
		else:
			return Global.States.PARTLY_CLOUD
	
	if sun_count >= 1 and cloud_count >= 1:
		return Global.States.PARTLY_CLOUD
	
	if sun_count >= 2:
		return Global.States.SUN
	
	return Global.States.PARTLY_CLOUD
	
	
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
					next_state = decide_weather_state(i, j)
				else:
					next_state = Global.States.CLEAR
			else:
				if vecinos == 3:
					next_state = decide_weather_state(i, j)
				else:
					next_state = Global.States.CLEAR

			row.append(next_state)

		next_states.append(row)

	for i in range(Global.ROWS):
		for j in range(Global.COLS):
			Global.board[i][j].set_state(next_states[i][j])

# ******************************************************************
# GLOBAL FUNCTIONS
# ******************************************************************

func end_game() -> void:
	if Global.Credibility <= 70:
		print("No has llegado al minimo de aciertos\n")
		get_tree().quit()
	elif Global.Credibility >= 150:
		print("Enhorabuena has conseguido un ascenso\n")
		get_tree().quit()
		
		
# ******************************************************************
# UI
# ******************************************************************

func show_day() -> void:
	$UI/CurrentDay/CurrentDayText.text = str(Global.Day)


func update_credibility() -> void:
	#funcion para calcular credibilidad AQUI
	show_credibility()

func show_credibility() -> void:
	$UI/CredibilityLabel/CredibilityLabelText.text = str(Global.Credibility)

func update_predictions_left() -> void:
	show_predictions_left()

func show_predictions_left() -> void:
	var remaining = Global.MAX_PREDICTIONS - predictions.size()
	$UI/PredictionsLeft/PredictionsLeftText.text = str(remaining)
	
		
func next_day() -> void:
	
	Global.Day += 1

	if Global.Day > Global.MaxDay: get_tree().quit()
	else: show_day()
	
	simulate_board()
	check_predictions()
	selected_prediction = null
	predictions.clear()
	update_predictions_left()
	
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

func _on_next_day_button_pressed() -> void:
	$UI/ClickSound.play()
	next_day()


func _on_screen_mouse_click_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

		var mouse_pos = event.position

		var col = int((mouse_pos.x - OFFSET_X) / Global.CELL_SIZE)
		var row = int((mouse_pos.y - OFFSET_Y) / Global.CELL_SIZE)
		
		if row >= 0 and row < Global.ROWS and col >= 0 and col < Global.COLS:
			if selected_prediction != null:
				print("Debes asignar primero un estado a la predicción pendiente")
				return
				
			if predictions.size() >= Global.MAX_PREDICTIONS:
				print("Ya tienes el máximo de predicciones")
				return
	
			var new_prediction = Prediction.new(
				Vector2i(row, col),
				Global.Day
	)
	
			predictions.append(new_prediction)
			selected_prediction = new_prediction
			update_predictions_left()
			var numero_prediccion = predictions.size()
			print("Predicción #", numero_prediccion, " en celda ", new_prediction.position)


func _on_predictions_mouse_click_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = event.position
		var offset = $UI/TrayPredictions.position
		var local_pos = mouse_pos - offset
		
		var prediction_state = int(local_pos.x / Global.CELL_SIZE) + 1

		if selected_prediction == null:
			print("Selecciona primero una celda")
			return
	
		# Si es goma (6)
		if prediction_state == 6:
			predictions.erase(selected_prediction)
			print("Predicción borrada")
			selected_prediction = null
			update_predictions_left()
			return
	
		selected_prediction.state = prediction_state
		print("Estado asignado:", prediction_state)
		selected_prediction = null
		update_predictions_left()
