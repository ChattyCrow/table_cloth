module TableCloth
  class Presenter
    attr_reader :view_context, :objects, :table, :klass, :human_names,
      :responsive, :table_html

    def initialize(objects, table, view, options)
      @objects = objects
      @view_context = view
      @table = table.new(objects, view)

      # Prepare for I18n localization in Rails
      @klass = objects.first.class
      @human_names = @klass.respond_to?(:human_attribute_name)

      # Set responsive and html table inputs
      @responsive  = options.delete(:responsive) || false
      @table_html  = options.delete(:table_html) || {}

      # If responsive add table class responsive_table
      if responsive
        @table_html[:class] = @table_html[:class].to_s
        @table_html[:class] << ' responsive_table'
      end
    end

    def render_table
      fail NoMethodError, 'You must override the .render method'
    end

    def thead
      fail NoMethodError, 'You must override the .header method'
    end

    def tbody
      fail NoMethodError, 'You must override the .rows method'
    end

    def columns
      @columns ||= table.class.columns.map do |name, column_hash|
        column = column_hash[:class].new(name, column_hash[:options])
        ColumnJury.new(column, table).available? ? column : nil
      end.compact
    end

    def row_values(object)
      columns.each_with_object([]) do |column, values|
        values << column.value(object, view_context, table)
      end
    end

    def rows
      objects.each_with_object([]) do |object, row|
        row << row_values(object)
      end
    end

    private

    def tag_options(type, options = {})
      options = options.dup

      if TableCloth.config.respond_to?(type)
        options = table.config.config_for(type).merge(options)
        options = TableCloth.config.config_for(type).merge(options)
      end

      options
    end

    def v
      view_context
    end

    def params
      v.params
    end
  end
end
