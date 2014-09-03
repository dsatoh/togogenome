class TextController < ApplicationController
  def index
  end

  def search(q)
    begin
      @q = q
      @stanzas = TextSearch.search(q)
    rescue StandardError => ex
      @error = ex
    ensure
      render 'index'
    end
  end

  def search_stanza(id, q)
    # XXX id に対応する stanza が見つからなかったら落ちる
    @stanza = TextSearch.search_stanza(id, q)
    @entry_ids = Kaminari.paginate_array(@stanza[:entry_ids]).page(params[:page]).per(10)
  end
end
