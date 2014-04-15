class CreateCommentTable < ActiveRecord::Migration
  def change
    create_table :comments do |t|
    	t.boolean :must_be_approved, default: false
    	t.string :title
      	t.timestamps
    end
  end
end