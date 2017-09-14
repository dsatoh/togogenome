require 'sparql_util'

module Sequence
  class Genome
    include Queryable

    class << self
      def search(sequence)
        genomes = Sequence::GggenomeSearch.search(sequence)

        sparqls = build_sparqls(genomes)
        results = sparqls.flat_map {|sparql| query(sparql) }

        genomes.map do |genome|
          so = results.select {|r| r[:name] == genome.name }

          genome.to_h.merge(
            sequence_ontologies: so.map {|r| {uri: r[:sequence_ontology], name: r[:sequence_ontology_name]} },
            locus_tags: so.map {|r| r[:locus_tag] }.compact.uniq,
            products: so.map {|r| r[:product] }.compact.uniq
          ).merge(fetch_genes(genome.refseq, genome.position, genome.position_end))
          end
      end

      def build_sparqls(gggenome)
        gggenome.each_slice(300).map do |sub_results|
          <<-SPARQL.strip_heredoc
            DEFINE sql:select-option "order"
            #{SPARQLUtil::PREFIX[:insdc]}
            #{SPARQLUtil::PREFIX[:faldo]}
            #{SPARQLUtil::PREFIX[:obo]}
            PREFIX refseq: <http://identifiers.org/refseq/>

            SELECT ?refseq_uri ?seq_label ?togogenome ?gene_name ?faldo_begin ?faldo_end
            FROM #{SPARQLUtil::ONTOLOGY[:tgup]}
            FROM #{SPARQLUtil::ONTOLOGY[:refseq]}
            {
              {
                SELECT ?refseq_uri (MAX(?faldo_end) AS ?max_pos)
                FROM #{SPARQLUtil::ONTOLOGY[:tgup]}
                FROM #{SPARQLUtil::ONTOLOGY[:refseq]}
                WHERE {
                  VALUES (?refseq_uri ?begin ?end ?dummy1 ?dummy2) {
                   #{bind_values(sub_results)}
                  }
                  ?refseq_uri insdc:sequence ?seq .
                  ?feature obo:so_part_of ?seq;
                    rdfs:label ?gene_name;
                    faldo:location ?loc.
                  ?loc faldo:begin/faldo:position ?faldo_begin;
                    faldo:end/faldo:position ?faldo_end.
                  FILTER(
                    ?faldo_begin != 1 && (?faldo_begin < ?begin && ?faldo_end < ?begin)
                  )
                } GROUP BY ?refseq_uri
              }
              ?refseq_uri insdc:sequence ?seq ;
                rdfs:label ?seq_label .
              ?feature obo:so_part_of ?seq;
                rdfs:label ?gene_name;
                faldo:location ?loc.
              ?loc faldo:begin/faldo:position ?faldo_begin;
                faldo:end/faldo:position ?faldo_end.
              ?togogenome skos:exactMatch ?feature .
              FILTER( ?faldo_begin = ?max_pos || ?faldo_end = ?max_pos)
            }
            SPARQL
        end
      end



      private

      def bind_values(genomes)
        genomes.map { |genome|
          "( refseq:#{genome.refseq} #{genome.position} #{genome.position_end} \"#{genome.name}\" \"#{genome.strand}\" )"
        }.join("\n")
      end

      def fetch_genes(refseq_id, result_begin, result_end)
        r_begin, r_end = [result_begin.to_i, result_end.to_i].sort

        ov_genes = query(build_gene_sparql(refseq_id, r_begin, r_end, :overlap))
        prev_genes = query(build_gene_sparql(refseq_id, r_begin, r_end, :prev))
        nxt_genes = query(build_gene_sparql(refseq_id, r_begin, r_end, :next))

        {previous: prev_genes, overlap: ov_genes, next: nxt_genes}
      end

      def build_gene_sparql(refseq_id, result_begin, result_end, position)
        <<-SPARQL.strip_heredoc
          #{SPARQLUtil::PREFIX[:insdc]}
          #{SPARQLUtil::PREFIX[:faldo]}
          #{SPARQLUtil::PREFIX[:obo]}

          SELECT ?togogenome ?gene_name ?faldo_begin ?faldo_end
          FROM <http://togogenome.org/graph/tgup>
          FROM <http://togogenome.org/graph/refseq>
          WHERE {
            VALUES (?refseq_id ?begin ?end) {
              ( \"#{refseq_id.to_s}\" #{result_begin.to_s} #{result_end.to_s} )
            }
            ?refseq_uri rdfs:label ?refseq_id;
                        insdc:sequence ?seq.
            ?feature obo:so_part_of ?seq;
                     rdfs:label ?gene_name;
                     faldo:location ?loc.
            ?loc faldo:begin/faldo:position ?faldo_begin;
                 faldo:end/faldo:position ?faldo_end.
            ?togogenome skos:exactMatch ?feature .
            #{make_filter(position)}
          }
          #{make_order(position)}
          #{make_limit(position)}
        SPARQL
      end

      def make_filter(position)
        case position
          when :prev
            <<-EOS
              FILTER(
                ?faldo_begin != 1 && (?faldo_begin < ?begin && ?faldo_end < ?begin)
              )
            EOS
          when :next
            <<-EOS
              FILTER(
                ?faldo_begin != 1 && (?begin < ?faldo_begin && ?end < ?faldo_end)
              )
            EOS
          else # :overlap
            <<-EOS
              FILTER(
                ?faldo_begin != 1 &&
                ! ( (?faldo_begin < ?begin && ?faldo_end < ?begin) ||
                    (?end < ?faldo_begin && ?end < ?faldo_end) ) ||
                (?faldo_begin < ?begin && ?end < ?faldo_end )
              )
            EOS
        end
      end

      def make_order(position)
        case position
          when :prev
            'ORDER BY DESC (?faldo_end)'
          when :next
            'ORDER BY ASC (?faldo_begin)'
        end
      end

      def make_limit(position)
        return if position == :overlap
        'limit 1'
      end
    end
  end
end
