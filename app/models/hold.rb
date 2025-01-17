# == Schema Information
#
# Table name: holds
#
#  id               :integer          not null, primary key
#  thesis_id        :integer          not null
#  date_requested   :date             not null
#  date_start       :date             not null
#  date_end         :date             not null
#  hold_source_id   :integer          not null
#  case_number      :string
#  status           :integer          not null
#  processing_notes :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Hold < ApplicationRecord
  has_paper_trail

  belongs_to :thesis
  belongs_to :hold_source
  has_many :users, through: :thesis

  enum status: %i[active expired released]

  validates :date_requested, presence: true
  validates :date_start, presence: true
  validates :date_end, presence: true
  validates :status, presence: true

  after_save :update_thesis_status

  def degrees
    thesis.degrees.map(&:name_dw).join("\n")
  end

  def grad_date
    thesis.grad_date
  end

  def author_names
    thesis.users.map(&:name).join('; ')
  end

  def created_by
    return unless versions.present? && versions.first.event == 'create'

    creator_id = versions.first.whodunnit
    if user = User.find_by(id: creator_id)
      user.kerberos_id
    else
      "User ID #{creator_id} no longer active."
    end
  end

  # This may later list just the info for the file flagged 'primary', once
  # we implement that feature.
  def dates_thesis_files_received
    return unless thesis.present? && thesis.files.present?

    thesis.files.map do |file|
      "#{file.created_at.strftime('%Y-%m-%d')} (#{file.blob.filename})"
    end.join('; ')
  end

  # In the unlikely scenario that the the status was changed to 'released'
  # multiple times, this assumes we want the most recent date released.
  def date_released
    released_versions = versions.select do |version|
      version.changeset['status'][1] == 'released' if version.changeset['status'].present?
    end
    dates_released = released_versions.map { |version| version.changeset['updated_at'][1] }
    dates_released.max
  end

  # The thesis' publication_status is recalculated every time the record is
  # saved, so in case this hold's status has changed, we force a recalculation.
  def update_thesis_status
    thesis.save
  end
end
