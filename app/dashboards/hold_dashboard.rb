require "administrate/base_dashboard"

class HoldDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    thesis: Field::BelongsTo,
    author_names: Field::String,
    degrees: Field::String,
    grad_date: Field::DateTime.with_options(
      format: "%Y %B",
    ),
    hold_source: Field::BelongsTo,
    id: Field::Number,
    date_requested: Field::Date,
    date_start: Field::Date,
    date_end: Field::Date,
    case_number: Field::String,
    status: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    processing_notes: Field::Text,
    created_at: Field::Date,
    updated_at: Field::Date,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  id
  author_names
  grad_date
  thesis
  hold_source
  status
  date_requested
  date_end
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  thesis
  author_names
  degrees
  grad_date
  hold_source
  id
  date_requested
  date_start
  date_end
  case_number
  status
  processing_notes
  created_at
  updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  thesis
  hold_source
  date_requested
  date_start
  date_end
  case_number
  status
  processing_notes
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {
    active: ->(resources) { resources.where(status: :active) }
  }.freeze

  # Overwrite this method to customize how holds are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(hold)
  #   "Hold ##{hold.id}"
  # end
  def display_resource(hold)
    "#{hold.thesis.title}"
  end
end