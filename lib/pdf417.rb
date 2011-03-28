# -*- coding: utf-8 -*-
# Modify the PATH on windows so that the external DLLs will get loaded.

require 'rbconfig'
ENV['PATH'] = [File.expand_path(
  File.join(File.dirname(__FILE__), "..", "ext", "pdf417")
), ENV['PATH']].compact.join(';') if RbConfig::CONFIG['host_os'] =~ /(mswin|mingw)/i

require 'pdf417/pdf417'
