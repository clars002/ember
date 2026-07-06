@tool
extends Node3D

var cell_size = 3

@export_file("*.tscn") var current_map: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	generate_map(current_map)
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed("quit"):
			get_tree().quit()
		if Input.is_action_just_pressed("save_scene"): # credit: https://forum.godotengine.org/t/how-to-save-node-like-scene-via-code/1240
			var node_to_save = $"@Node3D@2" # TODO: Figure out if we can change this name
			var scene = PackedScene.new()
			
			scene.pack(node_to_save)
			
			ResourceSaver.save(scene, "res://map_export.tscn")

#func _on_tile_map_layer_changed() -> void: # Doesn't work for dynamic map changes; signal isn't emitted when editing from Godot editor
	#print("TileMapLayer changed!")
	#if $world != null:
		#$world.queue_free()
	#generate_map()


func generate_map(source_map):
	var loaded_map = load(source_map)
	var instantiated_map = loaded_map.instantiate()
	
	var world = Node3D.new()

	add_child(world)

	var map = instantiated_map
	var terrain = map.get_child(0)
	var start_time = Time.get_ticks_msec()
	for square in terrain.get_used_cells():
		var tile_data = terrain.get_cell_tile_data(square)
		var cell_scene_path = "res://scenes/terrain/cell_" + tile_data.get_custom_data("material") + ".tscn"
		var cell_scene = load(cell_scene_path)
		var new_cell = cell_scene.instantiate()
		world.add_child(new_cell)
		new_cell.set_owner(world)
		new_cell.position.x = square.x * cell_size
		new_cell.position.z = square.y * cell_size
		if terrain.get_cell_tile_data(Vector2(square.x + 1, square.y)) == null:
			#new_cell.get_child(4).show()
			new_cell.toggle_wall(0)
		if terrain.get_cell_tile_data(Vector2(square.x - 1, square.y)) == null:
			new_cell.toggle_wall(2)
			#new_cell.get_child(1).show()
		if terrain.get_cell_tile_data(Vector2(square.x, square.y + 1)) == null:
			new_cell.toggle_wall(1)
			#new_cell.get_child(5).show()
		if terrain.get_cell_tile_data(Vector2(square.x, square.y - 1)) == null:
			new_cell.toggle_wall(3)
			#new_cell.get_child(3).show()
			
	terrain.hide()
	
	var actors = map.get_child(1)
	for actor in actors.get_used_cells():
		var tile_data = actors.get_cell_tile_data(actor)
		var actor_scene_path = "res://scenes/actors/actor_" + tile_data.get_custom_data("actor_type") + ".tscn"
		print("actor_scene_path: ", actor_scene_path)
		var actor_scene = load(actor_scene_path)
		var new_actor = actor_scene.instantiate()
		world.add_child(new_actor)
		new_actor.set_owner(world)
		new_actor.position.x = actor.x * cell_size
		new_actor.position.z = actor.y * cell_size
		
	actors.hide()
	
	print("Map built and populated in: ", (Time.get_ticks_msec() - start_time), " ms")
