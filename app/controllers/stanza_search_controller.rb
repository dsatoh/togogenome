class StanzaSearchController < ApplicationController
  def index(q)
    @stanzas = StanzaSearch.search(q)
  rescue => ex
    @error = ex
  end

  def show(q, stanza_id)
    result = StanzaSearch.search_by_stanza_id(q, stanza_id)

    stanzas = result['urls'].map {|url|
      {
        togogenome_url: url,
        stanza_id:      result[:stanza_id],
        report_type:    result[:report_type],
        stanza_attr_id: url.split('/').last
      }
    }

    @stanzas = Kaminari.paginate_array(stanzas).page(params[:page]).per(StanzaSearch::PAGINATE[:per_page])
  end
end
