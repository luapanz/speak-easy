module ApplicationHelper
  def app_name
    "My App"
  end
  def avatar
    # html = <<-HTML
    # 	<span class="head-menu__cart-items">#{count}</span>
    # HTML
  end

  def location_to_user_relations(locations, item_locations)
    locs = []

    if item_locations
      item_locations.each_with_index do |l, i|
        s = locations[l["location_id"]]

        # if l["is_active"]
        #   s += " (active)"
        # else
        #   s += " (deactivated)"
        # end
        locs.push s
      end
    end

    locs.join(', ')
  end

  def locations_ids(locations, item_locations)
    locs = []

    item_locations.each_with_index do |l, i|
      locs.push locations[l]
    end

    locs.join(', ')
  end

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} alert-dismissible", role: 'alert') do
        concat(content_tag(:button, class: 'close', data: { dismiss: 'alert' }) do
          concat content_tag(:span, '&times;'.html_safe, 'aria-hidden' => true)
          concat content_tag(:span, 'Close', class: 'sr-only')
        end)
        concat message.html_safe
      end)
    end
    nil
  end

  def page_title
    if @business.present?
      section_names = {
        "agents"    => "Team Member",
        "locations" => "Location",
        "account"   => "Account",
        "campaigns"    => "Campaign",
        "business"    => "Business Setting",
      }

      if action_name == "index"
        action = ""
        plural = "s" if controller_name != "account"
      else
        action    = action_name + " "
        action[0] = action_name[0].capitalize
        plural    = ""
      end

      "#{action}#{section_names[controller_name]}#{plural} - #{@business.name} - SpeakEasy"
    end
  end

  def include_menu?
    controller_name != 'sessions' && controller_name != 'signup' && controller_name != 'agent_signup'
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end
end
