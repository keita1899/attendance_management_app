module ApplicationHelper
  def page_title(title)
    base_title = "勤怠管理"

    title.empty? ? base_title : "#{title} | #{base_title}"
  end

  def flash_class(key)
    case key
    when "notice" then "alert-success"
    when "alert" then "alert-danger"
    else key
    end
  end

  def username
    if admin_signed_in?
      current_admin.name
    elsif user_signed_in?
      current_user.full_name
    end
  end

  def logout_link
    if admin_signed_in?
      link_to "ログアウト", destroy_admin_session_path, data: { turbo_method: :delete }, class: "nav-link"
    elsif user_signed_in?
      link_to "ログアウト", destroy_user_session_path, data: { turbo_method: :delete }, class: "nav-link"
    end
  end

  def format_time_only(time)
    time.strftime("%H:%M") if time.present?
  end

  def convert_minutes_to_hour(minutes)
    hours = minutes / 60
    minutes = minutes % 60
    hours < 1 ? "#{minutes}分" : "#{hours}時間 #{minutes}分"
  end

  def number_to_currency(price)
    "#{price.to_formatted_s(:delimited, delimiter: ',')}円"
  end
end
