extends Node

onready var _user_data_dir := OS.get_user_data_dir()
onready var _path_separator:= "\\" if _user_data_dir.find("\\") > -1 else "/"


var _screenshot_max := 1000
var _resize_factor := 1.0
var _screenshot_action_name := "toggle_screenshots"
var _single_screenshot_action_name := "take_screenshot"
var _frame_delay := 0.2
var _directory_name := ""
var _file_counter := 0
var _user_data_directory := Directory.new()
var _threads := []
var _time_since_last_frame := 0.0
var _stopwatch := Stopwatch.new()


func _ready():
	if !OS.has_feature("debug"):
		queue_free()
		return
	set_physics_process(false)
	if OK != _user_data_directory.open("user://"):
		printerr("ScreenshotMgr: could not open user data directory")
	_init_settings()

func _init_settings():
	var temp = ProjectSettings.get_setting("global/screenshot_mgr_max_images")
	if temp and temp > 0:
		_screenshot_max = temp
	
	temp = ProjectSettings.get_setting("global/screenshot_mgr_resize_factor")
	if temp and temp > 0.0:
		_resize_factor = temp

	temp = ProjectSettings.get_setting("global/screenshot_mgr_toggle_action_name")
	if temp:
		_screenshot_action_name = temp
	
	temp = ProjectSettings.get_setting("global/screenshot_mgr_frame_delay")
	if temp:
		_frame_delay = temp


func _input(event):
	if event.is_echo():
		return
	if event.is_action_pressed(_single_screenshot_action_name):
		if !_user_data_directory.dir_exists("screenshots"):
			if OK != _user_data_directory.make_dir("screenshots"):
				printerr("ScreenshotMgr: could not create screenshots folder.  Can't save screenshot")
				return

		var image = get_viewport().get_texture().get_data()
		var thread := Thread.new()
		_threads.append(thread)
		if OK != thread.start(self, "_save_image", [image, thread, true]):
			printerr("ScreenshotMgr: could not start thread to complete saving of screenshot image.")
		return
		
	if !event.is_action_pressed(_screenshot_action_name):
		return
	if !is_physics_processing():
		_directory_name = get_date_time_string()
		_file_counter = 0
		if OK != _user_data_directory.make_dir(_directory_name):
			printerr("ScreenshotMgr: could not make directory for screenshots: %s" % _directory_name)
			return
		print("starting screenshots")
		print("screenshots will be saved to:\r\n%s%s%s" % [_user_data_dir, _path_separator, _directory_name])
		_stopwatch.start()
		set_physics_process(true)
	else:
		_stopwatch.stop()
		var seconds = _stopwatch.get_elapsed_msec() / 1000.0
		var files_per_sec = _file_counter / seconds
		print("stopping screenshots")
		print("Stats: files: %d, elapsed seconds: %f, file/sec: %f" % [_file_counter, seconds, files_per_sec])
		set_physics_process(false)


func get_date_time_string():
	# year, month, day, weekday, dst (daylight savings time), hour, minute, second.
	var datetime = OS.get_datetime()
	return "%d%02d%02d_%02d%02d%02d" % [datetime["year"], datetime["month"], datetime["day"], datetime["hour"], datetime["minute"], datetime["second"]]


func _physics_process(delta):
	if _file_counter >= _screenshot_max:
		_stopwatch.stop()
		print("Max screenshots reached.")
		var seconds = _stopwatch.get_elapsed_msec() / 1000.0
		var files_per_sec = _file_counter / seconds
		print("Stats: files: %d, elapsed seconds: %f, file/sec: %f" % [_file_counter, seconds, files_per_sec])
		set_physics_process(false)
		return
	
	_time_since_last_frame += delta
	if _time_since_last_frame < _frame_delay:
		return
	_time_since_last_frame -= _frame_delay

	var image = get_viewport().get_texture().get_data()
	var thread := Thread.new()
	_threads.append(thread)
	if OK != thread.start(self, "_save_image", [image, thread, false]):
		printerr("ScreenshotMgr: could not start thread to complete saving of screenshot image.")
	_file_counter += 1


func _save_image(data: Array) -> void:
	var image: Image = data[0]
	image.flip_y()
	if _resize_factor != 1.0:
		var original_size = image.get_size()
		image.resize(original_size.x*_resize_factor, original_size.y*_resize_factor, Image.INTERPOLATE_BILINEAR)
	var directory_name = "screenshots" if data[2] else _directory_name
	var file_name = "%s.png" % get_date_time_string() if data[2] else "%04d.png" % _file_counter
	var file_path = "user://%s/%s" % [directory_name, file_name]
	var error = image.save_png(file_path)
	if error != OK:
		printerr("ScreenshotMgr: error while saving image to '%s' %d" % [file_path, error])
	_threads.erase(data[1])
