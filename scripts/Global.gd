extends Node

var key_parts = 0
var npc_questions = {"Guarda da entrada":false, "Soldado Comum":false, "Soldada Comum": false, "Soldado Popular":false, "Sacerdote Junior": false, "Sacerdote Senior":false, "A gata":false}

func get_key_part(npc_id):
	if npc_questions.has(npc_id):
		npc_questions[npc_id] = true
		key_parts += 1
		print("Você ganhou um pedaço de chave!" + str(key_parts))
