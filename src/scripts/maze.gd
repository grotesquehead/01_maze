extends Node2D

@export var grid_size: int = 11
@export var cell_size: int = 2
var grid: Array = []
var rng = RandomNumberGenerator.new()
var cells = []
var enemy = preload("res://enemy/enemy.tscn")
var dead = preload("res://dead.tscn")
var level = 0
var enemy_instance = null

const SPEED_ADDITIVE = 20
const MIN_ENEMY_SPAWN = 500




class MazeNode:
    var x : int
    var y : int
    var visited: bool = false
    var east_path: bool = false
    var south_path: bool = false
    var end_node: bool = false
    
    func _init(x: int, y: int) -> void:
        self.x = x
        self.y = y
        
    func _to_string():
        return "[x: " + str(self.x) + ", y: " + str(self.y) + "], east_path: " + str(self.east_path) + "|south_path: " + str(self.south_path)

class MazeNodeStack:
    var l: Array[MazeNode] = []
    
    func push(node: MazeNode) -> void:
        l.append(node)
        
    func peek() -> MazeNode:
        return l[-1]
        
    func pop() -> MazeNode:
        return l.pop_back()
        
    func _to_string():
        return str(self.l)
        
    func size():
        return l.size()
        
    func empty():
        return self.size() == 0

func initialize_grid():
    grid = []
    var atlas_coords = Vector2i(3, 3)
    
    # Draw north and west walls.
    
    for y in range((grid_size * cell_size) + 1):
        $TileMap.set_cell(0, Vector2i(-1, y - 1), 0, atlas_coords)
        cells.append(Vector2i(-1, y - 1))
    for x in range((grid_size * cell_size) + 1):
        $TileMap.set_cell(0, Vector2i(x - 1, -1), 0, atlas_coords)
        cells.append(Vector2i(x - 1, -1))        
    
    for y in range(grid_size):
        grid.append([])
        for x in range(grid_size):
            grid[y].append(MazeNode.new(x, y))
            for y_cell in range(cell_size):
                for x_cell in range(cell_size):
                    if not x_cell and not y_cell:
                        continue
                    $TileMap.set_cell(0, Vector2i((x * cell_size) + y_cell, (y * cell_size) + x_cell), 0, atlas_coords)

func get_random_exit() -> Vector2i:
    var options = []
    
    for i in range(grid_size):
        # All northern wall.
        if $TileMap.get_cell_source_id(0, Vector2i(i, 0)) == -1:
            options.append(Vector2i(i, -1))
        
        # All eastern wall.
        if $TileMap.get_cell_source_id(0, Vector2i((grid_size * cell_size) - 2, i)) == -1:
            options.append(Vector2i((grid_size * cell_size) - 1, i))
        
        # All southern wall.
        if $TileMap.get_cell_source_id(0, Vector2i(i, (grid_size * cell_size) - 2)) == -1:
            options.append(Vector2i(i, (grid_size * cell_size) - 1))
        
        # All western wall.
        if $TileMap.get_cell_source_id(0, Vector2i(0, i)) == -1:
            options.append(Vector2i(-1, i))
        
    return options[randi() % options.size()]
  
func draw_maze(tilemap: TileMap):
    var source_id = -1
    for y in range(grid.size()):
        for x in range(grid[y].size()):
            var current_node = grid[y][x];
            if current_node.east_path:
                var coords = Vector2i((x * cell_size) + 1, y * cell_size)
                tilemap.set_cell(0, coords, source_id)
            
            if current_node.south_path:
                var coords = Vector2i(x * cell_size , (y * cell_size) + 1)
                tilemap.set_cell(0, coords, source_id)

            # Check if the current node is an end node
            if current_node.end_node:
                # Generate a list of possible walls to remove
                var possible_walls_to_remove = []
                
                if y > 0 and not grid[y - 1][x].south_path:
                    possible_walls_to_remove.append("north")
                    
                if x < grid[y].size() - 1 and not current_node.east_path:
                    possible_walls_to_remove.append("east")
                    
                if y < grid.size() - 1 and not current_node.south_path:
                    possible_walls_to_remove.append("south")
                    
                if x > 0 and not grid[y][x - 1].east_path:
                    possible_walls_to_remove.append("west")
                
                
                
                # Randomly select a wall to remove
                if possible_walls_to_remove.size() > 0:
                    var wall_to_remove = possible_walls_to_remove[randi() % possible_walls_to_remove.size()]
                    var coords
                    match wall_to_remove:
                        "west":
                            coords = Vector2i((x * cell_size) - 1, y * cell_size)
                        "east":
                            coords = Vector2i((x * cell_size) + 1, y * cell_size)
                        "north":
                            coords = Vector2i(x * cell_size, (y * cell_size) - 1)
                        "south":
                            coords = Vector2i(x * cell_size, (y * cell_size) + 1)
                    
                    tilemap.set_cell(0, coords, source_id)
                              
