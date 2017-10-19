class CustomAutoCompleteHookListener < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context)
    css = Setting.redmine_custom_auto_complete['css']
    "<style type=\"text/css\">#{css}</style>" unless css.nil? or css.empty?
  end
  
  def view_issues_form_details_bottom(context={})
    html = ""
    if User.current.allowed_to?(:redmine_custom_auto_complete, Project.find(context[:issue].project_id))
      context[:issue].available_custom_fields.each do |field|
        if field.is_a?(IssueCustomField)
          if field.field_format == 'string'
            html << "<script>\n"
            html << "//<![CDATA[\n"
            html << "observeAutocompleteField(\'issue_custom_field_values_#{field.id}\', \'#{Redmine::Utils.relative_url_root}/custom_auto_complete/search?project_id=#{context[:issue].project_id}&custom_field_id=#{field.id}\');\n"
            html << "  $(function() { \n"
            html << "    $(\'#\' + \'issue_custom_field_values_#{field.id}\').on(\'click\', function() {\n"
            html << "      var self = $(this);\n"
            html << "      self\n"
            html << "        .autocomplete(\'option\', \'minLength\', 0)\n"
            html << "        .autocomplete(\'search\', \'\');\n"
            html << "    });\n"
            html << "  });\n"
            html << "//]]>\n"
            html << "</script>\n"
          end
        end
      end
    end
    return html
  end
end
