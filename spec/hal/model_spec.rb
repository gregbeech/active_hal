require 'spec_helper'
require 'support/test_models'

describe ActiveHal do
  describe '::belongs_to' do
    context 'when just a name is specified' do
      subject { Order.new(_links: { restaurant: { href: 'https://example.org/restaurants/72' } }) }

      before do
        stub_request(:get, 'https://example.org/restaurants/72').to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: { _links: { self: { href: 'https://example.org/restaurants/72' } }, id: 72, name: 'Curry in a Hurry' }.to_json)
      end

      it 'should return a model whose class is derived from the name' do
        expect(subject.restaurant).to be_a Restaurant
      end
      it 'should ensure the model is loaded' do
        expect(subject.restaurant).to be_loaded
      end
    end

    context 'when a class_name is specified' do
      subject { Order.new(_links: { user: { href: 'https://example.org/users/38' } }) }

      before do
        stub_request(:get, 'https://example.org/users/38').to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: { _links: { self: { href: 'https://example.org/users/38' } }, id: 38, first_name: 'John' }.to_json)
      end

      it 'should return a model of the specified class' do
        expect(subject.user).to be_a Customer
      end
      it 'should ensure the model is loaded' do
        expect(subject.user).to be_loaded
      end
    end

    context 'when a curie relation is specified' do
      subject { Order.new(_links: { 'curies' => [{ name: 'foo', href: 'https://example.org/rels/{rel}', templated: true }], 'foo:address' => { href: 'https://example.org/addresses/82' } }) }

      before do
        stub_request(:get, 'https://example.org/addresses/82').to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: { _links: { self: { href: 'https://example.org/addresses/82' } }, id: 82, line1: '23 Acacia Avenue' }.to_json)
      end

      it 'should decode the curie and return the right model' do
        expect(subject.address).to be_a Address
      end
      it 'should ensure the model is loaded' do
        expect(subject.address).to be_loaded
      end
    end
  end

  describe '::new' do
    context 'when regular attributes are provided' do
      subject { Order.new(id: 123, total_price: 1599) }

      it 'should set the attributes' do
        expect(subject.id).to eq 123
        expect(subject.total_price).to eq 1599
      end
    end

    context 'when _links are provided' do
      subject { Order.new(_links: { self: { href: 'https://example.org/orders/123' } }) }

      it 'should set the link information' do
        expect(subject.as_link[:href]).to eq 'https://example.org/orders/123'
      end
    end
  end

  describe '#reload' do
    subject { Order.new(_links: { self: { href: 'https://example.org/orders/123' } }).reload }

    before do
      stub_request(:get, 'https://example.org/orders/123').to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: { _links: { self: { href: 'https://example.org/orders/123' } }, id: 123, total_price: 1599 }.to_json)
    end

    it 'should load from the URL' do
        expect(subject.id).to eq 123
        expect(subject.total_price).to eq 1599
    end
  end

end
