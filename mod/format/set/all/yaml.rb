format :yaml do
  def show view, args={}
    view ||= :export
    render!(view, args).to_yaml
  end
end
