# frozen_string_literal: true

module Helpers
  def fixture(file)
    File.dirname(__FILE__) + "/../fixture/#{file}"
  end
end
