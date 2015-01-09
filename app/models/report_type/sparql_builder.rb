require 'erb'

module ReportType
  module SparqlBuilder
    extend ActiveSupport::Concern

    module ClassMethods
      def build_gene_sparql(prefix, ontology, meo_id, tax_id, bp_id, mf_id, cc_id, mpo_id, select_clause, limit = 1, offset = 0)
        if (bp_id.present? || mf_id.present? || cc_id.present?)
          genes_has_go_condition(prefix, ontology, mpo_id, meo_id, tax_id, bp_id, mf_id, cc_id, select_clause, limit, offset)
        elsif tax_id.present?
          genes_has_tax_condition(prefix, ontology, mpo_id, meo_id, tax_id, select_clause, limit, offset)
        elsif meo_id.present?
           genes_has_meo_condition(prefix, ontology, mpo_id, meo_id, select_clause, limit, offset)
        elsif mpo_id.present?
           genes_has_mpo_condition(prefix, ontology, mpo_id, select_clause, limit, offset)
        else
          genes_init_condition(prefix, ontology, select_clause, limit, offset)
        end
      end

      def build_organism_sparql(prefix, ontology, meo_id, tax_id, bp_id, mf_id, cc_id, mpo_id, select_clause, order_clause = '', limit = 1, offset = 0)
        if (bp_id.present? || mf_id.present? || cc_id.present?)
          organisms_has_go_condition(prefix, ontology, mpo_id, meo_id, tax_id, bp_id, mf_id, cc_id, select_clause, order_clause, limit, offset)
        elsif tax_id.present?
          organisms_has_tax_condition(prefix, ontology, mpo_id, meo_id, tax_id, select_clause, order_clause, limit, offset)
        elsif meo_id.present?
          organisms_has_meo_condition(prefix, ontology, mpo_id, meo_id, select_clause, order_clause, limit, offset)
        elsif mpo_id.present?
          organisms_has_mpo_condition(prefix, ontology, mpo_id, select_clause, order_clause, limit, offset)
        else
          organisms_init_condition(prefix, ontology, select_clause, order_clause, limit, offset)
        end
      end

      def build_environment_sparql(prefix, ontology, meo_id, tax_id, bp_id, mf_id, cc_id, mpo_id, select_clause, limit = 1, offset = 0)
        if (bp_id.present? || mf_id.present? || cc_id.present?)
          environments_has_go_condition(prefix, ontology, mpo_id, meo_id, tax_id, bp_id, mf_id, cc_id, select_clause, limit, offset)
        elsif tax_id.present?
          environments_has_tax_condition(prefix, ontology, mpo_id, meo_id, tax_id, select_clause, limit, offset)
        elsif meo_id.present?
          environments_has_meo_condition(prefix, ontology, mpo_id, meo_id, select_clause, limit, offset)
        elsif mpo_id.present?
          environments_has_mpo_condition(prefix, ontology, mpo_id, select_clause, limit, offset)
        else
          environments_init_condition(prefix, ontology, select_clause, limit, offset)
        end
      end

      extend ERB::DefMethod
      def_erb_method("genes_init_condition(prefix, ontology, select_clause, limit, offset)", 'app/views/sparql_templates/genes/init_condition.rq.erb')
      def_erb_method("genes_has_mpo_condition(prefix, ontology, mpo_id, select_clause, limit, offset)", 'app/views/sparql_templates/genes/has_mpo_condition.rq.erb')
      def_erb_method("genes_has_meo_condition(prefix, ontology, mpo_id, meo_id, select_clause, limit, offset)", 'app/views/sparql_templates/genes/has_meo_condition.rq.erb')
      def_erb_method("genes_has_tax_condition(prefix, ontology, mpo_id, meo_id, tax_id, select_clause, limit, offset)", 'app/views/sparql_templates/genes/has_tax_condition.rq.erb')
      def_erb_method("genes_has_go_condition(prefix, ontology, mpo_id, meo_id, tax_id, bp_id, mf_id, cc_id, select_clause, limit, offset)", 'app/views/sparql_templates/genes/has_go_condition.rq.erb')

      def_erb_method("organisms_init_condition(prefix, ontology, select_clause, order_clause, limit, offset)", 'app/views/sparql_templates/organisms/init_condition.rq.erb')
      def_erb_method("organisms_has_mpo_condition(prefix, ontology, mpo_id, select_clause, order_clause, limit, offset)", 'app/views/sparql_templates/organisms/has_mpo_condition.rq.erb')
      def_erb_method("organisms_has_meo_condition(prefix, ontology, mpo_id, meo_id, select_clause, order_clause, limit, offset)", 'app/views/sparql_templates/organisms/has_meo_condition.rq.erb')
      def_erb_method("organisms_has_tax_condition(prefix, ontology, mpo_id, meo_id, tax_id, select_clause, order_clause, limit, offset)", 'app/views/sparql_templates/organisms/has_tax_condition.rq.erb')
      def_erb_method("organisms_has_go_condition(prefix, ontology, mpo_id, meo_id, tax_id, bp_id, mf_id, cc_id, select_clause, order_clause, limit, offset)", 'app/views/sparql_templates/organisms/has_go_condition.rq.erb')

      def_erb_method("environments_init_condition(prefix, ontology, select_clause, limit, offset)", 'app/views/sparql_templates/environments/init_condition.rq.erb')
      def_erb_method("environments_has_mpo_condition(prefix, ontology, mpo_id, select_clause, limit, offset)", 'app/views/sparql_templates/environments/has_mpo_condition.rq.erb')
      def_erb_method("environments_has_meo_condition(prefix, ontology, mpo_id, meo_id, select_clause, limit, offset)", 'app/views/sparql_templates/environments/has_meo_condition.rq.erb')
      def_erb_method("environments_has_tax_condition(prefix, ontology, mpo_id, meo_id, tax_id, select_clause, limit, offset)", 'app/views/sparql_templates/environments/has_tax_condition.rq.erb')
      def_erb_method("environments_has_go_condition(prefix, ontology, mpo_id, meo_id, tax_id, bp_id, mf_id, cc_id, select_clause, limit, offset)", 'app/views/sparql_templates/environments/has_go_condition.rq.erb')

      def_erb_method("find_proteins_sparql(prefix, ontology, genes)", 'app/views/sparql_templates/find_proteins.rq.erb')
      def_erb_method("find_gene_ontologies_sparql(prefix, ontology, genes)", 'app/views/sparql_templates/find_gene_ontologies.rq.erb')
      def_erb_method("find_environments_sparql(prefix, ontology, taxonomies)", 'app/views/sparql_templates/find_environments.rq.erb')
      def_erb_method("find_phenotypes_sparql(prefix, ontology, taxonomies)", 'app/views/sparql_templates/find_phenotypes.rq.erb')
      def_erb_method("find_refseqs_sparql(prefix, ontology, taxonomies)", 'app/views/sparql_templates/find_refseqs.rq.erb')
      def_erb_method("find_genome_stats_sparql(prefix, ontology, taxonomies)", 'app/views/sparql_templates/find_genome_stats.rq.erb')
      def_erb_method("find_environment_root_sparql(prefix, ontology, meos)", 'app/views/sparql_templates/find_environment_root.rq.erb')
      def_erb_method("find_environment_inhabitants_stats_sparql(prefix, ontology, meos)", 'app/views/sparql_templates/find_environment_inhabitants_stats.rq.erb')
    end
  end
end
