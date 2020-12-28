# frozen_string_literal: true

folders = %w[infrastructure presentation application]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
