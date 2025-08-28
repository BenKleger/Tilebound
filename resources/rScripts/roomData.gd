class_name RoomData
extends Resource

var id: int
var depth: int
var type: String = "normal" # start, boss, treasure, etc.
var children = []
var cleared: bool = false

var reward: String = "none" # coin, health, upgrade, shop, boss, etc.
