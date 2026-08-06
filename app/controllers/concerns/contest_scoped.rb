module ContestScoped
  extend ActiveSupport::Concern

  included do
    helper_method :contest
  end

  private
    # Há uma única Competição, e toda tela precisa saber em que ponto dela estamos.
    def contest
      @contest ||= Contest.current
    end
end
