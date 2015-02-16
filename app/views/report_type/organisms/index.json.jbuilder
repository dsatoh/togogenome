json.iTotalRecords @total_count
json.iTotalDisplayRecords @hits_count
json.aaData do |json|
  json.array!(@results) do |r|
    json.taxonomy          r.tax.taxonomy
    json.organism_link     link_to(r.tax.name, organism_path(r.tax.id), target: '_blank')
    json.genome_size       r.stat.try(:genome_size)
    json.gene_num          r.stat.try(:gene_num)
    json.rrna_num          r.stat.try(:rrna_num)
    json.trna_num          r.stat.try(:trna_num)
    json.ncrna_num         r.stat.try(:ncrna_num)
    json.environment_links link_list(r.envs, 'environment')
    json.temperature       "TODO"
    json.morphology        link_to_if(r.morphology.mpo_name, r.morphology.mpo_name, r.morphology.mpo_url, target: '_blank'){}
    json.mortility         link_to_if(r.mortility.mpo_name, r.mortility.mpo_name, r.mortility.mpo_url, target: '_blank'){}
    json.energy_source      "TODO"

  end
end
