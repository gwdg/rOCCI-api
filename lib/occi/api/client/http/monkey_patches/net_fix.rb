##############################################################################
## Net hack hiding differences between Ruby 1.9.3 and Ruby 2+. Shouldn't have
## any side effects.
##############################################################################

module Net
  ##
  # OpenTimeout, a subclass of Timeout::Error, is raised if a connection cannot
  # be created within the open_timeout.
  class OpenTimeout < Timeout::Error; end

  ##
  # ReadTimeout, a subclass of Timeout::Error, is raised if a chunk of the
  # response cannot be read within the read_timeout.
  class ReadTimeout < Timeout::Error; end
end

