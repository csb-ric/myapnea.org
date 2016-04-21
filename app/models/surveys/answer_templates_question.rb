# frozen_string_literal: true

# Associates questions and answer templates
class AnswerTemplatesQuestion < ActiveRecord::Base
  # Associations
  belongs_to :question, -> { current }
  belongs_to :answer_template, -> { current }
end