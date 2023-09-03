extends Actor


var speed = 100
const SILENCE_DISTANCE = 500
const SILENCE = -18

var rng = RandomNumberGenerator.new()
var player: CharacterBody2D = null
const DISTANCE_THRESHOLD = 300
const CELL_SIZE = 40
var path = null
var direction = Vector2.ZERO
var grid: Array = []
var grid_size = null
var tile_size = null

class AStarNode:
    var x: int
    var y: int
    var traversable: bool
    
    func _init(x: int, y: int, traversable: bool) -> void:
        self.x = x
        self.y = y
        self.traversable = traversable
        
    func _to_string():
        return "[" + str(self.x) + ", " + str(self.y) + "] - traversable: " + str(self.traversable) + "\n"
        
    func as_vector(tile_size) -> Vector2:
        return Vector2(((self.x + 1) * tile_size), ((self.y + 1) * tile_size))
        
    func as_centered_vector(tile_size) -> Vector2:
        var v = self.as_vector(tile_size)
        return Vector2(v[0] + (tile_size / 2), v[1] + (tile_size / 2))
        
func populate_grid_with_nodes(tilemap: TileMap, grid_size: Vector2) -> Array:
    
    for y in range(grid_size.y):
        var row: Array = []
        
        for x in range(grid_size.x):
            var cell_coords = Vector2(x, y)
            
            # Check if there's a tile at this position
            var tile_id = tilemap.get_cell_tile_data(0, cell_coords)
            
            # If tile_id is -1, the cell is empty (i.e., traversable)
            var is_traversable = (tile_id == null)
            
            # Create a Node and add it to the row
            var node = AStarNode.new(x, y, is_traversable)
            row.append(node)
        
        # Add the row to the grid
        grid.append(row)
    
    return grid

func control_laugh():
    if player != null:
        var distance = player.position.distance_to(self.position)
        
        # Clamp the distance to be within [0, SILENCE_DISTANCE]
        distance = clamp(distance, 0, SILENCE_DISTANCE)
        
        # Calculate the ratio of the current distance to the SILENCE_DISTANCE
        var ratio = distance / SILENCE_DISTANCE
        # Linearly interpolate the volume from -100 to 0 based on the ratio
        var volume = lerp(0, SILENCE, ratio)
        
        $AudioStreamPlayer2D.volume_db = volume

func random_destination() -> AStarNode:
    var d = null
    while d == null or not d.traversable:
        d = grid[randi() % grid.size()][randi() % grid[0].size()]
    return d

func _process(_delta):
    control_laugh()
    
    if path:
        direction = (path.front().as_centered_vector(tile_size) - position).normalized()
        
    if player == null or not path:
        return
        
    var distance_player = position.distance_to(player.position)
    var distance_destination = position.distance_to(path.front().as_vector(tile_size))
    
    var player_node = get_node_at_index(player.position)
    var enemy_node = get_node_at_index(position)
    
    if player_node == null or enemy_node == null:
        return
    
    if distance_player < DISTANCE_THRESHOLD and player_node != path[-1]:
        print("player")
        path = a_star(enemy_node, player_node, grid)
    elif enemy_node == path.front():
        if path.size() > 1:
            print("pop")
            path.pop_front()
        else:
            print("newe")
            path = a_star(enemy_node, random_destination(), grid)
        

    velocity = direction * speed

    move_and_slide()
    $"../CanvasLayer/Glisten".global_position = global_position
    set_animation(velocity)

func heuristic(a, b) -> float:
    return abs(a.x - b.x) + abs(a.y - b.y)

func a_star(start, goal, grid) -> Array:
    var open_set = [start]
    var came_from = {}
    var g_score = {}
    var f_score = {}
    
    for y in grid.size():
        for x in grid[y].size():
            g_score[grid[y][x]] = INF
            f_score[grid[y][x]] = INF
            
    g_score[start] = 0
    f_score[start] = heuristic(start, goal)
    
    while open_set.size() > 0:
        var current = open_set[0]
        for node in open_set:
            if f_score[node] < f_score[current]:
                current = node
                
        if current == goal:
            var path = []
            var temp = current
            while temp in came_from:
                path.append(temp)
                temp = came_from[temp]
            path.reverse()
            return path
        
        open_set.erase(current)
        
        for neighbor in get_neighbors(current, grid):
            var tentative_g_score = g_score[current] + 1
            if tentative_g_score < g_score[neighbor]:
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g_score
                f_score[neighbor] = g_score[neighbor] + heuristic(neighbor, goal)
                if neighbor not in open_set:
                    open_set.append(neighbor)
                    
    return []
    
func get_neighbors(node: AStarNode, grid: Array) -> Array:
    var neighbors = []
    var x = node.x
    var y = node.y
    
    # Check East
    if x + 1 < grid[y].size():
        var east_neighbor = grid[y][x + 1]
        if east_neighbor.traversable:
            neighbors.append(east_neighbor)
    
    # Check South
    if y + 1 < grid.size():
        var south_neighbor = grid[y + 1][x]
        if south_neighbor.traversable:
            neighbors.append(south_neighbor)
    
    # Check West
    if x - 1 >= 0:
        var west_neighbor = grid[y][x - 1]
        if west_neighbor.traversable:
            neighbors.append(west_neighbor)
    
    # Check North
    if y - 1 >= 0:
        var north_neighbor = grid[y - 1][x]
        if north_neighbor.traversable:
            neighbors.append(north_neighbor)
    
    return neighbors

func get_node_at_index(location: Vector2i) -> AStarNode:
    var ix = int(location.x / tile_size) - 1
    var iy = int( location.y / tile_size ) - 1
    if iy >= grid.size() or ix >= grid[iy].size():
        return null
    return grid[iy][ix]

func post_ready():
    var p = get_tree().get_nodes_in_group("maze")[0]
    player = get_tree().get_nodes_in_group("player")[0]
    var tilemap = p.find_child("TileMap")
    tile_size = tilemap.tile_set.tile_size.x
    grid_size = Vector2((p.grid_size * p.cell_size) - 1, (p.grid_size * p.cell_size) - 1)  # Replace with your actual grid size
    populate_grid_with_nodes(tilemap, grid_size)
    path = a_star(get_node_at_index(position), random_destination(), grid)
    $AudioStreamPlayer2D.play()


func _on_audio_stream_player_2d_finished():
    $AudioStreamPlayer2D.stream_paused = false
    $AudioStreamPlayer2D.play()
