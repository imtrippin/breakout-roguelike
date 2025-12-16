extends Area2D

func _on_area_2d_body_shape_entered(
	_body_rid: RID, 
	body: Node2D, 
	_body_shape_index: int, 
	_local_shape_index: int
	) -> void:
	# Only kill balls
	if body.is_in_group("ball") and body.has_method("die_in_void"):
		body.die_in_void()


	
