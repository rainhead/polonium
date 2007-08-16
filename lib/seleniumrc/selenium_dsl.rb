module Seleniumrc
  module SeleniumDsl
    # The SeleniumConfiguration object.
    def configuration
      @configuration ||= SeleniumConfiguration.instance
    end
    attr_writer :configuration
    include WaitFor

    def type(locator,value)
      element(locator).is_present
      selenium.type(locator,value)
    end

    def click(locator)
      element(locator).is_present
      selenium.click(locator)
    end

    alias_method :wait_for_and_click, :click

    # Download a file from the Application Server
    def download(path)
      uri = URI.parse(configuration.browser_url + path)
      puts "downloading #{uri.to_s}"
      Net::HTTP.get(uri)
    end

    def select(select_locator,option_locator)
      element(select_locator).is_present
      selenium.select(select_locator,option_locator)
    end

    # Reload the current page that the browser is on.
    def reload
      selenium.get_eval("selenium.browserbot.getCurrentWindow().location.reload()")
    end

    # The default Selenium Core client side timeout.
    def default_timeout
      @default_timeout ||= 20000
    end
    attr_writer :default_timeout

    def method_missing(name, *args)
      return selenium.send(name, *args)
    end


#--------- Commands

    # Open a location and wait for the page to load.
    def open_and_wait( location)
      selenium.open(location)
      wait_for_page_to_load
    end

    # Click a link and wait for the page to load.
    def click_and_wait(locator, wait_for = default_timeout)
      selenium.click locator
      wait_for_page_to_load(wait_for)
    end

    # Click the back button and wait for the page to load.
    def go_back_and_wait
      selenium.go_back
      wait_for_page_to_load
    end

    # Open the home page of the Application and wait for the page to load.
    def open_home_page
      selenium.open(configuration.browser_url)
      wait_for_page_to_load
    end

    # Get the inner html of the located element.
    def get_inner_html(locator)
      element(locator).inner_html
    end

    # Does the element at locator contain the text?
    def element_contains_text(locator, text)
      selenium.is_element_present(locator) && get_inner_html(locator).include?(text)
    end

    # Does the element at locator not contain the text?
    def element_does_not_contain_text(locator, text)
      return true unless selenium.is_element_present(locator)
      return !get_inner_html(locator).include?(text)
    end


#------ Assertions and Conditions
    # Assert and wait for the page title.
    def assert_title(title, params={})
      page.has_title(title, params)
    end

    # Assert and wait for page to contain text.
    def assert_text_present(pattern, options = {})
      page.is_text_present(pattern, options)
    end

    # Assert and wait for page to not contain text.
    def assert_text_not_present(pattern, options = {})
      page.is_text_not_present(pattern, options)
    end    

    # Assert and wait for the locator element to have value.
    def assert_value(locator, value)
      element(locator).has_value(value)
    end

    # Assert and wait for the locator attribute to have a value.
    def assert_attribute(locator, value)
      element(locator).has_attribute(value)
    end

    # Assert and wait for locator select element to have value option selected.
    def assert_selected(locator, value)
      element(locator).has_selected(value)
    end

    # Assert and wait for locator check box to be checked.
    def assert_checked(locator)
      element(locator).is_checked
    end

    # Assert and wait for locator check box to not be checked.
    def assert_not_checked(locator)
      element(locator).is_not_checked
    end

    # Assert and wait for locator element to have text equal to passed in text.
    def assert_text(locator, text, options={})
      element(locator).has_text(text, options)      
    end

    # Assert and wait for locator element to be present.
    def assert_element_present(locator, params = {})
      element(locator).is_present(params)
    end

    # Assert and wait for locator element to not be present.
    def assert_element_not_present(locator, params = {})
      element(locator).is_not_present(params)
    end

    # Assert and wait for locator element to contain text.
    def assert_element_contains(locator, text, options = {})
      element(locator).contains_text(text, options)
    end

    # Assert and wait for locator element to not contain text.
    def assert_element_does_not_contain_text(locator, text, options={})
      element(locator).does_not_contain_text(text, options)
    end
    alias_method :assert_element_does_not_contain, :assert_element_does_not_contain_text
    alias_method :wait_for_element_to_not_contain_text, :assert_element_does_not_contain_text

    # Assert and wait for the element with id next sibling is the element with id expected_sibling_id.
    def assert_next_sibling(locator, expected_sibling_id, options = {})
      element(locator).has_next_sibling(expected_sibling_id, options)
    end

    # Assert browser url ends with passed in url.
    def assert_location_ends_in(ends_with, options={})
      page.url_ends_with(ends_with, options)
    end

    # Assert and wait for locator element has text fragments in a certain order.
    def assert_text_in_order(locator, *text_fragments)
      element(locator).has_text_in_order(*text_fragments)
    end
    alias_method :wait_for_text_in_order, :assert_text_in_order

#----- Waiting for conditions

    def wait_for_page_to_load(timeout=default_timeout)
      selenium.wait_for_page_to_load timeout
      if get_title.include?("Exception caught")
        fail "We got a new page, but it was an application exception page.\n\n" + get_html_source
      end
      assert !(get_title.include?("Exception caught")), "We got a new page, but it was an application exception page."
    end

    def assert_visible(locator, options = {})
      element(locator).is_visible(options)
    end

    def assert_not_visible(locator, options = {})
      element(locator).is_not_visible(options)
    end

    def click_and_wait_for_page_to_load(locator)
       click locator
       wait_for_page_to_load
    end

    def wait_for_element_to_contain(locator, text, message=nil, timeout=default_wait_for_time)
      wait_for({:message => message, :timeout => timeout}) {element_contains_text(locator, text)}
    end
    alias_method :wait_for_element_to_contain_text, :wait_for_element_to_contain

    # Open the log window on the browser. This is useful to diagnose issues with Selenium Core.
    def show_log(log_level = "debug")
      get_eval "LOG.setLogLevelThreshold('#{log_level}')"
    end

    # Slow down each Selenese step after this method is called.
    def slow_mode
      get_eval "slowMode = true"
      get_eval 'window.document.getElementsByName("FASTMODE")[0].checked = true'
    end

    # Speeds up each Selenese step to normal speed after this method is called.
    def fast_mode
      get_eval "slowMode = false"
      get_eval 'window.document.getElementsByName("FASTMODE")[0].checked = false'
    end

    def page
      SeleniumPage.new(@selenium)
    end

    def element(locator)
      SeleniumElement.new(@selenium, locator)
    end

    protected
    attr_accessor :selenium
    delegate :open,
             :wait_for_condition,
             :get_select_options,
             :get_selected_id,
             :get_selected_id,
             :get_selected_ids,
             :get_selected_index,
             :get_selected_indexes,
             :get_selected_label,
             :get_selected_labels,
             :get_selected_value,
             :get_selected_values,
             :get_body_text,
             :get_html_source,
             :to => :selenium

    def should_stop_selenese_interpreter?
      return false unless configuration.test_browser_mode?
      configuration.stop_selenese_interpreter?(passed?)
    end
  end
end