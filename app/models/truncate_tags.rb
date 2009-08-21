module TruncateTags
  include Radiant::Taggable
  
  desc %{
    Truncate the contents of the tag. When using this tag, by default, HTML is balanced
    meaning you won't have a &#60;p&#62; without it's closing tag. This tag may be used in
    2 modes. In one you work with HTML, in the other you work only with the text. 
    
    In mode 1, your only options are the @length@ and the @omission@:
    
    * @length@ is the number of words to display from the given content. This is 30 by default.
    * @omission@ is the text used inplace of the omitted content. This is "..." by default.
    
    *Mode 1 Examples:*
    
    <pre><r:truncate><r:content /></r:truncate></pre>
    
    <pre><r:truncate length="100" omission="...to be continued..."><r:content /></r:truncate></pre>
    
    The previous example would limit the content to 100 words and replace the extra content with the omission attribute.
    
    To use mode 2 (working only with text), *you must set @strip_html="true"@*. This changes the behaviour of the @length@ attribute to mean the number of *characters* of text (rather than _number of *words*_ as in mode 1).
    
    In mode 2 you'll have options such as 
    
    * @split_words@: whether or not to split words (so you can prevent a word like "happily" at the end of the content from appearing as "hap..."). This is *false by default*, meaning words will not be split.
    * @strip_whitespace@: whether or not you want to strip out extra whitespace (e.g. leading and trailing spaces, and line breaks). This is *true by default*
    * and the @length@ (number of characters in this case) and @omission@ attributes still apply
      
    *Mode 2 Examples:*
    
    <pre><r:truncate strip_html="true"><r:content /></r:truncate></pre>
    
    <pre><r:truncate strip_html="true" omission="---"><r:content /></r:truncate></pre>
    
    <pre><r:truncate strip_html="true" strip_whitespace="false" split_words="true"><r:content /></r:truncate></pre>
    
    When using mode 1 (meaning @strip_html@ is *not* set, or is false) @strip_whitespace@ and @split_words@ _will be ignored_.
  }
  tag 'truncate' do |tag|
    content = tag.expand
    length = tag.attr['length']
    omission = tag.attr['omission']
    options = {}
    options[:length] = length.to_i if length
    options[:omission] = omission if omission
    helper = ActionView::Base.new
    
    strip_html = tag.attr['strip_html'] == 'true' # defaults to false. 'true' must be explicitly set
    if strip_html
      content = content.mb_chars
      content = helper.strip_tags(content)
      strip_whitespace = !(tag.attr['strip_whitespace'] == 'false') # defaults to true. 'false' must be explicitly set
      content = content.strip.gsub(/\s+/, " ") if strip_whitespace
      split_words = tag.attr['split_words'] == 'true' # defaults to false. 'true' must be explicitly set
      content = split_words ? helper.truncate(content, options) : helper.truncate_words(content, options)
    else
      content = helper.truncate_html(content, options)
    end
    content
  end
  
end

module ActionView::Helpers::TextHelper

  def truncate_words(text, *args)
    text = text.mb_chars
    options = args.extract_options!
    truncate_string = options[:omission] || '...'
    length = options[:length] || 50
    return text if text.length <= length
    length = (length - truncate_string.mb_chars.length)
    str = text[0, length + 1] 
    return truncate_string unless str
    idx = 0
    last_idx = nil
    while(idx && last_idx != idx) do
      last_idx = idx
      idx = str.index(/\s/, idx.to_i + 1)
    end
    (str[0, last_idx] + truncate_string).to_s
  end
  
  def truncate_html(input, *args)
    options = args.extract_options!
    truncate_string = options[:omission] || '...'
    num_words = (options[:length] || 30).to_i
  	fragment = Nokogiri::HTML.fragment(input)

  	current = fragment.children.first
  	count = 0

  	while current != nil
  		# we found a text node
  		if current.class == Nokogiri::XML::Text
  			count += current.text.split.length
  			# we reached our limit, let's get outta here!
  			break if count > num_words
  		end

  		if current.children.length > 0
  			# this node has children, can't be a text node,
  			# lets descend and look for text nodes
  			current = current.children.first
  		elsif not current.next.nil?
  			#this has no children, but has a sibling, let's check it out
  			current = current.next
  		else 
  			# we are the last child, we need to ascend until we are
  			# either done or find a sibling to continue on to
  			n = current
  			if n.parent
    			while n.parent.next and n.parent.next.nil? and n != fragment
    				n = n.parent
    			end
    			unless n == fragment
    			  current = n.parent.next
    			end
    		else
    		  current = nil if n == fragment
        end
        # if n == fragment
        #   current = nil 
        # else
        #   current = n.parent.next
        # end
  		end
  	end

  	if count >= num_words
  		new_content = current.text.split(/ /)

  		# the most confusing part. we want to grab just the first [num_words]
  		# number of words, but this last text node could send us way over
  		# our limit.  So, we need to find the difference between the number
  		# of words we wanted and the number of words total we found (count - num_words)
  		# to find how many we need to take off of this last text node
  		# so we subtract from the number of words in this text node.
  		# Finally we add 1 because we are doing a range and we need to get the index right.
  		new_content = new_content[0..(new_content.length-(count-num_words)+1)]

  		current.content= new_content.join(' ') + truncate_string

  		#remove everything else
  		while current != fragment
  			while not current.next.nil?
  				current.next.remove
  			end
  			current = current.parent
  		end
  	end
  	
    fragment.to_html
  end
  
end