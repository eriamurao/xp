class CreateAnthropicConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :anthropic_conversations do |t|
      t.string :messages_id, null: false
      t.string :title
      t.jsonb :messages, null: false

      t.timestamps
    end
  end
end
