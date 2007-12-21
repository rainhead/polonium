require 'socket'
require 'logger'
require "stringio"

require "active_record"

require 'net/http'
require 'test/unit'
require 'test/unit/testresult'
require 'test/unit/ui/testrunnermediator'

require "selenium"
require "polonium/extensions/module"
require "polonium/extensions/testrunnermediator"
require "polonium/wait_for"
require "polonium/driver"
require "polonium/server_runner"
require "polonium/mongrel_selenium_server_runner"
require "polonium/webrick_selenium_server_runner"
require "polonium/dsl/selenium_dsl"
require "polonium/dsl/test_unit_dsl"
require "polonium/configuration"
require "polonium/page"
require "polonium/element"
require "polonium/test_case"
require "polonium/tasks/selenium_test_task"

require 'webrick_server' if self.class.const_defined? :RAILS_ROOT
