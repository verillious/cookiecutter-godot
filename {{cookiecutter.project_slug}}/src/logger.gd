# a logging utility class
# writes to stdout and logfiles
class_name Logger
extends Reference

enum LEVEL { INFO, DEBUG, WARNING, ERROR }

# path to the log file that will be created
const FILE_PATH = "user://logs/{{ cookiecutter.project_slug }}"

# the format string for time
const TIME_FORMAT = "{hour}.{minute}.{second}"

# the format string for date-time
const DATETIME_FORMAT = "{year}-{month}-{day}_%s" % TIME_FORMAT

# the current log level
export(LEVEL) var level := 0

# a file object for writing to disk
var _file = File.new()


# open the log file object
# - log_level, int: the log level to use.
#   any messages logged below this level will be ignored (default: Logger.LEVEL.INFO)
func _init(log_level := Logger.LEVEL.INFO) -> void:
	level = log_level if log_level != null else 0
	_file.open(get_file_path(), File.WRITE)


# return the path to the file including the current date-time
func get_file_path() -> String:
	return "%s_%s.log" % [FILE_PATH, DATETIME_FORMAT.format(get_datetime())]


# log a debug-level message
# - message, String: the message string to log
func debug(message: String) -> void:
	if level <= LEVEL.DEBUG:
		if OS.is_debug_build():
			_log("DEBUG", message)


# log an info-level message
# - message, String: the message string to log
func info(message: String) -> void:
	if level <= LEVEL.INFO:
		_log("INFO ", message)


# log a warning-level message
# - message, String: the message string to log
func warning(message: String) -> void:
	if level <= LEVEL.WARNING:
		_log("WARN ", message)


# log an error-level message
# - message, String: the message string to log
func error(message: String) -> void:
	_log("ERROR", message)


# get a zero padded datetime dictionary
# returns Dictionary: the zero padded datetime dictionary
func get_datetime() -> Dictionary:
	var datetime = OS.get_datetime()
	for key in datetime:
		datetime[key] = str(datetime[key]).pad_zeros(2)
	return datetime


# log a message with a given level string
# - level_string, String: the level string to prepend to the message
# - message, String: the message string to log
func _log(level_string: String, message: String) -> void:
	var log_message = "%s | %s | %s" % [TIME_FORMAT.format(get_datetime()), level_string, message]
	_file.store_line(log_message)
	if OS.is_debug_build():
		print(log_message)
