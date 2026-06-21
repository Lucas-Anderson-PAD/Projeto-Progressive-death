extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if "water" in body:
		body.water = true

func _on_body_exited(body):
	if "water" in body:
		body.water = false
