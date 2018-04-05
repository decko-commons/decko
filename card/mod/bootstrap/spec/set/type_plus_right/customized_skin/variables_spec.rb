RSpec.describe Card::Set::TypePlusRight::CustomizedSkin::Variables do
  SCSS = <<-SCSS.strip_heredoc
    $white:    #fff !default;
    $gray-100: #f8f9fa !default;
    $gray-200: #ebebeb !default;
    $gray-300: #dee2e6 !default;
    $gray-400: #ced4da !default;
    $gray-500: #adb5bd !default;
    $gray-600: #999 !default;
    $gray-700: #444 !default;
    $gray-800: #303030 !default;
    $gray-900: #222 !default;
    $black:    #000 !default;
    
    $blue:    #375a7f !default;
    $indigo:  #6610f2 !default;
    $purple:  #6f42c1 !default;
    $pink:    #e83e8c !default;
    $red:     #E74C3C !default;
    $orange:  #fd7e14 !default;
    $yellow:  #F39C12 !default;
    $green:   #00bc8c !default;
    $teal:    #20c997 !default;
    $cyan:    #3498DB !default;
    
    $primary:       $blue !default;
    $secondary:     $gray-700 !default;
    $success:       $green !default;
    $info:          $cyan !default;
    $warning:       $yellow !default;
    $danger:        $red !default;
    $light:         $gray-800 !default;
    $dark:          $gray-800 !default;
    
    // Body
    
    $body-bg:                   $gray-900 !default;
    $body-color:                $white !default;
  SCSS

  let(:card) do
    Card::Env.params[:theme] = "journal"
    Card::Auth.as_bot do
      create_customized_skin "my skin"
    end
  end

  it "copies content from source file" do
    expect(card.variables).to include("$cyan:    #369 !default;")
  end

  it "fetches variable value from content" do
    expect(card.variables_card.colors).to include(white: "#fff")
  end

  it "fetches missing variable value from bootstrap source" do
    expect(card.variables_card.theme_colors).to include("card-cap-bg": "rgba($black, .03)")
  end

end
