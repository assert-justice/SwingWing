extends Node

class_name NetworkManager

export var url = "http://assertjustice.pythonanywhere.com/?game=swingwing"

func _ready():
	$Getter.connect("request_completed", self, "_on_get_completed")
	$Poster.connect("request_completed", self, "on_post_completed")

func load_leaderboard():
	$Getter.request(url)

func post_score(name, score):
	var post = {"name": name, "score": score, "game": "swingwing"}
	$Poster.request(url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(post))

func _on_get_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8()).result
	print(json)
	emit_signal("get_completed", json)

func _on_post_completed(result, response_code, headers, body):
	print(body)

signal get_completed(data)
