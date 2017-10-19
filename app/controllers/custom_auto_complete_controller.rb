class CustomAutoCompleteController < ApplicationController
  unloadable

  before_filter :find_project, :find_wikipage, :authorize

  def search
    # @issues = Issue.find_by_sql(["select max(issues.id) as id, custom_values.value as value, count(*) as count from custom_values, issues where issues.project_id = ? and custom_values.customized_id = issues.id and custom_values.custom_field_id = ? and lower(custom_values.value) like lower(?) group by custom_values.value order by max(issues.updated_on) desc", params[:project_id], params[:custom_field_id], "%#{params[:term]}%"])

    @pattern = params[:term].to_s.strip.downcase;
    
    @issues = @page.text.split(/[\r\n]+/)
      .map { |x| x.to_s.strip }
      .select { |x| !x.empty? }
      .select { |x| @patter.empty? || x.downcase.include?(@pattern) }
      .uniq
      .reverse
      .each_with_index
      .map { |x, i| OpenStruct.new({id: i, value: x.split(/\s/).first}) }

    render :layout => false
  end

private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end 

  def find_wikipage
    @page = Wiki.find_page("Builds", :project => @project)
  rescue ActiveRecord::RecordNotFound
    render_404
  end 

end
