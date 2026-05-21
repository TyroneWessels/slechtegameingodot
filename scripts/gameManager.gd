extends Node

enum Area_Type {Main, crackalley}

var areaDict = {
	Area_Type.Main: "res://scenes/Main.tscn",
	Area_Type.crackalley: "res://scenes/map1.tscn"
}

var lastArea: Area_Type

func change_area(currentArea: Area_Type):
	lastArea = currentArea
