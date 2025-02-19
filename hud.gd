extends CanvasLayer

signal start_game


@onready var lives_label = $LivesLabel
@onready var best_score = $BestScoreLabel
var best_score_value = 0


func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()


func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = "Dodge the\nCreeps"
	$MessageLabel.show()
	best_score.show()
	lives_label.show()
	await get_tree().create_timer(1).timeout
	$StartButton.show()


func update_score(score):
	if score > best_score_value:
		best_score_value = score
		best_score.text = "Best Score: " + str(score)
	$ScoreLabel.text = str(score)


func _on_StartButton_pressed():
	$StartButton.hide()
	$LivesLabel.show()
	$LivesIcon.show()
	start_game.emit()


func _on_MessageTimer_timeout():
	$MessageLabel.hide()


func update_lives(lives):
	lives_label.text = "= " + str(lives)
	
