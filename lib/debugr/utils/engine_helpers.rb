# frozen_string_literal: true

def path_internal?(path)
  path.start_with?('<internal:')
end

def empty_or_internal?(path)
  path.nil? || path_internal?(path)
end

def add_trailing_slash(path)
  path.end_with?(File::SEPARATOR) ? path : path + File::SEPARATOR
end

def target_dir_and_script(session)
  script = session.script
  [script, add_trailing_slash(File.dirname(script))]
end

def script_or_within_script_dir?(path, script, dir)
  true if path == script || path.start_with?(dir)
end

def within_debugger_dir(dir, path)
  dir = add_trailing_slash(dir)
  path.start_with?(dir)
end
