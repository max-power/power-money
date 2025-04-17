# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "power-money"
require "tldr/autorun"

TLDR::Run.at_exit! TLDR::Config.new(emoji: true)
