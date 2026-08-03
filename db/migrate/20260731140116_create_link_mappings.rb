class CreateLinkMappings < ActiveRecord::Migration[8.1]
  def change
    create_table :link_mappings do |t|
      t.string :link_code, null: false
      t.string :redirect_link, null: false

      t.timestamps
    end

    add_index :link_mappings, :link_code, unique: true
  end
end
