class CustomAutoCompleteController < ApplicationController
  unloadable

  before_filter :find_project, :find_field, :authorize

  def search

    source = nil
    values = nil
    
    5.times do |idx|
      field = Setting.plugin_redmine_custom_auto_complete['acfield' + idx.to_s]
      if !field.nil? && Regexp.new(field, true).match(@field.name) then
        source = Setting.plugin_redmine_custom_auto_complete['acsource' + idx.to_s]
        values = Setting.plugin_redmine_custom_auto_complete['acvalues' + idx.to_s]
        break
      end
    end
    
    if source.to_s.strip.empty? then
      @issues = Issue.find_by_sql(["select max(issues.id) as id, custom_values.value as value from custom_values, issues where issues.project_id = ? and custom_values.customized_id = issues.id and custom_values.custom_field_id = ? and lower(custom_values.value) like lower(?) group by custom_values.value order by max(issues.updated_on) desc", params[:project_id], params[:custom_field_id], "%#{params[:term]}%"])            
    else
      page = find_wikipage(source.to_s.strip)
      
      if page.nil? then
        render_404
      else
        pattern = params[:term].to_s.strip.downcase
        
        # .concat values.to_s.split(/\;/)
        
        @issues = page.text.split(/[\r\n]+/)
          .map { |x| x.to_s.strip.split(/\s/).first }
          .select { |x| !x.empty? }
          .select { |x| pattern.empty? || x.downcase.include?(pattern) }
          .uniq
          .reverse
          .each_with_index
          .map { |x, i| OpenStruct.new({ id: i, value: x }) }     
      end
    end

    render :layout => false
  end

private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end 

  def find_field
    @field = CustomField.find(params[:custom_field_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end 

  def find_wikipage(pageName)
    return Wiki.find_page(pageName, :project => @project)
  rescue ActiveRecord::RecordNotFound
    return nil
  end 

end
