class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body
      t.text :from
      t.text :to
      t.text :status
      t.text :ref
      t.text :sid
      t.datetime :accepted_at

      t.timestamps
    end
  end
end
