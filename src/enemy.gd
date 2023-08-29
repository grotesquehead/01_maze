extends StaticBody2D


const SPEED = 5
const SILENCE_DISTANCE = 1000
const SILENCE = -30
var direction = Vector2()
var rng = RandomNumberGenerator.new()
var player: CharacterBody2D = null



func get_random_direction() -> Vector2i:
    return [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT][randi() % 4]

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
    

func _process(delta):
    var current_position = position
    control_laugh()
    move_and_collide(direction * SPEED)
    if current_position == position:
        direction = get_random_direction()
        
    
func _ready():
    direction = get_random_direction()
    $AudioStreamPlayer2D.play()
    player = get_tree().get_nodes_in_group("player")[0]
    


func _on_bounce_zone_body_entered(body):
    var current_direction = direction
    while current_direction == direction:
        direction = get_random_direction()


func _on_audio_stream_player_2d_finished():
    $AudioStreamPlayer2D.stream_paused = false
    $AudioStreamPlayer2D.play()
