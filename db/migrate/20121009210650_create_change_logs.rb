class CreateChangeLogs < ActiveRecord::Migration
  def change
    create_table :change_logs do |t|
      t.integer :record_id
      t.text    :table_name
      t.text    :column_name
      t.text    :old_value
      t.text    :new_value
    end
    execute <<-SQL
      CREATE TRIGGER track_changes_hand UPDATE OF hand ON players
      BEGIN
        INSERT INTO change_logs(record_id, table_name, column_name, new_value, old_value) VALUES (new.id, 'players', 'hand', new.hand, old.hand);
      END;
    SQL
 
    execute <<-SQL
      CREATE TRIGGER track_changes_action UPDATE OF action ON players
      BEGIN
        INSERT INTO change_logs(record_id, table_name, column_name, new_value, old_value) VALUES (new.id, 'players', 'action', new.action, old.action);
      END;
    SQL
  end
end
