extends Control

export (String, FILE, "*.txt") var team_credits_bbcode_file = "res://assets/data/team_credits.txt"

onready var _team_credits: RichTextLabel = $MarginContainer/VBoxContainer/TabContainer/Team/Team

func _ready():
	_team_credits.bbcode_enabled = true
	_team_credits.bbcode_text = FileUtil.load_text(team_credits_bbcode_file)


func _on_Team_meta_clicked(meta):
	OS.shell_open(str(meta))
