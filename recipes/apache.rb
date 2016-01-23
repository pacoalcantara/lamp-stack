# install and enable apache2
 $ sudo apt-get install apache2
package "apache2" do
  action :install
end

service "apache2" do
   action [:enable, :start]
end

# Virtual hosts files

node["lamp-stack"]["sites"].each do |sitename, data|
  document_root = "/var/www/html/#{sitename}"

  directory document_root do
    mode "0755"
    recursive true
  end

  execute "enable-sites" do
    command "a2ensite #{sitename}"
    action :nothing
  end

  template "/etc/apache2/sites-available/#{sitename}.conf" do
      source "virtualhosts.erb"
      mode "0644"
      variables(
         :document_root => document_root,
         :port => data["port"],
         :serveradmin => data["serveradmin"],
         :servername => data["servername"]
      )
      notifies :run, "execute[enable-sites]"
      notifies :restart, "service[apache2]"
    end

  directory "/var/www/html/#{sitename}/public_html" do
    action :create
  end

  directory "/var/www/html/#{sitename}/logs" do
    action :create
  end

  # write index.html to site on DEFAULT port :80
  template "/var/www/html/index.html" do
  #template "#{document_root}/index.html" do
    source "index.html.erb"
    mode "0644"
    # put variables here
  end

  # write index.html to sites NOT on port :80
  template "/var/www/html/#{sitename}/public_html/index.html" do
    source "index-non-80.html.erb"
    mode "0644"
    # put variables here
  end

end
