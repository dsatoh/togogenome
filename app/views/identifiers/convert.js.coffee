<% if @db_links.empty? %>
$('#message').html """
  <div class='alert'>
    <i class='icon-warning-sign'></i> Not found.
  </div>
"""
<% end %>

$('table#mapped-ids tbody').html "<%= j(render 'db_link_table') %>"
$('span#download-area').html "<%= j(render 'download_button') %>"
$('div#results_info').html "<%= hit_count_message(@count) %>"
