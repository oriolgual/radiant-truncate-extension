require File.dirname(__FILE__) + '/../spec_helper'

describe TruncateTags do
  
  before do
    @page = Page.create!(
      :title => 'New Page',
      :slug => 'page',
      :breadcrumb => 'New Page',
      :status_id => '100'
    )
  end
      
  describe "<r:schmuncate>" do
    it "should truncate the contents with ActionView::Base.truncate_html" do
      @page.should render(
        %{<r:schmuncate><p>This is a story about a very <strong>strong</strong> man</p><p>It is <em>very</em> boring.</p></r:schmuncate>}
      ).as('<p>This is a story about a very <strong>strong</strong> man</p><p>It is <em>very</em> boring.</p>')
    end
    it "should accept an 'omission' attribute" do
      test = %{<p>This text should be truncated using a method that checks the length in words and replaces the extra text with an elipsis or the given 'omission' attribute</p><p>so that the final text is not left with open HTML tags, but has the appropriate closing tag for the HTML</p>}
      expected = %{<p>This text should be truncated using a method that checks the length in words and replaces the extra text with an elipsis or the given 'omission' attribute</p><p>so that the final text,,,</p>}
      @page.should render(
        %{<r:schmuncate omission=",,,">#{test}</r:schmuncate>}
      ).as(expected)
    end
    it "should accept a 'length' attribute" do
      test = %{<p>This text should be truncated using a method that checks the length in words and replaces the extra text with an elipsis or the given 'omission' attribute</p><p>so that the final text is not left with open HTML tags, but has the appropriate closing tag for the HTML</p>}
      expected = %{<p>This text should be truncated using a method that checks the length...</p>}
      @page.should render(
        %{<r:schmuncate length="10">#{test}</r:schmuncate>}
      ).as(expected)
    end
    describe "with strip_html set to 'true'" do
      it "should strip html tags" do
        @page.should render("<r:schmuncate strip_html='true'><div class='red'>Something</div> <ul><li>Lalala</li></ul></r:schmuncate>").as("Something Lalala")
      end
      it "should strip extra whitespace" do
        @page.should render("<r:schmuncate strip_html='true'><div class='red'>                       Something</div>\n\n      <ul><li>Lalala</li></ul></r:schmuncate>").as("Something Lalala")
      end
      it "should not strip extra whitespace with strip_whitespace set to 'false'" do
        @page.should render(
          "<r:schmuncate strip_html='true' strip_whitespace='false'><div class='red'>          Something</div>\n\n                      
             <ul><li>Lalala</li></ul></r:schmuncate>"
        ).as("          Something\n\n                      \n   ...")
      end
      it "should not split words" do
        @page.should render("<r:schmuncate strip_html='true' length='14'>Something to split</r:schmuncate>").as('Something...')
      end
      it "should split words with split_words set to 'true'" do
        @page.should render("<r:schmuncate strip_html='true' length='14' split_words='true'>Something to split</r:schmuncate>").as('Something t...')
      end
    end
  end
end