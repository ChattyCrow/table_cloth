require 'spec_helper'

describe TableCloth::Column do
  subject { Class.new(TableCloth::Column) }
  let(:view_context) { ActionView::Base.new }
  let(:dummy_model) { FactoryGirl.build(:dummy_model) }

  USER_EMAIL = 'User email'.freeze

  # Dummy model for response to I18n
  # human_attribute_name
  class ArModel
    def human_attribute_name(*)
      USER_EMAIL
    end
  end

  # Dummy model without human_attr_name
  # method
  class NoArModel
  end

  context 'values' do
    let(:proc) do
      ->(object, _view) { object.email.gsub('@', ' at ') }
    end

    let(:name_column) { TableCloth::Column.new(:name) }
    let(:email_column) { TableCloth::Column.new(:my_email, proc: proc) }

    it 'returns the name correctly' do
      name_column.value(dummy_model, view_context).should == 'robert'
    end

    it 'returns the email from a proc correctly' do
      email_column.value(dummy_model, view_context).should == 'robert at example.com'
    end
  end

  context 'human name' do
    it 'returns the label when set' do
      column = FactoryGirl.build(:column, options: { label: 'Whatever' })
      expect(column.human_name(view_context, NoArModel, false)).to eq('Whatever')
    end

    it 'humanizes the symbol if no label is set' do
      column = FactoryGirl.build(:column, name: :email)
      expect(column.human_name(view_context, NoArModel, false)).to eq('Email')
    end

    it 'runs with a proc' do
      column = FactoryGirl.build(:column, options: { label: -> { tag :span } })
      expect(column.human_name(view_context, NoArModel, false)).to eq('<span />')
    end

    it 'returns human attribute name if it is possible' do
      column = FactoryGirl.build(:column, name: :email)
      expect(column.human_name(view_context, ArModel, true)).to eq(USER_EMAIL)
    end
  end
end
