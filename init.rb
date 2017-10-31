Redmine::Plugin.register :redmine_custom_auto_complete do
  require 'custom_auto_complete_hook'

  name 'Redmine Custom Auto-Complete plugin'
  author 'Sergey Alexeev, Taiki'
  description 'This plugin adds auto-complete to the custom fields'
  version '0.0.2'
  url 'https://github.com/SergeyA/redmine_custom_auto_complete'
  author_url 'https://github.com/SergeyA'

  settings :default => { :css => '' }, :partial => 'settings/custom_auto_complete'
  
  project_module :redmine_custom_auto_complete do
    permission :redmine_custom_auto_complete, :custom_auto_complete => [:search], :require => :member
  end
end
