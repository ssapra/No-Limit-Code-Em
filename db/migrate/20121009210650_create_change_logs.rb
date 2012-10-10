class CreateChangeLogs < ActiveRecord::Migration
  def change
    create_table :change_logs do |t|
      t.integer :record_id
      t.text    :table_name
      t.text    :column_name
      t.text    :old_value
      t.text    :new_value
    end
    if Rails.env == 'production'
      execute <<-SQL
        CREATE OR REPLACE FUNCTION track_hand_changes() RETURNS TRIGGER AS $$
        BEGIN
        IF (TG_OP = 'UPDATE') THEN
        INSERT INTO change_logs(record_id, table_name, column_name, new_value, old_value) VALUES (NEW.id, 'players', 'hand', NEW.hand, OLD.hand);
        END IF;
        RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
        CREATE TRIGGER track_hand_changes_trigger
        AFTER UPDATE ON players
        FOR EACH ROW EXECUTE PROCEDURE track_hand_changes();
      SQL
 
      execute <<-SQL
        CREATE OR REPLACE FUNCTION track_action_changes() RETURNS TRIGGER AS $$
        BEGIN
        IF (TG_OP = 'UPDATE') THEN
        INSERT INTO change_logs(record_id, table_name, column_name, new_value, old_value) VALUES (NEW.id, 'players', 'action', NEW.hand, OLD.hand);
        END IF;
        RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
        CREATE TRIGGER track_action_changes_trigger
        AFTER UPDATE ON players
        FOR EACH ROW EXECUTE PROCEDURE track_action_changes();
      SQL
    end
  end
end
