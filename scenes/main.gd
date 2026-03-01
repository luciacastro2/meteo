extends Node2D

signal day_changed
signal prediction_tray_clicked(event: InputEvent)


func _on_next_day_button_pressed() -> void:
	emit_signal("day_changed")


func _on_predictions_mouse_click_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	emit_signal("prediction_tray_clicked", event)
