module ReportType
  class Organism < Base
    class << self
      def count(meo_id: '', tax_id: '', bp_id: '', mf_id: '', cc_id: '', mpo_id: '')
        select_clause =  "SELECT COUNT(DISTINCT ?taxonomy_id) AS ?hits_count"
        sparql = build_organism_sparql(meo_id, tax_id, bp_id, mf_id, cc_id, mpo_id, select_clause)

        results = query(sparql)

        results.first[:hits_count]
      end

      def search(meo_id: '', tax_id: '', bp_id: '', mf_id: '', cc_id: '', mpo_id: '', limit: 25, offset: 0)
        select_clause, order_clause = "SELECT DISTINCT ?taxonomy_id ?taxonomy_name ?category_name ?sub_category_name", 'ORDER BY ?category_name ?sub_category_name'
        sparql = build_organism_sparql(meo_id, tax_id, bp_id, mf_id, cc_id, mpo_id, select_clause, order_clause, limit, offset)

        results = query(sparql)

        return [] if results.empty?

        taxids = results.map {|b| "<#{b[:taxonomy_id]}>" }.uniq.join(' ')

        sparqls = [
          find_environments_sparql(PREFIX, ONTOLOGY, taxids),
          find_genome_stats_sparql(PREFIX, ONTOLOGY, taxids),
          #find_temperature_sparql(PREFIX, ONTOLOGY, taxids),
          #find_morphology_sparql(PREFIX, ONTOLOGY, taxids),
          #find_mortility_sparql(PREFIX, ONTOLOGY, taxids),
          #find_energy_source_sparql(PREFIX, ONTOLOGY, taxids)
        ]

        envs, stats = Parallel.map(sparqls, in_threads: 4) {|sparql|
          query(sparql)
        }

        results.map do |result|
          select_envs       = envs.select {|e| e[:taxonomy_id] == result[:taxonomy_id] }
          select_stat       = stats.select {|s| s[:taxonomy_id] == result[:taxonomy_id] }.first

          new(result, select_envs, select_stat)
        end
      end
    end

    def initialize(up_tax, envs, stat)
      @uniprot_taxonomy, @envs, @stat = up_tax, envs, stat
    end

    def tax
      category, sub_category, uri, name = @uniprot_taxonomy.values_at(:category_name, :sub_category_name, :taxonomy_id, :taxonomy_name)

      OpenStruct.new(
        category:     category,
        sub_category: sub_category,
        uri:          uri,
        name:         name,
        id:           uri.split('/').last,
        taxonomy:     "#{category} / #{sub_category}"
      )
    end

    def envs
      @envs.map {|env|
        OpenStruct.new(id: env[:meo_id], name: env[:meo_name])
      }
    end


    def stat
      return nil unless @stat
      OpenStruct.new(@stat)
    end
  end
end
