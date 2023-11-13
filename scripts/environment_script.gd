extends WorldEnvironment

const night_star = preload("res://assets/night_sky_star_texture.tres")
@onready var light = %DirectionalLight3D
var is_night = false

func good_night():
	is_night = true
	environment.sky.sky_material.energy_multiplier = 1.0
	environment.sky.sky_material.rayleigh_coefficient = 0.05
	environment.sky.sky_material.night_sky = night_star
	light.light_energy = 0.01
	light.light_color = Color(0, 104/255.0, 1.0)

func good_morning():
	is_night = false
	environment.sky.sky_material.energy_multiplier = 3.0
	environment.sky.sky_material.rayleigh_coefficient = 2.0
	environment.sky.sky_material.night_sky = null
	light.light_energy = 1.0
	light.light_color = Color(1.0, 1.0, 1.0)

func toggle_night():
	if is_night:
		good_morning()
	else:
		good_night()

func _ready() -> void:
	good_morning()
