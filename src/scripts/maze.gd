extends Node2D

@export var grid_size: int = 10
@export var cell_size: int = 2
var grid: Array = []
var rng = RandomNumberGenerator.new()


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
	var cells = []
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
					cells.append(Vector2i((x * cell_size) + y_cell, (y * cell_size) + x_cell))
		$TileMap.set_cells_terrain_connect(0, cells, 0, 0, true)

	
  
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

