RSpec.describe ValueObjects::ActionView do

  it 'never loads unused modules' do
    expect(defined?(ValueObjects::ActionView::Cocoon)).to eq(nil)
  end

  describe '::integrate_with' do

    let(:action_view_base) { class_double(ActionView::Base).as_stubbed_const }

    it 'integrates with cocoon' do
      expect(action_view_base).to receive(:include) do |mod|
        expect(mod).to eq(ValueObjects::ActionView::Cocoon)
      end.once
      expect(subject.integrate_with(:cocoon)).to eq(true)
    end

  end

end
