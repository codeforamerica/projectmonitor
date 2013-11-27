class DropTagsAndTaggings < ActiveRecord::Migration
  def up
    drop_table :tags
    drop_table :taggings
  end

  def down
    create_table "taggings", force: true do |t|
      t.integer  "tag_id"
      t.integer  "taggable_id"
      t.string   "taggable_type"
      t.datetime "created_at"
      t.integer  "tagger_id"
      t.string   "tagger_type"
      t.string   "context"
    end

    add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

    create_table "tags", force: true do |t|
      t.string "name"
    end
  end
end
