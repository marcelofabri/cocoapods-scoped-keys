class String
  def cp_camelcase
    self[0].downcase + self[1..-1]
  end
end
