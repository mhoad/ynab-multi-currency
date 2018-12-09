class AddOn < ApplicationRecord
  has_many :syncs, dependent: :destroy
  belongs_to :user

  scope :active, -> { where(deleted_at: nil) }
  scope :automatic, -> { where(sync_automatically: true) }
  scope :syncable, -> { active.active.joins(:syncs).merge(Sync.confirmed).uniq }

  validates :ynab_budget_id, presence: true
  validates :ynab_account_id, presence: true
  validates :cached_ynab_account_name, presence: true
  validates :cached_ynab_budget_name, presence: true
  validates :start_date, presence: true
  validates :user, presence: true

  def last_synced_at
    syncs.confirmed.last&.created_at
  end
end