func recursive_backtracker():
    var stack = MazeNodeStack.new()
    stack.push(grid[0][0])
    stack.peek().visited = true
    var moving_in = true
    
    while not stack.empty():
        var current_node = stack.peek()
        var neighbours: Array = []
        
        # North
        if current_node.y - 1 >= 0 and not grid[current_node.y - 1][current_node.x].visited:
            neighbours.append([0, grid[current_node.y - 1][current_node.x]])

        # East
        if current_node.x + 1 < grid.size() and not grid[current_node.y][current_node.x + 1].visited:
            neighbours.append([1, grid[current_node.y][current_node.x + 1]])
            
        # South
        if current_node.y + 1 < grid.size() and not grid[current_node.y + 1][current_node.x].visited:
            neighbours.append([2, grid[current_node.y + 1][current_node.x]])
            
        # West
        if current_node.x - 1 >= 0 and not grid[current_node.y][current_node.x - 1].visited:
            neighbours.append([3, grid[current_node.y][current_node.x - 1]])
        
        if neighbours.is_empty():
            if moving_in:
                current_node.end_node = true
                moving_in = false
            stack.pop()
        else:
            var neighbour = neighbours[randi() % neighbours.size()]
            if neighbour[0] == 0:
                neighbour[1].south_path = true
            elif neighbour[0] == 1:
                current_node.east_path = true
            elif neighbour[0] == 2:
                current_node.south_path = true
            elif neighbour[0] == 3:
                neighbour[1].east_path = true
                
            stack.push(neighbour[1])
            neighbour[1].visited = true
            moving_in = true

func grid_to_world(l: Vector2) -> Vector2:
    return Vector2(
        ((l.x + 1) * $TileMap.tile_set.tile_size.x) + ($TileMap.tile_set.tile_size.x / 2),
        ((l.y + 1) * $TileMap.tile_set.tile_size.y) + ($TileMap.tile_set.tile_size.y / 2)
    )
    
func spawn_random_enemy():
    var tile_id
    var location
    var init = true
    
    
    while init or (tile_id != null or grid_to_world(location).distance_to(Vector2(460, 460)) < MIN_ENEMY_SPAWN):
        location = Vector2i(randi() % grid.size(), randi() % grid.size())
        tile_id = $TileMap.get_cell_tile_data(0, location)
        init = false
        
    
    var real_world = grid_to_world(location)
    
    var instance = enemy.instantiate()
    add_child(instance)
    instance.position = real_world
    instance.post_ready()
    instance.speed += SPEED_ADDITIVE * level
    enemy_instance = instance


func remove_wall_exit():
    var cell = get_random_exit()
    $TileMap.set_cell(0, cell, -1, Vector2i(3,3))
    $PointLight2D.global_position = move_light_to_exit(cell)

func inrement_level():
    level += 1
    $CanvasLayer/Score.text = "Level " + str("%02d" % level)

func move_light_to_exit(cell) -> Vector2:
    var light_position = Vector2.ZERO
    var tile_size = 40
    
    if cell.x == -1:
        light_position = Vector2(cell.x * tile_size + tile_size * 1.5, cell.y * tile_size + tile_size * 1.5)
    
    if cell.x == 21:
        light_position = Vector2(cell.x * tile_size + tile_size * 2.5, cell.y * tile_size + tile_size * 1.5)
    
    if cell.y == -1:
        light_position = Vector2(cell.x * tile_size + tile_size * 1.5, cell.y * tile_size + tile_size * 1.5)
    
    if cell.y == 21:
        light_position = Vector2(cell.x * tile_size + tile_size * 1.5, cell.y * tile_size + tile_size * 2.5)
    
    return light_position

func reset(pause: bool):
    inrement_level()
    $TileMap.clear_layer(0)
    get_tree().paused = pause
    initialize_grid()
    recursive_backtracker()
    draw_maze($TileMap)
    remove_wall_exit()
    $TileMap.set_cells_terrain_connect(0, $TileMap.get_used_cells(0), 0, 0, true)
    
    if enemy_instance != null:
        enemy_instance.queue_free()
    
    spawn_random_enemy()
    $CanvasLayer/Player.position = Vector2(460,460)
    


func _ready():
    rng.seed = 0
    reset(true)

func _on_area_2d_area_entered(area):
    $CanvasLayer/Black.fade_in = true
    $CanvasLayer/Black.active = true
    get_tree().paused = true
    await $CanvasLayer/Black.on_fade_in
    reset(true)
    
    

func _on_player_dead():
    $CanvasLayer/Black.active = true
    $CanvasLayer/Black.fade_in = true
    await $CanvasLayer/Black.on_fade_in
    get_tree().change_scene_to_file("res://dead.tscn")


