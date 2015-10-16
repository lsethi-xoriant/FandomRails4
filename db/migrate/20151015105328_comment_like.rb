class CommentLike < ActiveRecord::Migration
  def change
    create_table :comment_likes do |t|
      t.timestamps
      t.string :title
      t.references :comment
    end
  end
end
