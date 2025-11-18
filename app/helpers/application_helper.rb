module ApplicationHelper
  def active_path(path)
    'active' if request.path == path
  end

  def active_controller(controller)
    'active' if controller_name == controller
  end

  def active_for(path: nil, controller: nil)
    if path && path == request.path || controller && controller == controller_name
      'active'
    end
  end
  
end