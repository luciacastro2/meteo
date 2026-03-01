extends Node

enum Screen{
	TITLE,
	SIMULATOR,
	ENDING
}

const CELL_SIZE: int = 80
const ROWS: int = 6
const COLS: int = 8
const MaxDay: int = 28
const MAX_PREDICTIONS := 3

var Credibility = 100
var Day: int = 1
var board = []

enum States{
	CLEAR,
	SUN,
	PARTLY_CLOUD,
	CLOUD,
	RAIN,
	STORM
}
