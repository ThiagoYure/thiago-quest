extends Node

var key_parts = 0
var npc_questions = {"Soldado":false, "Novo Soldado": false}

func get_key_part(npc_id):
	if npc_questions.has(npc_id):
		npc_questions[npc_id] = true
		key_parts += 1
		print("Você ganhou um pedaço de chave!" + str(key_parts))
