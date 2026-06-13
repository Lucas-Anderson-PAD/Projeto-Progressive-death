extends StaticBody2D

@onready var timer = $Timer

func _on_area_2d_body_entered(body):
	if body.name == "Player": 
		timer.start() 

func _on_timer_timeout():
	queue_free() 
