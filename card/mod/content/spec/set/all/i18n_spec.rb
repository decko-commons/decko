#require '#benchmark/ips'
#
#RSpec.describe Card::Set::All::I18n do
#  it "can access scope" do
#    expect(Card["A"].format.t(:key))
#      .to eq "translation missing: en.mod.spec.set.all.i18n_spec.key"
#  end
#
#  it "gets correct text" do
#    x.report('with auto_scope') do
#      Card[:admin_info].format(:html).warning_list_with_auto_scope([])
#    end
#    x.report('with explicit scope') do
#      Card[:admin_info].format(:html).warning_list([])
#    end
#  end
#end
