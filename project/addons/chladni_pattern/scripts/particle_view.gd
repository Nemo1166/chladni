extends TextureRect

enum FillMode { STRETCH, FIT, COVER }

@export var fill_mode: FillMode = FillMode.FIT
@export_range(1, 12, 1) var particle_size: int = 5
@export var particle_color: Color = Color(0.5, 0.8, 1.0, 0.8)

var _image: Image
var _texture: ImageTexture


func _ready():
	_resize_image()
	resized.connect(_resize_image)


func _resize_image():
	var vs := size
	var w := int(vs.x)
	var h := int(vs.y)
	if w <= 0 or h <= 0:
		return
	if _image and _image.get_width() == w and _image.get_height() == h:
		return
	_image = Image.create(w, h, false, Image.FORMAT_RGBA8)
	_texture = ImageTexture.create_from_image(_image)
	texture = _texture


func render(positions: PackedVector2Array, count: int):
	if _image == null:
		return
	_image.fill(Color(0, 0, 0, 0))

	var half := int(particle_size / 2.0)
	var img_w := _image.get_width()
	var img_h := _image.get_height()

	var square: float
	var off_x: float
	var off_y: float

	match fill_mode:
		FillMode.STRETCH:
			square = 0.0
			off_x = 0.0
			off_y = 0.0
		FillMode.FIT:
			square = minf(img_w, img_h)
			off_x = (img_w - square) / 2.0
			off_y = (img_h - square) / 2.0
		FillMode.COVER:
			square = maxf(img_w, img_h)
			off_x = (img_w - square) / 2.0
			off_y = (img_h - square) / 2.0

	for i in count:
		var sx: int
		var sy: int
		if fill_mode == FillMode.STRETCH:
			sx = int(positions[i].x * img_w)
			sy = int(positions[i].y * img_h)
		else:
			sx = int(positions[i].x * square + off_x)
			sy = int(positions[i].y * square + off_y)

		var x0 := clampi(sx - half, 0, img_w - 1)
		var y0 := clampi(sy - half, 0, img_h - 1)
		var x1 := clampi(sx + half, 0, img_w - 1)
		var y1 := clampi(sy + half, 0, img_h - 1)
		if x1 > x0 and y1 > y0:
			_image.fill_rect(Rect2i(x0, y0, x1 - x0, y1 - y0), particle_color)

	_texture.update(_image)
