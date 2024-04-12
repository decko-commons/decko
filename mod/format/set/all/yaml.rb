format :yaml do
  def show view, args={}
    render!(view, args).to_yaml
  end

  view :core do
    render_pod
  end
end
