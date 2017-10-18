class CustomAutoCompleteController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def search
    begin  
      @page = Wiki.find_page("Builds", project => params[:project_id])

      @issues = @page.text.split(/[\r\n]+/)
        .each_with_index
        .map {|x, i| { 'id' => i, 'value' => x.split(/\s/).first } }
    
      # @issues = Issue.find_by_sql(["select max(issues.id) as id, custom_values.value as value, count(*) as count from custom_values, issues where issues.project_id = ? and custom_values.customized_id = issues.id and custom_values.custom_field_id = ? and lower(custom_values.value) like lower(?) group by custom_values.value order by max(issues.updated_on) desc", params[:project_id], params[:custom_field_id], "%#{params[:term]}%"])
      render :layout => false

    rescue ActiveRecord::RecordNotFound
      render_404
    end       
  end

private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end 

end
