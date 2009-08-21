require File.dirname(__FILE__) + '/../spec_helper'

describe "truncate_words" do
  include ActionView::Helpers::TextHelper

  it "should not truncate short contents" do
    truncate_words("hello", :length => 10, :omission => "...").should == "hello"
  end

  it "should return the omission string if the length is less than the first full word plus the omission string" do
    truncate_words("hello there", :length => 7, :omission => "...").should == "..."
  end
  
  it "should truncate the text to less than or equal to the given length" do
    text = "Returns the KC normalization of the string by default. NFKC is considered the best normalization form for passing strings to databases and validations."
    result = "Returns the KC normalization of the string by..."
    truncate_words(text, :length => 50, :omission => "...").length.should <= 50
  end
  
  it "should not truncate the text if the text is shorter than the the given length" do
    truncate_words("hello there", :length => 11, :omission => "...").should == "hello there"
  end
  
  it "should to the last full word within the given length plus the omission length" do
    truncate_words("hello there", :length => 9, :omission => "...").should == "hello..."
  end

  it "should truncate long contents" do
    text = "Returns the KC normalization of the string by default. NFKC is considered the best normalization form for passing strings to databases and validations."
    result = "Returns the KC normalization of the string by..."
    truncate_words(text, :length => 50, :omission => "...").should == result
  end

  it "should truncate multibyte contents" do
    truncate_words("ɦɛĺłø ŵőřļđ".mb_chars, :length => 9, :omission => "...").should == "ɦɛĺłø..."
  end
end

describe "truncate_html" do
  include ActionView::Helpers::TextHelper
  before do
    @html_text = %{<p>This text should be truncated using a method that checks the length in words and replaces the extra text with an elipsis or the given 'omission' attribute</p><p>so that the final text is not left with open HTML tags, but has the appropriate closing tag for the HTML</p>}
    @plain_text = %{This text should be truncated using a method that checks the length in words and replaces the extra text with an elipsis or the given 'omission' attribute so that the final text is not left with open HTML tags, but has the appropriate closing tag for the HTML}
    @default_html_result = %{<p>This text should be truncated using a method that checks the length in words and replaces the extra text with an elipsis or the given 'omission' attribute</p><p>so that the final text...</p>}
    @short_html_result = %{<p>This text should be truncated using a method that checks the length in...</p>}
    @plain_result = "This text should be truncated using a method that checks the length in words and replaces the extra text with an elipsis or the given 'omission' attribute so that the final text..."
  end
  it "should close any open HTML elements" do
    truncate_html(@html_text).should == @default_html_result
  end
  it "should set the length in words to the given :length value" do
    result = "This text should be truncated using a method that checks the length in..."
    truncate_html(@html_text, :length => 11).should == @short_html_result
  end
  it "should truncate plain text" do
    truncate_html(@plain_text).should == @plain_result
  end
  it "should set the omission text to the given :omission value" do
    result = "This text should be truncated using a method that checks the length in...read more..."
    truncate_html(@plain_text, :length => 11, :omission => "...read more...").should == result
  end
end