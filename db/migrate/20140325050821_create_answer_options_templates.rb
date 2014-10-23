class CreateAnswerOptionsTemplates < ActiveRecord::Migration
  def change
    create_table :answer_options_templates do |t|
      t.references :answer_template
      t.references :answer_option

      t.timestamps
    end
  end
end
