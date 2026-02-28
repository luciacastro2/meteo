extends Node

const CELL_SIZE: int = 80
const ROWS: int = 6
const COLS: int = 8
const MaxDay: int = 23580
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
