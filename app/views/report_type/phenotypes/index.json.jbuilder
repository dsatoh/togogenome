json.iTotalRecords @total_count
json.iTotalDisplayRecords @hits_count
json.aaData do |json|
  json.array!(@results) do |r|
    json.category       r.phenotype.category
    json.phenotype_link link_to(r.phenotype.name, phenotype_path(r.phenotype.id), target: '_blank')
    json.definition     r.phenotype.definition
    json.organisms      r.phenotype.organisms
  end
end
