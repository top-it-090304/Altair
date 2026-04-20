extends CanvasLayer

const SPRITESHEET = preload("res://Assets/Textures/Other/Confetti (16x16).png")
const FRAME_COUNT = 6
const FRAME_W = 16
const FRAME_H = 16
const EFFECT_DURATION = 2.0
const PARTICLES_PER_EMITTER = 33  # 33 * 6 = 198 частиц суммарно


func play() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var half_w := viewport_size.x / 2.0

	for i in FRAME_COUNT:
		var atlas := AtlasTexture.new()
		atlas.atlas = SPRITESHEET
		atlas.region = Rect2(i * FRAME_W, 0, FRAME_W, FRAME_H)

		var mat := ParticleProcessMaterial.new()

		# Спавн по всей ширине экрана у верхнего края
		mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		mat.emission_box_extents = Vector3(half_w, 1.0, 0.0)

		# Направление: вниз с небольшим случайным отклонением
		mat.direction = Vector3(0.0, 1.0, 0.0)
		mat.spread = 20.0
		mat.initial_velocity_min = 100.0
		mat.initial_velocity_max = 260.0

		# Гравитация вниз
		mat.gravity = Vector3(0.0, 180.0, 0.0)

		# Вращение каждой частицы
		mat.angle_min = 0.0
		mat.angle_max = 360.0
		mat.angular_velocity_min = -220.0
		mat.angular_velocity_max = 220.0

		# Масштаб — маленький (0.5)
		mat.scale_min = 0.5
		mat.scale_max = 0.5

		# Случайность стартового времени чтобы не все одновременно
		mat.lifetime_randomness = 0.6

		var particles := GPUParticles2D.new()
		particles.texture = atlas
		particles.process_material = mat
		particles.amount = PARTICLES_PER_EMITTER
		particles.lifetime = EFFECT_DURATION
		particles.one_shot = true
		particles.explosiveness = 0.0
		particles.randomness = 0.5
		# Центр по X, чуть выше верхнего края экрана
		particles.position = Vector2(half_w, -8.0)
		particles.emitting = true
		add_child(particles)

	# Ждём реальное время (ignore_time_scale = true), не зависит от Engine.time_scale
	await get_tree().create_timer(EFFECT_DURATION, true, false, true).timeout
