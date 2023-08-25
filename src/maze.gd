extends Node2D

@export var grid_size: int = 10
var grid: Array = []


 


func initialize_grid():
    for i in range(grid_size):
        grid.append([])
        for j in range(grid_size):
            grid[i].append(0) # 0 represents a wall, 1 represents a path


func generate_maze(start_x, start_y):
    var stack = []
    stack.push_back(Vector2(start_x, start_y))
    grid[start_x][start_y] = 1

    while stack.size() > 0:
        var current = stack.pop_back()
        var x = current.x
        var y = current.y
        var directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]
        directions.shuffle()

        for direction in directions:
            var nx = x + direction[0] * 2
            var ny = y + direction[1] * 2

            if nx >= 0 and nx < grid_size and ny >= 0 and ny < grid_size and grid[nx][ny] == 0:
                grid[x + direction[0]][y + direction[1]] = 1
                grid[nx][ny] = 1
                stack.push_back(Vector2(x, y)) # Push the current cell back onto the stack
                stack.push_back(Vector2(nx, ny)) # Push the next cell onto the stack
                break # Break to process the next cell on the next iteration

            
func draw_maze(tilemap: TileMap):
    for i in range(grid.size()):
        for j in range(grid[i].size()):
            if grid[i][j] == 1:
                var coords = Vector2i(i, j)
                var source_id = 0 # The source ID of the tile you want to place
                var atlas_coords = Vector2i(3, 3) # The atlas coordinates of the tile
                tilemap.set_cell(0, coords, source_id, atlas_coords)


func _ready():
    initialize_grid()
    grid[1][1] = 1 # Start point
    generate_maze(1, 1)
    var tilemap = $TileMap
    draw_maze(tilemap)
    
    # update() # Call to redraw the maze


#
#func _draw():
#    for i in range(grid_size):
#        for j in range(grid_size):
#            if grid[i][j] == 0:
#                draw_rect(Rect2(i * cell_size, j * cell_size, cell_size, cell_size), Color(0, 0, 0))
#            else:
#                draw_rect(Rect2(i * cell_size, j * cell_size, cell_size, cell_size), Color(1, 1, 1))

