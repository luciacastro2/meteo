extends SubViewport

var crt_view
var title_screen
var game_screen
var ending_screen

func _ready():
	crt_view = get_node("CRTViewport")
	title_screen = crt_view.get_node("TitleScreen")
	game_screen = crt_view.get_node("CRT")
	ending_screen = crt_view.get_node("EndingScreen")
	
	# Mostrar solo la pantalla de título al inicio
	title_screen.show()
	game_screen.hide()
	ending_screen.hide()
