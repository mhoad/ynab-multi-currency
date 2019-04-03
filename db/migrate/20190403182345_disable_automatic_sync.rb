class DisableAutomaticSync < ActiveRecord::Migration[5.2]
  def change
    add_ons_to_disable = AddOn.active.automatic - AddOn
                                                  .active
                                                  .automatic
                                                  .joins(:syncs)
                                                  .merge(Sync.confirmed)
                                                  .uniq

    add_ons_to_disable.each { |add_on| add_on.update_column(sync_automatically: false) }
  end
end
