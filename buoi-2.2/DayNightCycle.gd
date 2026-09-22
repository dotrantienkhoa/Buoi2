extends WorldEnvironment

@export var day_length: float = 60.0

@export var sun: DirectionalLight3D

var time: float = 0.0

var day_top := Color(0.385, 0.454, 0.55)
var day_horizon := Color(0.6463, 0.6558, 0.6708)

var sunset_top := Color(0.35, 0.12, 0.08)
var sunset_horizon := Color(1.0, 0.35, 0.08)

var night_top := Color(0.01, 0.02, 0.06)
var night_horizon := Color(0.08, 0.10, 0.16)

func _ready() -> void:

	# Kiểm tra DirectionalLight3D
	if sun == null:
		push_warning("Chưa gán DirectionalLight3D vào biến Sun!")
		return

	# Kiểm tra Environment
	if environment == null:
		push_warning("WorldEnvironment chưa có Environment!")
		return

	# Kiểm tra Sky
	if environment.sky == null:
		push_warning("Environment chưa có Sky!")
		return

	# Tạo bản sao Material để thay đổi bằng code
	if environment.sky.sky_material != null:
		environment.sky.sky_material = environment.sky.sky_material.duplicate()

func _process(delta: float) -> void:

	if sun == null:
		return

	if environment == null:
		return

	if environment.sky == null:
		return

	var sky_material := environment.sky.sky_material as ProceduralSkyMaterial

	if sky_material == null:
		return


	# --------------------------------
	# Tăng thời gian
	# --------------------------------

	time += delta

	if time >= day_length:
		time = 0.0


	# --------------------------------
	# Tính tiến trình ngày
	# 0.0 → 1.0
	# --------------------------------

	var progress := time / day_length


	# --------------------------------
	# Cho mặt trời quay
	# --------------------------------

	sun.rotation_degrees.x = progress * 360.0 - 90.0


	# --------------------------------
	# Xác định độ cao mặt trời
	# --------------------------------

	var sun_height := sin(progress * TAU)


	var top_color: Color
	var horizon_color: Color
	var light_energy: float


	# =================================
	# ☀️ BAN NGÀY
	# =================================

	if sun_height > 0.3:

		top_color = day_top
		horizon_color = day_horizon

		# Mặt trời sáng
		light_energy = 1.2


	# =================================
	# 🌅 HOÀNG HÔN / BÌNH MINH
	# =================================

	elif sun_height > -0.15:

		# Chuyển từ hoàng hôn → ngày
		var t := (sun_height + 0.15) / 0.45

		top_color = sunset_top.lerp(day_top, t)
		horizon_color = sunset_horizon.lerp(day_horizon, t)

		# Ánh sáng giảm dần
		light_energy = lerp(0.15, 1.2, t)


	# =================================
	# 🌙 BAN ĐÊM
	# =================================

	else:

		top_color = night_top
		horizon_color = night_horizon

		# Ánh sáng mặt trời rất yếu
		light_energy = 0.1


	# =================================
	# ÁP DỤNG MÀU CHO PROCEDURAL SKY
	# =================================

	sky_material.sky_top_color = top_color
	sky_material.sky_horizon_color = horizon_color


	# =================================
	# ÁP DỤNG ĐỘ SÁNG CHO MẶT TRỜI
	# =================================

	sun.light_energy = light_energy
