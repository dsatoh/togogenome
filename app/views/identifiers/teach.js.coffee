sampleIds = <%=raw @identifiers.to_json %>

$('textarea#identifiers').val(sampleIds.join("\n"))
$('div#add-new-id').addClass 'sample'

`<%=raw render(template: 'identifiers/convert') %>`
