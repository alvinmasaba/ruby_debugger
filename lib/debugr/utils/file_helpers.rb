# frozen_string_literal: true

def get_abs_path(path)
  File.expand_path(path)
rescue StandardError
  path
end
