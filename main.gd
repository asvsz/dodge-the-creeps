extends Node

@export var mob_scene: PackedScene
var score = 0  

@onready var best_score_label = $HUD/BestScoreLabel
@onready var particles = $GPUParticles2D  
@onready var score_timer = $ScoreTimer  
@onready var mob_timer = $MobTimer  
@onready var hud = $HUD  

@export var score_threshold = 10
@export var particle_duration = 3

var particles_active = false  # Controla se as partículas estão ativas
var particles_cooldown = false  # Controla se as partículas podem ser ativadas


func _ready():
	particles.emitting = false
	print("Particles initially disabled")

	score_timer.wait_time = 1.0
	score_timer.timeout.connect(_on_score_timer_timeout)

	mob_timer.stop()  # Agora o MobTimer NÃO começa sozinho

	# Conectar o sinal do botão Start do HUD para garantir que só inicie quando o jogador clicar
	hud.start_game.connect(new_game)

func _on_score_timer_timeout():
	if score >= score_threshold and not particles.emitting:
		activate_particles()

func activate_particles():
	if particles_active or particles_cooldown:
		return  # Evita reativação durante o cooldown
	
	print("Ativando partículas!")
	particles.emitting = true
	particles_active = true
	particles_cooldown = true  # Impede nova ativação até que o cooldown termine
	
	var temp_timer = Timer.new()
	temp_timer.wait_time = particle_duration
	temp_timer.one_shot = true
	temp_timer.timeout.connect(_deactivate_particles)
	add_child(temp_timer)
	temp_timer.start()

func _deactivate_particles():
	print("Desativando partículas!")
	particles.emitting = false
	particles_active = false
	
	# Criar um pequeno tempo de espera antes de permitir nova ativação
	var cooldown_timer = Timer.new()
	cooldown_timer.wait_time = 2.0  # Define um tempo de cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(func():
		particles_cooldown = false  # Libera para ativação futura
		print("Cooldown encerrado, partículas podem ser ativadas novamente.")
	)
	add_child(cooldown_timer)
	cooldown_timer.start()


func update_score(new_score):
	score = new_score
	print("Score atualizado para: ", score)
	if score >= score_threshold and not particles.emitting:
		activate_particles()

func game_over():
	score_timer.stop()
	mob_timer.stop()
	hud.show_game_over()
	$Music.stop()
	$DeathSound.play()

func new_game():
	print("Novo jogo iniciado!")  # Depuração
	get_tree().call_group(&"mobs", &"queue_free")
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	hud.update_score(score)
	hud.show_message("Get Ready")
	best_score_label.hide()
	$Music.play()

	# Agora os timers só começam quando o jogo realmente inicia
	score_timer.start()
	mob_timer.start()

func _on_MobTimer_timeout():
	print("Spawn de meteoros!")
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress = randi()
	mob.position = mob_spawn_location.position
	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	add_child(mob)

func _on_ScoreTimer_timeout():
	score += 1
	hud.update_score(score)
