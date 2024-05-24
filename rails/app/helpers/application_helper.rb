module ApplicationHelper
  def flash_class(key)
    case key
    when "notice" then "alert-success"
    when "alert" then "alert-danger"
    else key
    end
  end
end
