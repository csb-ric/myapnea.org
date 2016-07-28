class CreateSeparateResearchTopicModel < ActiveRecord::Migration[4.2]
  def change
    create_table :research_topics do |t|
      t.string :text
      t.text :description
      t.string :state, null: false, default: "under_review"
      t.references :user
      t.timestamps
    end
    add_column :votes, :research_topic_id, :integer
    add_column :votes, :comment_id, :integer
    add_column :votes, :post_id, :integer
    add_column :comments, :research_topic_id, :integer
  end
end
