# -*- encoding : utf-8 -*-

RSpec.describe Card::Format::MethodDelegation do
  let(:format) { Card.new.format }

  it "handles simple, optional view" do
    expect(format).to receive(:render!).with("viewname", { optional: :show })
    format.render_viewname
  end

  it "handles non-optional view" do
    expect(format).to receive(:render!).with("viewname", {})
    format.render_viewname!
  end

  it "handles permission skipping" do
    expect(format).to receive(:render!).with("viewname", { skip_perms: true })
    format._render_viewname!
  end

  it "handles optional view with permission skipping" do
    expect(format).to receive(:render!).with("viewname", { optional: :show,
                                                           skip_perms: true })
    format._render_viewname
  end

  it "handles miscellaneous options" do
    expect(format).to receive(:render!).with("viewname", { structure: :crooked })
    format.render_viewname! structure: :crooked
  end

  it "optional: :hide overrides default" do
    expect(format).to receive(:render!).with("viewname", { optional: :hide })
    format.render_viewname optional: :hide
  end
end
