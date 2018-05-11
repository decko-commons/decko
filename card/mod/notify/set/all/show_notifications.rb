format :html do
  view :flash, cache: :never do
    flash_notice = params[:flash] || Env.success.flash
    return "" unless flash_notice.present? && focal?
    Array(flash_notice).join "\n"
  end
end
