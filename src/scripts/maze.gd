extends Node2D

@export var grid_size: int = 11
@export var cell_size: int = 2
var grid: Array = []
var rng = RandomNumberGenerator.new()
var cells = []
var enemy = preload("res://enemy.tscn")



class MazeNode:
    var x : int
    var y : int
    var visited: bool = false
    var east_path: bool = false
    var south_path: bool = false
    
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
                

                
func recursive_backtracker():
    var stack = MazeNodeStack.new()
    stack.push(grid[0][0])
    stack.peek().visited = true
    
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

func spawn_random_enemy():
    var location = Vector2i(randi() % grid.size(), randi() % grid.size())
    var node = grid[location.y][location.x]
    
    # Check if the selected grid location is an open path
    if not node.east_path and not node.south_path:
        spawn_random_enemy()
        return
    
    # Calculate the real-world position based on the grid location and cell size
    var real_world_x = (location.x * cell_size + cell_size / 2) * $TileMap.tile_set.tile_size.x
    var real_world_y = (location.y * cell_size + cell_size / 2) * $TileMap.tile_set.tile_size.y
    var real_world = Vector2(real_world_x, real_world_y)
    
    var instance = enemy.instantiate()
    add_child(instance)
    instance.position = real_world


func remove_wall_exit():
    var cell = get_random_exit()
    $TileMap.set_cell(0, cell, -1, Vector2i(3,3))
    $PointLight2D.global_position = move_light_to_exit(cell)


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

func _ready():
    rng.seed = 0
    
    initialize_grid()

#    grid[0][0].east_path = true
#    var coords = Vector2i(0, 0)
#    $TileMap.set_cell(0, coords, 0, Vector2i(3,3))
#    $TileMap.set_cell(0, coords, 0, Vector2i(3,3))
    recursive_backtracker()
#    initialize_grid()
    draw_maze($TileMap)
    remove_wall_exit()
#    var my_timer = Timer.new()
    $TileMap.set_cells_terrain_connect(0, $TileMap.get_used_cells(0), 0, 0, true)
    spawn_random_enemy()
    
#    my_timer.wait_time = 1.0  # Set the wait time to 1 second
#    my_timer.autostart = true  # Set to start automatically
#
#    my_timer.connect("timeout", remove_wall_exit)
#
#    add_child(my_timer)

