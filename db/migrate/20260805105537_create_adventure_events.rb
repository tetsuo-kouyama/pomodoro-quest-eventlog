class CreateAdventureEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :adventure_events do |t|
      t.references :adventure, null: false, foreign_key: true
      t.integer :occurred_after_seconds, null: false
      t.integer :event_index, null: false
      t.string :event_type, null: false
      t.jsonb :payload, null: false, default: {}

      t.timestamps
    end
    add_index :adventure_events, [:adventure_id, :occurred_after_seconds]
    add_index :adventure_events, [:adventure_id, :event_index], unique: true
  end
end
