extends Node

const CELL_SIZE: int = 80
const ROWS: int = 6
const COLS: int = 8
const MaxDay: int = 23580

var Credibility
var Day: int = 1
var board = []

enum States{
	CLEAR,
	SUN,
	CLOUD,
	RAIN,
	STORM
}
