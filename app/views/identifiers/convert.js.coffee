<% if @db_links.empty? %>
$('#message').html """
  <div class='alert'>
    <i class='icon-warning-sign'></i> Not found.
  </div>
"""
<% end %>

$("table#mapped-ids tbody").html "<%= j(render 'results') %>"
